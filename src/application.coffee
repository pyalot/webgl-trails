schedule = require 'schedule'
loading = require 'loading'
camera = require 'camera'
Cube = require 'webgl/cube'
Sphere = require 'webgl/sphere'
{Texture2D} = require 'webgl/texture'

window.convert = (s) ->
    r = eval('0x' + s.slice(0,2))/255.0
    g = eval('0x' + s.slice(2,4))/255.0
    b = eval('0x' + s.slice(4,6))/255.0
    console.log "vec3(#{r},#{g},#{b})"

$('*').each ->
    $(@)
        .attr('unselectable', 'on')
        .css
           '-moz-user-select':'none',
           '-webkit-user-select':'none',
           'user-select':'none',
           '-ms-user-select':'none'
    @onselectstart = -> false

angle = (x1, y1, z1, x2, y2, z2) ->
    return (Math.acos(x1*x2 + y1*y2 + z1*z2)*360)/(Math.PI*2)

class Trail extends require('webgl/drawable')
    attribs: ['position']

    constructor: (@gl) ->
        super()
        @mode = @gl.TRIANGLE_STRIP
        result = []

        lx = 0
        ly = 0
        lz = 0

        lnx = 1
        lny = 0
        lnz = 0

        d = 0
        bc = [1,0,0]

        for j in [0...10000]
            i = j*0.1
            a = i+3
            b = i+7
            c = i+11

            x = Math.sin(a/5) + Math.sin(a/23) + Math.sin(a/53)
            y = Math.sin(b/7) + Math.sin(b/29) + Math.sin(b/67)
            z = Math.sin(b/11) + Math.sin(b/31) + Math.sin(b/73)

            nx = x-lx; ny=y-ly; nz=z-lz
            l = Math.sqrt(Math.pow(nx, 2) + Math.pow(ny, 2) + Math.pow(nz, 2))
            nx/=l; ny/=l; nz/=l

            if l > 1.5 or angle(nx, ny, nz, lnx, lny, lnz) > 8
                d += l
                result.push(x, y, z,  1, d, bc[0], bc[1], bc[2])
                bc.push(bc.splice(0,1)[0])
                result.push(x, y, z, -1, d, bc[0], bc[1], bc[2])
                bc.push(bc.splice(0,1)[0])

                lnx=nx; lny=ny; lnz=nz
                lx=x; ly=y; lz=z

        @components = 8

        @size = (result.length/@components) - 4
        @uploadList result

    setPointersForShader: (shader) ->
        @gl.bindBuffer @gl.ARRAY_BUFFER, @buffer
        @setPointer shader, 'last'          , 4,  0, @components
        @setPointer shader, 'current'       , 4, @components*2, @components
        @setPointer shader, 'texoff'        , 1, @components*2+4, @components
        @setPointer shader, 'barycentric'   , 3, @components*2+5, @components
        @setPointer shader, 'next'          , 4, @components*4, @components

        return @

exports.Application = class
    constructor: (@canvas) ->
        loading.hide()
        @camera = new camera.Orbit(near: 0.001, far: 100, dist:5)
        @sky = get 'sky.shader'
        @textured = get 'textured.shader'
        @wireframe = get 'wireframe.shader'
        @texture = new Texture2D(gl)
            .bind().upload(get 'smoke.png').mipmap().repeat()

        @display = @textured

        @sphere = new Sphere gl
        @geom = new Trail gl

        $(window).resize @resize
        @resize()
        schedule.run @update
        gl.enable gl.CULL_FACE
        @canvas.fadeIn(2000)
        
        container = $('<div></div>')
            .css('margin', 10)
            .appendTo('#ui')
       
        $('<span>Wireframe</span>')
            .appendTo(container)
        input = $('<input type="checkbox">')
            .appendTo(container)
            .change =>
                if input[0].checked
                    @display = @wireframe
                else
                    @display = @textured

    resize: =>
        @width = @canvas.width()
        @height = @canvas.height()

        @canvas[0].width = @width
        @canvas[0].height = @height
        gl.viewport 0, 0, @width, @height
        @camera.aspect @width, @height

    update: =>
        @step()
        @draw()
        
    step: ->
        @camera.update()

    draw: ->
        gl.cullFace gl.FRONT
        gl.disable gl.DEPTH_TEST
        gl.disable gl.SAMPLE_ALPHA_TO_COVERAGE
        gl.disable gl.BLEND

        gl.depthMask false
        @sky.use()
            .mat4('proj', @camera.proj)
            .mat3('rot', @camera.rot)
            .draw(@sphere)

        gl.cullFace gl.BACK
        gl.enable gl.DEPTH_TEST
        gl.depthMask true
        gl.enable gl.SAMPLE_ALPHA_TO_COVERAGE
        gl.enable gl.BLEND
        gl.blendFunc gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA

        @texture.bind(0)

        @display.use()
            .i('smoke', 0)
            .f('width', 0.13)
            .val2('viewport', @width, @height)
            .mat4('proj', @camera.proj)
            .mat4('view', @camera.view)
            .draw(@geom)
