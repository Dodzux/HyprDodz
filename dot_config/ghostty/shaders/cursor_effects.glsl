// Combined cursor effects: lightning followed by warp, one texture pass.
// Cursor lightning trail for Ghostty.
// Draws a brief, jagged bolt from the previous cursor position to the current one.

// -- CONFIGURATION --
#define BOLT_COLOR iCurrentCursorColor.rgb
#define GLOW_COLOR (iCurrentCursorColor.rgb * 0.85)
const float LIGHTNING_DURATION = 0.14;              // lifetime of each zap, in seconds
const float THRESHOLD_MIN_DISTANCE = 1.5; // cursor widths before a zap is drawn
const float JAGGEDNESS = 0.085;           // sideways displacement relative to bolt length
const float CORE_WIDTH = 1.15;            // pixels
const float GLOW_WIDTH = 5.5;             // pixels
const int BOLT_SEGMENTS = 12;

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float segmentDistance(vec2 p, vec2 a, vec2 b) {
    vec2 ab = b - a;
    float denom = max(dot(ab, ab), 0.0000001);
    float t = clamp(dot(p - a, ab) / denom, 0.0, 1.0);
    return length(p - (a + ab * t));
}

// A point on a piecewise-linear bolt. Endpoints stay fixed while interior
// nodes are displaced perpendicular to the cursor's direction of travel.
vec2 boltPoint(vec2 a, vec2 b, float t, float seed) {
    vec2 delta = b - a;
    float boltLength = length(delta);
    vec2 perpendicular = vec2(-delta.y, delta.x) / max(boltLength, 0.00001);
    float node = floor(t * float(BOLT_SEGMENTS) + 0.5);
    float randomOffset = hash11(node * 17.17 + seed) * 2.0 - 1.0;
    float endpointFade = sin(3.14159265 * t);
    return mix(a, b, t)
        + perpendicular * randomOffset * boltLength * JAGGEDNESS * endpointFade;
}

float mainBoltDistance(vec2 p, vec2 a, vec2 b, float seed) {
    float distanceToBolt = 100000.0;
    vec2 previous = a;

    for (int i = 1; i <= BOLT_SEGMENTS; ++i) {
        float t = float(i) / float(BOLT_SEGMENTS);
        vec2 current = boltPoint(a, b, t, seed);
        distanceToBolt = min(distanceToBolt, segmentDistance(p, previous, current));
        previous = current;
    }

    return distanceToBolt;
}

// Three small forks growing out of alternating points on the main bolt.
float forkDistance(vec2 p, vec2 a, vec2 b, float seed) {
    float distanceToFork = 100000.0;
    vec2 delta = b - a;
    float boltLength = length(delta);
    vec2 perpendicular = vec2(-delta.y, delta.x) / max(boltLength, 0.00001);

    for (int i = 0; i < 3; ++i) {
        float fi = float(i);
        float t = 0.28 + fi * 0.22;
        vec2 root = boltPoint(a, b, t, seed);
        float side = hash11(seed + fi * 41.0) < 0.5 ? -1.0 : 1.0;
        float reach = boltLength * (0.055 + 0.035 * hash11(seed + fi * 53.0));
        vec2 along = normalize(delta) * reach * (hash11(seed + fi * 67.0) - 0.35);
        vec2 tip = root + perpendicular * side * reach + along;
        vec2 elbow = mix(root, tip, 0.52)
            - perpendicular * side * reach * (0.12 + 0.18 * hash11(seed + fi * 79.0));
        distanceToFork = min(distanceToFork, segmentDistance(p, root, elbow));
        distanceToFork = min(distanceToFork, segmentDistance(p, elbow, tip));
    }

    return distanceToFork;
}

