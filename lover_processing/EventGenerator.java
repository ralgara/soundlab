class EventGenerator {
  static Generator noteGenerator = new Generator(20,100);
  static Generator velocityGenerator = new Generator(10,127);
  
  static Stream<Event> getEventStream() {
    Stream.generate(() -> {
      int note = noteGenerator.getNextValue();
      int velocity = velocityGenerator.getNextValue();
      return new Event(note, velocity);
    }.flatMap(event -> {
      Event up = event
      Stream.concat(Stream.of(event), Stream.o
  }
  
  static Stream<Event> getEventStream() {
    
}
