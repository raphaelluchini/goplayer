package goplayer
{
  import flash.display.Sprite
  import flash.display.StageDisplayState
  import flash.events.KeyboardEvent
  import flash.events.MouseEvent
  import flash.ui.Keyboard

  public class Application extends Sprite
    implements MovieHandler, PlayerFinishingListener
  {
    private const api : StreamioAPI
      = new StreamioAPI(new StandardHTTPFetcher)

    private var dimensions : Dimensions
    private var movieID : String
    private var autoplay : Boolean
    private var loop : Boolean

    private var ready : Boolean = false
    private var movie : Movie = null
    private var player : Player = null

    public function Application
      (dimensions : Dimensions,
       movieID : String,
       autoplay : Boolean,
       loop : Boolean)
    {
      this.dimensions = dimensions
      this.movieID = movieID
      this.autoplay = autoplay
      this.loop = loop
      
      drawBackground()
      
      addEventListener(MouseEvent.CLICK, handleClick)
      addEventListener(MouseEvent.DOUBLE_CLICK, handleDoubleClick)
    }

    private function drawBackground() : void
    {
      graphics.beginFill(0x000000)
      graphics.drawRect(0, 0, dimensions.width, dimensions.height)
      graphics.endFill()
    }

    private function handleClick(event : MouseEvent) : void
    {
      if (ready)
        ready = false, handleStartRequested()
    }

    private function handleStartRequested() : void
    {
      debug("Playing movie.")
      play()
    }

    private function handleDoubleClick(event : MouseEvent) : void
    {
      stage.displayState = fullscreen
        ? StageDisplayState.NORMAL
        : StageDisplayState.FULL_SCREEN
    }

    private function handleKeyDown(event : KeyboardEvent) : void
    {
      if (!player) return

      if (event.keyCode == Keyboard.SPACE)
        player.togglePaused()
      else if (event.keyCode == Keyboard.LEFT)
        player.seekBy(Duration.seconds(-3))
      else if (event.keyCode == Keyboard.RIGHT)
        player.seekBy(Duration.seconds(+3))
      else if (event.keyCode == Keyboard.UP)
        player.changeVolumeBy(+.1)
      else if (event.keyCode == Keyboard.DOWN)
        player.changeVolumeBy(-.1)
    }

    private function get fullscreen() : Boolean
    { return stage.displayState == StageDisplayState.FULL_SCREEN }

    public function start() : void
    {
      stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown)

      debug("Looking up Streamio movie “" + movieID + "”...")

      api.fetchMovie(movieID, this)
    }

    public function handleMovie(movie : Movie) : void
    {
      this.movie = movie

      debug("Movie “" + movie.title + "” found.")

      const bitrates : Array = []

      for each (var stream : RTMPStream in movie.rtmpStreams)
        bitrates.push(stream.bitrate)

      if (bitrates.length == 0)
        debug("No RTMP streams available.")
      else
        debug("Available RTMP streams: " + bitrates.join(", "))

      const kit : PlayerKit = new PlayerKit(movie)

      player = kit.player
      player.addFinishingListener(this)

      kit.view.dimensions = dimensions

      addChild(kit.view)

      if (autoplay)
        play()
      else
        ready = true, debug("Click movie to start playback.")
    }

    private function play() : void
    {
      player.start()
      doubleClickEnabled = true
    }

    public function handleMovieFinishedPlaying() : void
    {
      if (loop)
        debug("Looping."), player.rewind()
    }
  }
}
