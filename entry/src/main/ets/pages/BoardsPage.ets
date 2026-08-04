import { mediaquery } from '@kit.ArkUI';
import { Board, Pin, Profile } from '../models/InspirationModels';

enum ProfileSection {
  Created = 'created',
  Saved = 'saved'
}

const ALL_PINS_BOARD_ID: string = 'profile-all-pins';

@Component
export struct BoardsPage {
  @Prop @Watch('onContentChanged') boards: Board[] = [];
  @Prop @Watch('onContentChanged') pins: Pin[] = [];
  @Prop @Watch('onContentChanged') savedPinIds: string[] = [];
  @Prop profile: Profile = {
    displayName: '',
    handle: '',
    avatarInitial: '',
    followerCount: 0,
    followingCount: 0
  };
  onOpenSettings?: () => void;
  @State @Watch('onContentChanged') private selectedSection: ProfileSection = ProfileSection.Saved;
  @State private isTablet: boolean = false;
  @State private sections: WaterFlowSections = new WaterFlowSections();
  private tabletListener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(width >= 600vp)');

  aboutToAppear(): void {
    this.isTablet = this.tabletListener.matches;
    this.tabletListener.on('change', (result: mediaquery.MediaQueryResult) => {
      this.isTablet = result.matches;
      this.refreshSections();
    });
    this.refreshSections();
  }

  aboutToDisappear(): void {
    this.tabletListener.off('change');
  }

  onContentChanged(): void {
    if (this.boards.length === 0 && this.selectedSection === ProfileSection.Created) {
      this.selectedSection = ProfileSection.Saved;
      return;
    }
    this.refreshSections();
  }

  private refreshSections(): void {
    const boardCount: number = this.visibleBoards().length;
    const contentItemCount: number = boardCount > 0 ? boardCount : 1;
    const contentCrossCount: number = boardCount > 0 ? (this.isTablet ? 3 : 2) : 1;
    const sectionOptions: SectionOptions[] = [
      {
        itemsCount: 1,
        crossCount: 1,
        rowsGap: 0,
        margin: 0
      },
      {
        itemsCount: contentItemCount,
        crossCount: contentCrossCount,
        columnsGap: this.isTablet ? 16 : 12,
        rowsGap: 22,
        margin: { left: 16, right: 16, top: 18, bottom: 112 }
      }
    ];
    this.sections.splice(0, this.sections.length(), sectionOptions);
  }

  private validSavedPins(): Pin[] {
    return this.pins.filter((pin: Pin): boolean => this.savedPinIds.indexOf(pin.id) >= 0);
  }

  private savedBoards(): Board[] {
    const validSavedIds: string[] = this.validSavedPins().map((pin: Pin): string => pin.id);
    if (validSavedIds.length === 0) {
      return [];
    }
    const allPinsBoard: Board = {
      id: ALL_PINS_BOARD_ID,
      name: '所有 Pin 图',
      pinIds: validSavedIds,
      createdAt: 0
    };
    const boardsWithSavedPins: Board[] = this.boards
      .map((board: Board): Board => {
        return {
          id: board.id,
          name: board.name,
          pinIds: board.pinIds.filter((pinId: string): boolean => validSavedIds.indexOf(pinId) >= 0),
          createdAt: board.createdAt
        };
      })
      .filter((board: Board): boolean => board.pinIds.length > 0);
    return [allPinsBoard, ...boardsWithSavedPins];
  }

  private visibleBoards(): Board[] {
    return this.selectedSection === ProfileSection.Created ? this.boards : this.savedBoards();
  }

  private pinsForBoard(board: Board): Pin[] {
    return this.pins.filter((pin: Pin): boolean => board.pinIds.indexOf(pin.id) >= 0).slice(0, 3);
  }

  private validPinCount(board: Board): number {
    return this.pins.filter((pin: Pin): boolean => board.pinIds.indexOf(pin.id) >= 0).length;
  }

  private boardCoverHeight(board: Board): number {
    const coverPins: Pin[] = this.pinsForBoard(board);
    if (coverPins.length === 0) {
      return 144;
    }
    return Math.min(188, Math.max(142, Math.round(coverPins[0].artworkHeight * 0.72)));
  }

