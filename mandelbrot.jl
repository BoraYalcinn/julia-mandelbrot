using SimpleDirectMediaLayer.LibSDL2

function mandelbrot(c::Complex, max_iterations::Int)
    z = 0.0 + 0.0im
    for i in 1:max_iterations
        z = z^2 + c
        if abs2(z) > 4.0
            return i
        end
    end
    return max_iterations
end

function color_label(n::Int,max_iterations::Int,P::Int=32)
    if n == max_iterations
        return (0,0,0)
    end
    t = mod(n,P) / P

    r = round(Int, 255 * (0.5 + 0.5 *cos(2*π*t)))
    g = round(Int, 255 * (0.5 + 0.5 *cos(2*π*(t+0.33))))
    b = round(Int, 255 * (0.5 + 0.5 *cos(2*π*(t+0.67))))

    return (r, g, b)
end

function generate_mandelbrot_buffer(Xmin, Ymin, Xmax, Ymax, width, height, max_iterations)
    frame_buffer = zeros(Int, height, width)
    Threads.@threads for i in 1:width
        x = Xmin + (Xmax - Xmin) * (i - 1) / (width - 1)
        Threads.@threads for j in 1:height
            y = Ymax - (Ymax - Ymin) * (j - 1) / (height - 1)
            frame_buffer[j, i] = mandelbrot(Complex(x, y), max_iterations)
        end
    end

    return frame_buffer
end

function write_ppm(file_name,frame_buffer,max_iterations)
    height, width = size(frame_buffer)
    open(file_name, "w") do io
        println(io, "P3")
        println(io, width, " ", height)
        println(io, 255)

        for j in 1:height
            for i in 1:width
                r, g, b = color_label(frame_buffer[j, i], max_iterations,32)
                println(io, r, " ", g, " ", b)
            end
        end
    end
end

function buffer_to_pixel(frame_buffer,max_iterations)
    height, width = size(frame_buffer)
    pixels = Vector{UInt32}(undef, width * height)
    for i in 1:width
        for j in 1:height
            r, g, b = color_label(frame_buffer[j, i], max_iterations,32)
            pixels[(j - 1) * width + i] = 0xFF000000 | (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)
        end
    end
    return pixels
end

function zoom_mandelbrot(gaze_x, gaze_y, zoom, aspect)
    w = 3.0 / zoom
    h = w / aspect
    return (gaze_x - w/2, gaze_y - h/2, gaze_x + w/2, gaze_y + h/2)
end

function zoom_towards_mouse(gaze_x, gaze_y, zoom, mouse_x, mouse_y, factor, width, height)
    w = 3.0 / zoom
    h = w / (width / height)
    px = gaze_x - w/2 + w * mouse_x / (width - 1)
    py = gaze_y + h/2 - h * mouse_y / (height - 1)
    new_gaze_x = px + (gaze_x - px) / factor
    new_gaze_y = py + (gaze_y - py) / factor
    return (new_gaze_x, new_gaze_y, zoom * factor)
end

function main()
    if SDL_Init(SDL_INIT_VIDEO) != 0
        error("SDL initialization failed: $(unsafe_string(SDL_GetError()))")
    end
    println(Threads.nthreads())
    width, height = 900,600
    buffer = generate_mandelbrot_buffer(-2.0, -1.0, 1.0, 1.0, width, height, 100)
    pixels = buffer_to_pixel(buffer, 100)
    window = SDL_CreateWindow("Mandelbrot",SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,width,height,SDL_WINDOW_SHOWN)
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED)
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, width, height)
    try
        running = true
        zoom_action = false
        event_ref = Ref{SDL_Event}()
        gaze_x,gaze_y,zoom = -0.5,0.0,1.0
        zoom_action = true
        mouse_x = Ref{Cint}(0)
        mouse_y = Ref{Cint}(0)
        while running
            while Bool(SDL_PollEvent(event_ref))
                evt = event_ref[]
                if evt.type == SDL_QUIT
                    running = false
                end
            end

            SDL_GetMouseState(mouse_x, mouse_y)
            keys = SDL_GetKeyboardState(C_NULL)
            if unsafe_load(keys, Int(SDL_SCANCODE_ESCAPE) + 1) != 0
                running = false
            end
            if unsafe_load(keys, Int(SDL_SCANCODE_W) + 1) != 0
                gaze_x, gaze_y, zoom = zoom_towards_mouse(gaze_x, gaze_y, zoom, mouse_x[], mouse_y[], 1.05, width, height)
                zoom_action = true
            end
            if unsafe_load(keys, Int(SDL_SCANCODE_S) + 1) != 0
                gaze_x, gaze_y, zoom = zoom_towards_mouse(gaze_x, gaze_y, zoom, mouse_x[], mouse_y[], 1 / 1.05, width, height)
                zoom_action = true
            end

            if zoom_action == true
                xmin, ymin, xmax, ymax = zoom_mandelbrot(gaze_x, gaze_y, zoom, width / height)
                buffer = generate_mandelbrot_buffer(xmin, ymin, xmax, ymax, width, height, 100)
                pixels = buffer_to_pixel(buffer, 100)
                SDL_UpdateTexture(texture, C_NULL, pixels, width * 4)
                zoom_action = false
            end

            SDL_RenderClear(renderer)
            SDL_RenderCopy(renderer, texture, C_NULL, C_NULL)
            SDL_RenderPresent(renderer)
        end
    finally
        SDL_DestroyRenderer(renderer)
        SDL_DestroyTexture(texture)
        SDL_DestroyWindow(window)
        SDL_Quit()
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
