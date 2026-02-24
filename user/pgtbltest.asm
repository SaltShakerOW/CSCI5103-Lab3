
user/_pgtbltest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <err>:

char *testname = "???";

void
err(char *why)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84aa                	mv	s1,a0
  printf("pgtbltest: %s failed: %s, pid=%d\n", testname, why, getpid());
   e:	00001917          	auipc	s2,0x1
  12:	ff293903          	ld	s2,-14(s2) # 1000 <testname>
  16:	550000ef          	jal	ra,566 <getpid>
  1a:	86aa                	mv	a3,a0
  1c:	8626                	mv	a2,s1
  1e:	85ca                	mv	a1,s2
  20:	00001517          	auipc	a0,0x1
  24:	aa050513          	addi	a0,a0,-1376 # ac0 <malloc+0xe4>
  28:	101000ef          	jal	ra,928 <printf>
  exit(1);
  2c:	4505                	li	a0,1
  2e:	4b8000ef          	jal	ra,4e6 <exit>

0000000000000032 <print_pte>:
}

void
print_pte(uint64 va)
{
  32:	1101                	addi	sp,sp,-32
  34:	ec06                	sd	ra,24(sp)
  36:	e822                	sd	s0,16(sp)
  38:	e426                	sd	s1,8(sp)
  3a:	1000                	addi	s0,sp,32
  3c:	84aa                	mv	s1,a0
    pte_t pte = (pte_t) pgpte((void *) va);
  3e:	56a000ef          	jal	ra,5a8 <pgpte>
  42:	862a                	mv	a2,a0
    printf("va 0x%lx pte 0x%lx pa 0x%lx perm 0x%lx\n", va, pte, PTE2PA(pte), PTE_FLAGS(pte));
  44:	00a55693          	srli	a3,a0,0xa
  48:	3ff57713          	andi	a4,a0,1023
  4c:	06b2                	slli	a3,a3,0xc
  4e:	85a6                	mv	a1,s1
  50:	00001517          	auipc	a0,0x1
  54:	a9850513          	addi	a0,a0,-1384 # ae8 <malloc+0x10c>
  58:	0d1000ef          	jal	ra,928 <printf>
}
  5c:	60e2                	ld	ra,24(sp)
  5e:	6442                	ld	s0,16(sp)
  60:	64a2                	ld	s1,8(sp)
  62:	6105                	addi	sp,sp,32
  64:	8082                	ret

0000000000000066 <print_pgtbl>:

