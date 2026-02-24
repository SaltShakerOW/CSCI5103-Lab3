
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	02c000ef          	jal	ra,4a <matchhere>
  22:	e919                	bnez	a0,38 <matchstar+0x38>
  }while(*text!='\0' && (*text++==c || c=='.'));
  24:	0004c783          	lbu	a5,0(s1)
  28:	cb89                	beqz	a5,3a <matchstar+0x3a>
  2a:	0485                	addi	s1,s1,1
  2c:	2781                	sext.w	a5,a5
  2e:	ff2786e3          	beq	a5,s2,1a <matchstar+0x1a>
  32:	ff4904e3          	beq	s2,s4,1a <matchstar+0x1a>
  36:	a011                	j	3a <matchstar+0x3a>
      return 1;
  38:	4505                	li	a0,1
  return 0;
}
  3a:	70a2                	ld	ra,40(sp)
  3c:	7402                	ld	s0,32(sp)
  3e:	64e2                	ld	s1,24(sp)
  40:	6942                	ld	s2,16(sp)
  42:	69a2                	ld	s3,8(sp)
  44:	6a02                	ld	s4,0(sp)
  46:	6145                	addi	sp,sp,48
  48:	8082                	ret

000000000000004a <matchhere>:
  if(re[0] == '\0')
  4a:	00054703          	lbu	a4,0(a0)
  4e:	c73d                	beqz	a4,bc <matchhere+0x72>
{
  50:	1141                	addi	sp,sp,-16
  52:	e406                	sd	ra,8(sp)
  54:	e022                	sd	s0,0(sp)
  56:	0800                	addi	s0,sp,16
  58:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5a:	00154683          	lbu	a3,1(a0)
  5e:	02a00613          	li	a2,42
  62:	02c68563          	beq	a3,a2,8c <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  66:	02400613          	li	a2,36
  6a:	02c70863          	beq	a4,a2,9a <matchhere+0x50>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  6e:	0005c683          	lbu	a3,0(a1)
  return 0;
  72:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  74:	ca81                	beqz	a3,84 <matchhere+0x3a>
  76:	02e00613          	li	a2,46
  7a:	02c70b63          	beq	a4,a2,b0 <matchhere+0x66>
  return 0;
  7e:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  80:	02d70863          	beq	a4,a3,b0 <matchhere+0x66>
}
  84:	60a2                	ld	ra,8(sp)
  86:	6402                	ld	s0,0(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret
    return matchstar(re[0], re+2, text);
  8c:	862e                	mv	a2,a1
  8e:	00250593          	addi	a1,a0,2
  92:	853a                	mv	a0,a4
  94:	f6dff0ef          	jal	ra,0 <matchstar>
  98:	b7f5                	j	84 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  9a:	c691                	beqz	a3,a6 <matchhere+0x5c>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  9c:	0005c683          	lbu	a3,0(a1)
  a0:	fef9                	bnez	a3,7e <matchhere+0x34>
  return 0;
  a2:	4501                	li	a0,0
  a4:	b7c5                	j	84 <matchhere+0x3a>
    return *text == '\0';
  a6:	0005c503          	lbu	a0,0(a1)
  aa:	00153513          	seqz	a0,a0
  ae:	bfd9                	j	84 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b0:	0585                	addi	a1,a1,1
  b2:	00178513          	addi	a0,a5,1
  b6:	f95ff0ef          	jal	ra,4a <matchhere>
  ba:	b7e9                	j	84 <matchhere+0x3a>
    return 1;
  bc:	4505                	li	a0,1
}
  be:	8082                	ret

00000000000000c0 <match>:
{
  c0:	1101                	addi	sp,sp,-32
  c2:	ec06                	sd	ra,24(sp)
  c4:	e822                	sd	s0,16(sp)
  c6:	e426                	sd	s1,8(sp)
  c8:	e04a                	sd	s2,0(sp)
  ca:	1000                	addi	s0,sp,32
  cc:	892a                	mv	s2,a0
  ce:	84ae                	mv	s1,a1
  if(re[0] == '^')
  d0:	00054703          	lbu	a4,0(a0)
  d4:	05e00793          	li	a5,94
  d8:	00f70c63          	beq	a4,a5,f0 <match+0x30>
    if(matchhere(re, text))
  dc:	85a6                	mv	a1,s1
  de:	854a                	mv	a0,s2
  e0:	f6bff0ef          	jal	ra,4a <matchhere>
  e4:	e911                	bnez	a0,f8 <match+0x38>
  }while(*text++ != '\0');
  e6:	0485                	addi	s1,s1,1
  e8:	fff4c783          	lbu	a5,-1(s1)
  ec:	fbe5                	bnez	a5,dc <match+0x1c>
  ee:	a031                	j	fa <match+0x3a>
    return matchhere(re+1, text);
  f0:	0505                	addi	a0,a0,1
  f2:	f59ff0ef          	jal	ra,4a <matchhere>
  f6:	a011                	j	fa <match+0x3a>
      return 1;
  f8:	4505                	li	a0,1
}
  fa:	60e2                	ld	ra,24(sp)
  fc:	6442                	ld	s0,16(sp)
  fe:	64a2                	ld	s1,8(sp)
 100:	6902                	ld	s2,0(sp)
 102:	6105                	addi	sp,sp,32
 104:	8082                	ret

