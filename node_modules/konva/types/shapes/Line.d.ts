import { Shape } from '../Shape';
import { GetSet } from '../types';
export declare class Line extends Shape {
    constructor(config: any);
    _sceneFunc(context: any): void;
    getTensionPoints(): any;
    _getTensionPoints(): any[];
    _getTensionPointsClosed(): any[];
    getWidth(): number;
    getHeight(): number;
    getSelfRect(): {
        x: number;
        y: number;
        width: number;
        height: number;
    };
    closed: GetSet<boolean, this>;
    bezier: GetSet<boolean, this>;
    tension: GetSet<number, this>;
    points: GetSet<number[], this>;
}