vec4 applyCursorLightning(vec4 terminal, vec2 fragCoord) {
    vec4 fragColor = terminal;
    if (iTime - iTimeCursorChange >= LIGHTNING_DURATION) return terminal; // Expired: texture pass-through.

    vec2 currentCenter = iCurrentCursor.xy
        + vec2(iCurrentCursor.z * 0.5, -iCurrentCursor.w * 0.5);
    vec2 previousCenter = iPreviousCursor.xy
        + vec2(iPreviousCursor.z * 0.5, -iPreviousCursor.w * 0.5);
    float travel = length(currentCenter - previousCenter);
    float minimumTravel = iCurrentCursor.z * THRESHOLD_MIN_DISTANCE;

    float age = clamp((iTime - iTimeCursorChange) / LIGHTNING_DURATION, 0.0, 1.0);
    if (travel > minimumTravel && age < 1.0) {
        // All bolt/fork geometry fits inside this expanded segment box.
        // Whole four-pixel blocks keep neighboring derivative lanes together.
        float padding = travel * 0.22 + GLOW_WIDTH * 4.0 + CORE_WIDTH + 4.0;
        vec2 lower = floor((min(previousCenter, currentCenter) - vec2(padding)) / 4.0) * 4.0;
        vec2 upper = ceil((max(previousCenter, currentCenter) + vec2(padding)) / 4.0) * 4.0;
        vec2 block = floor(fragCoord / 4.0) * 4.0;
        if (any(lessThan(block, lower)) || any(greaterThanEqual(block, upper))) return terminal;
        // Quantizing the event time gives each cursor jump a stable bolt shape.
        float seed = floor(iTimeCursorChange * 1000.0) * 0.013;
        float mainDistance = mainBoltDistance(fragCoord, previousCenter, currentCenter, seed);
        float branches = forkDistance(fragCoord, previousCenter, currentCenter, seed);

        float pixel = max(fwidth(mainDistance), 0.65);
        float core = 1.0 - smoothstep(CORE_WIDTH, CORE_WIDTH + pixel, mainDistance);
        float forkCore = 1.0 - smoothstep(CORE_WIDTH * 0.72,
                                          CORE_WIDTH * 0.72 + pixel, branches);
        float glow = exp(-mainDistance * mainDistance / (GLOW_WIDTH * GLOW_WIDTH));
        float forkGlow = exp(-branches * branches / (GLOW_WIDTH * GLOW_WIDTH * 0.55));

        // Lightning flashes hard, then rapidly loses its core and leaves a glow.
        float flash = 1.0 - smoothstep(0.0, 1.0, age);
        flash *= flash;
        float flicker = 0.82 + 0.18 * sin(age * 95.0 + seed);
        float glowAmount = max(glow, forkGlow * 0.55) * flash * flicker * 0.72;
        float coreAmount = max(core, forkCore * 0.82) * flash * flicker;

        vec3 color = mix(fragColor.rgb, GLOW_COLOR, clamp(glowAmount, 0.0, 1.0));
        color = mix(color, BOLT_COLOR, clamp(coreAmount, 0.0, 1.0));
        fragColor = vec4(color, terminal.a);

        // Keep Ghostty's actual cursor crisp above the effect.
        vec2 cursorMin = vec2(iCurrentCursor.x, iCurrentCursor.y - iCurrentCursor.w);
        vec2 cursorMax = vec2(iCurrentCursor.x + iCurrentCursor.z, iCurrentCursor.y);
        float insideCursor = step(cursorMin.x, fragCoord.x)
            * step(cursorMin.y, fragCoord.y)
            * step(fragCoord.x, cursorMax.x)
            * step(fragCoord.y, cursorMax.y);
        fragColor = mix(fragColor, terminal, insideCursor);
    }
    return fragColor;
}


// Based on https://gist.github.com/chardskarth/95874c54e29da6b5a36ab7b50ae2d088
float ease(float x) {
    return pow(1.0 - x, 10.0);
}

float sdBox(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}
// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float blend(float t)
{
    float sqr = t * t;
    return sqr / (2.0 * (sqr - t) + 1.0);
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    // Conditions using step
    float condition1 = step(b.x, a.x) * step(a.y, b.y); // a.x < b.x && a.y > b.y
    float condition2 = step(a.x, b.x) * step(b.y, a.y); // a.x > b.x && a.y < b.y

    // If neither condition is met, return 1 (else case)
    return 1.0 - max(condition1, condition2);
}
vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