0000000000000106 <grep>:
{
 106:	715d                	addi	sp,sp,-80
 108:	e486                	sd	ra,72(sp)
 10a:	e0a2                	sd	s0,64(sp)
 10c:	fc26                	sd	s1,56(sp)
 10e:	f84a                	sd	s2,48(sp)
 110:	f44e                	sd	s3,40(sp)
 112:	f052                	sd	s4,32(sp)
 114:	ec56                	sd	s5,24(sp)
 116:	e85a                	sd	s6,16(sp)
 118:	e45e                	sd	s7,8(sp)
 11a:	0880                	addi	s0,sp,80
 11c:	89aa                	mv	s3,a0
 11e:	8b2e                	mv	s6,a1
  m = 0;
 120:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 122:	3ff00b93          	li	s7,1023
 126:	00001a97          	auipc	s5,0x1
 12a:	eeaa8a93          	addi	s5,s5,-278 # 1010 <buf>
 12e:	a835                	j	16a <grep+0x64>
      p = q+1;
 130:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 134:	45a9                	li	a1,10
 136:	854a                	mv	a0,s2
 138:	1bc000ef          	jal	ra,2f4 <strchr>
 13c:	84aa                	mv	s1,a0
 13e:	c505                	beqz	a0,166 <grep+0x60>
      *q = 0;
 140:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 144:	85ca                	mv	a1,s2
 146:	854e                	mv	a0,s3
 148:	f79ff0ef          	jal	ra,c0 <match>
 14c:	d175                	beqz	a0,130 <grep+0x2a>
        *q = '\n';
 14e:	47a9                	li	a5,10
 150:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 154:	00148613          	addi	a2,s1,1
 158:	4126063b          	subw	a2,a2,s2
 15c:	85ca                	mv	a1,s2
 15e:	4505                	li	a0,1
 160:	378000ef          	jal	ra,4d8 <write>
 164:	b7f1                	j	130 <grep+0x2a>
    if(m > 0){
 166:	03404363          	bgtz	s4,18c <grep+0x86>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 16a:	414b863b          	subw	a2,s7,s4
 16e:	014a85b3          	add	a1,s5,s4
 172:	855a                	mv	a0,s6
 174:	35c000ef          	jal	ra,4d0 <read>
 178:	02a05463          	blez	a0,1a0 <grep+0x9a>
    m += n;
 17c:	00aa0a3b          	addw	s4,s4,a0
    buf[m] = '\0';
 180:	014a87b3          	add	a5,s5,s4
 184:	00078023          	sb	zero,0(a5)
    p = buf;
 188:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 18a:	b76d                	j	134 <grep+0x2e>
      m -= p - buf;
 18c:	415907b3          	sub	a5,s2,s5
 190:	40fa0a3b          	subw	s4,s4,a5
      memmove(buf, p, m);
 194:	8652                	mv	a2,s4
 196:	85ca                	mv	a1,s2
 198:	8556                	mv	a0,s5
 19a:	270000ef          	jal	ra,40a <memmove>
 19e:	b7f1                	j	16a <grep+0x64>
}
 1a0:	60a6                	ld	ra,72(sp)
 1a2:	6406                	ld	s0,64(sp)
 1a4:	74e2                	ld	s1,56(sp)
 1a6:	7942                	ld	s2,48(sp)
 1a8:	79a2                	ld	s3,40(sp)
 1aa:	7a02                	ld	s4,32(sp)
 1ac:	6ae2                	ld	s5,24(sp)
 1ae:	6b42                	ld	s6,16(sp)
 1b0:	6ba2                	ld	s7,8(sp)
 1b2:	6161                	addi	sp,sp,80
 1b4:	8082                	ret

00000000000001b6 <main>:
{
 1b6:	7139                	addi	sp,sp,-64
 1b8:	fc06                	sd	ra,56(sp)
 1ba:	f822                	sd	s0,48(sp)
 1bc:	f426                	sd	s1,40(sp)
 1be:	f04a                	sd	s2,32(sp)
 1c0:	ec4e                	sd	s3,24(sp)
 1c2:	e852                	sd	s4,16(sp)
 1c4:	e456                	sd	s5,8(sp)
 1c6:	0080                	addi	s0,sp,64
  if(argc <= 1){
 1c8:	4785                	li	a5,1
 1ca:	04a7d663          	bge	a5,a0,216 <main+0x60>
  pattern = argv[1];
 1ce:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1d2:	4789                	li	a5,2
 1d4:	04a7db63          	bge	a5,a0,22a <main+0x74>
 1d8:	01058913          	addi	s2,a1,16
 1dc:	ffd5099b          	addiw	s3,a0,-3
 1e0:	02099793          	slli	a5,s3,0x20
 1e4:	01d7d993          	srli	s3,a5,0x1d
 1e8:	05e1                	addi	a1,a1,24
 1ea:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], O_RDONLY)) < 0){
 1ec:	4581                	li	a1,0
 1ee:	00093503          	ld	a0,0(s2)
 1f2:	306000ef          	jal	ra,4f8 <open>
 1f6:	84aa                	mv	s1,a0
 1f8:	04054063          	bltz	a0,238 <main+0x82>
    grep(pattern, fd);
 1fc:	85aa                	mv	a1,a0
 1fe:	8552                	mv	a0,s4
 200:	f07ff0ef          	jal	ra,106 <grep>
    close(fd);
 204:	8526                	mv	a0,s1
 206:	2da000ef          	jal	ra,4e0 <close>
  for(i = 2; i < argc; i++){
 20a:	0921                	addi	s2,s2,8
 20c:	ff3910e3          	bne	s2,s3,1ec <main+0x36>
  exit(0);
 210:	4501                	li	a0,0
 212:	2a6000ef          	jal	ra,4b8 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 216:	00001597          	auipc	a1,0x1
 21a:	87a58593          	addi	a1,a1,-1926 # a90 <malloc+0xe2>
 21e:	4509                	li	a0,2
 220:	6b0000ef          	jal	ra,8d0 <fprintf>
    exit(1);
 224:	4505                	li	a0,1
 226:	292000ef          	jal	ra,4b8 <exit>
    grep(pattern, 0);
 22a:	4581                	li	a1,0
 22c:	8552                	mv	a0,s4
 22e:	ed9ff0ef          	jal	ra,106 <grep>
    exit(0);
 232:	4501                	li	a0,0
 234:	284000ef          	jal	ra,4b8 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 238:	00093583          	ld	a1,0(s2)
 23c:	00001517          	auipc	a0,0x1
 240:	87450513          	addi	a0,a0,-1932 # ab0 <malloc+0x102>
 244:	6b6000ef          	jal	ra,8fa <printf>
      exit(1);
 248:	4505                	li	a0,1
 24a:	26e000ef          	jal	ra,4b8 <exit>

000000000000024e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 24e:	1141                	addi	sp,sp,-16
 250:	e406                	sd	ra,8(sp)
 252:	e022                	sd	s0,0(sp)
 254:	0800                	addi	s0,sp,16
  extern int main();
  main();
 256:	f61ff0ef          	jal	ra,1b6 <main>
  exit(0);
 25a:	4501                	li	a0,0
 25c:	25c000ef          	jal	ra,4b8 <exit>

0000000000000260 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 266:	87aa                	mv	a5,a0
 268:	0585                	addi	a1,a1,1
 26a:	0785                	addi	a5,a5,1
 26c:	fff5c703          	lbu	a4,-1(a1)
 270:	fee78fa3          	sb	a4,-1(a5)
 274:	fb75                	bnez	a4,268 <strcpy+0x8>
    ;
  return os;
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret

000000000000027c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 282:	00054783          	lbu	a5,0(a0)
 286:	cb91                	beqz	a5,29a <strcmp+0x1e>
 288:	0005c703          	lbu	a4,0(a1)
 28c:	00f71763          	bne	a4,a5,29a <strcmp+0x1e>
    p++, q++;
 290:	0505                	addi	a0,a0,1
 292:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 294:	00054783          	lbu	a5,0(a0)
 298:	fbe5                	bnez	a5,288 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 29a:	0005c503          	lbu	a0,0(a1)
}
 29e:	40a7853b          	subw	a0,a5,a0
 2a2:	6422                	ld	s0,8(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret

00000000000002a8 <strlen>:

uint
strlen(const char *s)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e422                	sd	s0,8(sp)
 2ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	cf91                	beqz	a5,2ce <strlen+0x26>
 2b4:	0505                	addi	a0,a0,1
 2b6:	87aa                	mv	a5,a0
 2b8:	4685                	li	a3,1
 2ba:	9e89                	subw	a3,a3,a0
 2bc:	00f6853b          	addw	a0,a3,a5
 2c0:	0785                	addi	a5,a5,1
 2c2:	fff7c703          	lbu	a4,-1(a5)
 2c6:	fb7d                	bnez	a4,2bc <strlen+0x14>
    ;
  return n;
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  for(n = 0; s[n]; n++)
 2ce:	4501                	li	a0,0
 2d0:	bfe5                	j	2c8 <strlen+0x20>

00000000000002d2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2d8:	ca19                	beqz	a2,2ee <memset+0x1c>
 2da:	87aa                	mv	a5,a0
 2dc:	1602                	slli	a2,a2,0x20
 2de:	9201                	srli	a2,a2,0x20
 2e0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2e4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2e8:	0785                	addi	a5,a5,1
 2ea:	fee79de3          	bne	a5,a4,2e4 <memset+0x12>
  }
  return dst;
}
 2ee:	6422                	ld	s0,8(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret

00000000000002f4 <strchr>:

char*
strchr(const char *s, char c)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	cb99                	beqz	a5,314 <strchr+0x20>
    if(*s == c)
 300:	00f58763          	beq	a1,a5,30e <strchr+0x1a>
  for(; *s; s++)
 304:	0505                	addi	a0,a0,1
 306:	00054783          	lbu	a5,0(a0)
 30a:	fbfd                	bnez	a5,300 <strchr+0xc>
      return (char*)s;
  return 0;
 30c:	4501                	li	a0,0
}
 30e:	6422                	ld	s0,8(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret
  return 0;
 314:	4501                	li	a0,0
 316:	bfe5                	j	30e <strchr+0x1a>

0000000000000318 <gets>:

char*
gets(char *buf, int max)
{
 318:	711d                	addi	sp,sp,-96
 31a:	ec86                	sd	ra,88(sp)
 31c:	e8a2                	sd	s0,80(sp)
 31e:	e4a6                	sd	s1,72(sp)
 320:	e0ca                	sd	s2,64(sp)
 322:	fc4e                	sd	s3,56(sp)
 324:	f852                	sd	s4,48(sp)
 326:	f456                	sd	s5,40(sp)
 328:	f05a                	sd	s6,32(sp)
 32a:	ec5e                	sd	s7,24(sp)
 32c:	1080                	addi	s0,sp,96
 32e:	8baa                	mv	s7,a0
 330:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 332:	892a                	mv	s2,a0
 334:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 336:	4aa9                	li	s5,10
 338:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 33a:	89a6                	mv	s3,s1
 33c:	2485                	addiw	s1,s1,1
 33e:	0344d663          	bge	s1,s4,36a <gets+0x52>
    cc = read(0, &c, 1);
 342:	4605                	li	a2,1
 344:	faf40593          	addi	a1,s0,-81
 348:	4501                	li	a0,0
 34a:	186000ef          	jal	ra,4d0 <read>
    if(cc < 1)
 34e:	00a05e63          	blez	a0,36a <gets+0x52>
    buf[i++] = c;
 352:	faf44783          	lbu	a5,-81(s0)
 356:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 35a:	01578763          	beq	a5,s5,368 <gets+0x50>
 35e:	0905                	addi	s2,s2,1
 360:	fd679de3          	bne	a5,s6,33a <gets+0x22>
  for(i=0; i+1 < max; ){
 364:	89a6                	mv	s3,s1
 366:	a011                	j	36a <gets+0x52>
 368:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 36a:	99de                	add	s3,s3,s7
 36c:	00098023          	sb	zero,0(s3)
  return buf;
}
 370:	855e                	mv	a0,s7
 372:	60e6                	ld	ra,88(sp)
 374:	6446                	ld	s0,80(sp)
 376:	64a6                	ld	s1,72(sp)
 378:	6906                	ld	s2,64(sp)
 37a:	79e2                	ld	s3,56(sp)
 37c:	7a42                	ld	s4,48(sp)
 37e:	7aa2                	ld	s5,40(sp)
 380:	7b02                	ld	s6,32(sp)
 382:	6be2                	ld	s7,24(sp)
 384:	6125                	addi	sp,sp,96
 386:	8082                	ret

0000000000000388 <stat>:

int
stat(const char *n, struct stat *st)
{
 388:	1101                	addi	sp,sp,-32
 38a:	ec06                	sd	ra,24(sp)
 38c:	e822                	sd	s0,16(sp)
 38e:	e426                	sd	s1,8(sp)
 390:	e04a                	sd	s2,0(sp)
 392:	1000                	addi	s0,sp,32
 394:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 396:	4581                	li	a1,0
 398:	160000ef          	jal	ra,4f8 <open>
  if(fd < 0)
 39c:	02054163          	bltz	a0,3be <stat+0x36>
 3a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a2:	85ca                	mv	a1,s2
 3a4:	16c000ef          	jal	ra,510 <fstat>
 3a8:	892a                	mv	s2,a0
  close(fd);
 3aa:	8526                	mv	a0,s1
 3ac:	134000ef          	jal	ra,4e0 <close>
  return r;
}
 3b0:	854a                	mv	a0,s2
 3b2:	60e2                	ld	ra,24(sp)
 3b4:	6442                	ld	s0,16(sp)
 3b6:	64a2                	ld	s1,8(sp)
 3b8:	6902                	ld	s2,0(sp)
 3ba:	6105                	addi	sp,sp,32
 3bc:	8082                	ret
    return -1;
 3be:	597d                	li	s2,-1
 3c0:	bfc5                	j	3b0 <stat+0x28>

00000000000003c2 <atoi>:

int
atoi(const char *s)
{
 3c2:	1141                	addi	sp,sp,-16
 3c4:	e422                	sd	s0,8(sp)
 3c6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c8:	00054683          	lbu	a3,0(a0)
 3cc:	fd06879b          	addiw	a5,a3,-48
 3d0:	0ff7f793          	zext.b	a5,a5
 3d4:	4625                	li	a2,9
 3d6:	02f66863          	bltu	a2,a5,406 <atoi+0x44>
 3da:	872a                	mv	a4,a0
  n = 0;
 3dc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3de:	0705                	addi	a4,a4,1
 3e0:	0025179b          	slliw	a5,a0,0x2
 3e4:	9fa9                	addw	a5,a5,a0
 3e6:	0017979b          	slliw	a5,a5,0x1
 3ea:	9fb5                	addw	a5,a5,a3
 3ec:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3f0:	00074683          	lbu	a3,0(a4)
 3f4:	fd06879b          	addiw	a5,a3,-48
 3f8:	0ff7f793          	zext.b	a5,a5
 3fc:	fef671e3          	bgeu	a2,a5,3de <atoi+0x1c>
  return n;
}
 400:	6422                	ld	s0,8(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret
  n = 0;
 406:	4501                	li	a0,0
 408:	bfe5                	j	400 <atoi+0x3e>

000000000000040a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e422                	sd	s0,8(sp)
 40e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 410:	02b57463          	bgeu	a0,a1,438 <memmove+0x2e>
    while(n-- > 0)
 414:	00c05f63          	blez	a2,432 <memmove+0x28>
 418:	1602                	slli	a2,a2,0x20
 41a:	9201                	srli	a2,a2,0x20
 41c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 420:	872a                	mv	a4,a0
      *dst++ = *src++;
 422:	0585                	addi	a1,a1,1
 424:	0705                	addi	a4,a4,1
 426:	fff5c683          	lbu	a3,-1(a1)
 42a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 42e:	fee79ae3          	bne	a5,a4,422 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 432:	6422                	ld	s0,8(sp)
 434:	0141                	addi	sp,sp,16
 436:	8082                	ret
    dst += n;
 438:	00c50733          	add	a4,a0,a2
    src += n;
 43c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 43e:	fec05ae3          	blez	a2,432 <memmove+0x28>
 442:	fff6079b          	addiw	a5,a2,-1
 446:	1782                	slli	a5,a5,0x20
 448:	9381                	srli	a5,a5,0x20
 44a:	fff7c793          	not	a5,a5
 44e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 450:	15fd                	addi	a1,a1,-1
 452:	177d                	addi	a4,a4,-1
 454:	0005c683          	lbu	a3,0(a1)
 458:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 45c:	fee79ae3          	bne	a5,a4,450 <memmove+0x46>
 460:	bfc9                	j	432 <memmove+0x28>

0000000000000462 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 462:	1141                	addi	sp,sp,-16
 464:	e422                	sd	s0,8(sp)
 466:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 468:	ca05                	beqz	a2,498 <memcmp+0x36>
 46a:	fff6069b          	addiw	a3,a2,-1
 46e:	1682                	slli	a3,a3,0x20
 470:	9281                	srli	a3,a3,0x20
 472:	0685                	addi	a3,a3,1
 474:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 476:	00054783          	lbu	a5,0(a0)
 47a:	0005c703          	lbu	a4,0(a1)
 47e:	00e79863          	bne	a5,a4,48e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 482:	0505                	addi	a0,a0,1
    p2++;
 484:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 486:	fed518e3          	bne	a0,a3,476 <memcmp+0x14>
  }
  return 0;
 48a:	4501                	li	a0,0
 48c:	a019                	j	492 <memcmp+0x30>
      return *p1 - *p2;
 48e:	40e7853b          	subw	a0,a5,a4
}
 492:	6422                	ld	s0,8(sp)
 494:	0141                	addi	sp,sp,16
 496:	8082                	ret
  return 0;
 498:	4501                	li	a0,0
 49a:	bfe5                	j	492 <memcmp+0x30>

000000000000049c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 49c:	1141                	addi	sp,sp,-16
 49e:	e406                	sd	ra,8(sp)
 4a0:	e022                	sd	s0,0(sp)
 4a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4a4:	f67ff0ef          	jal	ra,40a <memmove>
}
 4a8:	60a2                	ld	ra,8(sp)
 4aa:	6402                	ld	s0,0(sp)
 4ac:	0141                	addi	sp,sp,16
 4ae:	8082                	ret

