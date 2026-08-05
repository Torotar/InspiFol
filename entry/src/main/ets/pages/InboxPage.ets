import { HdsNavigation, HdsNavigationTitleMode } from '@kit.UIDesignKit';

interface InboxUpdate {
  id: string;
  content: string;
  timeLabel: string;
}

@Component
export struct InboxPage {
  @State private feedbackMessage: string = '';
  @State private updates: InboxUpdate[] = [];
  @State private showMessageComposer: boolean = false;
  @State private messageDraft: string = '';
  @State private messageValidation: string = '';
  private readonly inboxScroller: Scroller = new Scroller();

  private showUnavailableFeedback(message: string = '消息服务暂不可用') : void {
    this.feedbackMessage = message;
  }

  private openMessageComposer(): void {
    this.feedbackMessage = '';
    this.messageValidation = '';
    this.showMessageComposer = true;
  }

  private closeMessageComposer(): void {
    this.messageDraft = '';
    this.messageValidation = '';
    this.showMessageComposer = false;
  }

  private sendLocalMessage(): void {
    const content = this.messageDraft.trim();
    if (content.length === 0) {
      this.messageValidation = '请输入消息内容';
      return;
    }

    this.updates = [{
      id: `local-message-${Date.now()}`,
      content,
      timeLabel: '刚刚'
    }, ...this.updates];
    this.closeMessageComposer();
  }

  @Builder
  private buildComposeMenu() {
    Row() {
      Button() {
        Image($r('app.media.lucide_square_pen'))
          .width(24)
          .height(24)
      }
      .width(44)
      .height(44)
      .backgroundColor(Color.Transparent)
      .onClick(() => this.openMessageComposer())
      .accessibilityText('新建本地消息草稿')
    }
    .width('100%')
    .height('100%')
    .padding({ right: 16 })
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private buildMessagesHeader() {
    Row() {
      Text('消息')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
      Blank()
      Row({ space: 6 }) {
        Text('查看全部')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
        Text('›')
          .fontSize(28)
          .fontColor('#111111')
          .margin({ top: -2 })
      }
      .onClick(() => this.showUnavailableFeedback(
        this.updates.length === 0 ? '还没有消息草稿' : '消息服务尚未接入，仅显示本次会话内的草稿'
      ))
      .accessibilityText('查看全部消息')
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private buildContactEntry() {
    Row({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.lucide_user_round_plus'))
          .width(38)
          .height(38)
      }
      .width(68)
      .height(68)
      .backgroundColor('#E7E7E3')
      .borderRadius(20)
      Column({ space: 4 }) {
        Text('查找要发送消息的用户')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text('联系以开始聊天')
          .fontSize(16)
          .fontColor('#707070')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .onClick(() => this.openMessageComposer())
    .accessibilityText('查找要发送消息的用户，打开本地消息草稿编辑')
  }

  @Builder
  private buildUpdateRow(item: InboxUpdate) {
    Row({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.lucide_search'))
          .width(38)
          .height(38)
      }
      .width(68)
      .height(68)
      .backgroundColor('#E7E7E3')
      .borderRadius(34)
      Text(item.content)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .lineHeight(24)
        .fontColor('#111111')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
      Column({ space: 4 }) {
        Text(item.timeLabel)
          .fontSize(15)
          .fontColor('#707070')
          .maxLines(1)
          .textAlign(TextAlign.End)
        Button() {
          Text('...')
            .fontSize(19)
            .lineHeight(18)
            .fontColor('#707070')
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.showUnavailableFeedback('消息服务尚未接入'))
        .accessibilityText('更多消息操作，暂不可用')
      }
      .width(42)
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(84)
    .padding({ top: 8, bottom: 8 })
    .accessibilityText(`${item.content}，${item.timeLabel}`)
  }

  @Builder
  private buildMessageComposer() {
    Column() {
      Column({ space: 14 }) {
        Text('新建消息草稿')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
        Text('消息服务尚未接入，草稿仅在当前会话中显示，不会发送或保存。')
          .fontSize(14)
          .lineHeight(20)
          .fontColor('#707070')
          .width('100%')
        TextArea({ text: this.messageDraft, placeholder: '输入消息内容' })
          .width('100%')
          .height(120)
          .fontSize(16)
          .backgroundColor('#F1F3F4')
          .borderRadius(12)
          .padding(14)
          .onChange((value: string) => {
            this.messageDraft = value;
            if (this.messageValidation.length > 0) {
              this.messageValidation = '';
            }
          })
        if (this.messageValidation.length > 0) {
          Text(this.messageValidation)
            .fontSize(13)
            .fontColor('#B3261E')
            .width('100%')
        }
        Row({ space: 10 }) {
          Button('取消')
            .layoutWeight(1)
            .height(46)
            .backgroundColor('#F1F3F4')
            .fontColor('#202124')
            .borderRadius(12)
            .onClick(() => this.closeMessageComposer())
          Button('发送')
            .layoutWeight(1)
            .height(46)
            .backgroundColor('#E60023')
            .fontColor(Color.White)
            .borderRadius(12)
            .onClick(() => this.sendLocalMessage())
        }
        .width('100%')
      }
      .width('100%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .constraintSize({ maxWidth: 420 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.38)')
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      HdsNavigation() {
        List({ scroller: this.inboxScroller }) {
          ListItem() {
            Column({ space: 20 }) {
              Column({ space: 12 }) {
                this.buildMessagesHeader()
                this.buildContactEntry()
              }
              .width('100%')

              if (this.updates.length > 0) {
                Column({ space: 8 }) {
                  Text('更新')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#111111')
                    .width('100%')
                    .margin({ bottom: 4 })
                  ForEach(this.updates, (item: InboxUpdate) => {
                    this.buildUpdateRow(item)
                  }, (item: InboxUpdate) => item.id)
                }
                .width('100%')
              }

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
            .padding({ left: 20, right: 20, top: 0, bottom: 132 })
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      }
      .titleBar({
        avoidLayoutSafeArea: true,
        enableComponentSafeArea: true,
        content: {
          title: {
            mainTitle: '通知'
          },
          stackBuilder: () => {
            this.buildComposeMenu();
          }
        }
      })
      .titleMode(HdsNavigationTitleMode.MINI)
      .hideBackButton(true)
      .bindToScrollable([this.inboxScroller])
      .backgroundColor(Color.White)
      .width('100%')
      .height('100%')

      if (this.showMessageComposer) {
        this.buildMessageComposer()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
