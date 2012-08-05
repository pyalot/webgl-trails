varying vec3 vPosition;

vertex:
    attribute vec3 position;
    uniform mat4 proj;
    uniform mat3 rot;
    void main(){
        vPosition = normalize(position);
        gl_Position = proj * vec4(rot * position, 1.0);
    }

fragment:

    //#1e5799 0%
    //#2989d8 50%
    //#207cca 51%
    //#7db9e8 100%

    float pi = 3.141592653589793;
    vec4 c1 = vec4(0.11764705882352941,0.3411764705882353,0.6, 1.0); //0
    vec4 c2 = vec4(0.1607843137254902,0.5372549019607843,0.8470588235294118, 1.0); //0.5
    vec4 c3 = vec4(0.12549019607843137,0.48627450980392156,0.792156862745098, 1.0); //0.51
    vec4 c4 = vec4(0.49019607843137253,0.7254901960784313,0.9098039215686274, 1.0); //1.0

    void main(){
        vec3 position = normalize(vPosition);
        float f = 1.0-acos(position.y)/pi;

        if(f < 0.5){
            gl_FragColor = mix(c1, c2, f/0.5);
        }
        else if(f >= 0.5 && f < 0.51){
            gl_FragColor = mix(c2, c3, (f-0.5)/0.01);
        }
        else{
            gl_FragColor = mix(c3, c4, (f-0.51)/0.49);
        }
    }
