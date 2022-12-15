import sdl2
import nglib

when defined(emscripten):
  proc emscripten_set_main_loop(f: proc() {.cdecl.}, a: cint, b: bool) {.importc.}

var
  gClose = false
  w: WindowPtr

proc tick() {.cdecl.} =
  var e: Event
  while sdl2.pollEvent(e):
    case e.kind:
    of QuitEvent: gClose = true
    else: discard

    discard igSdl2ProcessEvent(e)

  # render scene
  igOpenGL3NewFrame()
  igSdl2NewFrame()
  igNewFrame()

  igShowDemoWindow()

  glClearColor(0.5f, 0.5f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)

  igRender()
  igOpenGL3RenderDrawData(igGetDrawData())

  glSwapWindow(w)

proc main() =
  # addHandler newConsoleLogger(levelThreshold=lvlAll)
  # info "Init SDL2"
  # defer: info "Bye SDL2"

  sdl2.init(INIT_EVERYTHING)
  defer: sdl2.quit()

  # info "Init OpenGL"
  when defined(emscripten):
    discard glSetAttribute(SDL_GL_CONTEXT_FLAGS, 0)
    discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES)
    discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2)
    discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0)
  else:
    discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
    discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
    discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3)
    discard glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)
    discard glSetAttribute(SDL_GL_DEPTH_SIZE, 24)
    discard glSetAttribute(SDL_GL_STENCIL_SIZE, 8)

  # info "Create window"
  w = createWindow("NGLib: Sample", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640'i32, 480'i32, SDL_WINDOW_ALLOW_HIGHDPI or SDL_WINDOW_OPENGL or SDL_WINDOW_SHOWN or SDL_WINDOW_RESIZABLE)
  defer: w.destroyWindow()

  # info "Create OpenGL context"
  var glContext = glCreateContext(w)
  discard glMakeCurrent(w, glContext)
  discard glSetSwapInterval(1)

  discard glInit()
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  var igContext = igCreateContext()
  defer: igDestroyContext(igContext)

  discard igSdl2InitForOpenGL(w)
  when defined(emscripten):
    discard igOpenGL3Init(100)
  else:
    discard igOpenGL3Init()
  defer: igOpenGL3Shutdown()
  defer: igSdl2Shutdown()

  igStyleColorsDark()

  var wi, he: cint
  glGetDrawableSize(w, wi, he)
  glViewport(0.GLint, 0.GLint, wi.GLsizei, he.GLsizei)

  when defined(emscripten):
    emscripten_set_main_loop(tick, 0, true)
  else:
    while not gClose:
      tick()

main()