void
print_pgtbl()
{
  66:	7179                	addi	sp,sp,-48
  68:	f406                	sd	ra,40(sp)
  6a:	f022                	sd	s0,32(sp)
  6c:	ec26                	sd	s1,24(sp)
  6e:	e84a                	sd	s2,16(sp)
  70:	e44e                	sd	s3,8(sp)
  72:	1800                	addi	s0,sp,48
  printf("print_pgtbl starting\n");
  74:	00001517          	auipc	a0,0x1
  78:	a9c50513          	addi	a0,a0,-1380 # b10 <malloc+0x134>
  7c:	0ad000ef          	jal	ra,928 <printf>
  80:	4481                	li	s1,0
  for (uint64 i = 0; i < 10; i++) {
  82:	6985                	lui	s3,0x1
  84:	6929                	lui	s2,0xa
    print_pte(i * PGSIZE);
  86:	8526                	mv	a0,s1
  88:	fabff0ef          	jal	ra,32 <print_pte>
  for (uint64 i = 0; i < 10; i++) {
  8c:	94ce                	add	s1,s1,s3
  8e:	ff249ce3          	bne	s1,s2,86 <print_pgtbl+0x20>
  92:	020004b7          	lui	s1,0x2000
  96:	14ed                	addi	s1,s1,-5 # 1fffffb <base+0x1ffefdb>
  98:	04b6                	slli	s1,s1,0xd
  }
  uint64 top = MAXVA/PGSIZE;
  for (uint64 i = top-10; i < top; i++) {
  9a:	6985                	lui	s3,0x1
  9c:	4905                	li	s2,1
  9e:	191a                	slli	s2,s2,0x26
    print_pte(i * PGSIZE);
  a0:	8526                	mv	a0,s1
  a2:	f91ff0ef          	jal	ra,32 <print_pte>
  for (uint64 i = top-10; i < top; i++) {
  a6:	94ce                	add	s1,s1,s3
  a8:	ff249ce3          	bne	s1,s2,a0 <print_pgtbl+0x3a>
  }
  printf("print_pgtbl: OK\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	a7c50513          	addi	a0,a0,-1412 # b28 <malloc+0x14c>
  b4:	075000ef          	jal	ra,928 <printf>
}
  b8:	70a2                	ld	ra,40(sp)
  ba:	7402                	ld	s0,32(sp)
  bc:	64e2                	ld	s1,24(sp)
  be:	6942                	ld	s2,16(sp)
  c0:	69a2                	ld	s3,8(sp)
  c2:	6145                	addi	sp,sp,48
  c4:	8082                	ret

00000000000000c6 <print_kpgtbl>:

void
print_kpgtbl()
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e406                	sd	ra,8(sp)
  ca:	e022                	sd	s0,0(sp)
  cc:	0800                	addi	s0,sp,16
  printf("print_kpgtbl starting\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	a7250513          	addi	a0,a0,-1422 # b40 <malloc+0x164>
  d6:	053000ef          	jal	ra,928 <printf>
  kpgtbl();
  da:	4d8000ef          	jal	ra,5b2 <kpgtbl>
  printf("print_kpgtbl: OK\n");
  de:	00001517          	auipc	a0,0x1
  e2:	a7a50513          	addi	a0,a0,-1414 # b58 <malloc+0x17c>
  e6:	043000ef          	jal	ra,928 <printf>
}
  ea:	60a2                	ld	ra,8(sp)
  ec:	6402                	ld	s0,0(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <supercheck>:


void
supercheck(uint64 s)
{
  f2:	7139                	addi	sp,sp,-64
  f4:	fc06                	sd	ra,56(sp)
  f6:	f822                	sd	s0,48(sp)
  f8:	f426                	sd	s1,40(sp)
  fa:	f04a                	sd	s2,32(sp)
  fc:	ec4e                	sd	s3,24(sp)
  fe:	e852                	sd	s4,16(sp)
 100:	e456                	sd	s5,8(sp)
 102:	e05a                	sd	s6,0(sp)
 104:	0080                	addi	s0,sp,64
 106:	89aa                	mv	s3,a0
  pte_t last_pte = 0;

  for (uint64 p = s;  p < s + 512 * PGSIZE; p += PGSIZE) {
 108:	00200a37          	lui	s4,0x200
 10c:	9a2a                	add	s4,s4,a0
 10e:	05457963          	bgeu	a0,s4,160 <supercheck+0x6e>
 112:	84aa                	mv	s1,a0
  pte_t last_pte = 0;
 114:	4501                	li	a0,0
    if(pte == 0)
      err("no pte");
    if ((uint64) last_pte != 0 && pte != last_pte) {
        err("pte different");
    }
    if((pte & PTE_V) == 0 || (pte & PTE_R) == 0 || (pte & PTE_W) == 0){
 116:	4b1d                	li	s6,7
  for (uint64 p = s;  p < s + 512 * PGSIZE; p += PGSIZE) {
 118:	6a85                	lui	s5,0x1
 11a:	a831                	j	136 <supercheck+0x44>
      err("no pte");
 11c:	00001517          	auipc	a0,0x1
 120:	a5450513          	addi	a0,a0,-1452 # b70 <malloc+0x194>
 124:	eddff0ef          	jal	ra,0 <err>
    if((pte & PTE_V) == 0 || (pte & PTE_R) == 0 || (pte & PTE_W) == 0){
 128:	00757793          	andi	a5,a0,7
 12c:	03679463          	bne	a5,s6,154 <supercheck+0x62>
  for (uint64 p = s;  p < s + 512 * PGSIZE; p += PGSIZE) {
 130:	94d6                	add	s1,s1,s5
 132:	0344f763          	bgeu	s1,s4,160 <supercheck+0x6e>
    pte_t pte = (pte_t) pgpte((void *) p);
 136:	892a                	mv	s2,a0
 138:	8526                	mv	a0,s1
 13a:	46e000ef          	jal	ra,5a8 <pgpte>
    if(pte == 0)
 13e:	dd79                	beqz	a0,11c <supercheck+0x2a>
    if ((uint64) last_pte != 0 && pte != last_pte) {
 140:	fe0904e3          	beqz	s2,128 <supercheck+0x36>
 144:	ff2502e3          	beq	a0,s2,128 <supercheck+0x36>
        err("pte different");
 148:	00001517          	auipc	a0,0x1
 14c:	a3050513          	addi	a0,a0,-1488 # b78 <malloc+0x19c>
 150:	eb1ff0ef          	jal	ra,0 <err>
      err("pte wrong");
 154:	00001517          	auipc	a0,0x1
 158:	a3450513          	addi	a0,a0,-1484 # b88 <malloc+0x1ac>
 15c:	ea5ff0ef          	jal	ra,0 <err>
  pte_t last_pte = 0;
 160:	4781                	li	a5,0
    }
    last_pte = pte;
  }

  for(int i = 0; i < 512 * PGSIZE; i += PGSIZE){
 162:	6605                	lui	a2,0x1
 164:	002006b7          	lui	a3,0x200
    *(int*)(s+i) = i;
 168:	01378733          	add	a4,a5,s3
 16c:	c31c                	sw	a5,0(a4)
  for(int i = 0; i < 512 * PGSIZE; i += PGSIZE){
 16e:	97b2                	add	a5,a5,a2
 170:	fed79ce3          	bne	a5,a3,168 <supercheck+0x76>
 174:	4781                	li	a5,0
  }

  for(int i = 0; i < 512 * PGSIZE; i += PGSIZE){
 176:	6585                	lui	a1,0x1
 178:	00200637          	lui	a2,0x200
    if(*(int*)(s+i) != i)
 17c:	00f98733          	add	a4,s3,a5
 180:	4314                	lw	a3,0(a4)
 182:	0007871b          	sext.w	a4,a5
 186:	00e69f63          	bne	a3,a4,1a4 <supercheck+0xb2>
  for(int i = 0; i < 512 * PGSIZE; i += PGSIZE){
 18a:	97ae                	add	a5,a5,a1
 18c:	fec798e3          	bne	a5,a2,17c <supercheck+0x8a>
      err("wrong value");
  }
}
 190:	70e2                	ld	ra,56(sp)
 192:	7442                	ld	s0,48(sp)
 194:	74a2                	ld	s1,40(sp)
 196:	7902                	ld	s2,32(sp)
 198:	69e2                	ld	s3,24(sp)
 19a:	6a42                	ld	s4,16(sp)
 19c:	6aa2                	ld	s5,8(sp)
 19e:	6b02                	ld	s6,0(sp)
 1a0:	6121                	addi	sp,sp,64
 1a2:	8082                	ret
      err("wrong value");
 1a4:	00001517          	auipc	a0,0x1
 1a8:	9f450513          	addi	a0,a0,-1548 # b98 <malloc+0x1bc>
 1ac:	e55ff0ef          	jal	ra,0 <err>

00000000000001b0 <superpg_test>:

void
superpg_test()
{
 1b0:	7179                	addi	sp,sp,-48
 1b2:	f406                	sd	ra,40(sp)
 1b4:	f022                	sd	s0,32(sp)
 1b6:	ec26                	sd	s1,24(sp)
 1b8:	1800                	addi	s0,sp,48
  int pid;

  printf("superpg_test starting\n");
 1ba:	00001517          	auipc	a0,0x1
 1be:	9ee50513          	addi	a0,a0,-1554 # ba8 <malloc+0x1cc>
 1c2:	766000ef          	jal	ra,928 <printf>
  testname = "superpg_test";
 1c6:	00001797          	auipc	a5,0x1
 1ca:	9fa78793          	addi	a5,a5,-1542 # bc0 <malloc+0x1e4>
 1ce:	00001717          	auipc	a4,0x1
 1d2:	e2f73923          	sd	a5,-462(a4) # 1000 <testname>

  char *end = sbrk(N);
 1d6:	00800537          	lui	a0,0x800
 1da:	394000ef          	jal	ra,56e <sbrk>
  if (end == 0 || end == (char*)0xffffffffffffffff)
 1de:	fff50713          	addi	a4,a0,-1 # 7fffff <base+0x7fefdf>
 1e2:	57f5                	li	a5,-3
 1e4:	04e7e463          	bltu	a5,a4,22c <superpg_test+0x7c>
    err("sbrk failed");

  uint64 s = SUPERPGROUNDUP((uint64) end);
 1e8:	002007b7          	lui	a5,0x200
 1ec:	17fd                	addi	a5,a5,-1 # 1fffff <base+0x1fefdf>
 1ee:	953e                	add	a0,a0,a5
 1f0:	ffe007b7          	lui	a5,0xffe00
 1f4:	00f574b3          	and	s1,a0,a5
  supercheck(s);
 1f8:	8526                	mv	a0,s1
 1fa:	ef9ff0ef          	jal	ra,f2 <supercheck>
  if((pid = fork()) < 0) {
 1fe:	2e0000ef          	jal	ra,4de <fork>
 202:	02054b63          	bltz	a0,238 <superpg_test+0x88>
    err("fork");
  } else if(pid == 0) {
 206:	cd1d                	beqz	a0,244 <superpg_test+0x94>
    supercheck(s);
    exit(0);
  } else {
    int status;
    wait(&status);
 208:	fdc40513          	addi	a0,s0,-36
 20c:	2e2000ef          	jal	ra,4ee <wait>
    if (status != 0) {
 210:	fdc42783          	lw	a5,-36(s0)
 214:	ef95                	bnez	a5,250 <superpg_test+0xa0>
      exit(0);
    }
  }
  printf("superpg_test: OK\n");
 216:	00001517          	auipc	a0,0x1
 21a:	9d250513          	addi	a0,a0,-1582 # be8 <malloc+0x20c>
 21e:	70a000ef          	jal	ra,928 <printf>
}
 222:	70a2                	ld	ra,40(sp)
 224:	7402                	ld	s0,32(sp)
 226:	64e2                	ld	s1,24(sp)
 228:	6145                	addi	sp,sp,48
 22a:	8082                	ret
    err("sbrk failed");
 22c:	00001517          	auipc	a0,0x1
 230:	9a450513          	addi	a0,a0,-1628 # bd0 <malloc+0x1f4>
 234:	dcdff0ef          	jal	ra,0 <err>
    err("fork");
 238:	00001517          	auipc	a0,0x1
 23c:	9a850513          	addi	a0,a0,-1624 # be0 <malloc+0x204>
 240:	dc1ff0ef          	jal	ra,0 <err>
    supercheck(s);
 244:	8526                	mv	a0,s1
 246:	eadff0ef          	jal	ra,f2 <supercheck>
    exit(0);
 24a:	4501                	li	a0,0
 24c:	29a000ef          	jal	ra,4e6 <exit>
      exit(0);
 250:	4501                	li	a0,0
 252:	294000ef          	jal	ra,4e6 <exit>

0000000000000256 <main>:
{
 256:	1141                	addi	sp,sp,-16
 258:	e406                	sd	ra,8(sp)
 25a:	e022                	sd	s0,0(sp)
 25c:	0800                	addi	s0,sp,16
  print_pgtbl();
 25e:	e09ff0ef          	jal	ra,66 <print_pgtbl>
  print_kpgtbl();
 262:	e65ff0ef          	jal	ra,c6 <print_kpgtbl>
  superpg_test();
 266:	f4bff0ef          	jal	ra,1b0 <superpg_test>
  printf("pgtbltest: all tests succeeded\n");
 26a:	00001517          	auipc	a0,0x1
 26e:	99650513          	addi	a0,a0,-1642 # c00 <malloc+0x224>
 272:	6b6000ef          	jal	ra,928 <printf>
  exit(0);
 276:	4501                	li	a0,0
 278:	26e000ef          	jal	ra,4e6 <exit>

000000000000027c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e406                	sd	ra,8(sp)
 280:	e022                	sd	s0,0(sp)
 282:	0800                	addi	s0,sp,16
  extern int main();
  main();
 284:	fd3ff0ef          	jal	ra,256 <main>
  exit(0);
 288:	4501                	li	a0,0
 28a:	25c000ef          	jal	ra,4e6 <exit>

000000000000028e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 294:	87aa                	mv	a5,a0
 296:	0585                	addi	a1,a1,1 # 1001 <testname+0x1>
 298:	0785                	addi	a5,a5,1 # ffffffffffe00001 <base+0xffffffffffdfefe1>
 29a:	fff5c703          	lbu	a4,-1(a1)
 29e:	fee78fa3          	sb	a4,-1(a5)
 2a2:	fb75                	bnez	a4,296 <strcpy+0x8>
    ;
  return os;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	cb91                	beqz	a5,2c8 <strcmp+0x1e>
 2b6:	0005c703          	lbu	a4,0(a1)
 2ba:	00f71763          	bne	a4,a5,2c8 <strcmp+0x1e>
    p++, q++;
 2be:	0505                	addi	a0,a0,1
 2c0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2c2:	00054783          	lbu	a5,0(a0)
 2c6:	fbe5                	bnez	a5,2b6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2c8:	0005c503          	lbu	a0,0(a1)
}
 2cc:	40a7853b          	subw	a0,a5,a0
 2d0:	6422                	ld	s0,8(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret

00000000000002d6 <strlen>:

uint
strlen(const char *s)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2dc:	00054783          	lbu	a5,0(a0)
 2e0:	cf91                	beqz	a5,2fc <strlen+0x26>
 2e2:	0505                	addi	a0,a0,1
 2e4:	87aa                	mv	a5,a0
 2e6:	4685                	li	a3,1
 2e8:	9e89                	subw	a3,a3,a0
 2ea:	00f6853b          	addw	a0,a3,a5
 2ee:	0785                	addi	a5,a5,1
 2f0:	fff7c703          	lbu	a4,-1(a5)
 2f4:	fb7d                	bnez	a4,2ea <strlen+0x14>
    ;
  return n;
}
 2f6:	6422                	ld	s0,8(sp)
 2f8:	0141                	addi	sp,sp,16
 2fa:	8082                	ret
  for(n = 0; s[n]; n++)
 2fc:	4501                	li	a0,0
 2fe:	bfe5                	j	2f6 <strlen+0x20>

0000000000000300 <memset>:

void*
memset(void *dst, int c, uint n)
{
 300:	1141                	addi	sp,sp,-16
 302:	e422                	sd	s0,8(sp)
 304:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 306:	ca19                	beqz	a2,31c <memset+0x1c>
 308:	87aa                	mv	a5,a0
 30a:	1602                	slli	a2,a2,0x20
 30c:	9201                	srli	a2,a2,0x20
 30e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 312:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 316:	0785                	addi	a5,a5,1
 318:	fee79de3          	bne	a5,a4,312 <memset+0x12>
  }
  return dst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret

0000000000000322 <strchr>:

char*
strchr(const char *s, char c)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  for(; *s; s++)
 328:	00054783          	lbu	a5,0(a0)
 32c:	cb99                	beqz	a5,342 <strchr+0x20>
    if(*s == c)
 32e:	00f58763          	beq	a1,a5,33c <strchr+0x1a>
  for(; *s; s++)
 332:	0505                	addi	a0,a0,1
 334:	00054783          	lbu	a5,0(a0)
 338:	fbfd                	bnez	a5,32e <strchr+0xc>
      return (char*)s;
  return 0;
 33a:	4501                	li	a0,0
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  return 0;
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <strchr+0x1a>

0000000000000346 <gets>:

char*
gets(char *buf, int max)
{
 346:	711d                	addi	sp,sp,-96
 348:	ec86                	sd	ra,88(sp)
 34a:	e8a2                	sd	s0,80(sp)
 34c:	e4a6                	sd	s1,72(sp)
 34e:	e0ca                	sd	s2,64(sp)
 350:	fc4e                	sd	s3,56(sp)
 352:	f852                	sd	s4,48(sp)
 354:	f456                	sd	s5,40(sp)
 356:	f05a                	sd	s6,32(sp)
 358:	ec5e                	sd	s7,24(sp)
 35a:	1080                	addi	s0,sp,96
 35c:	8baa                	mv	s7,a0
 35e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 360:	892a                	mv	s2,a0
 362:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 364:	4aa9                	li	s5,10
 366:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 368:	89a6                	mv	s3,s1
 36a:	2485                	addiw	s1,s1,1
 36c:	0344d663          	bge	s1,s4,398 <gets+0x52>
    cc = read(0, &c, 1);
 370:	4605                	li	a2,1
 372:	faf40593          	addi	a1,s0,-81
 376:	4501                	li	a0,0
 378:	186000ef          	jal	ra,4fe <read>
    if(cc < 1)
 37c:	00a05e63          	blez	a0,398 <gets+0x52>
    buf[i++] = c;
 380:	faf44783          	lbu	a5,-81(s0)
 384:	00f90023          	sb	a5,0(s2) # a000 <base+0x8fe0>
    if(c == '\n' || c == '\r')
 388:	01578763          	beq	a5,s5,396 <gets+0x50>
 38c:	0905                	addi	s2,s2,1
 38e:	fd679de3          	bne	a5,s6,368 <gets+0x22>
  for(i=0; i+1 < max; ){
 392:	89a6                	mv	s3,s1
 394:	a011                	j	398 <gets+0x52>
 396:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 398:	99de                	add	s3,s3,s7
 39a:	00098023          	sb	zero,0(s3) # 1000 <testname>
  return buf;
}
 39e:	855e                	mv	a0,s7
 3a0:	60e6                	ld	ra,88(sp)
 3a2:	6446                	ld	s0,80(sp)
 3a4:	64a6                	ld	s1,72(sp)
 3a6:	6906                	ld	s2,64(sp)
 3a8:	79e2                	ld	s3,56(sp)
 3aa:	7a42                	ld	s4,48(sp)
 3ac:	7aa2                	ld	s5,40(sp)
 3ae:	7b02                	ld	s6,32(sp)
 3b0:	6be2                	ld	s7,24(sp)
 3b2:	6125                	addi	sp,sp,96
 3b4:	8082                	ret

00000000000003b6 <stat>:

int
stat(const char *n, struct stat *st)
{
 3b6:	1101                	addi	sp,sp,-32
 3b8:	ec06                	sd	ra,24(sp)
 3ba:	e822                	sd	s0,16(sp)
 3bc:	e426                	sd	s1,8(sp)
 3be:	e04a                	sd	s2,0(sp)
 3c0:	1000                	addi	s0,sp,32
 3c2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c4:	4581                	li	a1,0
 3c6:	160000ef          	jal	ra,526 <open>
  if(fd < 0)
 3ca:	02054163          	bltz	a0,3ec <stat+0x36>
 3ce:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3d0:	85ca                	mv	a1,s2
 3d2:	16c000ef          	jal	ra,53e <fstat>
 3d6:	892a                	mv	s2,a0
  close(fd);
 3d8:	8526                	mv	a0,s1
 3da:	134000ef          	jal	ra,50e <close>
  return r;
}
 3de:	854a                	mv	a0,s2
 3e0:	60e2                	ld	ra,24(sp)
 3e2:	6442                	ld	s0,16(sp)
 3e4:	64a2                	ld	s1,8(sp)
 3e6:	6902                	ld	s2,0(sp)
 3e8:	6105                	addi	sp,sp,32
 3ea:	8082                	ret
    return -1;
 3ec:	597d                	li	s2,-1
 3ee:	bfc5                	j	3de <stat+0x28>

00000000000003f0 <atoi>:

int
atoi(const char *s)
{
 3f0:	1141                	addi	sp,sp,-16
 3f2:	e422                	sd	s0,8(sp)
 3f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f6:	00054683          	lbu	a3,0(a0)
 3fa:	fd06879b          	addiw	a5,a3,-48 # 1fffd0 <base+0x1fefb0>
 3fe:	0ff7f793          	zext.b	a5,a5
 402:	4625                	li	a2,9
 404:	02f66863          	bltu	a2,a5,434 <atoi+0x44>
 408:	872a                	mv	a4,a0
  n = 0;
 40a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 40c:	0705                	addi	a4,a4,1
 40e:	0025179b          	slliw	a5,a0,0x2
 412:	9fa9                	addw	a5,a5,a0
 414:	0017979b          	slliw	a5,a5,0x1
 418:	9fb5                	addw	a5,a5,a3
 41a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 41e:	00074683          	lbu	a3,0(a4)
 422:	fd06879b          	addiw	a5,a3,-48
 426:	0ff7f793          	zext.b	a5,a5
 42a:	fef671e3          	bgeu	a2,a5,40c <atoi+0x1c>
  return n;
}
 42e:	6422                	ld	s0,8(sp)
 430:	0141                	addi	sp,sp,16
 432:	8082                	ret
  n = 0;
 434:	4501                	li	a0,0
 436:	bfe5                	j	42e <atoi+0x3e>

0000000000000438 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 438:	1141                	addi	sp,sp,-16
 43a:	e422                	sd	s0,8(sp)
 43c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 43e:	02b57463          	bgeu	a0,a1,466 <memmove+0x2e>
    while(n-- > 0)
 442:	00c05f63          	blez	a2,460 <memmove+0x28>
 446:	1602                	slli	a2,a2,0x20
 448:	9201                	srli	a2,a2,0x20
 44a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 44e:	872a                	mv	a4,a0
      *dst++ = *src++;
 450:	0585                	addi	a1,a1,1
 452:	0705                	addi	a4,a4,1
 454:	fff5c683          	lbu	a3,-1(a1)
 458:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 45c:	fee79ae3          	bne	a5,a4,450 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 460:	6422                	ld	s0,8(sp)
 462:	0141                	addi	sp,sp,16
 464:	8082                	ret
    dst += n;
 466:	00c50733          	add	a4,a0,a2
    src += n;
 46a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 46c:	fec05ae3          	blez	a2,460 <memmove+0x28>
 470:	fff6079b          	addiw	a5,a2,-1 # 1fffff <base+0x1fefdf>
 474:	1782                	slli	a5,a5,0x20
 476:	9381                	srli	a5,a5,0x20
 478:	fff7c793          	not	a5,a5
 47c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 47e:	15fd                	addi	a1,a1,-1
 480:	177d                	addi	a4,a4,-1
 482:	0005c683          	lbu	a3,0(a1)
 486:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 48a:	fee79ae3          	bne	a5,a4,47e <memmove+0x46>
 48e:	bfc9                	j	460 <memmove+0x28>

0000000000000490 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 490:	1141                	addi	sp,sp,-16
 492:	e422                	sd	s0,8(sp)
 494:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 496:	ca05                	beqz	a2,4c6 <memcmp+0x36>
 498:	fff6069b          	addiw	a3,a2,-1
 49c:	1682                	slli	a3,a3,0x20
 49e:	9281                	srli	a3,a3,0x20
 4a0:	0685                	addi	a3,a3,1
 4a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4a4:	00054783          	lbu	a5,0(a0)
 4a8:	0005c703          	lbu	a4,0(a1)
 4ac:	00e79863          	bne	a5,a4,4bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4b0:	0505                	addi	a0,a0,1
    p2++;
 4b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4b4:	fed518e3          	bne	a0,a3,4a4 <memcmp+0x14>
  }
  return 0;
 4b8:	4501                	li	a0,0
 4ba:	a019                	j	4c0 <memcmp+0x30>
      return *p1 - *p2;
 4bc:	40e7853b          	subw	a0,a5,a4
}
 4c0:	6422                	ld	s0,8(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret
  return 0;
 4c6:	4501                	li	a0,0
 4c8:	bfe5                	j	4c0 <memcmp+0x30>

00000000000004ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ca:	1141                	addi	sp,sp,-16
 4cc:	e406                	sd	ra,8(sp)
 4ce:	e022                	sd	s0,0(sp)
 4d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4d2:	f67ff0ef          	jal	ra,438 <memmove>
}
 4d6:	60a2                	ld	ra,8(sp)
 4d8:	6402                	ld	s0,0(sp)
 4da:	0141                	addi	sp,sp,16
 4dc:	8082                	ret

00000000000004de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4de:	4885                	li	a7,1
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4e6:	4889                	li	a7,2
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ee:	488d                	li	a7,3
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4f6:	4891                	li	a7,4
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <read>:
.global read
read:
 li a7, SYS_read
 4fe:	4895                	li	a7,5
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <write>:
.global write
write:
 li a7, SYS_write
 506:	48c1                	li	a7,16
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <close>:
.global close
close:
 li a7, SYS_close
 50e:	48d5                	li	a7,21
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <kill>:
.global kill
kill:
 li a7, SYS_kill
 516:	4899                	li	a7,6
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <exec>:
.global exec
exec:
 li a7, SYS_exec
 51e:	489d                	li	a7,7
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <open>:
.global open
open:
 li a7, SYS_open
 526:	48bd                	li	a7,15
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 52e:	48c5                	li	a7,17
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 536:	48c9                	li	a7,18
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 53e:	48a1                	li	a7,8
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <link>:
.global link
link:
 li a7, SYS_link
 546:	48cd                	li	a7,19
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 54e:	48d1                	li	a7,20
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 556:	48a5                	li	a7,9
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <dup>:
.global dup
dup:
 li a7, SYS_dup
 55e:	48a9                	li	a7,10
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 566:	48ad                	li	a7,11
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 56e:	48b1                	li	a7,12
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 576:	48b5                	li	a7,13
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 57e:	48b9                	li	a7,14
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <bind>:
.global bind
bind:
 li a7, SYS_bind
 586:	48f5                	li	a7,29
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <unbind>:
.global unbind
unbind:
 li a7, SYS_unbind
 58e:	48f9                	li	a7,30
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <send>:
.global send
send:
 li a7, SYS_send
 596:	48fd                	li	a7,31
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <recv>:
.global recv
recv:
 li a7, SYS_recv
 59e:	02000893          	li	a7,32
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <pgpte>:
.global pgpte
pgpte:
 li a7, SYS_pgpte
 5a8:	02100893          	li	a7,33
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <kpgtbl>:
.global kpgtbl
kpgtbl:
 li a7, SYS_kpgtbl
 5b2:	02200893          	li	a7,34
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5bc:	1101                	addi	sp,sp,-32
 5be:	ec06                	sd	ra,24(sp)
 5c0:	e822                	sd	s0,16(sp)
 5c2:	1000                	addi	s0,sp,32
 5c4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5c8:	4605                	li	a2,1
 5ca:	fef40593          	addi	a1,s0,-17
 5ce:	f39ff0ef          	jal	ra,506 <write>
}
 5d2:	60e2                	ld	ra,24(sp)
 5d4:	6442                	ld	s0,16(sp)
 5d6:	6105                	addi	sp,sp,32
 5d8:	8082                	ret

00000000000005da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5da:	7139                	addi	sp,sp,-64
 5dc:	fc06                	sd	ra,56(sp)
 5de:	f822                	sd	s0,48(sp)
 5e0:	f426                	sd	s1,40(sp)
 5e2:	f04a                	sd	s2,32(sp)
 5e4:	ec4e                	sd	s3,24(sp)
 5e6:	0080                	addi	s0,sp,64
 5e8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5ea:	c299                	beqz	a3,5f0 <printint+0x16>
 5ec:	0805c763          	bltz	a1,67a <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5f0:	2581                	sext.w	a1,a1
  neg = 0;
 5f2:	4881                	li	a7,0
 5f4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5f8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5fa:	2601                	sext.w	a2,a2
 5fc:	00000517          	auipc	a0,0x0
 600:	63450513          	addi	a0,a0,1588 # c30 <digits>
 604:	883a                	mv	a6,a4
 606:	2705                	addiw	a4,a4,1
 608:	02c5f7bb          	remuw	a5,a1,a2
 60c:	1782                	slli	a5,a5,0x20
 60e:	9381                	srli	a5,a5,0x20
 610:	97aa                	add	a5,a5,a0
 612:	0007c783          	lbu	a5,0(a5)
 616:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 61a:	0005879b          	sext.w	a5,a1
 61e:	02c5d5bb          	divuw	a1,a1,a2
 622:	0685                	addi	a3,a3,1
 624:	fec7f0e3          	bgeu	a5,a2,604 <printint+0x2a>
  if(neg)
 628:	00088c63          	beqz	a7,640 <printint+0x66>
    buf[i++] = '-';
 62c:	fd070793          	addi	a5,a4,-48
 630:	00878733          	add	a4,a5,s0
 634:	02d00793          	li	a5,45
 638:	fef70823          	sb	a5,-16(a4)
 63c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 640:	02e05663          	blez	a4,66c <printint+0x92>
 644:	fc040793          	addi	a5,s0,-64
 648:	00e78933          	add	s2,a5,a4
 64c:	fff78993          	addi	s3,a5,-1
 650:	99ba                	add	s3,s3,a4
 652:	377d                	addiw	a4,a4,-1
 654:	1702                	slli	a4,a4,0x20
 656:	9301                	srli	a4,a4,0x20
 658:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 65c:	fff94583          	lbu	a1,-1(s2)
 660:	8526                	mv	a0,s1
 662:	f5bff0ef          	jal	ra,5bc <putc>
  while(--i >= 0)
 666:	197d                	addi	s2,s2,-1
 668:	ff391ae3          	bne	s2,s3,65c <printint+0x82>
}
 66c:	70e2                	ld	ra,56(sp)
 66e:	7442                	ld	s0,48(sp)
 670:	74a2                	ld	s1,40(sp)
 672:	7902                	ld	s2,32(sp)
 674:	69e2                	ld	s3,24(sp)
 676:	6121                	addi	sp,sp,64
 678:	8082                	ret
    x = -xx;
 67a:	40b005bb          	negw	a1,a1
    neg = 1;
 67e:	4885                	li	a7,1
    x = -xx;
 680:	bf95                	j	5f4 <printint+0x1a>

0000000000000682 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 682:	7119                	addi	sp,sp,-128
 684:	fc86                	sd	ra,120(sp)
 686:	f8a2                	sd	s0,112(sp)
 688:	f4a6                	sd	s1,104(sp)
 68a:	f0ca                	sd	s2,96(sp)
 68c:	ecce                	sd	s3,88(sp)
 68e:	e8d2                	sd	s4,80(sp)
 690:	e4d6                	sd	s5,72(sp)
 692:	e0da                	sd	s6,64(sp)
 694:	fc5e                	sd	s7,56(sp)
 696:	f862                	sd	s8,48(sp)
 698:	f466                	sd	s9,40(sp)
 69a:	f06a                	sd	s10,32(sp)
 69c:	ec6e                	sd	s11,24(sp)
 69e:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6a0:	0005c903          	lbu	s2,0(a1)
 6a4:	22090e63          	beqz	s2,8e0 <vprintf+0x25e>
 6a8:	8b2a                	mv	s6,a0
 6aa:	8a2e                	mv	s4,a1
 6ac:	8bb2                	mv	s7,a2
  state = 0;
 6ae:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6b0:	4481                	li	s1,0
 6b2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6b4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6b8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6bc:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6c0:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c4:	00000c97          	auipc	s9,0x0
 6c8:	56cc8c93          	addi	s9,s9,1388 # c30 <digits>
 6cc:	a005                	j	6ec <vprintf+0x6a>
        putc(fd, c0);
 6ce:	85ca                	mv	a1,s2
 6d0:	855a                	mv	a0,s6
 6d2:	eebff0ef          	jal	ra,5bc <putc>
 6d6:	a019                	j	6dc <vprintf+0x5a>
    } else if(state == '%'){
 6d8:	03598263          	beq	s3,s5,6fc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6dc:	2485                	addiw	s1,s1,1
 6de:	8726                	mv	a4,s1
 6e0:	009a07b3          	add	a5,s4,s1
 6e4:	0007c903          	lbu	s2,0(a5)
 6e8:	1e090c63          	beqz	s2,8e0 <vprintf+0x25e>
    c0 = fmt[i] & 0xff;
 6ec:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6f0:	fe0994e3          	bnez	s3,6d8 <vprintf+0x56>
      if(c0 == '%'){
 6f4:	fd579de3          	bne	a5,s5,6ce <vprintf+0x4c>
        state = '%';
 6f8:	89be                	mv	s3,a5
 6fa:	b7cd                	j	6dc <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6fc:	cfa5                	beqz	a5,774 <vprintf+0xf2>
 6fe:	00ea06b3          	add	a3,s4,a4
 702:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 706:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 708:	c681                	beqz	a3,710 <vprintf+0x8e>
 70a:	9752                	add	a4,a4,s4
 70c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 710:	03878a63          	beq	a5,s8,744 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 714:	05a78463          	beq	a5,s10,75c <vprintf+0xda>
      } else if(c0 == 'u'){
 718:	0db78763          	beq	a5,s11,7e6 <vprintf+0x164>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 71c:	07800713          	li	a4,120
 720:	10e78963          	beq	a5,a4,832 <vprintf+0x1b0>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 724:	07000713          	li	a4,112
 728:	12e78e63          	beq	a5,a4,864 <vprintf+0x1e2>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 72c:	07300713          	li	a4,115
 730:	16e78b63          	beq	a5,a4,8a6 <vprintf+0x224>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 734:	05579063          	bne	a5,s5,774 <vprintf+0xf2>
        putc(fd, '%');
 738:	85d6                	mv	a1,s5
 73a:	855a                	mv	a0,s6
 73c:	e81ff0ef          	jal	ra,5bc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 740:	4981                	li	s3,0
 742:	bf69                	j	6dc <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 744:	008b8913          	addi	s2,s7,8
 748:	4685                	li	a3,1
 74a:	4629                	li	a2,10
 74c:	000ba583          	lw	a1,0(s7)
 750:	855a                	mv	a0,s6
 752:	e89ff0ef          	jal	ra,5da <printint>
 756:	8bca                	mv	s7,s2
      state = 0;
 758:	4981                	li	s3,0
 75a:	b749                	j	6dc <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 75c:	03868663          	beq	a3,s8,788 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 760:	05a68163          	beq	a3,s10,7a2 <vprintf+0x120>
      } else if(c0 == 'l' && c1 == 'u'){
 764:	09b68d63          	beq	a3,s11,7fe <vprintf+0x17c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 768:	03a68f63          	beq	a3,s10,7a6 <vprintf+0x124>
      } else if(c0 == 'l' && c1 == 'x'){
 76c:	07800793          	li	a5,120
 770:	0cf68d63          	beq	a3,a5,84a <vprintf+0x1c8>
        putc(fd, '%');
 774:	85d6                	mv	a1,s5
 776:	855a                	mv	a0,s6
 778:	e45ff0ef          	jal	ra,5bc <putc>
        putc(fd, c0);
 77c:	85ca                	mv	a1,s2
 77e:	855a                	mv	a0,s6
 780:	e3dff0ef          	jal	ra,5bc <putc>
      state = 0;
 784:	4981                	li	s3,0
 786:	bf99                	j	6dc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 788:	008b8913          	addi	s2,s7,8
 78c:	4685                	li	a3,1
 78e:	4629                	li	a2,10
 790:	000ba583          	lw	a1,0(s7)
 794:	855a                	mv	a0,s6
 796:	e45ff0ef          	jal	ra,5da <printint>
        i += 1;
 79a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 79c:	8bca                	mv	s7,s2
      state = 0;
 79e:	4981                	li	s3,0
        i += 1;
 7a0:	bf35                	j	6dc <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7a2:	03860563          	beq	a2,s8,7cc <vprintf+0x14a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7a6:	07b60963          	beq	a2,s11,818 <vprintf+0x196>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7aa:	07800793          	li	a5,120
 7ae:	fcf613e3          	bne	a2,a5,774 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b2:	008b8913          	addi	s2,s7,8
 7b6:	4681                	li	a3,0
 7b8:	4641                	li	a2,16
 7ba:	000ba583          	lw	a1,0(s7)
 7be:	855a                	mv	a0,s6
 7c0:	e1bff0ef          	jal	ra,5da <printint>
        i += 2;
 7c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c6:	8bca                	mv	s7,s2
      state = 0;
 7c8:	4981                	li	s3,0
        i += 2;
 7ca:	bf09                	j	6dc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7cc:	008b8913          	addi	s2,s7,8
 7d0:	4685                	li	a3,1
 7d2:	4629                	li	a2,10
 7d4:	000ba583          	lw	a1,0(s7)
 7d8:	855a                	mv	a0,s6
 7da:	e01ff0ef          	jal	ra,5da <printint>
        i += 2;
 7de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7e0:	8bca                	mv	s7,s2
      state = 0;
 7e2:	4981                	li	s3,0
        i += 2;
 7e4:	bde5                	j	6dc <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 0);
 7e6:	008b8913          	addi	s2,s7,8
 7ea:	4681                	li	a3,0
 7ec:	4629                	li	a2,10
 7ee:	000ba583          	lw	a1,0(s7)
 7f2:	855a                	mv	a0,s6
 7f4:	de7ff0ef          	jal	ra,5da <printint>
 7f8:	8bca                	mv	s7,s2
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b5c5                	j	6dc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7fe:	008b8913          	addi	s2,s7,8
 802:	4681                	li	a3,0
 804:	4629                	li	a2,10
 806:	000ba583          	lw	a1,0(s7)
 80a:	855a                	mv	a0,s6
 80c:	dcfff0ef          	jal	ra,5da <printint>
        i += 1;
 810:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 812:	8bca                	mv	s7,s2
      state = 0;
 814:	4981                	li	s3,0
        i += 1;
 816:	b5d9                	j	6dc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 818:	008b8913          	addi	s2,s7,8
 81c:	4681                	li	a3,0
 81e:	4629                	li	a2,10
 820:	000ba583          	lw	a1,0(s7)
 824:	855a                	mv	a0,s6
 826:	db5ff0ef          	jal	ra,5da <printint>
        i += 2;
 82a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 82c:	8bca                	mv	s7,s2
      state = 0;
 82e:	4981                	li	s3,0
        i += 2;
 830:	b575                	j	6dc <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 16, 0);
 832:	008b8913          	addi	s2,s7,8
 836:	4681                	li	a3,0
 838:	4641                	li	a2,16
 83a:	000ba583          	lw	a1,0(s7)
 83e:	855a                	mv	a0,s6
 840:	d9bff0ef          	jal	ra,5da <printint>
 844:	8bca                	mv	s7,s2
      state = 0;
 846:	4981                	li	s3,0
 848:	bd51                	j	6dc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 84a:	008b8913          	addi	s2,s7,8
 84e:	4681                	li	a3,0
 850:	4641                	li	a2,16
 852:	000ba583          	lw	a1,0(s7)
 856:	855a                	mv	a0,s6
 858:	d83ff0ef          	jal	ra,5da <printint>
        i += 1;
 85c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 85e:	8bca                	mv	s7,s2
      state = 0;
 860:	4981                	li	s3,0
        i += 1;
 862:	bdad                	j	6dc <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 864:	008b8793          	addi	a5,s7,8
 868:	f8f43423          	sd	a5,-120(s0)
 86c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 870:	03000593          	li	a1,48
 874:	855a                	mv	a0,s6
 876:	d47ff0ef          	jal	ra,5bc <putc>
  putc(fd, 'x');
 87a:	07800593          	li	a1,120
 87e:	855a                	mv	a0,s6
 880:	d3dff0ef          	jal	ra,5bc <putc>
 884:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 886:	03c9d793          	srli	a5,s3,0x3c
 88a:	97e6                	add	a5,a5,s9
 88c:	0007c583          	lbu	a1,0(a5)
 890:	855a                	mv	a0,s6
 892:	d2bff0ef          	jal	ra,5bc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 896:	0992                	slli	s3,s3,0x4
 898:	397d                	addiw	s2,s2,-1
 89a:	fe0916e3          	bnez	s2,886 <vprintf+0x204>
        printptr(fd, va_arg(ap, uint64));
 89e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 8a2:	4981                	li	s3,0
 8a4:	bd25                	j	6dc <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 8a6:	008b8993          	addi	s3,s7,8
 8aa:	000bb903          	ld	s2,0(s7)
 8ae:	00090f63          	beqz	s2,8cc <vprintf+0x24a>
        for(; *s; s++)
 8b2:	00094583          	lbu	a1,0(s2)
 8b6:	c195                	beqz	a1,8da <vprintf+0x258>
          putc(fd, *s);
 8b8:	855a                	mv	a0,s6
 8ba:	d03ff0ef          	jal	ra,5bc <putc>
        for(; *s; s++)
 8be:	0905                	addi	s2,s2,1
 8c0:	00094583          	lbu	a1,0(s2)
 8c4:	f9f5                	bnez	a1,8b8 <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 8c6:	8bce                	mv	s7,s3
      state = 0;
 8c8:	4981                	li	s3,0
 8ca:	bd09                	j	6dc <vprintf+0x5a>
          s = "(null)";
 8cc:	00000917          	auipc	s2,0x0
 8d0:	35c90913          	addi	s2,s2,860 # c28 <malloc+0x24c>
        for(; *s; s++)
 8d4:	02800593          	li	a1,40
 8d8:	b7c5                	j	8b8 <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 8da:	8bce                	mv	s7,s3
      state = 0;
 8dc:	4981                	li	s3,0
 8de:	bbfd                	j	6dc <vprintf+0x5a>
    }
  }
}
 8e0:	70e6                	ld	ra,120(sp)
 8e2:	7446                	ld	s0,112(sp)
 8e4:	74a6                	ld	s1,104(sp)
 8e6:	7906                	ld	s2,96(sp)
 8e8:	69e6                	ld	s3,88(sp)
 8ea:	6a46                	ld	s4,80(sp)
 8ec:	6aa6                	ld	s5,72(sp)
 8ee:	6b06                	ld	s6,64(sp)
 8f0:	7be2                	ld	s7,56(sp)
 8f2:	7c42                	ld	s8,48(sp)
 8f4:	7ca2                	ld	s9,40(sp)
 8f6:	7d02                	ld	s10,32(sp)
 8f8:	6de2                	ld	s11,24(sp)
 8fa:	6109                	addi	sp,sp,128
 8fc:	8082                	ret

00000000000008fe <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8fe:	715d                	addi	sp,sp,-80
 900:	ec06                	sd	ra,24(sp)
 902:	e822                	sd	s0,16(sp)
 904:	1000                	addi	s0,sp,32
 906:	e010                	sd	a2,0(s0)
 908:	e414                	sd	a3,8(s0)
 90a:	e818                	sd	a4,16(s0)
 90c:	ec1c                	sd	a5,24(s0)
 90e:	03043023          	sd	a6,32(s0)
 912:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 916:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 91a:	8622                	mv	a2,s0
 91c:	d67ff0ef          	jal	ra,682 <vprintf>
}
 920:	60e2                	ld	ra,24(sp)
 922:	6442                	ld	s0,16(sp)
 924:	6161                	addi	sp,sp,80
 926:	8082                	ret

0000000000000928 <printf>:

void
printf(const char *fmt, ...)
{
 928:	711d                	addi	sp,sp,-96
 92a:	ec06                	sd	ra,24(sp)
 92c:	e822                	sd	s0,16(sp)
 92e:	1000                	addi	s0,sp,32
 930:	e40c                	sd	a1,8(s0)
 932:	e810                	sd	a2,16(s0)
 934:	ec14                	sd	a3,24(s0)
 936:	f018                	sd	a4,32(s0)
 938:	f41c                	sd	a5,40(s0)
 93a:	03043823          	sd	a6,48(s0)
 93e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 942:	00840613          	addi	a2,s0,8
 946:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 94a:	85aa                	mv	a1,a0
 94c:	4505                	li	a0,1
 94e:	d35ff0ef          	jal	ra,682 <vprintf>
}
 952:	60e2                	ld	ra,24(sp)
 954:	6442                	ld	s0,16(sp)
 956:	6125                	addi	sp,sp,96
 958:	8082                	ret

000000000000095a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 95a:	1141                	addi	sp,sp,-16
 95c:	e422                	sd	s0,8(sp)
 95e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 960:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 964:	00000797          	auipc	a5,0x0
 968:	6ac7b783          	ld	a5,1708(a5) # 1010 <freep>
 96c:	a02d                	j	996 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 96e:	4618                	lw	a4,8(a2)
 970:	9f2d                	addw	a4,a4,a1
 972:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 976:	6398                	ld	a4,0(a5)
 978:	6310                	ld	a2,0(a4)
 97a:	a83d                	j	9b8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 97c:	ff852703          	lw	a4,-8(a0)
 980:	9f31                	addw	a4,a4,a2
 982:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 984:	ff053683          	ld	a3,-16(a0)
 988:	a091                	j	9cc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 98a:	6398                	ld	a4,0(a5)
 98c:	00e7e463          	bltu	a5,a4,994 <free+0x3a>
 990:	00e6ea63          	bltu	a3,a4,9a4 <free+0x4a>
{
 994:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 996:	fed7fae3          	bgeu	a5,a3,98a <free+0x30>
 99a:	6398                	ld	a4,0(a5)
 99c:	00e6e463          	bltu	a3,a4,9a4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a0:	fee7eae3          	bltu	a5,a4,994 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9a4:	ff852583          	lw	a1,-8(a0)
 9a8:	6390                	ld	a2,0(a5)
 9aa:	02059813          	slli	a6,a1,0x20
 9ae:	01c85713          	srli	a4,a6,0x1c
 9b2:	9736                	add	a4,a4,a3
 9b4:	fae60de3          	beq	a2,a4,96e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9b8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9bc:	4790                	lw	a2,8(a5)
 9be:	02061593          	slli	a1,a2,0x20
 9c2:	01c5d713          	srli	a4,a1,0x1c
 9c6:	973e                	add	a4,a4,a5
 9c8:	fae68ae3          	beq	a3,a4,97c <free+0x22>
    p->s.ptr = bp->s.ptr;
 9cc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9ce:	00000717          	auipc	a4,0x0
 9d2:	64f73123          	sd	a5,1602(a4) # 1010 <freep>
}
 9d6:	6422                	ld	s0,8(sp)
 9d8:	0141                	addi	sp,sp,16
 9da:	8082                	ret

00000000000009dc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9dc:	7139                	addi	sp,sp,-64
 9de:	fc06                	sd	ra,56(sp)
 9e0:	f822                	sd	s0,48(sp)
 9e2:	f426                	sd	s1,40(sp)
 9e4:	f04a                	sd	s2,32(sp)
 9e6:	ec4e                	sd	s3,24(sp)
 9e8:	e852                	sd	s4,16(sp)
 9ea:	e456                	sd	s5,8(sp)
 9ec:	e05a                	sd	s6,0(sp)
 9ee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f0:	02051493          	slli	s1,a0,0x20
 9f4:	9081                	srli	s1,s1,0x20
 9f6:	04bd                	addi	s1,s1,15
 9f8:	8091                	srli	s1,s1,0x4
 9fa:	0014899b          	addiw	s3,s1,1
 9fe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a00:	00000517          	auipc	a0,0x0
 a04:	61053503          	ld	a0,1552(a0) # 1010 <freep>
 a08:	c515                	beqz	a0,a34 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a0c:	4798                	lw	a4,8(a5)
 a0e:	02977f63          	bgeu	a4,s1,a4c <malloc+0x70>
 a12:	8a4e                	mv	s4,s3
 a14:	0009871b          	sext.w	a4,s3
 a18:	6685                	lui	a3,0x1
 a1a:	00d77363          	bgeu	a4,a3,a20 <malloc+0x44>
 a1e:	6a05                	lui	s4,0x1
 a20:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a24:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a28:	00000917          	auipc	s2,0x0
 a2c:	5e890913          	addi	s2,s2,1512 # 1010 <freep>
  if(p == (char*)-1)
 a30:	5afd                	li	s5,-1
 a32:	a885                	j	aa2 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 a34:	00000797          	auipc	a5,0x0
 a38:	5ec78793          	addi	a5,a5,1516 # 1020 <base>
 a3c:	00000717          	auipc	a4,0x0
 a40:	5cf73a23          	sd	a5,1492(a4) # 1010 <freep>
 a44:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a46:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a4a:	b7e1                	j	a12 <malloc+0x36>
      if(p->s.size == nunits)
 a4c:	02e48c63          	beq	s1,a4,a84 <malloc+0xa8>
        p->s.size -= nunits;
 a50:	4137073b          	subw	a4,a4,s3
 a54:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a56:	02071693          	slli	a3,a4,0x20
 a5a:	01c6d713          	srli	a4,a3,0x1c
 a5e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a60:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a64:	00000717          	auipc	a4,0x0
 a68:	5aa73623          	sd	a0,1452(a4) # 1010 <freep>
      return (void*)(p + 1);
 a6c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a70:	70e2                	ld	ra,56(sp)
 a72:	7442                	ld	s0,48(sp)
 a74:	74a2                	ld	s1,40(sp)
 a76:	7902                	ld	s2,32(sp)
 a78:	69e2                	ld	s3,24(sp)
 a7a:	6a42                	ld	s4,16(sp)
 a7c:	6aa2                	ld	s5,8(sp)
 a7e:	6b02                	ld	s6,0(sp)
 a80:	6121                	addi	sp,sp,64
 a82:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a84:	6398                	ld	a4,0(a5)
 a86:	e118                	sd	a4,0(a0)
 a88:	bff1                	j	a64 <malloc+0x88>
  hp->s.size = nu;
 a8a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a8e:	0541                	addi	a0,a0,16
 a90:	ecbff0ef          	jal	ra,95a <free>
  return freep;
 a94:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a98:	dd61                	beqz	a0,a70 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a9a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a9c:	4798                	lw	a4,8(a5)
 a9e:	fa9777e3          	bgeu	a4,s1,a4c <malloc+0x70>
    if(p == freep)
 aa2:	00093703          	ld	a4,0(s2)
 aa6:	853e                	mv	a0,a5
 aa8:	fef719e3          	bne	a4,a5,a9a <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 aac:	8552                	mv	a0,s4
 aae:	ac1ff0ef          	jal	ra,56e <sbrk>
  if(p == (char*)-1)
 ab2:	fd551ce3          	bne	a0,s5,a8a <malloc+0xae>
        return 0;
 ab6:	4501                	li	a0,0
 ab8:	bf65                	j	a70 <malloc+0x94>
