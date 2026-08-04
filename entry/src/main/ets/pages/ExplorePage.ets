import { Pin } from '../models/InspirationModels';
import { PinFlow } from '../components/PinFlow';

@Component
export struct ExplorePage {
  @Prop pins: Pin[] = [];
  @Prop searchText: string = '';
  onSearchChange?: (value: string) => void;
  onOpenPin?: (pin: Pin) => void;
  onSharePin?: (pin: Pin) => void;

  build() {
    Column({ space: 12 }) {
      Row() {
        TextInput({ text: this.searchText, placeholder: '搜索家居、摄影、版式...' })
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#F1F3F4')
          .borderRadius(14)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            if (this.onSearchChange !== undefined) {
              this.onSearchChange(value);
            }
          })
          .accessibilityText('搜索灵感')
      }
        .width('100%')
        .constraintSize({ maxWidth: 720 })
        .padding({ left: 20, right: 20 })
      PinFlow({ pins: this.pins, onOpen: this.onOpenPin, onShare: this.onSharePin })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 56 })
    .alignItems(HorizontalAlign.Center)
  }
}