00000000000004b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4b0:	4885                	li	a7,1
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4b8:	4889                	li	a7,2
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4c0:	488d                	li	a7,3
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4c8:	4891                	li	a7,4
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <read>:
.global read
read:
 li a7, SYS_read
 4d0:	4895                	li	a7,5
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <write>:
.global write
write:
 li a7, SYS_write
 4d8:	48c1                	li	a7,16
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <close>:
.global close
close:
 li a7, SYS_close
 4e0:	48d5                	li	a7,21
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4e8:	4899                	li	a7,6
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4f0:	489d                	li	a7,7
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <open>:
.global open
open:
 li a7, SYS_open
 4f8:	48bd                	li	a7,15
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 500:	48c5                	li	a7,17
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 508:	48c9                	li	a7,18
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 510:	48a1                	li	a7,8
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <link>:
.global link
link:
 li a7, SYS_link
 518:	48cd                	li	a7,19
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 520:	48d1                	li	a7,20
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 528:	48a5                	li	a7,9
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <dup>:
.global dup
dup:
 li a7, SYS_dup
 530:	48a9                	li	a7,10
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 538:	48ad                	li	a7,11
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 540:	48b1                	li	a7,12
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 548:	48b5                	li	a7,13
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 550:	48b9                	li	a7,14
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <bind>:
.global bind
bind:
 li a7, SYS_bind
 558:	48f5                	li	a7,29
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <unbind>:
.global unbind
unbind:
 li a7, SYS_unbind
 560:	48f9                	li	a7,30
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <send>:
.global send
send:
 li a7, SYS_send
 568:	48fd                	li	a7,31
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <recv>:
.global recv
recv:
 li a7, SYS_recv
 570:	02000893          	li	a7,32
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <pgpte>:
.global pgpte
pgpte:
 li a7, SYS_pgpte
 57a:	02100893          	li	a7,33
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <kpgtbl>:
.global kpgtbl
kpgtbl:
 li a7, SYS_kpgtbl
 584:	02200893          	li	a7,34
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 58e:	1101                	addi	sp,sp,-32
 590:	ec06                	sd	ra,24(sp)
 592:	e822                	sd	s0,16(sp)
 594:	1000                	addi	s0,sp,32
 596:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 59a:	4605                	li	a2,1
 59c:	fef40593          	addi	a1,s0,-17
 5a0:	f39ff0ef          	jal	ra,4d8 <write>
}
 5a4:	60e2                	ld	ra,24(sp)
 5a6:	6442                	ld	s0,16(sp)
 5a8:	6105                	addi	sp,sp,32
 5aa:	8082                	ret

