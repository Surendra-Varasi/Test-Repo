trigger createOfferings on Account (after insert) {
	triggerHandler.createOfferingsTrigger(Trigger.new);
}