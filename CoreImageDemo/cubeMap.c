//
//  cubeMap.c
//  coreImageTest
//
//  Created by Colin on 14/11/19.
//  Copyright (c) 2014年 icephone. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

struct CubeMap {
    int length;
    float dimension;
    float *data;
};

/*
 把你想消除的颜色的alpha值设置为0，其他的颜色不变，
 Core Image将会把图像数据上的颜色映射为表中的颜色，以此来达到消除某种颜色的目的。
 我们要消除的“深绿色”并不只是视觉上的一种颜色，而是颜色的范围，最直接的方法是将RGBA转成HSV（Hue色彩，Saturation深浅，Value明暗），
 在HSV的格式下，颜色是围绕圆柱体中轴的角度来表现的，在这种表现方法下，你能把颜色的范围想象成连在一起的扇形，然后直接把该块区域干掉（alpha设为0），
 这就表示我们实际上需要指定颜色区域的范围------围绕圆柱体中轴线的最小角度以及最大角度，此范围内的颜色alpha设为0。
 最后，Cube Map表中的数据必须乘以alpha，所以创建Cube Map的最后一步是把RGB值乘以你刚刚计算出来的alpha值：如果是想要消除的颜色，乘出来就是0，反之则不变。
 
 http://www.color-blindness.com/color-name-hue/
*/

void rgbToHSV(float *rgb, float *hsv) {
    float min, max, delta;
    float r = rgb[0], g = rgb[1], b = rgb[2];
    float *h = hsv, *s = hsv + 1, *v = hsv + 2;
    
    min = fmin(fmin(r, g), b );
    max = fmax(fmax(r, g), b );
    *v = max;
    delta = max - min;
    if( max != 0 )
        *s = delta / max;
    else {
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;
    else if( g == max )
        *h = 2 + ( b - r ) / delta;
    else
        *h = 4 + ( r - g ) / delta;
    *h *= 60;
    if( *h < 0 )
        *h += 360;
}

struct CubeMap createCubeMap(float minHueAngle, float maxHueAngle) {
    const unsigned int size = 64;
    struct CubeMap map;
    map.length = size * size * size * sizeof (float) * 4;
    map.dimension = size;
    float *cubeData = (float *)malloc (map.length);
    float rgb[3], hsv[3], *c = cubeData;
    
    for (int z = 0; z < size; z++){
        rgb[2] = ((double)z)/(size-1); // Blue value
        for (int y = 0; y < size; y++){
            rgb[1] = ((double)y)/(size-1); // Green value
            for (int x = 0; x < size; x ++){
                rgb[0] = ((double)x)/(size-1); // Red value
                rgbToHSV(rgb,hsv);
                // Use the hue value to determine which to make transparent
                // The minimum and maximum hue angle depends on
                // the color you want to remove
                float alpha = (hsv[0] > minHueAngle && hsv[0] < maxHueAngle) ? 0.0f: 1.0f;
                // Calculate premultiplied alpha values for the cube
                c[0] = rgb[0] * alpha;
                c[1] = rgb[1] * alpha;
                c[2] = rgb[2] * alpha;
                c[3] = alpha;
                c += 4; // advance our pointer into memory for the next color value
            }
        }
    }
    map.data = cubeData;
    return map;
}
