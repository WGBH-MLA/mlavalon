import { Line } from './Line';
import { GetSet } from '../types';
export declare class Arrow extends Line {
    _sceneFunc(ctx: any): void;
    pointerLength: GetSet<number, this>;
    pointerWidth: GetSet<number, this>;
    pointerAtBeginning: GetSet<boolean, this>;
}
