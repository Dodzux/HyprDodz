#!/usr/bin/env python3
"""G614PH Fn mode: persist the last choice, restore at login, notify on Fn+Esc."""
from pathlib import Path
import fcntl,json,os,subprocess,sys,tempfile,time

CONTROL_PATTERN=bytes.fromhex('855a19002aff00150026ff0075089501810019002aff00150026ff007508953fb100')
MODES=('locked','normal')

def state_path():
    return Path(os.environ.get('XDG_STATE_HOME',str(Path.home()/'.local/state')))/'hypr/fn-mode.json'

def load_state():
    data=json.loads(state_path().read_text())
    if not isinstance(data,dict) or data.get('mode') not in MODES or type(data.get('locked_value')) is not int or data['locked_value'] not in (0,1):
        raise ValueError('Invalid saved Fn mode; refusing to guess')
    return data

def save_state(data):
    path=state_path();path.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=path.parent,mode='w',delete=False) as stream:
        temporary=Path(stream.name)
        try:
            json.dump(data,stream);stream.write('\n');stream.flush();os.fsync(stream.fileno())
            temporary.chmod(0o600);os.replace(temporary,path)
        finally:temporary.unlink(missing_ok=True)

def find_control():
    if Path('/sys/class/dmi/id/board_name').read_text().strip()!='G614PH':
        raise RuntimeError('This Fn-control helper is only verified for G614PH')
    controls=[]
    for node in Path('/sys/class/hidraw').glob('hidraw*'):
        device=node/'device'
        if 'HID_ID=0003:00000B05:000019B6' not in (device/'uevent').read_text().splitlines():continue
        if CONTROL_PATTERN in (device/'report_descriptor').read_bytes():controls.append(Path('/dev')/node.name)
    if len(controls)!=1:raise RuntimeError('Expected exactly one verified ASUS Fn-control interface')
    return controls[0]

def packet(data):
    value=data['locked_value'] if data['mode']=='locked' else 1-data['locked_value']
    return bytes([0x5a,0xd0,0x4e,value])+bytes(60)

def set_hardware(data):
    expected=packet(data);fd=os.open(find_control(),os.O_RDWR|os.O_CLOEXEC)
    try:
        # This is the kernel's exact dedicated Fn command. The firmware does
        # not provide a reliable state getter; check the transfer, not an echo.
        buf=bytearray(expected)
        size=fcntl.ioctl(fd,(3<<30)|(len(buf)<<16)|(ord('H')<<8)|6,buf,True)
        if size!=len(buf):raise RuntimeError('Incomplete Fn-control transfer')
    finally:os.close(fd)

def notify(data,runtime):
    title='Fn locked' if data['mode']=='locked' else 'Fn normal'
    body='F1–F12 use the laptop shortcuts.' if data['mode']=='locked' else 'F1–F12 act as standard function keys.'
    icon=Path(__file__).resolve().parent/'icons'/('fn-'+data['mode']+'.svg')
    args=['notify-send','--app-name=Fn key mode','--expire-time=3000','--icon='+str(icon),'--print-id']
    marker=runtime/'fn-mode.notification'
    try:
        previous=marker.read_text().strip();age=time.time()-marker.stat().st_mtime
        if previous.isdecimal() and 0<=age<2.5:args.append('--replace-id='+previous)
    except OSError:pass
    p=subprocess.run(args+[title,body],capture_output=True,text=True,timeout=4)
    if p.returncode:raise RuntimeError(p.stderr.strip() or 'Fn notification failed')
    if p.stdout.strip().isdecimal():marker.write_text(p.stdout.strip()+'\n')

def run(action):
    if action=='status':print(json.dumps(load_state()));return
    if action not in ('restore','toggle'):raise ValueError('Use restore, toggle, or status')
    runtime=Path(os.environ.get('XDG_RUNTIME_DIR','/run/user/'+str(os.getuid())))
    with (runtime/'fn-mode.lock').open('a') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        previous=load_state();next_state=dict(previous)
        if action=='toggle':
            time.sleep(.08)
            next_state['mode']='normal' if previous['mode']=='locked' else 'locked'
        for attempt in range(4):
            try:set_hardware(next_state);break
            except (OSError,RuntimeError):
                if action!='restore' or attempt==3:raise
                time.sleep(.2*(attempt+1))
        if action=='toggle':
            try:save_state(next_state)
            except BaseException:
                set_hardware(previous);raise
            try:notify(next_state,runtime)
            except (OSError,RuntimeError,subprocess.SubprocessError) as error:
                print('Fn mode saved, but notification failed: '+str(error),file=sys.stderr)
        print(next_state['mode'])

if __name__=='__main__':
    try:run(sys.argv[1] if len(sys.argv)==2 else '')
    except (OSError,RuntimeError,ValueError,subprocess.SubprocessError) as error:
        print('Fn mode: '+str(error),file=sys.stderr);sys.exit(1)