00000000000005ac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5ac:	7139                	addi	sp,sp,-64
 5ae:	fc06                	sd	ra,56(sp)
 5b0:	f822                	sd	s0,48(sp)
 5b2:	f426                	sd	s1,40(sp)
 5b4:	f04a                	sd	s2,32(sp)
 5b6:	ec4e                	sd	s3,24(sp)
 5b8:	0080                	addi	s0,sp,64
 5ba:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5bc:	c299                	beqz	a3,5c2 <printint+0x16>
 5be:	0805c763          	bltz	a1,64c <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5c2:	2581                	sext.w	a1,a1
  neg = 0;
 5c4:	4881                	li	a7,0
 5c6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5ca:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5cc:	2601                	sext.w	a2,a2
 5ce:	00000517          	auipc	a0,0x0
 5d2:	50250513          	addi	a0,a0,1282 # ad0 <digits>
 5d6:	883a                	mv	a6,a4
 5d8:	2705                	addiw	a4,a4,1
 5da:	02c5f7bb          	remuw	a5,a1,a2
 5de:	1782                	slli	a5,a5,0x20
 5e0:	9381                	srli	a5,a5,0x20
 5e2:	97aa                	add	a5,a5,a0
 5e4:	0007c783          	lbu	a5,0(a5)
 5e8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5ec:	0005879b          	sext.w	a5,a1
 5f0:	02c5d5bb          	divuw	a1,a1,a2
 5f4:	0685                	addi	a3,a3,1
 5f6:	fec7f0e3          	bgeu	a5,a2,5d6 <printint+0x2a>
  if(neg)
 5fa:	00088c63          	beqz	a7,612 <printint+0x66>
    buf[i++] = '-';
 5fe:	fd070793          	addi	a5,a4,-48
 602:	00878733          	add	a4,a5,s0
 606:	02d00793          	li	a5,45
 60a:	fef70823          	sb	a5,-16(a4)
 60e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 612:	02e05663          	blez	a4,63e <printint+0x92>
 616:	fc040793          	addi	a5,s0,-64
 61a:	00e78933          	add	s2,a5,a4
 61e:	fff78993          	addi	s3,a5,-1
 622:	99ba                	add	s3,s3,a4
 624:	377d                	addiw	a4,a4,-1
 626:	1702                	slli	a4,a4,0x20
 628:	9301                	srli	a4,a4,0x20
 62a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 62e:	fff94583          	lbu	a1,-1(s2)
 632:	8526                	mv	a0,s1
 634:	f5bff0ef          	jal	ra,58e <putc>
  while(--i >= 0)
 638:	197d                	addi	s2,s2,-1
 63a:	ff391ae3          	bne	s2,s3,62e <printint+0x82>
}
 63e:	70e2                	ld	ra,56(sp)
 640:	7442                	ld	s0,48(sp)
 642:	74a2                	ld	s1,40(sp)
 644:	7902                	ld	s2,32(sp)
 646:	69e2                	ld	s3,24(sp)
 648:	6121                	addi	sp,sp,64
 64a:	8082                	ret
    x = -xx;
 64c:	40b005bb          	negw	a1,a1
    neg = 1;
 650:	4885                	li	a7,1
    x = -xx;
 652:	bf95                	j	5c6 <printint+0x1a>

