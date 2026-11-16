# julia-mandelbrot

A real-time Mandelbrot set explorer written in Julia, rendered with SDL2.
Multithreaded rendering, a periodic color palette, and mouse-targeted zoom
where the iteration count scales with the zoom level.

## Demo

[![Watch the demo](https://img.youtube.com/vi/4Im9F8wjDCk/maxresdefault.jpg)](https://www.youtube.com/watch?v=4Im9F8wjDCk)

## Run

```bash
julia --project -e 'using Pkg; Pkg.instantiate()'
julia --project -t auto mandelbrot.jl
```

## Controls

| Key | Action |
| --- | --- |
| `W` | Zoom in towards the mouse cursor |
| `S` | Zoom out |
| `Esc` | Quit |

## Gallery

![Full set](gallery/Screenshot_20261116_140047.png)

![Seahorse valley](gallery/Screenshot_20261116_140441.png)

![Spike detail](gallery/Screenshot_20261116_140345.png)

![Deep zoom](gallery/Screenshot_20261116_140402.png)

![Filament](gallery/Screenshot_20261116_140322.png)

### Early images

The first versions wrote PPM files instead of drawing to a window, and the
palette was a simple blue gradient.

![First test render](gallery/test.png)

![Low resolution attempt](gallery/Screenshot_20261114_232223.png)

![First full PPM render](gallery/mandelbrot.png)

![Early zoom](gallery/zoom1.png)

![Early zoom](gallery/zoom2.png)
