//
//  MadokaTextField.m
//  CCTextFieldEffects
//
//  Created by Kelvin on 6/26/16.
//  Copyright © 2016 Cokile. All rights reserved.
//

#import "MadokaTextField.h"

@interface MadokaTextField ()

@property (strong, nonatomic) CAShapeLayer *borderLayer;

@end

@implementation MadokaTextField

#pragma mark - Constants
static CGFloat const borderThickness = 1;
static CGPoint const textFieldInsets = {6, 6};
static CGPoint const placeholderInsets = {6, 6};

#pragma mark - Custom accessory
- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    
    [self updatePlaceholder];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    
    [self updateBorder];
}

- (void)setPlaceholderFontScale:(CGFloat)placeholderFontScale {
    _placeholderFontScale = placeholderFontScale;
    
    [self updatePlaceholder];
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    
    [self updatePlaceholder];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    [self updateBorder];
    [self updatePlaceholder];
}

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.borderLayer = [[CAShapeLayer alloc] init];
        self.borderLayer.fillColor = [UIColor clearColor].CGColor;
        
        self.placeholderLabel = [[UILabel alloc] init];
        self.placeholderColor = [UIColor colorWithRed:0.4039 green:0.3922 blue:0.4863 alpha:1.0];
        self.borderColor = self.placeholderColor;
        self.borderLayer.strokeColor = self.borderColor.CGColor;
        self.cursorColor = self.placeholderColor;
        self.textColor = self.placeholderColor;
        
        self.placeholderFontScale = 0.65;
        
        self.font = [UIFont boldSystemFontOfSize:self.font.pointSize];
    }
    
    return self;
}

#pragma mark - Overridden methods
- (void)drawRect:(CGRect)rect {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect));
    
    self.placeholderLabel.frame = CGRectInset(frame, placeholderInsets.x, placeholderInsets.y);
    self.placeholderLabel.font = [self placeholderFontFromFont:self.font];
    
    [self updateBorder];
    [self updatePlaceholder];
    
    [self.layer addSublayer:self.borderLayer];
    [self addSubview:self.placeholderLabel];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset([self rectForBorderBounds:bounds], textFieldInsets.x, 0);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset([self rectForBorderBounds:bounds], textFieldInsets.x, 0);
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateViewsForTextEntry];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateViewsForTextDisplay];
}

#pragma mark - Private methods
- (void)animateViewsForTextEntry {
    self.borderLayer.strokeEnd = 1;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform translate = CGAffineTransformMakeTranslation(-placeholderInsets.x, self.placeholderLabel.bounds.size.height + (placeholderInsets.y*2));
        CGAffineTransform scale = CGAffineTransformMakeScale(0.9, 0.9);
        
        self.placeholderLabel.transform = CGAffineTransformConcat(translate, scale);
    } completion:^(BOOL finished) {
        if (self.animationCompletionHandler != nil) {
            self.animationCompletionHandler(CCAnimationTypeTextEntry);
        }
    }];
}

- (void)animateViewsForTextDisplay {
    if (self.text.length == 0) {
        self.borderLayer.strokeEnd = [self percentageForBottomBorder];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.placeholderLabel.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (self.animationCompletionHandler != nil) {
                self.animationCompletionHandler(CCAnimationTypeTextDisplay);
            }
        }];
    }
}

- (void)updateBorder {
    CGRect rect = [self rectForBorderBounds:self.bounds];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(rect.origin.x+borderThickness, rect.size.height-borderThickness)];
    [path addLineToPoint:CGPointMake(rect.size.width-borderThickness, rect.size.height-borderThickness)];
    [path addLineToPoint:CGPointMake(rect.size.width-borderThickness, rect.origin.y+borderThickness)];
    [path addLineToPoint:CGPointMake(rect.origin.x+borderThickness, rect.origin.y+borderThickness)];
    [path closePath];
    
    self.borderLayer.path = path.CGPath;
    self.borderLayer.lineCap = kCALineCapSquare;
    self.borderLayer.lineWidth = borderThickness;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = self.borderColor.CGColor;
    self.borderLayer.strokeEnd = [self percentageForBottomBorder];
}

- (CGFloat)percentageForBottomBorder {
    CGRect borderRect = [self rectForBorderBounds:self.bounds];
    CGFloat sumOfSides = (borderRect.size.width*2) + (borderRect.size.height*2);
    return (borderRect.size.width*100 / sumOfSides) / 100;
}

- (void)updatePlaceholder {
    self.placeholderLabel.text = self.placeholder;
    self.placeholderLabel.textColor = self.placeholderColor;
    [self.placeholderLabel sizeToFit];
    [self layoutPlaceholderInTextRect];
    
    if ([self isFirstResponder] || self.text.length!=0) {
        [self animateViewsForTextEntry];
    }
}

- (UIFont *)placeholderFontFromFont:(UIFont *)font {
    UIFont *smallerFont = [UIFont fontWithName:font.fontName size:font.pointSize*self.placeholderFontScale];
    
    return smallerFont;
}

- (CGRect)rectForBorderBounds:(CGRect)bounds {
    return CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds)-self.font.lineHeight+textFieldInsets.y);
}

- (void)layoutPlaceholderInTextRect {
    self.placeholderLabel.transform = CGAffineTransformIdentity;
    
    CGRect textRect = [self textRectForBounds:self.bounds];
    CGFloat originX = textRect.origin.x;
    
    switch (self.textAlignment) {
        case NSTextAlignmentCenter:
            originX += textRect.size.width/2-self.placeholderLabel.bounds.size.width/2;
            break;
        case NSTextAlignmentRight:
            originX += textRect.size.width-self.placeholderLabel.bounds.size.width;
            break;
        default:
            break;
    }
    
    self.placeholderLabel.frame = CGRectMake(originX, CGRectGetHeight(textRect)-CGRectGetHeight(self.placeholderLabel.bounds)-placeholderInsets.y, CGRectGetWidth(self.placeholderLabel.bounds), CGRectGetHeight(self.placeholderLabel.bounds));
}

@end