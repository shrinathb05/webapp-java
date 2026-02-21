# Code analysis
## 01-maven-web-app 
#### Version 3.0-RELEASE 

**By: Administrator**

*Date: 2026-02-21*

## Introduction
This document contains results of the code analysis of 01-maven-web-app



## Configuration

- Quality Profiles
    - Names: Sonar way [CSS]; Sonar way [Java]; Sonar way [JavaScript]; Sonar way [JSP]; Sonar way [XML]; 
    - Files: AZyACdtg1jdQiNM-HZc5.json; AZyACdzT1jdQiNM-HaWK.json; AZyACdvb1jdQiNM-HZrx.json; AZyACduL1jdQiNM-HZe2.json; AZyACd1A1jdQiNM-HaiI.json; 


 - Quality Gate
    - Name: Sonar way
    - File: Sonar way.xml

## Synthesis

### Analysis Status

Reliability | Security | Security Review | Maintainability |
:---:|:---:|:---:|:---:
C | A | E | A |

### Quality gate status

| Quality Gate Status | OK |
|-|-|



### Metrics

Coverage | Duplications | Comment density | Median number of lines of code per file | Adherence to coding standard |
:---:|:---:|:---:|:---:|:---:
0.0 % | 6.9 % | 0.9 % | 259.0 | 99.6 %

### Tests

Total | Success Rate | Skipped | Errors | Failures |
:---:|:---:|:---:|:---:|:---:
2 | 100.0 % | 0 | 0 | 0

### Detailed technical debt

Reliability|Security|Maintainability|Total
---|---|---|---
0d 4h 27min|-|0d 6h 45min|1d 3h 12min


### Metrics Range

\ | Cyclomatic Complexity | Cognitive Complexity | Lines of code per file | Coverage | Comment density (%) | Duplication (%)
:---|:---:|:---:|:---:|:---:|:---:|:---:
Min | 1.0 | 0.0 | 6.0 | 0.0 | 0.0 | 0.0
Max | 8.0 | 0.0 | 11916.0 | 0.0 | 10.0 | 70.6

### Volume

Language|Number
---|---
CSS|10398
Java|9
JSP|1503
XML|38
Total|11948


## Issues

### Issues count by severity and types

Type / Severity|INFO|MINOR|MAJOR|CRITICAL|BLOCKER
---|---|---|---|---|---
BUG|0|51|6|0|0
VULNERABILITY|0|0|0|0|0
CODE_SMELL|0|1|29|0|0


### Issues List