0000000000000654 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 654:	7119                	addi	sp,sp,-128
 656:	fc86                	sd	ra,120(sp)
 658:	f8a2                	sd	s0,112(sp)
 65a:	f4a6                	sd	s1,104(sp)
 65c:	f0ca                	sd	s2,96(sp)
 65e:	ecce                	sd	s3,88(sp)
 660:	e8d2                	sd	s4,80(sp)
 662:	e4d6                	sd	s5,72(sp)
 664:	e0da                	sd	s6,64(sp)
 666:	fc5e                	sd	s7,56(sp)
 668:	f862                	sd	s8,48(sp)
 66a:	f466                	sd	s9,40(sp)
 66c:	f06a                	sd	s10,32(sp)
 66e:	ec6e                	sd	s11,24(sp)
 670:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 672:	0005c903          	lbu	s2,0(a1)
 676:	22090e63          	beqz	s2,8b2 <vprintf+0x25e>
 67a:	8b2a                	mv	s6,a0
 67c:	8a2e                	mv	s4,a1
 67e:	8bb2                	mv	s7,a2
  state = 0;
 680:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 682:	4481                	li	s1,0
 684:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 686:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 68a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 68e:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 692:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 696:	00000c97          	auipc	s9,0x0
 69a:	43ac8c93          	addi	s9,s9,1082 # ad0 <digits>
 69e:	a005                	j	6be <vprintf+0x6a>
        putc(fd, c0);
 6a0:	85ca                	mv	a1,s2
 6a2:	855a                	mv	a0,s6
 6a4:	eebff0ef          	jal	ra,58e <putc>
 6a8:	a019                	j	6ae <vprintf+0x5a>
    } else if(state == '%'){
 6aa:	03598263          	beq	s3,s5,6ce <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6ae:	2485                	addiw	s1,s1,1
 6b0:	8726                	mv	a4,s1
 6b2:	009a07b3          	add	a5,s4,s1
 6b6:	0007c903          	lbu	s2,0(a5)
 6ba:	1e090c63          	beqz	s2,8b2 <vprintf+0x25e>
    c0 = fmt[i] & 0xff;
 6be:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6c2:	fe0994e3          	bnez	s3,6aa <vprintf+0x56>
      if(c0 == '%'){
 6c6:	fd579de3          	bne	a5,s5,6a0 <vprintf+0x4c>
        state = '%';
 6ca:	89be                	mv	s3,a5
 6cc:	b7cd                	j	6ae <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6ce:	cfa5                	beqz	a5,746 <vprintf+0xf2>
 6d0:	00ea06b3          	add	a3,s4,a4
 6d4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6d8:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6da:	c681                	beqz	a3,6e2 <vprintf+0x8e>
 6dc:	9752                	add	a4,a4,s4
 6de:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6e2:	03878a63          	beq	a5,s8,716 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 6e6:	05a78463          	beq	a5,s10,72e <vprintf+0xda>
      } else if(c0 == 'u'){
 6ea:	0db78763          	beq	a5,s11,7b8 <vprintf+0x164>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6ee:	07800713          	li	a4,120
 6f2:	10e78963          	beq	a5,a4,804 <vprintf+0x1b0>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6f6:	07000713          	li	a4,112
 6fa:	12e78e63          	beq	a5,a4,836 <vprintf+0x1e2>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 6fe:	07300713          	li	a4,115
 702:	16e78b63          	beq	a5,a4,878 <vprintf+0x224>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 706:	05579063          	bne	a5,s5,746 <vprintf+0xf2>
        putc(fd, '%');
 70a:	85d6                	mv	a1,s5
 70c:	855a                	mv	a0,s6
 70e:	e81ff0ef          	jal	ra,58e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 712:	4981                	li	s3,0
 714:	bf69                	j	6ae <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 716:	008b8913          	addi	s2,s7,8
 71a:	4685                	li	a3,1
 71c:	4629                	li	a2,10
 71e:	000ba583          	lw	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	e89ff0ef          	jal	ra,5ac <printint>
 728:	8bca                	mv	s7,s2
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b749                	j	6ae <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 72e:	03868663          	beq	a3,s8,75a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 732:	05a68163          	beq	a3,s10,774 <vprintf+0x120>
      } else if(c0 == 'l' && c1 == 'u'){
 736:	09b68d63          	beq	a3,s11,7d0 <vprintf+0x17c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 73a:	03a68f63          	beq	a3,s10,778 <vprintf+0x124>
      } else if(c0 == 'l' && c1 == 'x'){
 73e:	07800793          	li	a5,120
 742:	0cf68d63          	beq	a3,a5,81c <vprintf+0x1c8>
        putc(fd, '%');
 746:	85d6                	mv	a1,s5
 748:	855a                	mv	a0,s6
 74a:	e45ff0ef          	jal	ra,58e <putc>
        putc(fd, c0);
 74e:	85ca                	mv	a1,s2
 750:	855a                	mv	a0,s6
 752:	e3dff0ef          	jal	ra,58e <putc>
      state = 0;
 756:	4981                	li	s3,0
 758:	bf99                	j	6ae <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 75a:	008b8913          	addi	s2,s7,8
 75e:	4685                	li	a3,1
 760:	4629                	li	a2,10
 762:	000ba583          	lw	a1,0(s7)
 766:	855a                	mv	a0,s6
 768:	e45ff0ef          	jal	ra,5ac <printint>
        i += 1;
 76c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 76e:	8bca                	mv	s7,s2
      state = 0;
 770:	4981                	li	s3,0
        i += 1;
 772:	bf35                	j	6ae <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 774:	03860563          	beq	a2,s8,79e <vprintf+0x14a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 778:	07b60963          	beq	a2,s11,7ea <vprintf+0x196>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 77c:	07800793          	li	a5,120
 780:	fcf613e3          	bne	a2,a5,746 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 784:	008b8913          	addi	s2,s7,8
 788:	4681                	li	a3,0
 78a:	4641                	li	a2,16
 78c:	000ba583          	lw	a1,0(s7)
 790:	855a                	mv	a0,s6
 792:	e1bff0ef          	jal	ra,5ac <printint>
        i += 2;
 796:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 798:	8bca                	mv	s7,s2
      state = 0;
 79a:	4981                	li	s3,0
        i += 2;
 79c:	bf09                	j	6ae <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 79e:	008b8913          	addi	s2,s7,8
 7a2:	4685                	li	a3,1
 7a4:	4629                	li	a2,10
 7a6:	000ba583          	lw	a1,0(s7)
 7aa:	855a                	mv	a0,s6
 7ac:	e01ff0ef          	jal	ra,5ac <printint>
        i += 2;
 7b0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7b2:	8bca                	mv	s7,s2
      state = 0;
 7b4:	4981                	li	s3,0
        i += 2;
 7b6:	bde5                	j	6ae <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 0);
 7b8:	008b8913          	addi	s2,s7,8
 7bc:	4681                	li	a3,0
 7be:	4629                	li	a2,10
 7c0:	000ba583          	lw	a1,0(s7)
 7c4:	855a                	mv	a0,s6
 7c6:	de7ff0ef          	jal	ra,5ac <printint>
 7ca:	8bca                	mv	s7,s2
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	b5c5                	j	6ae <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d0:	008b8913          	addi	s2,s7,8
 7d4:	4681                	li	a3,0
 7d6:	4629                	li	a2,10
 7d8:	000ba583          	lw	a1,0(s7)
 7dc:	855a                	mv	a0,s6
 7de:	dcfff0ef          	jal	ra,5ac <printint>
        i += 1;
 7e2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e4:	8bca                	mv	s7,s2
      state = 0;
 7e6:	4981                	li	s3,0
        i += 1;
 7e8:	b5d9                	j	6ae <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ea:	008b8913          	addi	s2,s7,8
 7ee:	4681                	li	a3,0
 7f0:	4629                	li	a2,10
 7f2:	000ba583          	lw	a1,0(s7)
 7f6:	855a                	mv	a0,s6
 7f8:	db5ff0ef          	jal	ra,5ac <printint>
        i += 2;
 7fc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7fe:	8bca                	mv	s7,s2
      state = 0;
 800:	4981                	li	s3,0
        i += 2;
 802:	b575                	j	6ae <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 16, 0);
 804:	008b8913          	addi	s2,s7,8
 808:	4681                	li	a3,0
 80a:	4641                	li	a2,16
 80c:	000ba583          	lw	a1,0(s7)
 810:	855a                	mv	a0,s6
 812:	d9bff0ef          	jal	ra,5ac <printint>
 816:	8bca                	mv	s7,s2
      state = 0;
 818:	4981                	li	s3,0
 81a:	bd51                	j	6ae <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 81c:	008b8913          	addi	s2,s7,8
 820:	4681                	li	a3,0
 822:	4641                	li	a2,16
 824:	000ba583          	lw	a1,0(s7)
 828:	855a                	mv	a0,s6
 82a:	d83ff0ef          	jal	ra,5ac <printint>
        i += 1;
 82e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 830:	8bca                	mv	s7,s2
      state = 0;
 832:	4981                	li	s3,0
        i += 1;
 834:	bdad                	j	6ae <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 836:	008b8793          	addi	a5,s7,8
 83a:	f8f43423          	sd	a5,-120(s0)
 83e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 842:	03000593          	li	a1,48
 846:	855a                	mv	a0,s6
 848:	d47ff0ef          	jal	ra,58e <putc>
  putc(fd, 'x');
 84c:	07800593          	li	a1,120
 850:	855a                	mv	a0,s6
 852:	d3dff0ef          	jal	ra,58e <putc>
 856:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 858:	03c9d793          	srli	a5,s3,0x3c
 85c:	97e6                	add	a5,a5,s9
 85e:	0007c583          	lbu	a1,0(a5)
 862:	855a                	mv	a0,s6
 864:	d2bff0ef          	jal	ra,58e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 868:	0992                	slli	s3,s3,0x4
 86a:	397d                	addiw	s2,s2,-1
 86c:	fe0916e3          	bnez	s2,858 <vprintf+0x204>
        printptr(fd, va_arg(ap, uint64));
 870:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 874:	4981                	li	s3,0
 876:	bd25                	j	6ae <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 878:	008b8993          	addi	s3,s7,8
 87c:	000bb903          	ld	s2,0(s7)
 880:	00090f63          	beqz	s2,89e <vprintf+0x24a>
        for(; *s; s++)
 884:	00094583          	lbu	a1,0(s2)
 888:	c195                	beqz	a1,8ac <vprintf+0x258>
          putc(fd, *s);
 88a:	855a                	mv	a0,s6
 88c:	d03ff0ef          	jal	ra,58e <putc>
        for(; *s; s++)
 890:	0905                	addi	s2,s2,1
 892:	00094583          	lbu	a1,0(s2)
 896:	f9f5                	bnez	a1,88a <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 898:	8bce                	mv	s7,s3
      state = 0;
 89a:	4981                	li	s3,0
 89c:	bd09                	j	6ae <vprintf+0x5a>
          s = "(null)";
 89e:	00000917          	auipc	s2,0x0
 8a2:	22a90913          	addi	s2,s2,554 # ac8 <malloc+0x11a>
        for(; *s; s++)
 8a6:	02800593          	li	a1,40
 8aa:	b7c5                	j	88a <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 8ac:	8bce                	mv	s7,s3
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	bbfd                	j	6ae <vprintf+0x5a>
    }
  }
}
 8b2:	70e6                	ld	ra,120(sp)
 8b4:	7446                	ld	s0,112(sp)
 8b6:	74a6                	ld	s1,104(sp)
 8b8:	7906                	ld	s2,96(sp)
 8ba:	69e6                	ld	s3,88(sp)
 8bc:	6a46                	ld	s4,80(sp)
 8be:	6aa6                	ld	s5,72(sp)
 8c0:	6b06                	ld	s6,64(sp)
 8c2:	7be2                	ld	s7,56(sp)
 8c4:	7c42                	ld	s8,48(sp)
 8c6:	7ca2                	ld	s9,40(sp)
 8c8:	7d02                	ld	s10,32(sp)
 8ca:	6de2                	ld	s11,24(sp)
 8cc:	6109                	addi	sp,sp,128
 8ce:	8082                	ret

