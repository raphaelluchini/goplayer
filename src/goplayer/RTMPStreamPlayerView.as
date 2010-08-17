package goplayer
{
  import flash.display.Sprite
  import flash.geom.Rectangle
  import flash.media.Video
  import flash.net.NetStream

  public class RTMPStreamPlayerView extends Sprite
    implements RTMPStreamPlayerListener
  {
    private var player : RTMPStreamPlayer
    private var video : Video

    private var statusbar : RTMPStreamStatusbar

    public function RTMPStreamPlayerView
      (player : RTMPStreamPlayer, video : Video)
    {
      this.player = player
      this.video = video

      player.addListener(this)

      statusbar = new RTMPStreamStatusbar(player)

      addChild(video)
      addChild(statusbar)

      mouseEnabled = false
      mouseChildren = false

      update()
    }

    public function handleRTMPStreamCreated() : void
    {}

    public function handleRTMPStreamUpdated() : void
    { update() }

    public function handleRTMPStreamFinishedPlaying() : void
    {}

    private function update() : void
    {
      video.width = player.dimensions.width
      video.height = player.dimensions.height
      video.visible = player.playheadPosition.seconds > 0.1

      statusbar.update()

      statusbar.x = video.width - statusbar.width
      statusbar.y = video.height - statusbar.height

      if (stage)
        stage.fullScreenSourceRect
          = new Rectangle(0, 0, video.width, video.height)
    }
  }
}
