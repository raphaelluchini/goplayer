package goplayer
{
  public interface PlayerListener
  { 
    function handleMovieFinishedPlaying() : void
    function handleCurrentTimeChanged() : void
  }
}