#define TRAIL_COLOR vec4(iCurrentCursorColor.rgb, 0.60)
const vec4 CURRENT_CURSOR_COLOR = vec4(1.0, 1.0, 1.0, 1.0);
const vec4 PREVIOUS_CURSOR_COLOR = vec4(1.0, 1.0, 1.0, 1.0);
#define TRAIL_COLOR_ACCENT vec4(iCurrentCursorColor.rgb, 0.90)
const float WARP_DURATION = .4;
const float OPACITY = .6;
// Don't draw trail within that distance * cursor size.
// This prevents trails from appearing when typing.
const float DRAW_THRESHOLD = 1.5;
// Don't draw trails within the same line: same line jumps are usually where
// people expect them.
const bool HIDE_TRAILS_ON_THE_SAME_LINE = false;

vec4 applyCursorWarp(vec4 terminal, vec2 fragCoord)
{
    vec4 fragColor = terminal;
    if (iTime - iTimeCursorChange >= WARP_DURATION) return terminal; // Idle: no trail calculations.
    // Reject small/no cursor moves before doing screen-wide geometry work.
    vec2 currentCenterPixels = getRectangleCenter(iCurrentCursor);
    vec2 previousCenterPixels = getRectangleCenter(iPreviousCursor);
    float cursorSizePixels = max(iCurrentCursor.z, iCurrentCursor.w);
    if (distance(currentCenterPixels, previousCenterPixels) <= DRAW_THRESHOLD * cursorSizePixels) return terminal;
    if (HIDE_TRAILS_ON_THE_SAME_LINE && iCurrentCursor.y == iPreviousCursor.y) return terminal;
    float sourceAlpha = fragColor.a;
    //Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    //Normalization for cursor position and size;
    //cursor xy has the postion in a space of -1 to 1;
    //zw has the width and height
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    //When drawing a parellelogram between cursors for the trail i need to determine where to start at the top-left or top-right vertex of the cursor
    float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invertedVertexFactor = 1.0 - vertexFactor;

    //Set every vertex of my parellogram
    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor, previousCursor.y);
    vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);

    vec4 newColor = vec4(fragColor);

    float progress = blend(clamp((iTime - iTimeCursorChange) / WARP_DURATION, 0.0, 1));
    float easedProgress = ease(progress);

    //Distance between cursors determine the total length of the parallelogram;
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float cursorSize = max(currentCursor.z, currentCursor.w);
    float trailThreshold = DRAW_THRESHOLD * cursorSize;
    float lineLength = distance(centerCC, centerCP);
    //
    bool isFarEnough = lineLength > trailThreshold;
    bool isOnSeparateLine = HIDE_TRAILS_ON_THE_SAME_LINE ? currentCursor.y != previousCursor.y : true;
    if (isFarEnough && isOnSeparateLine) {
        float distanceToEnd = distance(vu.xy, centerCC);
        float alphaModifier = distanceToEnd / max(lineLength * easedProgress, 0.000001);

        if (alphaModifier > 1.0) { // this change fixed it for me.
            alphaModifier = 1.0;
        }

        // At full fade, the original mix is exactly the unmodified texture.
        if (alphaModifier >= 1.0) return terminal;

        float sdfCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
        float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

        newColor = mix(newColor, TRAIL_COLOR_ACCENT, 1.0 - smoothstep(sdfTrail, -0.01, 0.001));
        newColor = mix(newColor, TRAIL_COLOR, antialising(sdfTrail));
        newColor = mix(fragColor, newColor, (1.0 - alphaModifier) * TRAIL_COLOR.a);
        fragColor = mix(newColor, fragColor, step(sdfCursor, 0));
        fragColor.a = sourceAlpha; // Preserve native transparency for compositor blur.
    }
    return fragColor;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 terminal = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = applyCursorWarp(applyCursorLightning(terminal, fragCoord), fragCoord);
}