  @Builder
  private buildArtworkTile(pin: Pin, height: number, weight: number) {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(pin.backgroundColor)
      Text(pin.artworkSymbol)
        .fontSize(height > 90 ? 46 : 30)
        .fontWeight(FontWeight.Bold)
        .fontColor(pin.accentColor)
        .maxLines(1)
        .opacity(0.9)
    }
    .width('100%')
    .height(height)
    .layoutWeight(weight)
  }

  @Builder
  private buildBoardCover(board: Board) {
    Stack({ alignContent: Alignment.Center }) {
      if (this.pinsForBoard(board).length === 0) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#ECEFF1')
        Text('+')
          .fontSize(48)
          .fontWeight(FontWeight.Lighter)
          .fontColor('#5F6368')
      } else if (this.pinsForBoard(board).length === 1) {
        this.buildArtworkTile(this.pinsForBoard(board)[0], this.boardCoverHeight(board), 1)
      } else {
        Row({ space: 3 }) {
          this.buildArtworkTile(this.pinsForBoard(board)[0], this.boardCoverHeight(board), 2)
          Column({ space: 3 }) {
            this.buildArtworkTile(
              this.pinsForBoard(board)[1],
              this.pinsForBoard(board).length > 2 ? (this.boardCoverHeight(board) - 3) / 2 : this.boardCoverHeight(board),
              1
            )
            if (this.pinsForBoard(board).length > 2) {
              this.buildArtworkTile(this.pinsForBoard(board)[2], (this.boardCoverHeight(board) - 3) / 2, 1)
            }
          }
          .height('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height(this.boardCoverHeight(board))
    .borderRadius(16)
    .clip(true)
  }

  @Builder
  private buildBoardCard(board: Board) {
    Column({ space: 8 }) {
      this.buildBoardCover(board)
      Text(board.name)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Text(`${this.validPinCount(board)} 张 Pin 图`)
        .fontSize(13)
        .fontColor('#5F6368')
        .maxLines(1)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .accessibilityGroup(true)
    .accessibilityText(`${board.name}，${this.validPinCount(board)} 张 Pin 图`)
  }

  @Builder
  private buildIconButton(icon: Resource, label: Resource, action?: () => void) {
    Button({ type: ButtonType.Circle }) {
      Image(icon)
        .width(26)
        .height(26)
    }
    .width(44)
    .height(44)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      if (action !== undefined) {
        action();
      }
    })
    .accessibilityText(label)
  }

  @Builder
  private buildSectionTab(section: ProfileSection, label: Resource) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
        .maxLines(1)
      Column()
        .width(54)
        .height(3)
        .borderRadius(2)
        .backgroundColor(this.selectedSection === section ? '#111111' : Color.Transparent)
    }
    .height(42)
    .justifyContent(FlexAlign.End)
    .onClick(() => {
      this.selectedSection = section;
    })
    .accessibilityText(label)
    .accessibilitySelected(this.selectedSection === section)
  }

  @Builder
  private buildProfileHeader() {
    Column() {
      Column() {
        Row({ space: 4 }) {
          Blank()
          this.buildIconButton($r('app.media.lucide_share_2'), $r('app.string.profile_share'))
          this.buildIconButton($r('app.media.lucide_ellipsis'), $r('app.string.profile_settings'), () => {
            if (this.onOpenSettings !== undefined) {
              this.onOpenSettings();
            }
          })
        }
        .width('100%')
        .height(54)

        Column({ space: 8 }) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(112)
              .height(112)
              .borderRadius(56)
              .backgroundColor('#6072C8')
            Text(this.profile.avatarInitial)
              .fontSize(58)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .width(112)
          .height(112)
          .accessibilityText(`头像，${this.profile.displayName}`)

          Text(this.profile.displayName)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: 6 }) {
            Image($r('app.media.pinterest_mark'))
              .width(20)
              .height(20)
              .borderRadius(10)
              .objectFit(ImageFit.Contain)
              .accessibilityLevel('no')
            Text(this.profile.handle)
              .fontSize(16)
              .fontColor('#666666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          Text(`${this.profile.followerCount} 粉丝 · ${this.profile.followingCount} 关注中`)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111111')

          Button($r('app.string.profile_creator_hub'))
            .height(46)
            .padding({ left: 24, right: 24 })
            .margin({ top: 8 })
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor('#E60023')
            .borderRadius(23)
            .accessibilityDescription($r('app.string.profile_unavailable'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 20, right: 20 })

        Row({ space: 38 }) {
          if (this.boards.length > 0) {
            this.buildSectionTab(ProfileSection.Created, $r('app.string.profile_created'))
          }
          this.buildSectionTab(ProfileSection.Saved, $r('app.string.profile_saved'))
        }
        .width('100%')
        .height(64)
        .margin({ top: 42 })
        .justifyContent(FlexAlign.Center)

        Row({ space: 10 }) {
          Row({ space: 10 }) {
            Image($r('app.media.lucide_search'))
              .width(22)
              .height(22)
            Text($r('app.string.profile_search_placeholder'))
              .fontSize(16)
              .fontColor('#666666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .height(46)
          .padding({ left: 16, right: 14 })
          .layoutWeight(1)
          .border({ width: 1.5, color: '#A6A6A2' })
          .borderRadius(23)
          .accessibilityText($r('app.string.profile_search_placeholder'))
          .accessibilityDescription($r('app.string.profile_unavailable'))

          this.buildIconButton($r('app.media.lucide_sliders_horizontal'), $r('app.string.profile_filter'))
          this.buildIconButton($r('app.media.lucide_plus_dark'), $r('app.string.profile_add'))
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .constraintSize({ maxWidth: 760 })
      .padding({ top: 48 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildEmptyState() {
    Column({ space: 8 }) {
      Text($r('app.string.profile_saved_empty_title'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#202124')
      Text($r('app.string.profile_saved_empty_subtitle'))
        .fontSize(14)
        .fontColor('#70757A')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(148)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    WaterFlow({ sections: this.sections, layoutMode: WaterFlowLayoutMode.SLIDING_WINDOW }) {
      FlowItem() {
        this.buildProfileHeader()
      }
      .width('100%')

      if (this.visibleBoards().length === 0) {
        FlowItem() {
          this.buildEmptyState()
        }
        .width('100%')
      } else {
        ForEach(this.visibleBoards(), (board: Board) => {
          FlowItem() {
            this.buildBoardCard(board)
          }
          .width('100%')
        }, (board: Board): string => board.id)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .scrollBar(BarState.Off)
  }
}
