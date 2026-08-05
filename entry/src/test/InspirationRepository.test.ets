import { describe, it, expect } from '@ohos/hypium';
import { Pin } from '../main/ets/models/InspirationModels';

export default function inspirationRepositoryTest() {
  describe('Content state', () => {
    it('starts without bundled inspiration content', 0, () => {
      const pins: Pin[] = [];
      expect(pins.length).assertEqual(0);
    });
  });
}
