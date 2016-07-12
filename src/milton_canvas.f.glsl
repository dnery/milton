// Copyright (c) 2015-2016 Sergio Gonzalez. All rights reserved.
// License: https://github.com/serge-rgb/milton#license


flat in ivec3 v_pointa;
flat in ivec3 v_pointb;

// Uniform stroke points

in vec3 u_stroke_points[];
in int  u_num_points;

vec4 blend(vec4 dst, vec4 src)
{
    vec4 result = src + dst*(1.0f-src.a);

    return result;
}

// TODO: this layout qualifier introduces GLSL 150 dependency.
layout(origin_upper_left) in vec4 gl_FragCoord;

#define PRESSURE_RESOLUTION_GL (1<<20)

// x,y  - closest point
// z    - t in [0,1] interpolation value
vec3 closest_point_in_segment_gl(vec2 a, vec2 b,
                                 vec2 ab, float ab_magnitude_squared,
                                 vec2 point)
{
    vec3 result;
    float mag_ab = sqrt(ab_magnitude_squared);
    float d_x = ab.x / mag_ab;
    float d_y = ab.y / mag_ab;
    float ax_x = float(point.x - a.x);
    float ax_y = float(point.y - a.y);
    float disc = d_x * ax_x + d_y * ax_y;
    /* if (disc < 0.0) */
    /* { */
    /*     disc = 0.0; */
    /* } */
    /* else if (disc > mag_ab) */
    /* { */
    /*     disc = mag_ab; */
    /* } */
    result.z = disc / mag_ab;
    result.xy = VEC2(int(a.x + disc * d_x), int(a.y + disc * d_y));
    return result;
}

void main()
{
    vec4 color = u_brush_color;

    vec2 ab = VEC2(v_pointb.xy - v_pointa.xy);
    float ab_magnitude_squared = ab.x*ab.x + ab.y*ab.y;

    vec2 fragment_point = raster_to_canvas_gl(gl_FragCoord.xy);

    if (ab_magnitude_squared > 0)
    {
        // t = point.z
        vec3 stroke_point = closest_point_in_segment_gl(VEC2(v_pointa.xy), VEC2(v_pointb.xy), ab, ab_magnitude_squared, fragment_point);
        float d = distance(stroke_point.xy, fragment_point);
        float t = stroke_point.z;
        float pressure = (1-t)*v_pointa.z + t*v_pointb.z;
        pressure /= float(PRESSURE_RESOLUTION_GL);
        float radius = pressure *  u_radius;
        bool inside = d < radius;;
        if (inside)
        {
            //gl_FragColor = blend(as_vec4(u_background_color), u_brush_color);
            //gl_FragColor = blend(as_vec4(u_background_color), u_brush_color);
            gl_FragColor = u_brush_color;
        }
        else
        {

        }
    }

// TODO: check shader compiler warnings
}

