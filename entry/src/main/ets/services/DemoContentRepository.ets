import { Pin, Profile } from '../models/InspirationModels';

export class DemoContentRepository {
  private readonly pins: Pin[] = [
    { id: 'quiet-corner', title: '把安静留给窗边', creator: 'Lina Mori', category: '家居灵感', description: '用浅木、柔软织物和一束光，留出能慢下来阅读的角落。', backgroundColor: '#DFE7DA', accentColor: '#35523A', artworkSymbol: '◒', artworkLabel: 'SLOW HOME', artworkHeight: 236 },
    { id: 'paper-fruit', title: '夏日果色调色板', creator: 'Studio Momo', category: '平面设计', description: '用番石榴粉、柚子黄和深绿建立轻快但不刺眼的视觉节奏。', backgroundColor: '#FFC1AD', accentColor: '#8A2E3B', artworkSymbol: '●', artworkLabel: 'FRUIT STUDY', artworkHeight: 182 },
    { id: 'ceramic-shape', title: '手作陶器的留白', creator: 'Nono Clay', category: '手作', description: '不对称器型与低饱和釉色，让桌面保留呼吸感。', backgroundColor: '#D9D1C4', accentColor: '#5C4136', artworkSymbol: '◖', artworkLabel: 'CLAY NOTES', artworkHeight: 262 },
    { id: 'night-type', title: '夜色中的粗体字', creator: 'BOLD/FORM', category: '版式设计', description: '高对比排版适合把一句短文本变成画面中心。', backgroundColor: '#202B3D', accentColor: '#E6E9F0', artworkSymbol: 'A', artworkLabel: 'TYPE AFTER DARK', artworkHeight: 210 },
    { id: 'city-walk', title: '街角的蓝色时刻', creator: 'N. Kato', category: '摄影灵感', description: '在天色转暗前观察建筑、影子和路人的层次。', backgroundColor: '#9CBBD1', accentColor: '#173A59', artworkSymbol: '⌂', artworkLabel: 'CITY WALK', artworkHeight: 248 },
    { id: 'table-garden', title: '一人份餐桌花园', creator: 'Mina Table', category: '生活方式', description: '餐盘、亚麻与当季植物也可以组成日常的小型仪式。', backgroundColor: '#E8E2A9', accentColor: '#526138', artworkSymbol: '✦', artworkLabel: 'TABLE GARDEN', artworkHeight: 194 }
  ];

  getPins(): Pin[] {
    return this.pins.slice();
  }

  getProfile(): Profile {
    return {
      displayName: 'pinter',
      handle: 'torotarne',
      avatarInitial: 't',
      followerCount: 0,
      followingCount: 1
    };
  }
}
