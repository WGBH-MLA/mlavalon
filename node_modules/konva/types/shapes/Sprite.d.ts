import { Shape } from '../Shape';
import { Animation } from '../Animation';
import { GetSet } from '../types';
export declare class Sprite extends Shape {
    _updated: boolean;
    anim: Animation;
    interval: any;
    constructor(config: any);
    _sceneFunc(context: any): void;
    _hitFunc(context: any): void;
    _useBufferCanvas(): boolean;
    _setInterval(): void;
    start(): void;
    stop(): void;
    isRunning(): boolean;
    _updateIndex(): void;
    frameIndex: GetSet<number, this>;
    animation: GetSet<string, this>;
    image: GetSet<CanvasImageSource, this>;
    animations: GetSet<any, this>;
    frameOffsets: GetSet<any, this>;
    frameRate: GetSet<number, this>;
}
