import { Shape } from '../Shape';
import { Group } from '../Group';
import { GetSet } from '../types';
export declare class Label extends Group {
    constructor(config: any);
    getText(): import("../Node").Node;
    getTag(): Tag;
    _addListeners(text: any): void;
    getWidth(): number;
    getHeight(): number;
    _sync(): void;
}
export declare class Tag extends Shape {
    _sceneFunc(context: any): void;
    getSelfRect(): {
        x: number;
        y: number;
        width: number;
        height: number;
    };
    pointerDirection: GetSet<'left' | 'top' | 'right' | 'bottom', this>;
    pointerWidth: GetSet<number, this>;
    pointerHeight: GetSet<number, this>;
    cornerRadius: GetSet<number, this>;
}
