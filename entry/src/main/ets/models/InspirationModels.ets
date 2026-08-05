export interface Pin {
  id: string;
  title: string;
  creator: string;
  category: string;
  description: string;
  websiteUrl?: string;
  backgroundColor: string;
  accentColor: string;
  artworkSymbol: string;
  artworkLabel: string;
  artworkHeight: number;
  likeCount?: number;
  commentCount?: number;
}

export interface Board {
  id: string;
  name: string;
  pinIds: string[];
  createdAt: number;
}

export interface Profile {
  displayName: string;
  handle: string;
  avatarInitial: string;
  avatarUrl?: string;
  followerCount: number;
  followingCount: number;
}

export interface LocalBoardState {
  boards: Board[];
  savedPinIds: string[];
}