00000000000008d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8d0:	715d                	addi	sp,sp,-80
 8d2:	ec06                	sd	ra,24(sp)
 8d4:	e822                	sd	s0,16(sp)
 8d6:	1000                	addi	s0,sp,32
 8d8:	e010                	sd	a2,0(s0)
 8da:	e414                	sd	a3,8(s0)
 8dc:	e818                	sd	a4,16(s0)
 8de:	ec1c                	sd	a5,24(s0)
 8e0:	03043023          	sd	a6,32(s0)
 8e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8ec:	8622                	mv	a2,s0
 8ee:	d67ff0ef          	jal	ra,654 <vprintf>
}
 8f2:	60e2                	ld	ra,24(sp)
 8f4:	6442                	ld	s0,16(sp)
 8f6:	6161                	addi	sp,sp,80
 8f8:	8082                	ret

00000000000008fa <printf>:

void
printf(const char *fmt, ...)
{
 8fa:	711d                	addi	sp,sp,-96
 8fc:	ec06                	sd	ra,24(sp)
 8fe:	e822                	sd	s0,16(sp)
 900:	1000                	addi	s0,sp,32
 902:	e40c                	sd	a1,8(s0)
 904:	e810                	sd	a2,16(s0)
 906:	ec14                	sd	a3,24(s0)
 908:	f018                	sd	a4,32(s0)
 90a:	f41c                	sd	a5,40(s0)
 90c:	03043823          	sd	a6,48(s0)
 910:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 914:	00840613          	addi	a2,s0,8
 918:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 91c:	85aa                	mv	a1,a0
 91e:	4505                	li	a0,1
 920:	d35ff0ef          	jal	ra,654 <vprintf>
}
 924:	60e2                	ld	ra,24(sp)
 926:	6442                	ld	s0,16(sp)
 928:	6125                	addi	sp,sp,96
 92a:	8082                	ret

