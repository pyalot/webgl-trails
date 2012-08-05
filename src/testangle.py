from math import pi, atan2, sin, cos

def ark(angle):
    return (angle/360.0) * 2 * pi

def deg(angle):
    return (angle/(2*pi))*360.0

def dot(x1, y1, x2, y2):
    return x1*x2 + y1*y2


for i in range(0, 400, 10):
    x1 = sin(ark(i))
    y1 = cos(ark(i))
    x2 = sin(ark(i+170))
    y2 = cos(ark(i+170))
    d = x1*y2 - y1*x2

    a = atan2(d, dot(x1, y1, x2, y2))
    print deg(a)
