// Brief Kitty-like beam trail. No lightning, warping, or background effects.
// Keep the terminal's native alpha and the actual cursor/text untouched.
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 terminal = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = terminal;
    float elapsed = iTime - iTimeCursorChange;
    const float duration = 0.18;
    if (elapsed < 0.0 || elapsed >= duration || iCurrentCursor.w <= 0.0) return;

    vec2 current = iCurrentCursor.xy + vec2(0.9, -iCurrentCursor.w * 0.5);
    vec2 previous = iPreviousCursor.xy + vec2(0.9, -iPreviousCursor.w * 0.5);
    // Normal typing stays crisp; only jumps of two or more cells leave a trail.
    if (distance(current, previous) < max(2.0, iCurrentCursor.z * 2.0)) return;

    float progress = clamp(elapsed / duration, 0.0, 1.0);
    float remaining = 1.0 - progress;
    vec2 tail = mix(previous, current, 1.0 - remaining * remaining * remaining);
    vec2 cursorHalf = vec2(1.1, max(1.0, iCurrentCursor.w * 0.48));
    // Reject pixels outside the small moving trail rectangle before geometry work.
    vec2 lower = min(tail, current) - cursorHalf - vec2(1.0);
    vec2 upper = max(tail, current) + cursorHalf + vec2(1.0);
    if (any(lessThan(fragCoord, lower)) || any(greaterThan(fragCoord, upper))) return;

    vec2 p = (fragCoord - current) / cursorHalf;
    vec2 segment = (tail - current) / cursorHalf;
    float t = clamp(dot(p, segment) / max(dot(segment, segment), 0.0001), 0.0, 1.0);
    float distanceToTrail = length(p - segment * t);
    float coverage = 1.0 - smoothstep(0.72, 1.05, distanceToTrail);
    float opacity = coverage * remaining * remaining * (1.0 - t * 0.75) * 0.24;

    // Never paint over the current cursor cell or its character.
    vec2 cursorMin = vec2(iCurrentCursor.x, iCurrentCursor.y - iCurrentCursor.w);
    vec2 cursorMax = vec2(iCurrentCursor.x + iCurrentCursor.z, iCurrentCursor.y);
    if (all(greaterThanEqual(fragCoord, cursorMin)) && all(lessThanEqual(fragCoord, cursorMax))) return;
    fragColor = vec4(mix(terminal.rgb, iCurrentCursorColor.rgb, opacity), terminal.a);
}