000000000000092c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 92c:	1141                	addi	sp,sp,-16
 92e:	e422                	sd	s0,8(sp)
 930:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 932:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 936:	00000797          	auipc	a5,0x0
 93a:	6ca7b783          	ld	a5,1738(a5) # 1000 <freep>
 93e:	a02d                	j	968 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 940:	4618                	lw	a4,8(a2)
 942:	9f2d                	addw	a4,a4,a1
 944:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 948:	6398                	ld	a4,0(a5)
 94a:	6310                	ld	a2,0(a4)
 94c:	a83d                	j	98a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 94e:	ff852703          	lw	a4,-8(a0)
 952:	9f31                	addw	a4,a4,a2
 954:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 956:	ff053683          	ld	a3,-16(a0)
 95a:	a091                	j	99e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 95c:	6398                	ld	a4,0(a5)
 95e:	00e7e463          	bltu	a5,a4,966 <free+0x3a>
 962:	00e6ea63          	bltu	a3,a4,976 <free+0x4a>
{
 966:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 968:	fed7fae3          	bgeu	a5,a3,95c <free+0x30>
 96c:	6398                	ld	a4,0(a5)
 96e:	00e6e463          	bltu	a3,a4,976 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 972:	fee7eae3          	bltu	a5,a4,966 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 976:	ff852583          	lw	a1,-8(a0)
 97a:	6390                	ld	a2,0(a5)
 97c:	02059813          	slli	a6,a1,0x20
 980:	01c85713          	srli	a4,a6,0x1c
 984:	9736                	add	a4,a4,a3
 986:	fae60de3          	beq	a2,a4,940 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 98a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 98e:	4790                	lw	a2,8(a5)
 990:	02061593          	slli	a1,a2,0x20
 994:	01c5d713          	srli	a4,a1,0x1c
 998:	973e                	add	a4,a4,a5
 99a:	fae68ae3          	beq	a3,a4,94e <free+0x22>
    p->s.ptr = bp->s.ptr;
 99e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9a0:	00000717          	auipc	a4,0x0
 9a4:	66f73023          	sd	a5,1632(a4) # 1000 <freep>
}
 9a8:	6422                	ld	s0,8(sp)
 9aa:	0141                	addi	sp,sp,16
 9ac:	8082                	ret

