interface InboxUpdate {
  id: string;
  prefix: string;
  highlight: string;
  suffix: string;
  timeLabel: string;
}

@Component
export struct InboxPage {
  @State private feedbackMessage: string = '';

  private readonly updates: InboxUpdate[] = [
    { id: 'word-study', prefix: '还在搜寻？探索有关 ', highlight: '单词学习', suffix: ' 的点子', timeLabel: '1周' },
    { id: 'software-icon', prefix: '还在搜寻？探索有关 ', highlight: '软件图标', suffix: ' 的点子', timeLabel: '2周' },
    { id: 'privacy', prefix: '还在搜寻？探索有关 ', highlight: '隐私声明', suffix: ' 界面的点子', timeLabel: '3周' },
    { id: 'diary', prefix: '还在搜寻？探索有关 ', highlight: '日记软件', suffix: ' 的点子', timeLabel: '1个月' },
    { id: 'portfolio', prefix: '还在搜寻？探索有关 ', highlight: '作品集', suffix: ' 的点子', timeLabel: '1个月' },
    { id: 'layout', prefix: '还在搜寻？探索有关 ', highlight: '场景布局', suffix: ' 的点子', timeLabel: '1个月' }
  ];

  private showUnavailableFeedback(): void {
    this.feedbackMessage = '消息功能暂不可用';
  }

  @Builder
  private buildMessagesHeader() {
    Row() {
      Text('消息')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
      Blank()
      Row({ space: 6 }) {
        Text('查看全部')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
        Text('›')
          .fontSize(30)
          .fontColor('#111111')
          .margin({ top: -2 })
      }
      .onClick(() => this.showUnavailableFeedback())
      .accessibilityText('查看全部消息')
    }
    .width('100%')
    .height(42)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private buildContactEntry() {
    Row({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.lucide_user_round_plus'))
          .width(40)
          .height(40)
      }
      .width(72)
      .height(72)
      .backgroundColor('#E7E7E3')
      .borderRadius(22)
      Column({ space: 4 }) {
        Text('查找要发送消息的用户')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text('联系以开始聊天')
          .fontSize(18)
          .fontColor('#707070')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .onClick(() => this.showUnavailableFeedback())
    .accessibilityText('查找要发送消息的用户，联系以开始聊天')
  }

  @Builder
  private buildUpdateRow(item: InboxUpdate) {
    Row({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.lucide_search'))
          .width(42)
          .height(42)
      }
      .width(72)
      .height(72)
      .backgroundColor('#E7E7E3')
      .borderRadius(36)
      Column({ space: 2 }) {
        Text() {
          Span(item.prefix)
          Span(item.highlight).fontWeight(FontWeight.Bold)
          Span(item.suffix)
        }
        .fontSize(19)
        .fontWeight(FontWeight.Medium)
        .lineHeight(26)
        .fontColor('#111111')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      }
      .layoutWeight(1)
      Column({ space: 7 }) {
        Text(item.timeLabel)
          .fontSize(16)
          .fontColor('#707070')
          .maxLines(1)
          .textAlign(TextAlign.End)
        Text('...')
          .fontSize(21)
          .lineHeight(18)
          .fontColor('#707070')
          .textAlign(TextAlign.End)
          .accessibilityText('更多操作')
      }
      .width(46)
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(92)
    .padding({ top: 8, bottom: 8 })
    .onClick(() => this.showUnavailableFeedback())
    .accessibilityText(`${item.prefix}${item.highlight}${item.suffix}，${item.timeLabel}`)
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 24 }) {
          Column({ space: 16 }) {
            this.buildMessagesHeader()
            this.buildContactEntry()
          }
          .width('100%')

          Column({ space: 8 }) {
            Text('更新')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111111')
              .width('100%')
              .margin({ bottom: 4 })
            ForEach(this.updates, (item: InboxUpdate) => {
              this.buildUpdateRow(item)
            }, (item: InboxUpdate) => item.id)
          }
          .width('100%')

          if (this.feedbackMessage.length > 0) {
            Text(this.feedbackMessage)
              .fontSize(14)
              .fontColor('#707070')
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 4, bottom: 8 })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 8, bottom: 132 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('收件箱')
    .titleMode(NavigationTitleMode.Full)
    .menus([
      {
        value: '新建消息',
        icon: $r('app.media.lucide_square_pen'),
        action: () => this.showUnavailableFeedback()
      }
    ])
    .backgroundColor(Color.White)
    .width('100%')
    .height('100%')
  }
}
