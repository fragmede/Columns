/**
 * This is a very basic model class that is a 3-D matrix
 * of points. The model contains just one fixture.
 */
static class Model extends LXModel {
  
  public Model() {
    super(new Fixture());
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private static final int MATRIX_SIZE = 4;
    
    private Fixture() {
      // Here's the core loop where we generate the positions
      // of the points in our model
      for (int x = 0; x < 4; ++x) {
        for (int z = 0; z < 4; ++z) {
          for (int i = 0; i < 2; ++i) {
            for (int y = 0; y < 30; ++y) {
              // Add point to the fixture
              // addPoint(new LXPoint(x*FEET, (i * (30 - y) + (1 - i) * y)*FEET/6, -z * FEET - 0.5 * i));
              addPoint(new LXPoint(x*FEET, (i * (30 - y) + (1 - i) * y)*FEET/6, z * FEET + i));
              //not sure if doubled up pixels are in x or z
              // addPoint(new LXPoint(x*FEET+0.5, y*FEET/6, z*FEET));
            }
          }
        }
      }
    }
  }
}

