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
  followerCount: number;
  followingCount: number;
}

export interface LocalBoardState {
  boards: Board[];
  savedPinIds: string[];
}

export interface RecommendationChip {
  id: string;
  label: string;
  query: string;
  source: RecommendationSource;
}

export enum RecommendationSource {
  Demo = 'demo'
}

export enum RecommendationStatus {
  Loading = 'loading',
  Ready = 'ready',
  Empty = 'empty',
  Error = 'error'
}

export interface RecommendationResult {
  status: RecommendationStatus;
  items: RecommendationChip[];
  message?: string;
}
