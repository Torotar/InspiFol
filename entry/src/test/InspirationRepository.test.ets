import { describe, it, expect } from '@ohos/hypium';
import { DemoContentRepository } from '../main/ets/services/DemoContentRepository';
import { DemoRecommendationProvider } from '../main/ets/services/RecommendationService';
import { RecommendationSource, RecommendationStatus } from '../main/ets/models/InspirationModels';

export default function inspirationRepositoryTest() {
  describe('DemoContentRepository', () => {
    it('returns stable inspiration content', 0, () => {
      const repository = new DemoContentRepository();
      const pins = repository.getPins();
      expect(pins.length).assertEqual(6);
      expect(pins[0].id).assertEqual('quiet-corner');
      expect(pins[0].title).assertContain('窗边');
    });

    it('returns a prototype profile', 0, () => {
      const profile = new DemoContentRepository().getProfile();
      expect(profile.displayName).assertEqual('pinter');
      expect(profile.handle).assertEqual('torotarne');
      expect(profile.avatarInitial).assertEqual('t');
      expect(profile.followerCount).assertEqual(0);
      expect(profile.followingCount).assertEqual(1);
    });

    it('derives stable demo recommendation chips from pin categories', 0, async () => {
      const result = await new DemoRecommendationProvider(new DemoContentRepository().getPins()).loadRecommendations();
      expect(result.status).assertEqual(RecommendationStatus.Ready);
      expect(result.items.length).assertEqual(7);
      expect(result.items[0].label).assertEqual('为你推荐');
      expect(result.items[0].query).assertEqual('');
      expect(result.items[0].source).assertEqual(RecommendationSource.Demo);
      expect(result.items[1].query).assertEqual('家居灵感');
    });

    it('returns an empty recommendation state when no pins exist', 0, async () => {
      const result = await new DemoRecommendationProvider([]).loadRecommendations();
      expect(result.status).assertEqual(RecommendationStatus.Empty);
      expect(result.items.length).assertEqual(0);
    });
  });
}
