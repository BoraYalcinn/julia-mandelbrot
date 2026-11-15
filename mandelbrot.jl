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

function color_label(n::Int,max_iterations::Int)
    if n == max_iterations
        return (0,0,0)
    end
    t = n / max_iterations

    r = round(Int, 255 * 9 * (1 - t) * t^3)
    g = round(Int, 255 * 15 * (1 - t)^2 * t^2)
    b = round(Int, 255 * 8.5 * (1 - t)^3 * t)

    return (r, g, b)
end

function generate_mandelbrot_buffer(Xmin, Ymin, Xmax, Ymax, width, height, max_iterations)
    frame_buffer = zeros(Int, height, width)
    for i in 1:width
        x = Xmin + (Xmax - Xmin) * (i - 1) / (width - 1)
        for j in 1:height
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
                r, g, b = color_label(frame_buffer[j, i], max_iterations)
                println(io, r, " ", g, " ", b)
            end
        end
    end
end
