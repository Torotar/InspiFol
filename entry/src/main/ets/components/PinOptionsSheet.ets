@Component
export struct PinOptionsSheet {
  @Prop creator: string = '';
  onClose?: () => void;
  onAction?: (action: string) => void;

  private trigger(action: string): void {
    if (this.onAction !== undefined) {
      this.onAction(action);
    }
  }

  @Builder
  private option(label: string, action: string, subtitle?: string) {
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
    .padding({ left: 22, right: 24, top: 10, bottom: 10 })
    .alignItems(HorizontalAlign.Start)
    .onClick(() => this.trigger(action))
    .accessibilityText(label)
  }

  build() {
    Column() {
      Column() {
        this.option(`关注 ${this.creator}`, 'follow')
        this.option('复制链接', 'copy')
        this.option('下载图片', 'download')
        this.option('隐藏 Pin 图片', 'hide')
        this.option('举报 Pin 图片', 'report', '这违反了 PinCase 的社区准则')
      }
      .width('100%')
    }
    .width('100%')
    .constraintSize({ maxWidth: 720 })
    .backgroundColor(Color.White)
    .padding({ top: 4, bottom: 16 })
  }
}