Name|Description|Type|Severity|Number
---|---|---|---|---
"<html>" element should have a language attribute|The &lt;html&gt;&nbsp;element should provide the lang and/or xml:lang attribute in order to identify the <br /> default language of a document. <br /> It enables assistive technologies, such as screen readers,&nbsp;to provide a comfortable reading experience by adapting the pronunciation and <br /> accent to the language. It also helps braille translation software, telling it to switch the control codes for accented characters for instance. <br /> Other benefits of marking the language include: <br />  <br />    assisting user agents in providing dictionary definitions or helping users benefit from translation tools.  <br />    improving search engine ranking. <br />    <br />  <br /> Both the lang and the xml:lang attributes can take only one value. <br /> &nbsp; <br /> Noncompliant Code Example <br />  <br /> &lt;!DOCTYPE html&gt; <br /> &lt;html&gt; &lt;!-- Noncompliant --&gt; <br /> &nbsp;&nbsp;&nbsp; &lt;head&gt; <br />  &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &lt;title&gt;A page written in english&lt;/title&gt; <br />  &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &lt;meta content="text/html; charset=utf-8" /&gt; <br /> &nbsp;&nbsp;&nbsp; &lt;/head&gt; &nbsp; <br />  <br />  <br /> &nbsp;&nbsp;&nbsp; &lt;body&gt; &nbsp;&nbsp;&nbsp;&nbsp; <br /> &nbsp;&nbsp;&nbsp; ... &nbsp;&nbsp; <br /> &nbsp;&nbsp;&nbsp; &lt;/body&gt; <br /> &lt;/html&gt; <br />  <br /> Compliant Solution <br />  <br /> &lt;!DOCTYPE html&gt; <br /> &lt;html lang="en"&gt; <br /> &nbsp;&nbsp;&nbsp; &lt;head&gt; <br />  &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &lt;title&gt;A page written in english&lt;/title&gt; <br />  &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &lt;meta content="text/html; charset=utf-8" /&gt; <br /> &nbsp;&nbsp;&nbsp; &lt;/head&gt; &nbsp; <br />  <br />  <br /> &nbsp;&nbsp;&nbsp; &lt;body&gt; &nbsp;&nbsp;&nbsp;&nbsp; <br /> &nbsp;&nbsp;&nbsp; ... &nbsp;&nbsp; <br /> &nbsp;&nbsp;&nbsp; &lt;/body&gt; <br /> &lt;/html&gt; <br />  <br />  <br /> &lt;!DOCTYPE html&gt; <br /> &lt;html lang="en" xml:lang="en"&gt; <br /> &nbsp;&nbsp;&nbsp; &lt;head&gt; <br />  &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &lt;title&gt;A page written in english&lt;/title&gt; <br />  &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &lt;meta content="text/html; charset=utf-8" /&gt; <br /> &nbsp;&nbsp;&nbsp; &lt;/head&gt; &nbsp; <br />  <br />  <br /> &nbsp;&nbsp;&nbsp; &lt;body&gt; &nbsp;&nbsp;&nbsp;&nbsp; <br /> &nbsp;&nbsp;&nbsp; ... &nbsp;&nbsp; <br /> &nbsp;&nbsp;&nbsp; &lt;/body&gt; <br /> &lt;/html&gt; <br />  <br /> See <br />  <br />    WCAG2, H57 - Using language attributes on the html element  <br />    WCAG2, 3.1.1 - Language of Page  <br /> |BUG|MAJOR|6
"<fieldset>" tags should contain a "<legend>"|For users of assistive technology such as screen readers, it may be challenging to know what is expected in each form’s input. The input’s label <br /> alone might not be sufficient: 'street' could be part of a billing or a shipping address for instance. <br /> Fieldset legends are read out loud by screen readers before the label each time the focus is set on an input. For example, a legend 'Billing <br /> address' with a label 'Street' will read 'Billing address street'. Legends should be short, and 'Your' should not be repeated in both the legend and <br /> the label, as it would result in 'Your address Your City' being read. <br /> Noncompliant Code Example <br />  <br /> &lt;fieldset&gt;                                 &lt;!-- Noncompliant --&gt; <br />   Street: &lt;input type="text"&gt;&lt;br /&gt; <br />   Town: &lt;input type="text"&gt;&lt;br /&gt; <br />   Country: &lt;input type="text"&gt;&lt;br /&gt; <br /> &lt;/fieldset&gt; <br />  <br /> Compliant Solution <br />  <br /> &lt;fieldset&gt; <br />   &lt;legend&gt;Billing address&lt;/legend&gt; <br />   Street: &lt;input type="text"&gt;&lt;br /&gt; <br />   Town: &lt;input type="text"&gt;&lt;br /&gt; <br />   Country: &lt;input type="text"&gt;&lt;br /&gt; <br /> &lt;/fieldset&gt; <br /> |BUG|MINOR|26
Image, area and button with image tags should have an "alt" attribute|The alt attribute provides a textual alternative to an image. <br /> It is used whenever the actual image cannot be rendered. <br /> Common reasons for that include: <br />  <br />    The image can no longer be found  <br />    Visually impaired users using a screen reader software  <br />    Images loading is disabled, to reduce data consumption on mobile phones  <br />  <br /> It is also very important to not set an alt attribute to a non-informative value. For example &lt;img ... alt="logo"&gt; <br /> is useless as it doesn’t give any information to the user. In this case, as for any other decorative image, it is better to use a CSS background image <br /> instead of an &lt;img&gt; tag. If using CSS background-image is not possible, an empty alt="" is tolerated. See Exceptions <br /> bellow. <br /> This rule raises an issue when <br />  <br />    an &lt;input type="image"&gt; tag or an &lt;area&gt; tag have no alt attribute or their <br />   alt&nbsp;attribute has an empty string value.  <br />    an &lt;img&gt; tag has no alt attribute.  <br />  <br /> Noncompliant Code Example <br />  <br /> &lt;img src="foo.png" /&gt; &lt;!-- Noncompliant --&gt; <br /> &lt;input type="image" src="bar.png" /&gt; &lt;!-- Noncompliant --&gt; <br /> &lt;input type="image" src="bar.png" alt="" /&gt; &lt;!-- Noncompliant --&gt; <br />  <br /> &lt;img src="house.gif" usemap="#map1" <br />     alt="rooms of the house." /&gt; <br /> &lt;map id="map1" name="map1"&gt; <br />   &lt;area shape="rect" coords="0,0,42,42" <br />     href="bedroom.html"/&gt; &lt;!-- Noncompliant --&gt; <br />   &lt;area shape="rect" coords="0,0,21,21" <br />     href="lounge.html" alt=""/&gt; &lt;!-- Noncompliant --&gt; <br /> &lt;/map&gt; <br />  <br /> Compliant Solution <br />  <br /> &lt;img src="foo.png" alt="Some textual description of foo.png" /&gt; <br /> &lt;input type="image" src="bar.png" alt="Textual description of bar.png" /&gt; <br />  <br /> &lt;img src="house.gif" usemap="#map1" <br />     alt="rooms of the house." /&gt; <br /> &lt;map id="map1" name="map1"&gt; <br />   &lt;area shape="rect" coords="0,0,42,42" <br />     href="bedroom.html" alt="Bedroom" /&gt; <br />   &lt;area shape="rect" coords="0,0,21,21" <br />     href="lounge.html" alt="Lounge"/&gt; <br /> &lt;/map&gt; <br />  <br /> Exceptions <br /> &lt;img&gt; tags with empty string&nbsp;alt="" attributes won’t raise any issue. However this technic should be used in <br /> two cases only: <br /> When the image is decorative and it is not possible to use a CSS background image. For example, when the decorative &lt;img&gt; is <br /> generated via javascript with a source image coming from a database, it is better to use an &lt;img alt=""&gt; tag rather than generate <br /> CSS code. <br />  <br /> &lt;li *ngFor="let image of images"&gt; <br />     &lt;img [src]="image" alt=""&gt; <br /> &lt;/li&gt; <br />  <br /> When the image is not decorative but it’s alt text would repeat a nearby text. For example, images contained in links should not <br /> duplicate the link’s text in their alt attribute, as it would make the screen reader repeat the text twice. <br />  <br /> &lt;a href="flowers.html"&gt; <br />     &lt;img src="tulip.gif" alt="" /&gt; <br />     A blooming tulip <br /> &lt;/a&gt; <br />  <br /> In all other cases you should use CSS background images. <br /> See&nbsp;W3C WAI&nbsp;Web Accessibility Tutorials&nbsp;for more <br /> information. <br /> See <br />  <br />    WCAG2, H24 - Providing text alternatives for the area elements of image maps  <br />    WCAG2, H36 - Using alt attributes on images used as submit buttons  <br />    WCAG2, H37 - Using alt attributes on img elements  <br />    WCAG2, H67 - Using null alt text and no title attribute on img elements for images <br />   that AT should ignore  <br />    WCAG2, H2 - Combining adjacent image and text links for the same resource  <br />    WCAG2, 1.1.1 - Non-text Content  <br />    WCAG2, 2.4.4 - Link Purpose (In Context)  <br />    WCAG2, 2.4.9 - Link Purpose (Link Only)  <br /> |BUG|MINOR|25
Links should not directly target images|Whenever a user clicks on a link that targets an image, the website’s navigation menu will be lost. <br /> From a user point of view, it is as if she left the website. <br /> The only way to return to it is using the browser’s 'Back' button. <br /> Instead, it is better to create a page which will display the image using the &lt;img&gt; tag and preserve the navigation menu. <br /> Further, in terms of accessibility, when the image is embedded into a page, content providers are able to provide an alternate text equivalent <br /> through the alt attribute. <br /> Noncompliant Code Example <br />  <br /> &lt;a href="image.png"&gt;...&lt;/a&gt;  &lt;!-- Non-Compliant --&gt; <br />  <br /> Compliant Solution <br />  <br /> &lt;a href="page.html"&gt;...&lt;/a&gt;  &lt;!-- Compliant --&gt; <br /> |CODE_SMELL|MAJOR|25
Videos should have subtitles|In order to make your site usable by as many people as possible, subtitles should be provided for videos. <br /> This rule raises an issue when a video does not include at least one &lt;track/&gt; tag with the kind <br /> attribute set to captions, or descriptions or at the very least subtitles. <br /> Note that the subtitles kind is not meant for accessibility but for translation. The kind captions targets people with <br /> hearing impairment, whereas descriptions targets people with vision impairment. <br /> Noncompliant Code Example <br />  <br /> &lt;video id="video" controls preload="metadata"&gt; <br />    &lt;source src="resources/myvideo.mp4" type="video/mp4"&gt; <br />    &lt;source src="resources/myvideo.webm" type="video/webm"&gt; <br /> &lt;/video&gt; <br />  <br /> Compliant Solution <br />  <br /> &lt;video id="video" controls preload="metadata"&gt; <br />    &lt;source src="resources/myvideo.mp4" type="video/mp4"&gt; <br />    &lt;source src="resources/myvideo.webm" type="video/webm"&gt; <br />    &lt;track label="English" kind="captions" srclang="en" src="resources/myvideo-en.vtt" default&gt; <br />    &lt;track label="Deutsch" kind="captions" srclang="de" src="resources/myvideo-de.vtt"&gt; <br />    &lt;track label="Español" kind="captions" srclang="es" src="resources/myvideo-es.vtt"&gt; <br /> &lt;/video&gt; <br /> |CODE_SMELL|MAJOR|3
Standard outputs should not be used directly to log anything|When logging a message there are several important requirements which must be fulfilled: <br />  <br />    The user must be able to easily retrieve the logs  <br />    The format of all logged message must be uniform to allow the user to easily read the log  <br />    Logged data must actually be recorded  <br />    Sensitive data must only be logged securely  <br />  <br /> If a program directly writes to the standard outputs, there is absolutely no way to comply with those requirements. That’s why defining and using a <br /> dedicated logger is highly recommended. <br /> Noncompliant Code Example <br />  <br /> System.out.println("My Message");  // Noncompliant <br />  <br /> Compliant Solution <br />  <br /> logger.log("My Message"); <br />  <br /> See <br />  <br />    OWASP Top 10 2021 Category A9 - Security Logging and <br />   Monitoring Failures  <br />    OWASP Top 10 2017 Category A3 - Sensitive Data <br />   Exposure  <br />    CERT, ERR02-J. - Prevent exceptions while logging data  <br /> |CODE_SMELL|MAJOR|1
Methods should not return constants|There’s no point in forcing the overhead of a method call for a method that always returns the same constant value. Even worse, the fact that a <br /> method call must be made will likely mislead developers who call the method thinking that something more is done. Declare a constant instead. <br /> This rule raises an issue if on methods that contain only one statement: the return of a constant value. <br /> Noncompliant Code Example <br />  <br /> int getBestNumber() { <br />   return 12;  // Noncompliant <br /> } <br />  <br /> Compliant Solution <br />  <br /> static final int BEST_NUMBER = 12; <br />  <br /> Exceptions <br /> Methods with annotations, such as @Override and Spring’s @RequestMapping, are ignored.|CODE_SMELL|MINOR|1


## Security Hotspots

### Security hotspots count by category and priority

Category / Priority|LOW|MEDIUM|HIGH
---|---|---|---
LDAP Injection|0|0|0
Object Injection|0|0|0
Server-Side Request Forgery (SSRF)|0|0|0
XML External Entity (XXE)|0|0|0
Insecure Configuration|0|0|0
XPath Injection|0|0|0
Authentication|0|0|0
Weak Cryptography|0|0|0
Denial of Service (DoS)|0|0|0
Log Injection|0|0|0
Cross-Site Request Forgery (CSRF)|0|0|0
Open Redirect|0|0|0
Permission|0|0|0
SQL Injection|0|0|0
Encryption of Sensitive Data|0|0|0
Traceability|0|0|0
Buffer Overflow|0|0|0
File Manipulation|0|0|0
Code Injection (RCE)|0|0|0
Cross-Site Scripting (XSS)|0|0|0
Command Injection|0|0|0
Path Traversal Injection|0|0|0
HTTP Response Splitting|0|0|0
Others|6|0|0


### Security hotspots

Category|Name|Priority|Severity|Count
---|---|---|---|---
Others|Disabling resource integrity features is security-sensitive|LOW|MINOR|6
