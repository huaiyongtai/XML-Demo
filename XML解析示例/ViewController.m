//
//  ViewController.m
//  XML解析示例
//
//  Created by HelloWorld on 15/10/19.
//  Copyright (c) 2015年 无法修盖. All rights reserved.
//

#import "ViewController.h"
#import "GDataXMLNode.h"
#import "CountryCode.h"

@interface ViewController () <NSXMLParserDelegate>

@property (nonatomic, strong) CountryCode *countryCode; //模型

@property (nonatomic, copy) NSString *elementValue; //元素的值

@property (nonatomic, strong) NSMutableArray *countryCodeArr;   //模型数组

@property (nonatomic, assign) NSInteger countryCodeMemberCount; //一个完整地Row中元素的个数
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xml.xml" ofType:nil]];
    
    /**DOM解析，会一次性将整个文档加载到内存中，适合解析比较小的文档*/
    
    /**将数据使用XML解析，加载到xml文档*/
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data encoding:0 error:nil];

    /**获得的文档的根元素*/
    GDataXMLElement *rootElement = doc.rootElement;
    NSLog(@"根元素：%@", rootElement.name);
    
    /**取得rootElement元素的所有直接子元素*/
    NSArray *elementArray = [rootElement elementsForName:@"department"];
    for (GDataXMLElement *element in elementArray) {
        /**取出属性值*/
        NSLog(@"rootElement元素的直接子元素:%@", element.name);
        
    }
    
    
    /*XPath即为XML路径语言，它是一种用来确定XML文档中某部分位置的语言。XPath基于XML的树状结构，提供在数据结构树中找寻节点的能力。
     详见：HelpDoc/iOS开发笔记XML解析 或 百度 XPath
     */
    //获取doc中所有的employe元素
    NSArray *allEmployeElement = [doc nodesForXPath:@"//employe" error:NULL];
    [allEmployeElement enumerateObjectsUsingBlock:^(GDataXMLElement *element, NSUInteger idx, BOOL *stop) {
        NSLog(@"element:%@", element.stringValue);
    }];
    
}

//方式一
- (void)parserXML {
    
    NSData *countryCodeData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"国家代码" ofType:@"xml"]];
    
    /**创建XML解析器*/
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:countryCodeData];
    
    parser.delegate = self;
    
    /**开始事件驱动解析操作
     这是一个同步操作，也就是会阻塞
     */
    [parser parse];
    
}

//开始解析文档
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    _countryCodeArr = [NSMutableArray array];
}

//开始解析一个元素
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"Row"] ) {
        self.countryCode = [[CountryCode alloc] init];
        self.countryCodeMemberCount = 3;
    }
}
//解析一个元素的值
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    self.elementValue = string;
}
//解析一个元素结束
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"Row"] ) {
        [self.countryCodeArr addObject:self.countryCode];
        self.countryCode = nil;
    } else if ([elementName isEqualToString:@"Cell"]) {
        
        NSInteger memberIndex = self.countryCodeMemberCount % 3;
        if (memberIndex == 0) {
            self.countryCode.enName = self.elementValue;
        } else if (memberIndex == 1) {
            self.countryCode.chName = self.elementValue;
        } else if (memberIndex == 2){
            self.countryCode.code = self.elementValue;
        }
        self.countryCodeMemberCount--;
    }
}

//文档解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.countryCodeArr enumerateObjectsUsingBlock:^(CountryCode *countryCode, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@, %@, %@", countryCode.enName, countryCode.chName, countryCode.code);
    }];
}
@end
