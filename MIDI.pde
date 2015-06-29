class MidiEngine {

  private final LX lx;

  public MidiEngine(LX lx) {
		this.lx = lx;
    try {
        APC40.getAPC40(lx).setMode(byte(0x42));
    } catch (java.lang.NullPointerException e) {
		println("Did not find APC40 to setup.");
        return;
    }

    LXMidiInput apcInput = APC40.matchInput(lx);
    if (apcInput != null) {
      println("Setting up APC40.");

			final APC40 apc40 = APC40.getAPC40(lx);

			final LXChannel channel = lx.engine.getChannel(0);

			// create a current pattern Parameter to use in the track selection binding
			final DiscreteParameter currentPattern = new DiscreteParameter("Current Pattern", lx.getPatterns().size());
			channel.addListener(new LXChannel.AbstractListener() {
				public void patternWillChange(LXChannel channel, LXPattern pattern) {
					if (channel.getNextPatternIndex() != currentPattern.getValuei()) {
						currentPattern.setValue(channel.getNextPatternIndex());
					}
				}
				public void patternDidChange(LXChannel channel, LXPattern pattern) {
					if (channel.getActivePatternIndex() != currentPattern.getValuei()) {
						currentPattern.setValue(channel.getActivePatternIndex());
					}
				}
			});
			currentPattern.addListener(new LXParameterListener() {
				void onParameterChanged(LXParameter parameter) {
					if (channel.getNextPatternIndex() != currentPattern.getValuei()) {
						channel.goIndex(currentPattern.getValuei());
					}
				}
			});

			// Binds the track selection section of the apc40 to select patterns 1-8
			int numPatterns = min(8, lx.getPatterns().size());
      int[] channelIndices = new int[numPatterns];
      for (int i = 0; i < numPatterns; i++) {
        channelIndices[i] = i;
      }
			apc40.bindNotes(currentPattern, channelIndices, APC40.TRACK_SELECTION);

			// Binds the volume faders on the bottom of the apc40 to the first
			// parameter of their respective pattern (i.e. fader 3 goes to the first
			// parameter of pattern 3)
			for (int i = 0; i < numPatterns; i++) {
				List<LXParameter> patternParameters = lx.getPatterns().get(i).getParameters();
				if (patternParameters.size() > 0) {
					apc40.bindController(patternParameters.get(0), i, APC40.VOLUME);
				}
			}

			// Binds the knobs on the bottom right of the apc40 to the parameters
			// of whatever pattern is active
      apc40.bindDeviceControlKnobs(lx.engine);
		} else {
			println("Did not find APC40 to setup.");
		}
	}
}
