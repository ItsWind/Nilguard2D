extern vec2 plyScreenPos;
extern float screenScale;
extern float proxCullPercent;
extern float objYDrawLevel;

float maxDistance = 64.0 * screenScale;
float minDistance = 16.0 * screenScale;
float maxAlpha = 0.65;
float minAlpha = 0.15;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 textureColor = Texel(texture, texture_coords);
    vec4 regularColor = textureColor * color;

    if (screen_coords.y > objYDrawLevel) {
        return regularColor;
    }

    float dx = plyScreenPos.x - screen_coords.x;
    float dy = plyScreenPos.y - screen_coords.y;
    float distance = sqrt(dx * dx + dy * dy);

    //a * (1-t) + b * t

    float alphaToUse;

    if (distance < minDistance) {
        alphaToUse = minAlpha;
        //return vec4(regularColor.r, regularColor.g, regularColor.b, regularColor.a * minAlpha);
    } else if (distance > maxDistance) {
        alphaToUse = maxAlpha;
        //return vec4(regularColor.r, regularColor.g, regularColor.b, regularColor.a * maxAlpha);
    } else {
        float distPercent = (distance - minDistance) / (maxDistance - minDistance);
        alphaToUse = minAlpha * (1-distPercent) + maxAlpha * distPercent;
        //return vec4(regularColor.r, regularColor.g, regularColor.b, regularColor.a * alphaToUse);
    }

    alphaToUse = (1 - proxCullPercent) + alphaToUse * proxCullPercent;

    return vec4(regularColor.r, regularColor.g, regularColor.b, regularColor.a * alphaToUse);
}