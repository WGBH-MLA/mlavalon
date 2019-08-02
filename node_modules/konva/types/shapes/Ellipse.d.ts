import { Shape } from '../Shape';
import { GetSet, Vector2d } from '../types';
export declare class Ellipse extends Shape {
    _sceneFunc(context: any): void;
    getWidth(): number;
    getHeight(): number;
    setWidth(width: any): void;
    setHeight(height: any): void;
    radius: GetSet<Vector2d, this>;
    radiusX: GetSet<number, this>;
    radiusY: GetSet<number, this>;
}
