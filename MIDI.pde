







//class MidiEngine {
//  private final LX lx;
//	private void OnNoteRecieved(LXMidiNoteOn note){
//		int pattern_num = (note.getPitch() - 53) * 8 + note.getChannel();
//		println("Selecting clip " + pattern_num);
//		try { 
//   	  lx.engine.getChannel(0).goPattern(patterns[pattern_num]);
//		} catch (java.lang.ArrayIndexOutOfBoundsException e){
//			println("There aren't that many patterns.");
//		}
//  }
//  public MidiEngine(LX lx) {
//    LXMidiInput apcInput = APC40.matchInput(lx);
//		this.lx = lx;
//    if (apcInput != null) {
//      println("Setting up APC40.");
//      this.lx.engine.midiEngine.addInput(apcInput);
//      this.lx.engine.midiEngine.addListener(new LXAbstractMidiListener() {
//        public void noteOnReceived(LXMidiNoteOn note) {
//					OnNoteRecieved(note);
//				}
//			});
//		} else {
//			println("Did not find APC40 to setup.");
//		}
//	}
//}
