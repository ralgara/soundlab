import java.util.Random;
import static java.lang.System.out;

// Bounded brownian generator
class Generator {
  int min, max;
  int value;
  Random random = new Random();
  
  Generator(int min, int max) {
    this.min = min;
    this.max = max;
    this.value = (max - min)/2;
  }
  
  int getNextValue() {
    int RANGE = 10;
    int sign = random.nextFloat() > 0.5 ? 1 : -1;
    int skip = random.nextInt(RANGE) * sign;
    int nextValue = value + skip;
    if (nextValue > this.max || nextValue < this.min) {
      System.out.println("overflow, nv: " + nextValue + ", skip: " + skip);
      nextValue -= skip;
      System.out.println("nv: " + nextValue);
    }
    value = nextValue;
    return value;
  }
}
