import { Shape } from '../Shape';
import { GetSet } from '../types';
export declare class Text extends Shape {
    textArr: Array<{
        text: string;
        width: number;
    }>;
    _partialText: string;
    _partialTextX: number;
    _partialTextY: number;
    textWidth: number;
    textHeight: number;
    constructor(config: any);
    _sceneFunc(context: any): void;
    _hitFunc(context: any): void;
    setText(text: any): this;
    getWidth(): any;
    getHeight(): any;
    getTextWidth(): number;
    getTextHeight(): number;
    measureSize(text: any): {
        width: any;
        height: number;
    };
    _getContextFont(): string;
    _addTextLine(line: any): number;
    _getTextWidth(text: any): any;
    _setTextData(): void;
    getStrokeScaleEnabled(): boolean;
    fontFamily: GetSet<string, this>;
    fontSize: GetSet<number, this>;
    fontStyle: GetSet<string, this>;
    fontVariant: GetSet<string, this>;
    align: GetSet<string, this>;
    letterSpacing: GetSet<number, this>;
    verticalAlign: GetSet<string, this>;
    padding: GetSet<number, this>;
    lineHeight: GetSet<number, this>;
    textDecoration: GetSet<string, this>;
    text: GetSet<string, this>;
    wrap: GetSet<string, this>;
    ellipsis: GetSet<boolean, this>;
}