00000000000009ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ae:	7139                	addi	sp,sp,-64
 9b0:	fc06                	sd	ra,56(sp)
 9b2:	f822                	sd	s0,48(sp)
 9b4:	f426                	sd	s1,40(sp)
 9b6:	f04a                	sd	s2,32(sp)
 9b8:	ec4e                	sd	s3,24(sp)
 9ba:	e852                	sd	s4,16(sp)
 9bc:	e456                	sd	s5,8(sp)
 9be:	e05a                	sd	s6,0(sp)
 9c0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c2:	02051493          	slli	s1,a0,0x20
 9c6:	9081                	srli	s1,s1,0x20
 9c8:	04bd                	addi	s1,s1,15
 9ca:	8091                	srli	s1,s1,0x4
 9cc:	0014899b          	addiw	s3,s1,1
 9d0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9d2:	00000517          	auipc	a0,0x0
 9d6:	62e53503          	ld	a0,1582(a0) # 1000 <freep>
 9da:	c515                	beqz	a0,a06 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9de:	4798                	lw	a4,8(a5)
 9e0:	02977f63          	bgeu	a4,s1,a1e <malloc+0x70>
 9e4:	8a4e                	mv	s4,s3
 9e6:	0009871b          	sext.w	a4,s3
 9ea:	6685                	lui	a3,0x1
 9ec:	00d77363          	bgeu	a4,a3,9f2 <malloc+0x44>
 9f0:	6a05                	lui	s4,0x1
 9f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9f6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9fa:	00000917          	auipc	s2,0x0
 9fe:	60690913          	addi	s2,s2,1542 # 1000 <freep>
  if(p == (char*)-1)
 a02:	5afd                	li	s5,-1
 a04:	a885                	j	a74 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 a06:	00001797          	auipc	a5,0x1
 a0a:	a0a78793          	addi	a5,a5,-1526 # 1410 <base>
 a0e:	00000717          	auipc	a4,0x0
 a12:	5ef73923          	sd	a5,1522(a4) # 1000 <freep>
 a16:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a18:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a1c:	b7e1                	j	9e4 <malloc+0x36>
      if(p->s.size == nunits)
 a1e:	02e48c63          	beq	s1,a4,a56 <malloc+0xa8>
        p->s.size -= nunits;
 a22:	4137073b          	subw	a4,a4,s3
 a26:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a28:	02071693          	slli	a3,a4,0x20
 a2c:	01c6d713          	srli	a4,a3,0x1c
 a30:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a32:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a36:	00000717          	auipc	a4,0x0
 a3a:	5ca73523          	sd	a0,1482(a4) # 1000 <freep>
      return (void*)(p + 1);
 a3e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a42:	70e2                	ld	ra,56(sp)
 a44:	7442                	ld	s0,48(sp)
 a46:	74a2                	ld	s1,40(sp)
 a48:	7902                	ld	s2,32(sp)
 a4a:	69e2                	ld	s3,24(sp)
 a4c:	6a42                	ld	s4,16(sp)
 a4e:	6aa2                	ld	s5,8(sp)
 a50:	6b02                	ld	s6,0(sp)
 a52:	6121                	addi	sp,sp,64
 a54:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a56:	6398                	ld	a4,0(a5)
 a58:	e118                	sd	a4,0(a0)
 a5a:	bff1                	j	a36 <malloc+0x88>
  hp->s.size = nu;
 a5c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a60:	0541                	addi	a0,a0,16
 a62:	ecbff0ef          	jal	ra,92c <free>
  return freep;
 a66:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a6a:	dd61                	beqz	a0,a42 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a6c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a6e:	4798                	lw	a4,8(a5)
 a70:	fa9777e3          	bgeu	a4,s1,a1e <malloc+0x70>
    if(p == freep)
 a74:	00093703          	ld	a4,0(s2)
 a78:	853e                	mv	a0,a5
 a7a:	fef719e3          	bne	a4,a5,a6c <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 a7e:	8552                	mv	a0,s4
 a80:	ac1ff0ef          	jal	ra,540 <sbrk>
  if(p == (char*)-1)
 a84:	fd551ce3          	bne	a0,s5,a5c <malloc+0xae>
        return 0;
 a88:	4501                	li	a0,0
 a8a:	bf65                	j	a42 <malloc+0x94>
