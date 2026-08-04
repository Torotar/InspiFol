import {
  Pin,
  RecommendationChip,
  RecommendationResult,
  RecommendationSource,
  RecommendationStatus
} from '../models/InspirationModels';

export interface RecommendationProvider {
  loadRecommendations(): Promise<RecommendationResult>;
}

export class DemoRecommendationProvider implements RecommendationProvider {
  private readonly pins: Pin[];

  constructor(pins: Pin[]) {
    this.pins = pins;
  }

  async loadRecommendations(): Promise<RecommendationResult> {
    const seen: string[] = [];
    const items: RecommendationChip[] = this.pins.length > 0 ? [{
      id: 'demo-for-you',
      label: '为你推荐',
      query: '',
      source: RecommendationSource.Demo
    }] : [];
    this.pins.forEach((pin: Pin) => {
      if (seen.indexOf(pin.category) >= 0) {
        return;
      }
      seen.push(pin.category);
      items.push({
        id: `demo-${pin.id}`,
        label: pin.category,
        query: pin.category,
        source: RecommendationSource.Demo
      });
    });
    return {
      status: items.length > 0 ? RecommendationStatus.Ready : RecommendationStatus.Empty,
      items,
      message: items.length > 0 ? '推荐内容' : '暂无推荐内容'
    };
  }
}
