export declare const version = "@@version";
export declare const isBrowser: boolean;
export declare const isUnminified: boolean;
export declare const dblClickWindow = 400;
export declare const getAngle: (angle: any) => any;
export declare const _parseUA: (userAgent: any) => {
    browser: any;
    version: any;
    isIE: number | boolean;
    mobile: boolean;
    ieMobile: boolean;
};
export declare const glob: any;
export declare const UA: {
    browser: any;
    version: any;
    isIE: number | boolean;
    mobile: boolean;
    ieMobile: boolean;
};
export declare const document: any;
export declare const _getGlobalKonva: () => any;
export declare const _NODES_REGISTRY: {};
export declare const _injectGlobal: (Konva: any) => void;
export declare const _registerNode: (NodeClass: any) => void;
