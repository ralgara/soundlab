class Event {
  public long timestamp;
  public byte note;
  public byte velocity;
  
  Event(note, velocity) {
    timestamp = Time.getCurrentTimestamp();
    this.note = note;
    this.velocity = velocity;
  }
  
  Event(Event event) {
    return new Event(event.note, event.velocity);
  }
}
