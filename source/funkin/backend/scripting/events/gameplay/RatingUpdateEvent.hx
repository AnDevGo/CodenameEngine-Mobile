package funkin.backend.scripting.events.gameplay;

final class RatingUpdateEvent extends CancellableEvent {
	/**
		New combo
	**/
	public var rating:ComboRating;
	/**
		Old combo (may be null)
	**/
	public var oldRating:ComboRating;

}