import { Pin } from '../models/InspirationModels';
import { PinArtwork } from './PinArtwork';

@Component
export struct PinCard {
  @Prop pin: Pin = {} as Pin;
  onOpen?: (pin: Pin) => void;
  onShare?: (pin: Pin) => void;

  build() {
    Column({ space: 8 }) {
      PinArtwork({ pin: this.pin, compact: true })
      Row({ space: 4 }) {
        if (this.pin.title.trim().length > 0) {
          Text(this.pin.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#202124')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        } else {
          Blank()
        }
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.lucide_ellipsis'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.onShare !== undefined) {
            this.onShare(this.pin);
          }
        })
        .accessibilityText('分享')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      if (this.onOpen !== undefined) {
        this.onOpen(this.pin);
      }
    })
    .accessibilityText(this.pin.title.trim().length > 0 ? this.pin.title : '打开灵感内容')
  }
}
