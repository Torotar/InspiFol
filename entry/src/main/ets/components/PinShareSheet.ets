import { Pin } from '../models/InspirationModels';

interface ShareTarget {
  id: string;
  label: string;
  iconAsset: string;
  icon: string;
  backgroundColor: string;
  iconColor: string;
  outlined: boolean;
}

@Component
export struct PinShareSheet {
  @Prop pin: Pin = {} as Pin;
  onAction?: (action: string) => void;

  private readonly targets: ShareTarget[] = [
    { id: 'send', label: '发送', iconAsset: 'app.media.lucide_send', icon: '', backgroundColor: '#E60023', iconColor: '#FFFFFF', outlined: false },
    { id: 'facebook', label: 'Facebook', iconAsset: 'app.media.share_facebook', icon: '', backgroundColor: '#FFFFFF', iconColor: '#1877F2', outlined: true },
    { id: 'instagram', label: 'Instagram', iconAsset: 'app.media.share_instagram', icon: '', backgroundColor: '#FFFFFF', iconColor: '#E4405F', outlined: true },
    { id: 'x', label: 'X', iconAsset: 'app.media.share_x', icon: '', backgroundColor: '#FFFFFF', iconColor: '#000000', outlined: true },
    { id: 'telegram', label: 'Telegram', iconAsset: 'app.media.share_telegram', icon: '', backgroundColor: '#FFFFFF', iconColor: '#26A5E4', outlined: true },
    { id: 'copy', label: '复制链接', iconAsset: 'app.media.lucide_link', icon: '', backgroundColor: '#E8E8E3', iconColor: '#111111', outlined: false },
    { id: 'more', label: '更多', iconAsset: 'app.media.lucide_ellipsis', icon: '', backgroundColor: '#E8E8E3', iconColor: '#111111', outlined: false }
  ];

  private trigger(action: string): void {
    if (this.onAction !== undefined) {
      this.onAction(action);
    }
  }

  @Builder
  private targetItem(target: ShareTarget) {
    Column({ space: 8 }) {
      Stack({ alignContent: Alignment.Center }) {
        if (target.iconAsset.length > 0) {
          Image($r(target.iconAsset))
            .width(target.id === 'send' ? 30 :
              (target.id === 'copy' || target.id === 'more' ? 28 : 46))
            .height(target.id === 'send' ? 30 :
              (target.id === 'copy' || target.id === 'more' ? 28 : 46))
            .objectFit(ImageFit.Contain)
        } else {
          Text(target.icon)
            .fontSize(target.id === 'more' ? 24 : 32)
            .fontWeight(FontWeight.Bold)
            .fontColor(target.iconColor)
        }
      }
      .width(68)
      .height(68)
      .backgroundColor(target.backgroundColor)
      .borderRadius(18)
      .border({
        width: target.outlined ? 1.5 : 0,
        color: target.outlined ? '#8A8A8A' : Color.Transparent
      })
      .clip(true)
      .onClick(() => this.trigger(target.id))
      .accessibilityText(target.label)

      Text(target.label)
        .fontSize(15)
        .fontColor('#202124')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(80)
        .textAlign(TextAlign.Center)
    }
    .width(84)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private unavailableOption(label: string, action: string, subtitle?: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(21)
        .fontWeight(FontWeight.Medium)
        .fontColor('#202124')
      if (subtitle !== undefined) {
        Text(subtitle)
          .fontSize(14)
          .fontColor('#5F6368')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding({ left: 22, right: 24, top: 9, bottom: 9 })
    .alignItems(HorizontalAlign.Start)
    .onClick(() => this.trigger(action))
    .accessibilityText(label)
  }

  build() {
    Column() {
      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.targets, (target: ShareTarget) => {
            this.targetItem(target);
          }, (target: ShareTarget) => target.id)
        }
        .padding({ left: 22, right: 22, top: 4, bottom: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Divider().color('#F1F3F4')
      Column() {
        this.unavailableOption('下载图片', 'download')
        this.unavailableOption('隐藏 Pin 图', 'hide')
        this.unavailableOption('举报 Pin 图', 'report', '这违反了 PinCase 的社区准则')
        Text('此 Pin 图的灵感来源于你最近的活动')
          .fontSize(16)
          .fontColor('#202124')
          .width('100%')
          .padding({ left: 22, right: 22, top: 18, bottom: 14 })
      }
      .width('100%')
    }
    .width('100%')
    .constraintSize({ maxWidth: 720 })
    .backgroundColor(Color.White)
    .padding({ top: 6, bottom: 12 })
  }
}
