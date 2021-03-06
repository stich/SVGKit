//
//  SVGPolygonElement.m
//  SVGKit
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "SVGPolygonElement.h"

#import "SVGElement+Private.h"
#import "SVGShapeElement+Private.h"

#import "SVGPointsAndPathsParser.h"

@interface SVGPolygonElement()

- (void) parseData:(NSString *)data;

@end

@implementation SVGPolygonElement

- (void)parseAttributes:(NSDictionary *)attributes {
	[super parseAttributes:attributes];
	
	id value = nil;
	
	if ((value = [attributes objectForKey:@"points"])) {
		[self parseData:value];
	}
}

/*! According to SVG spec, a 'polygon' is EXACTYLY IDENTICAL to a 'path', if you prepend the letter "M", and
 postfix the letter 'z'.
 
 So, we take the complicated parser from SVGPathElement, remove all the multi-command stuff, and just use the
 "M" command
 */
- (void)parseData:(NSString *)data
{
	CGMutablePathRef path = CGPathCreateMutable();
    NSScanner* dataScanner = [NSScanner scannerWithString:data];
    CGPoint lastCoordinate = CGPointZero;
    
	NSCharacterSet* knownCommands = [NSCharacterSet characterSetWithCharactersInString:@""];
	
	NSString* cmdArgs = nil;
	[dataScanner scanUpToCharactersFromSet:knownCommands
													   intoString:&cmdArgs];
	
	NSString* commandWithParameters = [@"M" stringByAppendingString:cmdArgs];
	NSScanner* commandScanner = [NSScanner scannerWithString:commandWithParameters];
	
	
	lastCoordinate = [SVGPointsAndPathsParser readMovetoDrawtoCommandGroups:commandScanner
													path:path
											  relativeTo:CGPointZero
											  isRelative:FALSE];
	
    
//	lastCoordinate = //unused 
	[SVGPointsAndPathsParser readCloseCommand:[NSScanner scannerWithString:@"z"]
									   path:path
								 relativeTo:lastCoordinate];
	
	[self loadPath:path];
	CGPathRelease(path);
}

/* reference
 http://www.w3.org/TR/2011/REC-SVG11-20110816/shapes.html#PointsBNF
 */

/*
 list-of-points:
 wsp* coordinate-pairs? wsp*
 coordinate-pairs:
 coordinate-pair
 | coordinate-pair comma-wsp coordinate-pairs
 coordinate-pair:
 coordinate comma-wsp coordinate
 | coordinate negative-coordinate
 coordinate:
 number
 number:
 sign? integer-constant
 | sign? floating-point-constant
 negative-coordinate:
 "-" integer-constant
 | "-" floating-point-constant
 comma-wsp:
 (wsp+ comma? wsp*) | (comma wsp*)
 comma:
 ","
 integer-constant:
 digit-sequence
 floating-point-constant:
 fractional-constant exponent?
 | digit-sequence exponent
 fractional-constant:
 digit-sequence? "." digit-sequence
 | digit-sequence "."
 exponent:
 ( "e" | "E" ) sign? digit-sequence
 sign:
 "+" | "-"
 digit-sequence:
 digit
 | digit digit-sequence
 digit:
 "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
 */

@end
