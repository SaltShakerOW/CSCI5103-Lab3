
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	9b013103          	ld	sp,-1616(sp) # 800079b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	547040ef          	jal	ra,80004d5c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <superinit>:
  superinit(); //allocate space for superpages before regular pages
  freerange(end, (void*)PHYSTOP - (uint64)NSUPERPAGES * SUPERPAGESIZE); //modification made here to ensure space for 60 superpages
}

void
superinit() {
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
  uint64 pool_size = (uint64)NSUPERPAGES * SUPERPGSIZE;
  uint64 available = PHYSTOP - (uint64)end;
    80000024:	47c5                	li	a5,17
    80000026:	07ee                	slli	a5,a5,0x1b
    80000028:	00021717          	auipc	a4,0x21
    8000002c:	f0870713          	addi	a4,a4,-248 # 80020f30 <end>
    80000030:	8f99                	sub	a5,a5,a4

  if (pool_size >= available)
    80000032:	07800737          	lui	a4,0x7800
    80000036:	04f77863          	bgeu	a4,a5,80000086 <superinit+0x6a>
    panic("superinit: pool too large");

  initlock(&supermem.lock, "supermem");
    8000003a:	00007597          	auipc	a1,0x7
    8000003e:	ff658593          	addi	a1,a1,-10 # 80007030 <etext+0x30>
    80000042:	00008517          	auipc	a0,0x8
    80000046:	9be50513          	addi	a0,a0,-1602 # 80007a00 <supermem>
    8000004a:	698050ef          	jal	ra,800056e2 <initlock>
  supermem.nfree = 0; //reset number of free superpages

  uint64 top = PHYSTOP; //start allocation at top of memory space
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    8000004e:	00008697          	auipc	a3,0x8
    80000052:	9ca68693          	addi	a3,a3,-1590 # 80007a18 <supermem+0x18>
  initlock(&supermem.lock, "supermem");
    80000056:	4705                	li	a4,1
  uint64 top = PHYSTOP; //start allocation at top of memory space
    80000058:	47c5                	li	a5,17
    8000005a:	07ee                	slli	a5,a5,0x1b
    top -= SUPERPAGESIZE;
    8000005c:	ffe00537          	lui	a0,0xffe00
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    80000060:	10100613          	li	a2,257
    80000064:	065e                	slli	a2,a2,0x17
    top -= SUPERPAGESIZE;
    80000066:	97aa                	add	a5,a5,a0
    top = top & ~((uint64)SUPERPAGESIZE - 1);
    supermem.superpages[supermem.nfree] = (void*)top;
    80000068:	e29c                	sd	a5,0(a3)
    supermem.nfree++;
    8000006a:	0007059b          	sext.w	a1,a4
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    8000006e:	0705                	addi	a4,a4,1 # 7800001 <_entry-0x787fffff>
    80000070:	06a1                	addi	a3,a3,8
    80000072:	fec79ae3          	bne	a5,a2,80000066 <superinit+0x4a>
    80000076:	00008797          	auipc	a5,0x8
    8000007a:	b8b7a123          	sw	a1,-1150(a5) # 80007bf8 <supermem+0x1f8>
  }
}
    8000007e:	60a2                	ld	ra,8(sp)
    80000080:	6402                	ld	s0,0(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret
    panic("superinit: pool too large");
    80000086:	00007517          	auipc	a0,0x7
    8000008a:	f8a50513          	addi	a0,a0,-118 # 80007010 <etext+0x10>
    8000008e:	3c4050ef          	jal	ra,80005452 <panic>

0000000080000092 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000092:	7179                	addi	sp,sp,-48
    80000094:	f406                	sd	ra,40(sp)
    80000096:	f022                	sd	s0,32(sp)
    80000098:	ec26                	sd	s1,24(sp)
    8000009a:	e84a                	sd	s2,16(sp)
    8000009c:	e44e                	sd	s3,8(sp)
    8000009e:	1800                	addi	s0,sp,48
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800000a0:	03451793          	slli	a5,a0,0x34
    800000a4:	ebb1                	bnez	a5,800000f8 <kfree+0x66>
    800000a6:	84aa                	mv	s1,a0
    800000a8:	00021797          	auipc	a5,0x21
    800000ac:	e8878793          	addi	a5,a5,-376 # 80020f30 <end>
    800000b0:	04f56463          	bltu	a0,a5,800000f8 <kfree+0x66>
    800000b4:	47c5                	li	a5,17
    800000b6:	07ee                	slli	a5,a5,0x1b
    800000b8:	04f57063          	bgeu	a0,a5,800000f8 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800000bc:	6605                	lui	a2,0x1
    800000be:	4585                	li	a1,1
    800000c0:	120000ef          	jal	ra,800001e0 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800000c4:	00008997          	auipc	s3,0x8
    800000c8:	93c98993          	addi	s3,s3,-1732 # 80007a00 <supermem>
    800000cc:	00008917          	auipc	s2,0x8
    800000d0:	b3490913          	addi	s2,s2,-1228 # 80007c00 <kmem>
    800000d4:	854a                	mv	a0,s2
    800000d6:	68c050ef          	jal	ra,80005762 <acquire>
  r->next = kmem.freelist;
    800000da:	2189b783          	ld	a5,536(s3)
    800000de:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800000e0:	2099bc23          	sd	s1,536(s3)
  release(&kmem.lock);
    800000e4:	854a                	mv	a0,s2
    800000e6:	714050ef          	jal	ra,800057fa <release>
}
    800000ea:	70a2                	ld	ra,40(sp)
    800000ec:	7402                	ld	s0,32(sp)
    800000ee:	64e2                	ld	s1,24(sp)
    800000f0:	6942                	ld	s2,16(sp)
    800000f2:	69a2                	ld	s3,8(sp)
    800000f4:	6145                	addi	sp,sp,48
    800000f6:	8082                	ret
    panic("kfree");
    800000f8:	00007517          	auipc	a0,0x7
    800000fc:	f4850513          	addi	a0,a0,-184 # 80007040 <etext+0x40>
    80000100:	352050ef          	jal	ra,80005452 <panic>

0000000080000104 <freerange>:
{
    80000104:	7179                	addi	sp,sp,-48
    80000106:	f406                	sd	ra,40(sp)
    80000108:	f022                	sd	s0,32(sp)
    8000010a:	ec26                	sd	s1,24(sp)
    8000010c:	e84a                	sd	s2,16(sp)
    8000010e:	e44e                	sd	s3,8(sp)
    80000110:	e052                	sd	s4,0(sp)
    80000112:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000114:	6785                	lui	a5,0x1
    80000116:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    8000011a:	00e504b3          	add	s1,a0,a4
    8000011e:	777d                	lui	a4,0xfffff
    80000120:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000122:	94be                	add	s1,s1,a5
    80000124:	0095ec63          	bltu	a1,s1,8000013c <freerange+0x38>
    80000128:	892e                	mv	s2,a1
    kfree(p);
    8000012a:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    8000012c:	6985                	lui	s3,0x1
    kfree(p);
    8000012e:	01448533          	add	a0,s1,s4
    80000132:	f61ff0ef          	jal	ra,80000092 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000136:	94ce                	add	s1,s1,s3
    80000138:	fe997be3          	bgeu	s2,s1,8000012e <freerange+0x2a>
}
    8000013c:	70a2                	ld	ra,40(sp)
    8000013e:	7402                	ld	s0,32(sp)
    80000140:	64e2                	ld	s1,24(sp)
    80000142:	6942                	ld	s2,16(sp)
    80000144:	69a2                	ld	s3,8(sp)
    80000146:	6a02                	ld	s4,0(sp)
    80000148:	6145                	addi	sp,sp,48
    8000014a:	8082                	ret

000000008000014c <kinit>:
{
    8000014c:	1141                	addi	sp,sp,-16
    8000014e:	e406                	sd	ra,8(sp)
    80000150:	e022                	sd	s0,0(sp)
    80000152:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000154:	00007597          	auipc	a1,0x7
    80000158:	ef458593          	addi	a1,a1,-268 # 80007048 <etext+0x48>
    8000015c:	00008517          	auipc	a0,0x8
    80000160:	aa450513          	addi	a0,a0,-1372 # 80007c00 <kmem>
    80000164:	57e050ef          	jal	ra,800056e2 <initlock>
  superinit(); //allocate space for superpages before regular pages
    80000168:	eb5ff0ef          	jal	ra,8000001c <superinit>
  freerange(end, (void*)PHYSTOP - (uint64)NSUPERPAGES * SUPERPAGESIZE); //modification made here to ensure space for 60 superpages
    8000016c:	10100593          	li	a1,257
    80000170:	05de                	slli	a1,a1,0x17
    80000172:	00021517          	auipc	a0,0x21
    80000176:	dbe50513          	addi	a0,a0,-578 # 80020f30 <end>
    8000017a:	f8bff0ef          	jal	ra,80000104 <freerange>
}
    8000017e:	60a2                	ld	ra,8(sp)
    80000180:	6402                	ld	s0,0(sp)
    80000182:	0141                	addi	sp,sp,16
    80000184:	8082                	ret

0000000080000186 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000186:	1101                	addi	sp,sp,-32
    80000188:	ec06                	sd	ra,24(sp)
    8000018a:	e822                	sd	s0,16(sp)
    8000018c:	e426                	sd	s1,8(sp)
    8000018e:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000190:	00008517          	auipc	a0,0x8
    80000194:	a7050513          	addi	a0,a0,-1424 # 80007c00 <kmem>
    80000198:	5ca050ef          	jal	ra,80005762 <acquire>
  r = kmem.freelist;
    8000019c:	00008497          	auipc	s1,0x8
    800001a0:	a7c4b483          	ld	s1,-1412(s1) # 80007c18 <kmem+0x18>
  if (r) {
    800001a4:	c49d                	beqz	s1,800001d2 <kalloc+0x4c>
    kmem.freelist = r->next;
    800001a6:	609c                	ld	a5,0(s1)
    800001a8:	00008717          	auipc	a4,0x8
    800001ac:	a6f73823          	sd	a5,-1424(a4) # 80007c18 <kmem+0x18>
  }
  release(&kmem.lock);
    800001b0:	00008517          	auipc	a0,0x8
    800001b4:	a5050513          	addi	a0,a0,-1456 # 80007c00 <kmem>
    800001b8:	642050ef          	jal	ra,800057fa <release>

  if (r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
    800001bc:	6605                	lui	a2,0x1
    800001be:	4595                	li	a1,5
    800001c0:	8526                	mv	a0,s1
    800001c2:	01e000ef          	jal	ra,800001e0 <memset>
  }
  return (void*)r;
}
    800001c6:	8526                	mv	a0,s1
    800001c8:	60e2                	ld	ra,24(sp)
    800001ca:	6442                	ld	s0,16(sp)
    800001cc:	64a2                	ld	s1,8(sp)
    800001ce:	6105                	addi	sp,sp,32
    800001d0:	8082                	ret
  release(&kmem.lock);
    800001d2:	00008517          	auipc	a0,0x8
    800001d6:	a2e50513          	addi	a0,a0,-1490 # 80007c00 <kmem>
    800001da:	620050ef          	jal	ra,800057fa <release>
  if (r) {
    800001de:	b7e5                	j	800001c6 <kalloc+0x40>

00000000800001e0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800001e0:	1141                	addi	sp,sp,-16
    800001e2:	e422                	sd	s0,8(sp)
    800001e4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800001e6:	ca19                	beqz	a2,800001fc <memset+0x1c>
    800001e8:	87aa                	mv	a5,a0
    800001ea:	1602                	slli	a2,a2,0x20
    800001ec:	9201                	srli	a2,a2,0x20
    800001ee:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    800001f2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800001f6:	0785                	addi	a5,a5,1
    800001f8:	fee79de3          	bne	a5,a4,800001f2 <memset+0x12>
  }
  return dst;
}
    800001fc:	6422                	ld	s0,8(sp)
    800001fe:	0141                	addi	sp,sp,16
    80000200:	8082                	ret

0000000080000202 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000202:	1141                	addi	sp,sp,-16
    80000204:	e422                	sd	s0,8(sp)
    80000206:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000208:	ca05                	beqz	a2,80000238 <memcmp+0x36>
    8000020a:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    8000020e:	1682                	slli	a3,a3,0x20
    80000210:	9281                	srli	a3,a3,0x20
    80000212:	0685                	addi	a3,a3,1
    80000214:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000216:	00054783          	lbu	a5,0(a0)
    8000021a:	0005c703          	lbu	a4,0(a1)
    8000021e:	00e79863          	bne	a5,a4,8000022e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000222:	0505                	addi	a0,a0,1
    80000224:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000226:	fed518e3          	bne	a0,a3,80000216 <memcmp+0x14>
  }

  return 0;
    8000022a:	4501                	li	a0,0
    8000022c:	a019                	j	80000232 <memcmp+0x30>
      return *s1 - *s2;
    8000022e:	40e7853b          	subw	a0,a5,a4
}
    80000232:	6422                	ld	s0,8(sp)
    80000234:	0141                	addi	sp,sp,16
    80000236:	8082                	ret
  return 0;
    80000238:	4501                	li	a0,0
    8000023a:	bfe5                	j	80000232 <memcmp+0x30>

000000008000023c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    8000023c:	1141                	addi	sp,sp,-16
    8000023e:	e422                	sd	s0,8(sp)
    80000240:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000242:	c205                	beqz	a2,80000262 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000244:	02a5e263          	bltu	a1,a0,80000268 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000248:	1602                	slli	a2,a2,0x20
    8000024a:	9201                	srli	a2,a2,0x20
    8000024c:	00c587b3          	add	a5,a1,a2
{
    80000250:	872a                	mv	a4,a0
      *d++ = *s++;
    80000252:	0585                	addi	a1,a1,1
    80000254:	0705                	addi	a4,a4,1
    80000256:	fff5c683          	lbu	a3,-1(a1)
    8000025a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    8000025e:	fef59ae3          	bne	a1,a5,80000252 <memmove+0x16>

  return dst;
}
    80000262:	6422                	ld	s0,8(sp)
    80000264:	0141                	addi	sp,sp,16
    80000266:	8082                	ret
  if(s < d && s + n > d){
    80000268:	02061693          	slli	a3,a2,0x20
    8000026c:	9281                	srli	a3,a3,0x20
    8000026e:	00d58733          	add	a4,a1,a3
    80000272:	fce57be3          	bgeu	a0,a4,80000248 <memmove+0xc>
    d += n;
    80000276:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000278:	fff6079b          	addiw	a5,a2,-1
    8000027c:	1782                	slli	a5,a5,0x20
    8000027e:	9381                	srli	a5,a5,0x20
    80000280:	fff7c793          	not	a5,a5
    80000284:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000286:	177d                	addi	a4,a4,-1
    80000288:	16fd                	addi	a3,a3,-1
    8000028a:	00074603          	lbu	a2,0(a4)
    8000028e:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000292:	fee79ae3          	bne	a5,a4,80000286 <memmove+0x4a>
    80000296:	b7f1                	j	80000262 <memmove+0x26>

0000000080000298 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000298:	1141                	addi	sp,sp,-16
    8000029a:	e406                	sd	ra,8(sp)
    8000029c:	e022                	sd	s0,0(sp)
    8000029e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800002a0:	f9dff0ef          	jal	ra,8000023c <memmove>
}
    800002a4:	60a2                	ld	ra,8(sp)
    800002a6:	6402                	ld	s0,0(sp)
    800002a8:	0141                	addi	sp,sp,16
    800002aa:	8082                	ret

00000000800002ac <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800002ac:	1141                	addi	sp,sp,-16
    800002ae:	e422                	sd	s0,8(sp)
    800002b0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    800002b2:	ce11                	beqz	a2,800002ce <strncmp+0x22>
    800002b4:	00054783          	lbu	a5,0(a0)
    800002b8:	cf89                	beqz	a5,800002d2 <strncmp+0x26>
    800002ba:	0005c703          	lbu	a4,0(a1)
    800002be:	00f71a63          	bne	a4,a5,800002d2 <strncmp+0x26>
    n--, p++, q++;
    800002c2:	367d                	addiw	a2,a2,-1
    800002c4:	0505                	addi	a0,a0,1
    800002c6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800002c8:	f675                	bnez	a2,800002b4 <strncmp+0x8>
  if(n == 0)
    return 0;
    800002ca:	4501                	li	a0,0
    800002cc:	a809                	j	800002de <strncmp+0x32>
    800002ce:	4501                	li	a0,0
    800002d0:	a039                	j	800002de <strncmp+0x32>
  if(n == 0)
    800002d2:	ca09                	beqz	a2,800002e4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800002d4:	00054503          	lbu	a0,0(a0)
    800002d8:	0005c783          	lbu	a5,0(a1)
    800002dc:	9d1d                	subw	a0,a0,a5
}
    800002de:	6422                	ld	s0,8(sp)
    800002e0:	0141                	addi	sp,sp,16
    800002e2:	8082                	ret
    return 0;
    800002e4:	4501                	li	a0,0
    800002e6:	bfe5                	j	800002de <strncmp+0x32>

00000000800002e8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800002e8:	1141                	addi	sp,sp,-16
    800002ea:	e422                	sd	s0,8(sp)
    800002ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800002ee:	872a                	mv	a4,a0
    800002f0:	8832                	mv	a6,a2
    800002f2:	367d                	addiw	a2,a2,-1
    800002f4:	01005963          	blez	a6,80000306 <strncpy+0x1e>
    800002f8:	0705                	addi	a4,a4,1
    800002fa:	0005c783          	lbu	a5,0(a1)
    800002fe:	fef70fa3          	sb	a5,-1(a4)
    80000302:	0585                	addi	a1,a1,1
    80000304:	f7f5                	bnez	a5,800002f0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000306:	86ba                	mv	a3,a4
    80000308:	00c05c63          	blez	a2,80000320 <strncpy+0x38>
    *s++ = 0;
    8000030c:	0685                	addi	a3,a3,1
    8000030e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000312:	40d707bb          	subw	a5,a4,a3
    80000316:	37fd                	addiw	a5,a5,-1
    80000318:	010787bb          	addw	a5,a5,a6
    8000031c:	fef048e3          	bgtz	a5,8000030c <strncpy+0x24>
  return os;
}
    80000320:	6422                	ld	s0,8(sp)
    80000322:	0141                	addi	sp,sp,16
    80000324:	8082                	ret

0000000080000326 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000326:	1141                	addi	sp,sp,-16
    80000328:	e422                	sd	s0,8(sp)
    8000032a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000032c:	02c05363          	blez	a2,80000352 <safestrcpy+0x2c>
    80000330:	fff6069b          	addiw	a3,a2,-1
    80000334:	1682                	slli	a3,a3,0x20
    80000336:	9281                	srli	a3,a3,0x20
    80000338:	96ae                	add	a3,a3,a1
    8000033a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000033c:	00d58963          	beq	a1,a3,8000034e <safestrcpy+0x28>
    80000340:	0585                	addi	a1,a1,1
    80000342:	0785                	addi	a5,a5,1
    80000344:	fff5c703          	lbu	a4,-1(a1)
    80000348:	fee78fa3          	sb	a4,-1(a5)
    8000034c:	fb65                	bnez	a4,8000033c <safestrcpy+0x16>
    ;
  *s = 0;
    8000034e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000352:	6422                	ld	s0,8(sp)
    80000354:	0141                	addi	sp,sp,16
    80000356:	8082                	ret

0000000080000358 <strlen>:

int
strlen(const char *s)
{
    80000358:	1141                	addi	sp,sp,-16
    8000035a:	e422                	sd	s0,8(sp)
    8000035c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000035e:	00054783          	lbu	a5,0(a0)
    80000362:	cf91                	beqz	a5,8000037e <strlen+0x26>
    80000364:	0505                	addi	a0,a0,1
    80000366:	87aa                	mv	a5,a0
    80000368:	4685                	li	a3,1
    8000036a:	9e89                	subw	a3,a3,a0
    8000036c:	00f6853b          	addw	a0,a3,a5
    80000370:	0785                	addi	a5,a5,1
    80000372:	fff7c703          	lbu	a4,-1(a5)
    80000376:	fb7d                	bnez	a4,8000036c <strlen+0x14>
    ;
  return n;
}
    80000378:	6422                	ld	s0,8(sp)
    8000037a:	0141                	addi	sp,sp,16
    8000037c:	8082                	ret
  for(n = 0; s[n]; n++)
    8000037e:	4501                	li	a0,0
    80000380:	bfe5                	j	80000378 <strlen+0x20>

0000000080000382 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000382:	1141                	addi	sp,sp,-16
    80000384:	e406                	sd	ra,8(sp)
    80000386:	e022                	sd	s0,0(sp)
    80000388:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000038a:	317000ef          	jal	ra,80000ea0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000038e:	00007717          	auipc	a4,0x7
    80000392:	64270713          	addi	a4,a4,1602 # 800079d0 <started>
  if(cpuid() == 0){
    80000396:	c51d                	beqz	a0,800003c4 <main+0x42>
    while(started == 0)
    80000398:	431c                	lw	a5,0(a4)
    8000039a:	2781                	sext.w	a5,a5
    8000039c:	dff5                	beqz	a5,80000398 <main+0x16>
      ;
    __sync_synchronize();
    8000039e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800003a2:	2ff000ef          	jal	ra,80000ea0 <cpuid>
    800003a6:	85aa                	mv	a1,a0
    800003a8:	00007517          	auipc	a0,0x7
    800003ac:	cc050513          	addi	a0,a0,-832 # 80007068 <etext+0x68>
    800003b0:	5ef040ef          	jal	ra,8000519e <printf>
    kvminithart();    // turn on paging
    800003b4:	080000ef          	jal	ra,80000434 <kvminithart>
    trapinithart();   // install kernel trap vector
    800003b8:	602010ef          	jal	ra,800019ba <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800003bc:	3f8040ef          	jal	ra,800047b4 <plicinithart>
  }

  scheduler();
    800003c0:	73f000ef          	jal	ra,800012fe <scheduler>
    consoleinit();
    800003c4:	505040ef          	jal	ra,800050c8 <consoleinit>
    printfinit();
    800003c8:	0c4050ef          	jal	ra,8000548c <printfinit>
    printf("\n");
    800003cc:	00007517          	auipc	a0,0x7
    800003d0:	cac50513          	addi	a0,a0,-852 # 80007078 <etext+0x78>
    800003d4:	5cb040ef          	jal	ra,8000519e <printf>
    printf("xv6 kernel is booting\n");
    800003d8:	00007517          	auipc	a0,0x7
    800003dc:	c7850513          	addi	a0,a0,-904 # 80007050 <etext+0x50>
    800003e0:	5bf040ef          	jal	ra,8000519e <printf>
    printf("\n");
    800003e4:	00007517          	auipc	a0,0x7
    800003e8:	c9450513          	addi	a0,a0,-876 # 80007078 <etext+0x78>
    800003ec:	5b3040ef          	jal	ra,8000519e <printf>
    kinit();         // physical page allocator
    800003f0:	d5dff0ef          	jal	ra,8000014c <kinit>
    kvminit();       // create kernel page table
    800003f4:	2d4000ef          	jal	ra,800006c8 <kvminit>
    kvminithart();   // turn on paging
    800003f8:	03c000ef          	jal	ra,80000434 <kvminithart>
    procinit();      // process table
    800003fc:	1fd000ef          	jal	ra,80000df8 <procinit>
    trapinit();      // trap vectors
    80000400:	596010ef          	jal	ra,80001996 <trapinit>
    trapinithart();  // install kernel trap vector
    80000404:	5b6010ef          	jal	ra,800019ba <trapinithart>
    plicinit();      // set up interrupt controller
    80000408:	396040ef          	jal	ra,8000479e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000040c:	3a8040ef          	jal	ra,800047b4 <plicinithart>
    binit();         // buffer cache
    80000410:	429010ef          	jal	ra,80002038 <binit>
    iinit();         // inode table
    80000414:	204020ef          	jal	ra,80002618 <iinit>
    fileinit();      // file table
    80000418:	7a7020ef          	jal	ra,800033be <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000041c:	488040ef          	jal	ra,800048a4 <virtio_disk_init>
    userinit();      // first user process
    80000420:	515000ef          	jal	ra,80001134 <userinit>
    __sync_synchronize();
    80000424:	0ff0000f          	fence
    started = 1;
    80000428:	4785                	li	a5,1
    8000042a:	00007717          	auipc	a4,0x7
    8000042e:	5af72323          	sw	a5,1446(a4) # 800079d0 <started>
    80000432:	b779                	j	800003c0 <main+0x3e>

0000000080000434 <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    80000434:	1141                	addi	sp,sp,-16
    80000436:	e422                	sd	s0,8(sp)
    80000438:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000043a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000043e:	00007797          	auipc	a5,0x7
    80000442:	59a7b783          	ld	a5,1434(a5) # 800079d8 <kernel_pagetable>
    80000446:	83b1                	srli	a5,a5,0xc
    80000448:	577d                	li	a4,-1
    8000044a:	177e                	slli	a4,a4,0x3f
    8000044c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000044e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000452:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000456:	6422                	ld	s0,8(sp)
    80000458:	0141                	addi	sp,sp,16
    8000045a:	8082                	ret

000000008000045c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000045c:	7139                	addi	sp,sp,-64
    8000045e:	fc06                	sd	ra,56(sp)
    80000460:	f822                	sd	s0,48(sp)
    80000462:	f426                	sd	s1,40(sp)
    80000464:	f04a                	sd	s2,32(sp)
    80000466:	ec4e                	sd	s3,24(sp)
    80000468:	e852                	sd	s4,16(sp)
    8000046a:	e456                	sd	s5,8(sp)
    8000046c:	e05a                	sd	s6,0(sp)
    8000046e:	0080                	addi	s0,sp,64
    80000470:	892a                	mv	s2,a0
    80000472:	89ae                	mv	s3,a1
    80000474:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000476:	57fd                	li	a5,-1
    80000478:	83e9                	srli	a5,a5,0x1a
    8000047a:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--)
    8000047c:	4b31                	li	s6,12
  if (va >= MAXVA)
    8000047e:	02b7fb63          	bgeu	a5,a1,800004b4 <walk+0x58>
    panic("walk");
    80000482:	00007517          	auipc	a0,0x7
    80000486:	bfe50513          	addi	a0,a0,-1026 # 80007080 <etext+0x80>
    8000048a:	7c9040ef          	jal	ra,80005452 <panic>
      }
#endif
    }
    else
    {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    8000048e:	060a8563          	beqz	s5,800004f8 <walk+0x9c>
    80000492:	cf5ff0ef          	jal	ra,80000186 <kalloc>
    80000496:	892a                	mv	s2,a0
    80000498:	c135                	beqz	a0,800004fc <walk+0xa0>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000049a:	6605                	lui	a2,0x1
    8000049c:	4581                	li	a1,0
    8000049e:	d43ff0ef          	jal	ra,800001e0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800004a2:	00c95793          	srli	a5,s2,0xc
    800004a6:	07aa                	slli	a5,a5,0xa
    800004a8:	0017e793          	ori	a5,a5,1
    800004ac:	e09c                	sd	a5,0(s1)
  for (int level = 2; level > 0; level--)
    800004ae:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde0c7>
    800004b0:	036a0263          	beq	s4,s6,800004d4 <walk+0x78>
    pte_t *pte = &pagetable[PX(level, va)];
    800004b4:	0149d4b3          	srl	s1,s3,s4
    800004b8:	1ff4f493          	andi	s1,s1,511
    800004bc:	048e                	slli	s1,s1,0x3
    800004be:	94ca                	add	s1,s1,s2
    if (*pte & PTE_V)
    800004c0:	609c                	ld	a5,0(s1)
    800004c2:	0017f713          	andi	a4,a5,1
    800004c6:	d761                	beqz	a4,8000048e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800004c8:	00a7d913          	srli	s2,a5,0xa
    800004cc:	0932                	slli	s2,s2,0xc
      if (PTE_LEAF(*pte))
    800004ce:	8bb9                	andi	a5,a5,14
    800004d0:	dff9                	beqz	a5,800004ae <walk+0x52>
    800004d2:	a801                	j	800004e2 <walk+0x86>
    }
  }
  return &pagetable[PX(0, va)];
    800004d4:	00c9d993          	srli	s3,s3,0xc
    800004d8:	1ff9f993          	andi	s3,s3,511
    800004dc:	098e                	slli	s3,s3,0x3
    800004de:	013904b3          	add	s1,s2,s3
}
    800004e2:	8526                	mv	a0,s1
    800004e4:	70e2                	ld	ra,56(sp)
    800004e6:	7442                	ld	s0,48(sp)
    800004e8:	74a2                	ld	s1,40(sp)
    800004ea:	7902                	ld	s2,32(sp)
    800004ec:	69e2                	ld	s3,24(sp)
    800004ee:	6a42                	ld	s4,16(sp)
    800004f0:	6aa2                	ld	s5,8(sp)
    800004f2:	6b02                	ld	s6,0(sp)
    800004f4:	6121                	addi	sp,sp,64
    800004f6:	8082                	ret
        return 0;
    800004f8:	4481                	li	s1,0
    800004fa:	b7e5                	j	800004e2 <walk+0x86>
    800004fc:	84aa                	mv	s1,a0
    800004fe:	b7d5                	j	800004e2 <walk+0x86>

0000000080000500 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000500:	57fd                	li	a5,-1
    80000502:	83e9                	srli	a5,a5,0x1a
    80000504:	00b7f463          	bgeu	a5,a1,8000050c <walkaddr+0xc>
    return 0;
    80000508:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000050a:	8082                	ret
{
    8000050c:	1141                	addi	sp,sp,-16
    8000050e:	e406                	sd	ra,8(sp)
    80000510:	e022                	sd	s0,0(sp)
    80000512:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000514:	4601                	li	a2,0
    80000516:	f47ff0ef          	jal	ra,8000045c <walk>
  if (pte == 0)
    8000051a:	c105                	beqz	a0,8000053a <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    8000051c:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    8000051e:	0117f693          	andi	a3,a5,17
    80000522:	4745                	li	a4,17
    return 0;
    80000524:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000526:	00e68663          	beq	a3,a4,80000532 <walkaddr+0x32>
}
    8000052a:	60a2                	ld	ra,8(sp)
    8000052c:	6402                	ld	s0,0(sp)
    8000052e:	0141                	addi	sp,sp,16
    80000530:	8082                	ret
  pa = PTE2PA(*pte);
    80000532:	83a9                	srli	a5,a5,0xa
    80000534:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000538:	bfcd                	j	8000052a <walkaddr+0x2a>
    return 0;
    8000053a:	4501                	li	a0,0
    8000053c:	b7fd                	j	8000052a <walkaddr+0x2a>

000000008000053e <mappages>:
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000053e:	715d                	addi	sp,sp,-80
    80000540:	e486                	sd	ra,72(sp)
    80000542:	e0a2                	sd	s0,64(sp)
    80000544:	fc26                	sd	s1,56(sp)
    80000546:	f84a                	sd	s2,48(sp)
    80000548:	f44e                	sd	s3,40(sp)
    8000054a:	f052                	sd	s4,32(sp)
    8000054c:	ec56                	sd	s5,24(sp)
    8000054e:	e85a                	sd	s6,16(sp)
    80000550:	e45e                	sd	s7,8(sp)
    80000552:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80000554:	03459793          	slli	a5,a1,0x34
    80000558:	e7a9                	bnez	a5,800005a2 <mappages+0x64>
    8000055a:	8aaa                	mv	s5,a0
    8000055c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    8000055e:	03461793          	slli	a5,a2,0x34
    80000562:	e7b1                	bnez	a5,800005ae <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    80000564:	ca39                	beqz	a2,800005ba <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    80000566:	77fd                	lui	a5,0xfffff
    80000568:	963e                	add	a2,a2,a5
    8000056a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000056e:	892e                	mv	s2,a1
    80000570:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80000574:	6b85                	lui	s7,0x1
    80000576:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000057a:	4605                	li	a2,1
    8000057c:	85ca                	mv	a1,s2
    8000057e:	8556                	mv	a0,s5
    80000580:	eddff0ef          	jal	ra,8000045c <walk>
    80000584:	c539                	beqz	a0,800005d2 <mappages+0x94>
    if (*pte & PTE_V)
    80000586:	611c                	ld	a5,0(a0)
    80000588:	8b85                	andi	a5,a5,1
    8000058a:	ef95                	bnez	a5,800005c6 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000058c:	80b1                	srli	s1,s1,0xc
    8000058e:	04aa                	slli	s1,s1,0xa
    80000590:	0164e4b3          	or	s1,s1,s6
    80000594:	0014e493          	ori	s1,s1,1
    80000598:	e104                	sd	s1,0(a0)
    if (a == last)
    8000059a:	05390863          	beq	s2,s3,800005ea <mappages+0xac>
    a += PGSIZE;
    8000059e:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800005a0:	bfd9                	j	80000576 <mappages+0x38>
    panic("mappages: va not aligned");
    800005a2:	00007517          	auipc	a0,0x7
    800005a6:	ae650513          	addi	a0,a0,-1306 # 80007088 <etext+0x88>
    800005aa:	6a9040ef          	jal	ra,80005452 <panic>
    panic("mappages: size not aligned");
    800005ae:	00007517          	auipc	a0,0x7
    800005b2:	afa50513          	addi	a0,a0,-1286 # 800070a8 <etext+0xa8>
    800005b6:	69d040ef          	jal	ra,80005452 <panic>
    panic("mappages: size");
    800005ba:	00007517          	auipc	a0,0x7
    800005be:	b0e50513          	addi	a0,a0,-1266 # 800070c8 <etext+0xc8>
    800005c2:	691040ef          	jal	ra,80005452 <panic>
      panic("mappages: remap");
    800005c6:	00007517          	auipc	a0,0x7
    800005ca:	b1250513          	addi	a0,a0,-1262 # 800070d8 <etext+0xd8>
    800005ce:	685040ef          	jal	ra,80005452 <panic>
      return -1;
    800005d2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800005d4:	60a6                	ld	ra,72(sp)
    800005d6:	6406                	ld	s0,64(sp)
    800005d8:	74e2                	ld	s1,56(sp)
    800005da:	7942                	ld	s2,48(sp)
    800005dc:	79a2                	ld	s3,40(sp)
    800005de:	7a02                	ld	s4,32(sp)
    800005e0:	6ae2                	ld	s5,24(sp)
    800005e2:	6b42                	ld	s6,16(sp)
    800005e4:	6ba2                	ld	s7,8(sp)
    800005e6:	6161                	addi	sp,sp,80
    800005e8:	8082                	ret
  return 0;
    800005ea:	4501                	li	a0,0
    800005ec:	b7e5                	j	800005d4 <mappages+0x96>

00000000800005ee <kvmmap>:
{
    800005ee:	1141                	addi	sp,sp,-16
    800005f0:	e406                	sd	ra,8(sp)
    800005f2:	e022                	sd	s0,0(sp)
    800005f4:	0800                	addi	s0,sp,16
    800005f6:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    800005f8:	86b2                	mv	a3,a2
    800005fa:	863e                	mv	a2,a5
    800005fc:	f43ff0ef          	jal	ra,8000053e <mappages>
    80000600:	e509                	bnez	a0,8000060a <kvmmap+0x1c>
}
    80000602:	60a2                	ld	ra,8(sp)
    80000604:	6402                	ld	s0,0(sp)
    80000606:	0141                	addi	sp,sp,16
    80000608:	8082                	ret
    panic("kvmmap");
    8000060a:	00007517          	auipc	a0,0x7
    8000060e:	ade50513          	addi	a0,a0,-1314 # 800070e8 <etext+0xe8>
    80000612:	641040ef          	jal	ra,80005452 <panic>

0000000080000616 <kvmmake>:
{
    80000616:	1101                	addi	sp,sp,-32
    80000618:	ec06                	sd	ra,24(sp)
    8000061a:	e822                	sd	s0,16(sp)
    8000061c:	e426                	sd	s1,8(sp)
    8000061e:	e04a                	sd	s2,0(sp)
    80000620:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80000622:	b65ff0ef          	jal	ra,80000186 <kalloc>
    80000626:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000628:	6605                	lui	a2,0x1
    8000062a:	4581                	li	a1,0
    8000062c:	bb5ff0ef          	jal	ra,800001e0 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000630:	4719                	li	a4,6
    80000632:	6685                	lui	a3,0x1
    80000634:	10000637          	lui	a2,0x10000
    80000638:	100005b7          	lui	a1,0x10000
    8000063c:	8526                	mv	a0,s1
    8000063e:	fb1ff0ef          	jal	ra,800005ee <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000642:	4719                	li	a4,6
    80000644:	6685                	lui	a3,0x1
    80000646:	10001637          	lui	a2,0x10001
    8000064a:	100015b7          	lui	a1,0x10001
    8000064e:	8526                	mv	a0,s1
    80000650:	f9fff0ef          	jal	ra,800005ee <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80000654:	4719                	li	a4,6
    80000656:	040006b7          	lui	a3,0x4000
    8000065a:	0c000637          	lui	a2,0xc000
    8000065e:	0c0005b7          	lui	a1,0xc000
    80000662:	8526                	mv	a0,s1
    80000664:	f8bff0ef          	jal	ra,800005ee <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    80000668:	00007917          	auipc	s2,0x7
    8000066c:	99890913          	addi	s2,s2,-1640 # 80007000 <etext>
    80000670:	4729                	li	a4,10
    80000672:	80007697          	auipc	a3,0x80007
    80000676:	98e68693          	addi	a3,a3,-1650 # 7000 <_entry-0x7fff9000>
    8000067a:	4605                	li	a2,1
    8000067c:	067e                	slli	a2,a2,0x1f
    8000067e:	85b2                	mv	a1,a2
    80000680:	8526                	mv	a0,s1
    80000682:	f6dff0ef          	jal	ra,800005ee <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    80000686:	4719                	li	a4,6
    80000688:	46c5                	li	a3,17
    8000068a:	06ee                	slli	a3,a3,0x1b
    8000068c:	412686b3          	sub	a3,a3,s2
    80000690:	864a                	mv	a2,s2
    80000692:	85ca                	mv	a1,s2
    80000694:	8526                	mv	a0,s1
    80000696:	f59ff0ef          	jal	ra,800005ee <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000069a:	4729                	li	a4,10
    8000069c:	6685                	lui	a3,0x1
    8000069e:	00006617          	auipc	a2,0x6
    800006a2:	96260613          	addi	a2,a2,-1694 # 80006000 <_trampoline>
    800006a6:	040005b7          	lui	a1,0x4000
    800006aa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800006ac:	05b2                	slli	a1,a1,0xc
    800006ae:	8526                	mv	a0,s1
    800006b0:	f3fff0ef          	jal	ra,800005ee <kvmmap>
  proc_mapstacks(kpgtbl);
    800006b4:	8526                	mv	a0,s1
    800006b6:	6b8000ef          	jal	ra,80000d6e <proc_mapstacks>
}
    800006ba:	8526                	mv	a0,s1
    800006bc:	60e2                	ld	ra,24(sp)
    800006be:	6442                	ld	s0,16(sp)
    800006c0:	64a2                	ld	s1,8(sp)
    800006c2:	6902                	ld	s2,0(sp)
    800006c4:	6105                	addi	sp,sp,32
    800006c6:	8082                	ret

00000000800006c8 <kvminit>:
{
    800006c8:	1141                	addi	sp,sp,-16
    800006ca:	e406                	sd	ra,8(sp)
    800006cc:	e022                	sd	s0,0(sp)
    800006ce:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800006d0:	f47ff0ef          	jal	ra,80000616 <kvmmake>
    800006d4:	00007797          	auipc	a5,0x7
    800006d8:	30a7b223          	sd	a0,772(a5) # 800079d8 <kernel_pagetable>
}
    800006dc:	60a2                	ld	ra,8(sp)
    800006de:	6402                	ld	s0,0(sp)
    800006e0:	0141                	addi	sp,sp,16
    800006e2:	8082                	ret

00000000800006e4 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800006e4:	715d                	addi	sp,sp,-80
    800006e6:	e486                	sd	ra,72(sp)
    800006e8:	e0a2                	sd	s0,64(sp)
    800006ea:	fc26                	sd	s1,56(sp)
    800006ec:	f84a                	sd	s2,48(sp)
    800006ee:	f44e                	sd	s3,40(sp)
    800006f0:	f052                	sd	s4,32(sp)
    800006f2:	ec56                	sd	s5,24(sp)
    800006f4:	e85a                	sd	s6,16(sp)
    800006f6:	e45e                	sd	s7,8(sp)
    800006f8:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;
  int sz;

  if ((va % PGSIZE) != 0)
    800006fa:	03459793          	slli	a5,a1,0x34
    800006fe:	e795                	bnez	a5,8000072a <uvmunmap+0x46>
    80000700:	8a2a                	mv	s4,a0
    80000702:	892e                	mv	s2,a1
    80000704:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += sz)
    80000706:	0632                	slli	a2,a2,0xc
    80000708:	00b609b3          	add	s3,a2,a1
    if ((*pte & PTE_V) == 0)
    {
      printf("va=%ld pte=%ld\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if (PTE_FLAGS(*pte) == PTE_V)
    8000070c:	4b85                	li	s7,1
  for (a = va; a < va + npages * PGSIZE; a += sz)
    8000070e:	6b05                	lui	s6,0x1
    80000710:	0735e163          	bltu	a1,s3,80000772 <uvmunmap+0x8e>
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
  }
}
    80000714:	60a6                	ld	ra,72(sp)
    80000716:	6406                	ld	s0,64(sp)
    80000718:	74e2                	ld	s1,56(sp)
    8000071a:	7942                	ld	s2,48(sp)
    8000071c:	79a2                	ld	s3,40(sp)
    8000071e:	7a02                	ld	s4,32(sp)
    80000720:	6ae2                	ld	s5,24(sp)
    80000722:	6b42                	ld	s6,16(sp)
    80000724:	6ba2                	ld	s7,8(sp)
    80000726:	6161                	addi	sp,sp,80
    80000728:	8082                	ret
    panic("uvmunmap: not aligned");
    8000072a:	00007517          	auipc	a0,0x7
    8000072e:	9c650513          	addi	a0,a0,-1594 # 800070f0 <etext+0xf0>
    80000732:	521040ef          	jal	ra,80005452 <panic>
      panic("uvmunmap: walk");
    80000736:	00007517          	auipc	a0,0x7
    8000073a:	9d250513          	addi	a0,a0,-1582 # 80007108 <etext+0x108>
    8000073e:	515040ef          	jal	ra,80005452 <panic>
      printf("va=%ld pte=%ld\n", a, *pte);
    80000742:	85ca                	mv	a1,s2
    80000744:	00007517          	auipc	a0,0x7
    80000748:	9d450513          	addi	a0,a0,-1580 # 80007118 <etext+0x118>
    8000074c:	253040ef          	jal	ra,8000519e <printf>
      panic("uvmunmap: not mapped");
    80000750:	00007517          	auipc	a0,0x7
    80000754:	9d850513          	addi	a0,a0,-1576 # 80007128 <etext+0x128>
    80000758:	4fb040ef          	jal	ra,80005452 <panic>
      panic("uvmunmap: not a leaf");
    8000075c:	00007517          	auipc	a0,0x7
    80000760:	9e450513          	addi	a0,a0,-1564 # 80007140 <etext+0x140>
    80000764:	4ef040ef          	jal	ra,80005452 <panic>
    *pte = 0;
    80000768:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += sz)
    8000076c:	995a                	add	s2,s2,s6
    8000076e:	fb3973e3          	bgeu	s2,s3,80000714 <uvmunmap+0x30>
    if ((pte = walk(pagetable, a, 0)) == 0)
    80000772:	4601                	li	a2,0
    80000774:	85ca                	mv	a1,s2
    80000776:	8552                	mv	a0,s4
    80000778:	ce5ff0ef          	jal	ra,8000045c <walk>
    8000077c:	84aa                	mv	s1,a0
    8000077e:	dd45                	beqz	a0,80000736 <uvmunmap+0x52>
    if ((*pte & PTE_V) == 0)
    80000780:	6110                	ld	a2,0(a0)
    80000782:	00167793          	andi	a5,a2,1
    80000786:	dfd5                	beqz	a5,80000742 <uvmunmap+0x5e>
    if (PTE_FLAGS(*pte) == PTE_V)
    80000788:	3ff67793          	andi	a5,a2,1023
    8000078c:	fd7788e3          	beq	a5,s7,8000075c <uvmunmap+0x78>
    if (do_free)
    80000790:	fc0a8ce3          	beqz	s5,80000768 <uvmunmap+0x84>
      uint64 pa = PTE2PA(*pte);
    80000794:	8229                	srli	a2,a2,0xa
      kfree((void *)pa);
    80000796:	00c61513          	slli	a0,a2,0xc
    8000079a:	8f9ff0ef          	jal	ra,80000092 <kfree>
    8000079e:	b7e9                	j	80000768 <uvmunmap+0x84>

00000000800007a0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800007a0:	1101                	addi	sp,sp,-32
    800007a2:	ec06                	sd	ra,24(sp)
    800007a4:	e822                	sd	s0,16(sp)
    800007a6:	e426                	sd	s1,8(sp)
    800007a8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    800007aa:	9ddff0ef          	jal	ra,80000186 <kalloc>
    800007ae:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800007b0:	c509                	beqz	a0,800007ba <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800007b2:	6605                	lui	a2,0x1
    800007b4:	4581                	li	a1,0
    800007b6:	a2bff0ef          	jal	ra,800001e0 <memset>
  return pagetable;
}
    800007ba:	8526                	mv	a0,s1
    800007bc:	60e2                	ld	ra,24(sp)
    800007be:	6442                	ld	s0,16(sp)
    800007c0:	64a2                	ld	s1,8(sp)
    800007c2:	6105                	addi	sp,sp,32
    800007c4:	8082                	ret

00000000800007c6 <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800007c6:	7179                	addi	sp,sp,-48
    800007c8:	f406                	sd	ra,40(sp)
    800007ca:	f022                	sd	s0,32(sp)
    800007cc:	ec26                	sd	s1,24(sp)
    800007ce:	e84a                	sd	s2,16(sp)
    800007d0:	e44e                	sd	s3,8(sp)
    800007d2:	e052                	sd	s4,0(sp)
    800007d4:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    800007d6:	6785                	lui	a5,0x1
    800007d8:	04f67063          	bgeu	a2,a5,80000818 <uvmfirst+0x52>
    800007dc:	8a2a                	mv	s4,a0
    800007de:	89ae                	mv	s3,a1
    800007e0:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800007e2:	9a5ff0ef          	jal	ra,80000186 <kalloc>
    800007e6:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800007e8:	6605                	lui	a2,0x1
    800007ea:	4581                	li	a1,0
    800007ec:	9f5ff0ef          	jal	ra,800001e0 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    800007f0:	4779                	li	a4,30
    800007f2:	86ca                	mv	a3,s2
    800007f4:	6605                	lui	a2,0x1
    800007f6:	4581                	li	a1,0
    800007f8:	8552                	mv	a0,s4
    800007fa:	d45ff0ef          	jal	ra,8000053e <mappages>
  memmove(mem, src, sz);
    800007fe:	8626                	mv	a2,s1
    80000800:	85ce                	mv	a1,s3
    80000802:	854a                	mv	a0,s2
    80000804:	a39ff0ef          	jal	ra,8000023c <memmove>
}
    80000808:	70a2                	ld	ra,40(sp)
    8000080a:	7402                	ld	s0,32(sp)
    8000080c:	64e2                	ld	s1,24(sp)
    8000080e:	6942                	ld	s2,16(sp)
    80000810:	69a2                	ld	s3,8(sp)
    80000812:	6a02                	ld	s4,0(sp)
    80000814:	6145                	addi	sp,sp,48
    80000816:	8082                	ret
    panic("uvmfirst: more than a page");
    80000818:	00007517          	auipc	a0,0x7
    8000081c:	94050513          	addi	a0,a0,-1728 # 80007158 <etext+0x158>
    80000820:	433040ef          	jal	ra,80005452 <panic>

0000000080000824 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    8000082e:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80000830:	00b67d63          	bgeu	a2,a1,8000084a <uvmdealloc+0x26>
    80000834:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    80000836:	6785                	lui	a5,0x1
    80000838:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000083a:	00f60733          	add	a4,a2,a5
    8000083e:	76fd                	lui	a3,0xfffff
    80000840:	8f75                	and	a4,a4,a3
    80000842:	97ae                	add	a5,a5,a1
    80000844:	8ff5                	and	a5,a5,a3
    80000846:	00f76863          	bltu	a4,a5,80000856 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000084a:	8526                	mv	a0,s1
    8000084c:	60e2                	ld	ra,24(sp)
    8000084e:	6442                	ld	s0,16(sp)
    80000850:	64a2                	ld	s1,8(sp)
    80000852:	6105                	addi	sp,sp,32
    80000854:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000856:	8f99                	sub	a5,a5,a4
    80000858:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000085a:	4685                	li	a3,1
    8000085c:	0007861b          	sext.w	a2,a5
    80000860:	85ba                	mv	a1,a4
    80000862:	e83ff0ef          	jal	ra,800006e4 <uvmunmap>
    80000866:	b7d5                	j	8000084a <uvmdealloc+0x26>

0000000080000868 <uvmalloc>:
  if (newsz < oldsz)
    80000868:	08b66963          	bltu	a2,a1,800008fa <uvmalloc+0x92>
{
    8000086c:	7139                	addi	sp,sp,-64
    8000086e:	fc06                	sd	ra,56(sp)
    80000870:	f822                	sd	s0,48(sp)
    80000872:	f426                	sd	s1,40(sp)
    80000874:	f04a                	sd	s2,32(sp)
    80000876:	ec4e                	sd	s3,24(sp)
    80000878:	e852                	sd	s4,16(sp)
    8000087a:	e456                	sd	s5,8(sp)
    8000087c:	e05a                	sd	s6,0(sp)
    8000087e:	0080                	addi	s0,sp,64
    80000880:	8aaa                	mv	s5,a0
    80000882:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80000884:	6785                	lui	a5,0x1
    80000886:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000888:	95be                	add	a1,a1,a5
    8000088a:	77fd                	lui	a5,0xfffff
    8000088c:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += sz)
    80000890:	06c9f763          	bgeu	s3,a2,800008fe <uvmalloc+0x96>
    80000894:	894e                	mv	s2,s3
    if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000896:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000089a:	8edff0ef          	jal	ra,80000186 <kalloc>
    8000089e:	84aa                	mv	s1,a0
    if (mem == 0)
    800008a0:	c11d                	beqz	a0,800008c6 <uvmalloc+0x5e>
    memset(mem, 0, sz);
    800008a2:	6605                	lui	a2,0x1
    800008a4:	4581                	li	a1,0
    800008a6:	93bff0ef          	jal	ra,800001e0 <memset>
    if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    800008aa:	875a                	mv	a4,s6
    800008ac:	86a6                	mv	a3,s1
    800008ae:	6605                	lui	a2,0x1
    800008b0:	85ca                	mv	a1,s2
    800008b2:	8556                	mv	a0,s5
    800008b4:	c8bff0ef          	jal	ra,8000053e <mappages>
    800008b8:	e51d                	bnez	a0,800008e6 <uvmalloc+0x7e>
  for (a = oldsz; a < newsz; a += sz)
    800008ba:	6785                	lui	a5,0x1
    800008bc:	993e                	add	s2,s2,a5
    800008be:	fd496ee3          	bltu	s2,s4,8000089a <uvmalloc+0x32>
  return newsz;
    800008c2:	8552                	mv	a0,s4
    800008c4:	a039                	j	800008d2 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    800008c6:	864e                	mv	a2,s3
    800008c8:	85ca                	mv	a1,s2
    800008ca:	8556                	mv	a0,s5
    800008cc:	f59ff0ef          	jal	ra,80000824 <uvmdealloc>
      return 0;
    800008d0:	4501                	li	a0,0
}
    800008d2:	70e2                	ld	ra,56(sp)
    800008d4:	7442                	ld	s0,48(sp)
    800008d6:	74a2                	ld	s1,40(sp)
    800008d8:	7902                	ld	s2,32(sp)
    800008da:	69e2                	ld	s3,24(sp)
    800008dc:	6a42                	ld	s4,16(sp)
    800008de:	6aa2                	ld	s5,8(sp)
    800008e0:	6b02                	ld	s6,0(sp)
    800008e2:	6121                	addi	sp,sp,64
    800008e4:	8082                	ret
      kfree(mem);
    800008e6:	8526                	mv	a0,s1
    800008e8:	faaff0ef          	jal	ra,80000092 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800008ec:	864e                	mv	a2,s3
    800008ee:	85ca                	mv	a1,s2
    800008f0:	8556                	mv	a0,s5
    800008f2:	f33ff0ef          	jal	ra,80000824 <uvmdealloc>
      return 0;
    800008f6:	4501                	li	a0,0
    800008f8:	bfe9                	j	800008d2 <uvmalloc+0x6a>
    return oldsz;
    800008fa:	852e                	mv	a0,a1
}
    800008fc:	8082                	ret
  return newsz;
    800008fe:	8532                	mv	a0,a2
    80000900:	bfc9                	j	800008d2 <uvmalloc+0x6a>

0000000080000902 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    80000902:	7179                	addi	sp,sp,-48
    80000904:	f406                	sd	ra,40(sp)
    80000906:	f022                	sd	s0,32(sp)
    80000908:	ec26                	sd	s1,24(sp)
    8000090a:	e84a                	sd	s2,16(sp)
    8000090c:	e44e                	sd	s3,8(sp)
    8000090e:	e052                	sd	s4,0(sp)
    80000910:	1800                	addi	s0,sp,48
    80000912:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    80000914:	84aa                	mv	s1,a0
    80000916:	6905                	lui	s2,0x1
    80000918:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    8000091a:	4985                	li	s3,1
    8000091c:	a819                	j	80000932 <freewalk+0x30>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000091e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80000920:	00c79513          	slli	a0,a5,0xc
    80000924:	fdfff0ef          	jal	ra,80000902 <freewalk>
      pagetable[i] = 0;
    80000928:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    8000092c:	04a1                	addi	s1,s1,8
    8000092e:	01248f63          	beq	s1,s2,8000094c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80000932:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000934:	00f7f713          	andi	a4,a5,15
    80000938:	ff3703e3          	beq	a4,s3,8000091e <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    8000093c:	8b85                	andi	a5,a5,1
    8000093e:	d7fd                	beqz	a5,8000092c <freewalk+0x2a>
    {
      panic("freewalk: leaf");
    80000940:	00007517          	auipc	a0,0x7
    80000944:	83850513          	addi	a0,a0,-1992 # 80007178 <etext+0x178>
    80000948:	30b040ef          	jal	ra,80005452 <panic>
    }
  }
  kfree((void *)pagetable);
    8000094c:	8552                	mv	a0,s4
    8000094e:	f44ff0ef          	jal	ra,80000092 <kfree>
}
    80000952:	70a2                	ld	ra,40(sp)
    80000954:	7402                	ld	s0,32(sp)
    80000956:	64e2                	ld	s1,24(sp)
    80000958:	6942                	ld	s2,16(sp)
    8000095a:	69a2                	ld	s3,8(sp)
    8000095c:	6a02                	ld	s4,0(sp)
    8000095e:	6145                	addi	sp,sp,48
    80000960:	8082                	ret

0000000080000962 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000962:	1101                	addi	sp,sp,-32
    80000964:	ec06                	sd	ra,24(sp)
    80000966:	e822                	sd	s0,16(sp)
    80000968:	e426                	sd	s1,8(sp)
    8000096a:	1000                	addi	s0,sp,32
    8000096c:	84aa                	mv	s1,a0
  if (sz > 0)
    8000096e:	e989                	bnez	a1,80000980 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80000970:	8526                	mv	a0,s1
    80000972:	f91ff0ef          	jal	ra,80000902 <freewalk>
}
    80000976:	60e2                	ld	ra,24(sp)
    80000978:	6442                	ld	s0,16(sp)
    8000097a:	64a2                	ld	s1,8(sp)
    8000097c:	6105                	addi	sp,sp,32
    8000097e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80000980:	6785                	lui	a5,0x1
    80000982:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000984:	95be                	add	a1,a1,a5
    80000986:	4685                	li	a3,1
    80000988:	00c5d613          	srli	a2,a1,0xc
    8000098c:	4581                	li	a1,0
    8000098e:	d57ff0ef          	jal	ra,800006e4 <uvmunmap>
    80000992:	bff9                	j	80000970 <uvmfree+0xe>

0000000080000994 <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;
  int szinc;

  for (i = 0; i < sz; i += szinc)
    80000994:	c65d                	beqz	a2,80000a42 <uvmcopy+0xae>
{
    80000996:	715d                	addi	sp,sp,-80
    80000998:	e486                	sd	ra,72(sp)
    8000099a:	e0a2                	sd	s0,64(sp)
    8000099c:	fc26                	sd	s1,56(sp)
    8000099e:	f84a                	sd	s2,48(sp)
    800009a0:	f44e                	sd	s3,40(sp)
    800009a2:	f052                	sd	s4,32(sp)
    800009a4:	ec56                	sd	s5,24(sp)
    800009a6:	e85a                	sd	s6,16(sp)
    800009a8:	e45e                	sd	s7,8(sp)
    800009aa:	0880                	addi	s0,sp,80
    800009ac:	8b2a                	mv	s6,a0
    800009ae:	8aae                	mv	s5,a1
    800009b0:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += szinc)
    800009b2:	4981                	li	s3,0
  {
    szinc = PGSIZE;
    if ((pte = walk(old, i, 0)) == 0)
    800009b4:	4601                	li	a2,0
    800009b6:	85ce                	mv	a1,s3
    800009b8:	855a                	mv	a0,s6
    800009ba:	aa3ff0ef          	jal	ra,8000045c <walk>
    800009be:	c121                	beqz	a0,800009fe <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    800009c0:	6118                	ld	a4,0(a0)
    800009c2:	00177793          	andi	a5,a4,1
    800009c6:	c3b1                	beqz	a5,80000a0a <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800009c8:	00a75593          	srli	a1,a4,0xa
    800009cc:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800009d0:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    800009d4:	fb2ff0ef          	jal	ra,80000186 <kalloc>
    800009d8:	892a                	mv	s2,a0
    800009da:	c129                	beqz	a0,80000a1c <uvmcopy+0x88>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    800009dc:	6605                	lui	a2,0x1
    800009de:	85de                	mv	a1,s7
    800009e0:	85dff0ef          	jal	ra,8000023c <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    800009e4:	8726                	mv	a4,s1
    800009e6:	86ca                	mv	a3,s2
    800009e8:	6605                	lui	a2,0x1
    800009ea:	85ce                	mv	a1,s3
    800009ec:	8556                	mv	a0,s5
    800009ee:	b51ff0ef          	jal	ra,8000053e <mappages>
    800009f2:	e115                	bnez	a0,80000a16 <uvmcopy+0x82>
  for (i = 0; i < sz; i += szinc)
    800009f4:	6785                	lui	a5,0x1
    800009f6:	99be                	add	s3,s3,a5
    800009f8:	fb49eee3          	bltu	s3,s4,800009b4 <uvmcopy+0x20>
    800009fc:	a805                	j	80000a2c <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800009fe:	00006517          	auipc	a0,0x6
    80000a02:	78a50513          	addi	a0,a0,1930 # 80007188 <etext+0x188>
    80000a06:	24d040ef          	jal	ra,80005452 <panic>
      panic("uvmcopy: page not present");
    80000a0a:	00006517          	auipc	a0,0x6
    80000a0e:	79e50513          	addi	a0,a0,1950 # 800071a8 <etext+0x1a8>
    80000a12:	241040ef          	jal	ra,80005452 <panic>
    {
      kfree(mem);
    80000a16:	854a                	mv	a0,s2
    80000a18:	e7aff0ef          	jal	ra,80000092 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000a1c:	4685                	li	a3,1
    80000a1e:	00c9d613          	srli	a2,s3,0xc
    80000a22:	4581                	li	a1,0
    80000a24:	8556                	mv	a0,s5
    80000a26:	cbfff0ef          	jal	ra,800006e4 <uvmunmap>
  return -1;
    80000a2a:	557d                	li	a0,-1
}
    80000a2c:	60a6                	ld	ra,72(sp)
    80000a2e:	6406                	ld	s0,64(sp)
    80000a30:	74e2                	ld	s1,56(sp)
    80000a32:	7942                	ld	s2,48(sp)
    80000a34:	79a2                	ld	s3,40(sp)
    80000a36:	7a02                	ld	s4,32(sp)
    80000a38:	6ae2                	ld	s5,24(sp)
    80000a3a:	6b42                	ld	s6,16(sp)
    80000a3c:	6ba2                	ld	s7,8(sp)
    80000a3e:	6161                	addi	sp,sp,80
    80000a40:	8082                	ret
  return 0;
    80000a42:	4501                	li	a0,0
}
    80000a44:	8082                	ret

0000000080000a46 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    80000a46:	1141                	addi	sp,sp,-16
    80000a48:	e406                	sd	ra,8(sp)
    80000a4a:	e022                	sd	s0,0(sp)
    80000a4c:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80000a4e:	4601                	li	a2,0
    80000a50:	a0dff0ef          	jal	ra,8000045c <walk>
  if (pte == 0)
    80000a54:	c901                	beqz	a0,80000a64 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000a56:	611c                	ld	a5,0(a0)
    80000a58:	9bbd                	andi	a5,a5,-17
    80000a5a:	e11c                	sd	a5,0(a0)
}
    80000a5c:	60a2                	ld	ra,8(sp)
    80000a5e:	6402                	ld	s0,0(sp)
    80000a60:	0141                	addi	sp,sp,16
    80000a62:	8082                	ret
    panic("uvmclear");
    80000a64:	00006517          	auipc	a0,0x6
    80000a68:	76450513          	addi	a0,a0,1892 # 800071c8 <etext+0x1c8>
    80000a6c:	1e7040ef          	jal	ra,80005452 <panic>

0000000080000a70 <copyout>:
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while (len > 0)
    80000a70:	c6c1                	beqz	a3,80000af8 <copyout+0x88>
{
    80000a72:	711d                	addi	sp,sp,-96
    80000a74:	ec86                	sd	ra,88(sp)
    80000a76:	e8a2                	sd	s0,80(sp)
    80000a78:	e4a6                	sd	s1,72(sp)
    80000a7a:	e0ca                	sd	s2,64(sp)
    80000a7c:	fc4e                	sd	s3,56(sp)
    80000a7e:	f852                	sd	s4,48(sp)
    80000a80:	f456                	sd	s5,40(sp)
    80000a82:	f05a                	sd	s6,32(sp)
    80000a84:	ec5e                	sd	s7,24(sp)
    80000a86:	e862                	sd	s8,16(sp)
    80000a88:	e466                	sd	s9,8(sp)
    80000a8a:	1080                	addi	s0,sp,96
    80000a8c:	8b2a                	mv	s6,a0
    80000a8e:	8a2e                	mv	s4,a1
    80000a90:	8ab2                	mv	s5,a2
    80000a92:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80000a94:	74fd                	lui	s1,0xfffff
    80000a96:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000a98:	57fd                	li	a5,-1
    80000a9a:	83e9                	srli	a5,a5,0x1a
    80000a9c:	0697e063          	bltu	a5,s1,80000afc <copyout+0x8c>
    80000aa0:	6c05                	lui	s8,0x1
    80000aa2:	8bbe                	mv	s7,a5
    80000aa4:	a015                	j	80000ac8 <copyout+0x58>
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000aa6:	409a04b3          	sub	s1,s4,s1
    80000aaa:	0009061b          	sext.w	a2,s2
    80000aae:	85d6                	mv	a1,s5
    80000ab0:	9526                	add	a0,a0,s1
    80000ab2:	f8aff0ef          	jal	ra,8000023c <memmove>

    len -= n;
    80000ab6:	412989b3          	sub	s3,s3,s2
    src += n;
    80000aba:	9aca                	add	s5,s5,s2
  while (len > 0)
    80000abc:	02098c63          	beqz	s3,80000af4 <copyout+0x84>
    if (va0 >= MAXVA)
    80000ac0:	059be063          	bltu	s7,s9,80000b00 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80000ac4:	84e6                	mv	s1,s9
    dstva = va0 + PGSIZE;
    80000ac6:	8a66                	mv	s4,s9
    if ((pte = walk(pagetable, va0, 0)) == 0)
    80000ac8:	4601                	li	a2,0
    80000aca:	85a6                	mv	a1,s1
    80000acc:	855a                	mv	a0,s6
    80000ace:	98fff0ef          	jal	ra,8000045c <walk>
    80000ad2:	c90d                	beqz	a0,80000b04 <copyout+0x94>
    if ((*pte & PTE_W) == 0)
    80000ad4:	611c                	ld	a5,0(a0)
    80000ad6:	8b91                	andi	a5,a5,4
    80000ad8:	c7a1                	beqz	a5,80000b20 <copyout+0xb0>
    pa0 = walkaddr(pagetable, va0);
    80000ada:	85a6                	mv	a1,s1
    80000adc:	855a                	mv	a0,s6
    80000ade:	a23ff0ef          	jal	ra,80000500 <walkaddr>
    if (pa0 == 0)
    80000ae2:	c129                	beqz	a0,80000b24 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80000ae4:	01848cb3          	add	s9,s1,s8
    80000ae8:	414c8933          	sub	s2,s9,s4
    80000aec:	fb29fde3          	bgeu	s3,s2,80000aa6 <copyout+0x36>
    80000af0:	894e                	mv	s2,s3
    80000af2:	bf55                	j	80000aa6 <copyout+0x36>
  }
  return 0;
    80000af4:	4501                	li	a0,0
    80000af6:	a801                	j	80000b06 <copyout+0x96>
    80000af8:	4501                	li	a0,0
}
    80000afa:	8082                	ret
      return -1;
    80000afc:	557d                	li	a0,-1
    80000afe:	a021                	j	80000b06 <copyout+0x96>
    80000b00:	557d                	li	a0,-1
    80000b02:	a011                	j	80000b06 <copyout+0x96>
      return -1;
    80000b04:	557d                	li	a0,-1
}
    80000b06:	60e6                	ld	ra,88(sp)
    80000b08:	6446                	ld	s0,80(sp)
    80000b0a:	64a6                	ld	s1,72(sp)
    80000b0c:	6906                	ld	s2,64(sp)
    80000b0e:	79e2                	ld	s3,56(sp)
    80000b10:	7a42                	ld	s4,48(sp)
    80000b12:	7aa2                	ld	s5,40(sp)
    80000b14:	7b02                	ld	s6,32(sp)
    80000b16:	6be2                	ld	s7,24(sp)
    80000b18:	6c42                	ld	s8,16(sp)
    80000b1a:	6ca2                	ld	s9,8(sp)
    80000b1c:	6125                	addi	sp,sp,96
    80000b1e:	8082                	ret
      return -1;
    80000b20:	557d                	li	a0,-1
    80000b22:	b7d5                	j	80000b06 <copyout+0x96>
      return -1;
    80000b24:	557d                	li	a0,-1
    80000b26:	b7c5                	j	80000b06 <copyout+0x96>

0000000080000b28 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    80000b28:	c6a5                	beqz	a3,80000b90 <copyin+0x68>
{
    80000b2a:	715d                	addi	sp,sp,-80
    80000b2c:	e486                	sd	ra,72(sp)
    80000b2e:	e0a2                	sd	s0,64(sp)
    80000b30:	fc26                	sd	s1,56(sp)
    80000b32:	f84a                	sd	s2,48(sp)
    80000b34:	f44e                	sd	s3,40(sp)
    80000b36:	f052                	sd	s4,32(sp)
    80000b38:	ec56                	sd	s5,24(sp)
    80000b3a:	e85a                	sd	s6,16(sp)
    80000b3c:	e45e                	sd	s7,8(sp)
    80000b3e:	e062                	sd	s8,0(sp)
    80000b40:	0880                	addi	s0,sp,80
    80000b42:	8b2a                	mv	s6,a0
    80000b44:	8a2e                	mv	s4,a1
    80000b46:	8c32                	mv	s8,a2
    80000b48:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000b4a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000b4c:	6a85                	lui	s5,0x1
    80000b4e:	a00d                	j	80000b70 <copyin+0x48>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000b50:	018505b3          	add	a1,a0,s8
    80000b54:	0004861b          	sext.w	a2,s1
    80000b58:	412585b3          	sub	a1,a1,s2
    80000b5c:	8552                	mv	a0,s4
    80000b5e:	edeff0ef          	jal	ra,8000023c <memmove>

    len -= n;
    80000b62:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000b66:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000b68:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80000b6c:	02098063          	beqz	s3,80000b8c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000b70:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000b74:	85ca                	mv	a1,s2
    80000b76:	855a                	mv	a0,s6
    80000b78:	989ff0ef          	jal	ra,80000500 <walkaddr>
    if (pa0 == 0)
    80000b7c:	cd01                	beqz	a0,80000b94 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000b7e:	418904b3          	sub	s1,s2,s8
    80000b82:	94d6                	add	s1,s1,s5
    80000b84:	fc99f6e3          	bgeu	s3,s1,80000b50 <copyin+0x28>
    80000b88:	84ce                	mv	s1,s3
    80000b8a:	b7d9                	j	80000b50 <copyin+0x28>
  }
  return 0;
    80000b8c:	4501                	li	a0,0
    80000b8e:	a021                	j	80000b96 <copyin+0x6e>
    80000b90:	4501                	li	a0,0
}
    80000b92:	8082                	ret
      return -1;
    80000b94:	557d                	li	a0,-1
}
    80000b96:	60a6                	ld	ra,72(sp)
    80000b98:	6406                	ld	s0,64(sp)
    80000b9a:	74e2                	ld	s1,56(sp)
    80000b9c:	7942                	ld	s2,48(sp)
    80000b9e:	79a2                	ld	s3,40(sp)
    80000ba0:	7a02                	ld	s4,32(sp)
    80000ba2:	6ae2                	ld	s5,24(sp)
    80000ba4:	6b42                	ld	s6,16(sp)
    80000ba6:	6ba2                	ld	s7,8(sp)
    80000ba8:	6c02                	ld	s8,0(sp)
    80000baa:	6161                	addi	sp,sp,80
    80000bac:	8082                	ret

0000000080000bae <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80000bae:	c2cd                	beqz	a3,80000c50 <copyinstr+0xa2>
{
    80000bb0:	715d                	addi	sp,sp,-80
    80000bb2:	e486                	sd	ra,72(sp)
    80000bb4:	e0a2                	sd	s0,64(sp)
    80000bb6:	fc26                	sd	s1,56(sp)
    80000bb8:	f84a                	sd	s2,48(sp)
    80000bba:	f44e                	sd	s3,40(sp)
    80000bbc:	f052                	sd	s4,32(sp)
    80000bbe:	ec56                	sd	s5,24(sp)
    80000bc0:	e85a                	sd	s6,16(sp)
    80000bc2:	e45e                	sd	s7,8(sp)
    80000bc4:	0880                	addi	s0,sp,80
    80000bc6:	8a2a                	mv	s4,a0
    80000bc8:	8b2e                	mv	s6,a1
    80000bca:	8bb2                	mv	s7,a2
    80000bcc:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000bce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000bd0:	6985                	lui	s3,0x1
    80000bd2:	a02d                	j	80000bfc <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    80000bd4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000bd8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80000bda:	37fd                	addiw	a5,a5,-1
    80000bdc:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    80000be0:	60a6                	ld	ra,72(sp)
    80000be2:	6406                	ld	s0,64(sp)
    80000be4:	74e2                	ld	s1,56(sp)
    80000be6:	7942                	ld	s2,48(sp)
    80000be8:	79a2                	ld	s3,40(sp)
    80000bea:	7a02                	ld	s4,32(sp)
    80000bec:	6ae2                	ld	s5,24(sp)
    80000bee:	6b42                	ld	s6,16(sp)
    80000bf0:	6ba2                	ld	s7,8(sp)
    80000bf2:	6161                	addi	sp,sp,80
    80000bf4:	8082                	ret
    srcva = va0 + PGSIZE;
    80000bf6:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80000bfa:	c4b9                	beqz	s1,80000c48 <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80000bfc:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000c00:	85ca                	mv	a1,s2
    80000c02:	8552                	mv	a0,s4
    80000c04:	8fdff0ef          	jal	ra,80000500 <walkaddr>
    if (pa0 == 0)
    80000c08:	c131                	beqz	a0,80000c4c <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80000c0a:	417906b3          	sub	a3,s2,s7
    80000c0e:	96ce                	add	a3,a3,s3
    80000c10:	00d4f363          	bgeu	s1,a3,80000c16 <copyinstr+0x68>
    80000c14:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80000c16:	955e                	add	a0,a0,s7
    80000c18:	41250533          	sub	a0,a0,s2
    while (n > 0)
    80000c1c:	dee9                	beqz	a3,80000bf6 <copyinstr+0x48>
    80000c1e:	87da                	mv	a5,s6
      if (*p == '\0')
    80000c20:	41650633          	sub	a2,a0,s6
    80000c24:	fff48593          	addi	a1,s1,-1 # ffffffffffffefff <end+0xffffffff7ffde0cf>
    80000c28:	95da                	add	a1,a1,s6
    while (n > 0)
    80000c2a:	96da                	add	a3,a3,s6
      if (*p == '\0')
    80000c2c:	00f60733          	add	a4,a2,a5
    80000c30:	00074703          	lbu	a4,0(a4)
    80000c34:	d345                	beqz	a4,80000bd4 <copyinstr+0x26>
        *dst = *p;
    80000c36:	00e78023          	sb	a4,0(a5)
      --max;
    80000c3a:	40f584b3          	sub	s1,a1,a5
      dst++;
    80000c3e:	0785                	addi	a5,a5,1
    while (n > 0)
    80000c40:	fed796e3          	bne	a5,a3,80000c2c <copyinstr+0x7e>
      dst++;
    80000c44:	8b3e                	mv	s6,a5
    80000c46:	bf45                	j	80000bf6 <copyinstr+0x48>
    80000c48:	4781                	li	a5,0
    80000c4a:	bf41                	j	80000bda <copyinstr+0x2c>
      return -1;
    80000c4c:	557d                	li	a0,-1
    80000c4e:	bf49                	j	80000be0 <copyinstr+0x32>
  int got_null = 0;
    80000c50:	4781                	li	a5,0
  if (got_null)
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007851b          	sext.w	a0,a5
}
    80000c58:	8082                	ret

0000000080000c5a <vmprint_recurse>:
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
}
#endif

void vmprint_recurse(pagetable_t pagetable, int depth, uint64 va_recursive)
{ // seperate function so we can keep track of depth using a parameter
    80000c5a:	7119                	addi	sp,sp,-128
    80000c5c:	fc86                	sd	ra,120(sp)
    80000c5e:	f8a2                	sd	s0,112(sp)
    80000c60:	f4a6                	sd	s1,104(sp)
    80000c62:	f0ca                	sd	s2,96(sp)
    80000c64:	ecce                	sd	s3,88(sp)
    80000c66:	e8d2                	sd	s4,80(sp)
    80000c68:	e4d6                	sd	s5,72(sp)
    80000c6a:	e0da                	sd	s6,64(sp)
    80000c6c:	fc5e                	sd	s7,56(sp)
    80000c6e:	f862                	sd	s8,48(sp)
    80000c70:	f466                	sd	s9,40(sp)
    80000c72:	f06a                	sd	s10,32(sp)
    80000c74:	ec6e                	sd	s11,24(sp)
    80000c76:	0100                	addi	s0,sp,128
    80000c78:	8aae                	mv	s5,a1
    80000c7a:	8d32                	mv	s10,a2
    { // skip the pte if it's not valid per lab spec
      continue;
    }

    // reconstruct va using i, px shift, and the previous va
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000c7c:	4789                	li	a5,2
    80000c7e:	9f8d                	subw	a5,a5,a1
    80000c80:	00379c9b          	slliw	s9,a5,0x3
    80000c84:	00fc8cbb          	addw	s9,s9,a5
    80000c88:	2cb1                	addiw	s9,s9,12
    80000c8a:	8a2a                	mv	s4,a0
    80000c8c:	4981                	li	s3,0
      printf(".. ");
    }
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));

    // recursive block
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000c8e:	4d85                	li	s11,1
    {
      uint64 child_pa = PTE2PA(pte); // get child pa to convert to a pagetable
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000c90:	0015879b          	addiw	a5,a1,1
    80000c94:	f8f43423          	sd	a5,-120(s0)
      printf(".. ");
    80000c98:	00006b17          	auipc	s6,0x6
    80000c9c:	548b0b13          	addi	s6,s6,1352 # 800071e0 <etext+0x1e0>
  for (int i = 0; i < 512; i++)
    80000ca0:	20000c13          	li	s8,512
    80000ca4:	a029                	j	80000cae <vmprint_recurse+0x54>
    80000ca6:	0985                	addi	s3,s3,1 # 1001 <_entry-0x7fffefff>
    80000ca8:	0a21                	addi	s4,s4,8
    80000caa:	07898163          	beq	s3,s8,80000d0c <vmprint_recurse+0xb2>
    pte_t pte = pagetable[i]; // store pte from page table
    80000cae:	000a3903          	ld	s2,0(s4)
    if (!(pte & PTE_V))
    80000cb2:	00197793          	andi	a5,s2,1
    80000cb6:	dbe5                	beqz	a5,80000ca6 <vmprint_recurse+0x4c>
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000cb8:	01999bb3          	sll	s7,s3,s9
    80000cbc:	01abebb3          	or	s7,s7,s10
    printf(" ");
    80000cc0:	00006517          	auipc	a0,0x6
    80000cc4:	51850513          	addi	a0,a0,1304 # 800071d8 <etext+0x1d8>
    80000cc8:	4d6040ef          	jal	ra,8000519e <printf>
    for (int j = 0; j < depth; j++)
    80000ccc:	01505963          	blez	s5,80000cde <vmprint_recurse+0x84>
    80000cd0:	4481                	li	s1,0
      printf(".. ");
    80000cd2:	855a                	mv	a0,s6
    80000cd4:	4ca040ef          	jal	ra,8000519e <printf>
    for (int j = 0; j < depth; j++)
    80000cd8:	2485                	addiw	s1,s1,1
    80000cda:	fe9a9ce3          	bne	s5,s1,80000cd2 <vmprint_recurse+0x78>
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));
    80000cde:	00a95493          	srli	s1,s2,0xa
    80000ce2:	04b2                	slli	s1,s1,0xc
    80000ce4:	86a6                	mv	a3,s1
    80000ce6:	864a                	mv	a2,s2
    80000ce8:	85de                	mv	a1,s7
    80000cea:	00006517          	auipc	a0,0x6
    80000cee:	4fe50513          	addi	a0,a0,1278 # 800071e8 <etext+0x1e8>
    80000cf2:	4ac040ef          	jal	ra,8000519e <printf>
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000cf6:	00f97913          	andi	s2,s2,15
    80000cfa:	fbb916e3          	bne	s2,s11,80000ca6 <vmprint_recurse+0x4c>
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000cfe:	865e                	mv	a2,s7
    80000d00:	f8843583          	ld	a1,-120(s0)
    80000d04:	8526                	mv	a0,s1
    80000d06:	f55ff0ef          	jal	ra,80000c5a <vmprint_recurse>
    80000d0a:	bf71                	j	80000ca6 <vmprint_recurse+0x4c>
    }
  }
}
    80000d0c:	70e6                	ld	ra,120(sp)
    80000d0e:	7446                	ld	s0,112(sp)
    80000d10:	74a6                	ld	s1,104(sp)
    80000d12:	7906                	ld	s2,96(sp)
    80000d14:	69e6                	ld	s3,88(sp)
    80000d16:	6a46                	ld	s4,80(sp)
    80000d18:	6aa6                	ld	s5,72(sp)
    80000d1a:	6b06                	ld	s6,64(sp)
    80000d1c:	7be2                	ld	s7,56(sp)
    80000d1e:	7c42                	ld	s8,48(sp)
    80000d20:	7ca2                	ld	s9,40(sp)
    80000d22:	7d02                	ld	s10,32(sp)
    80000d24:	6de2                	ld	s11,24(sp)
    80000d26:	6109                	addi	sp,sp,128
    80000d28:	8082                	ret

0000000080000d2a <vmprint>:
{
    80000d2a:	1101                	addi	sp,sp,-32
    80000d2c:	ec06                	sd	ra,24(sp)
    80000d2e:	e822                	sd	s0,16(sp)
    80000d30:	e426                	sd	s1,8(sp)
    80000d32:	1000                	addi	s0,sp,32
    80000d34:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80000d36:	85aa                	mv	a1,a0
    80000d38:	00006517          	auipc	a0,0x6
    80000d3c:	4c850513          	addi	a0,a0,1224 # 80007200 <etext+0x200>
    80000d40:	45e040ef          	jal	ra,8000519e <printf>
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
    80000d44:	4601                	li	a2,0
    80000d46:	4581                	li	a1,0
    80000d48:	8526                	mv	a0,s1
    80000d4a:	f11ff0ef          	jal	ra,80000c5a <vmprint_recurse>
}
    80000d4e:	60e2                	ld	ra,24(sp)
    80000d50:	6442                	ld	s0,16(sp)
    80000d52:	64a2                	ld	s1,8(sp)
    80000d54:	6105                	addi	sp,sp,32
    80000d56:	8082                	ret

0000000080000d58 <pgpte>:

#ifdef LAB_PGTBL
pte_t *
pgpte(pagetable_t pagetable, uint64 va)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e406                	sd	ra,8(sp)
    80000d5c:	e022                	sd	s0,0(sp)
    80000d5e:	0800                	addi	s0,sp,16
  return walk(pagetable, va, 0);
    80000d60:	4601                	li	a2,0
    80000d62:	efaff0ef          	jal	ra,8000045c <walk>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000d6e:	7139                	addi	sp,sp,-64
    80000d70:	fc06                	sd	ra,56(sp)
    80000d72:	f822                	sd	s0,48(sp)
    80000d74:	f426                	sd	s1,40(sp)
    80000d76:	f04a                	sd	s2,32(sp)
    80000d78:	ec4e                	sd	s3,24(sp)
    80000d7a:	e852                	sd	s4,16(sp)
    80000d7c:	e456                	sd	s5,8(sp)
    80000d7e:	e05a                	sd	s6,0(sp)
    80000d80:	0080                	addi	s0,sp,64
    80000d82:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80000d84:	00007497          	auipc	s1,0x7
    80000d88:	2cc48493          	addi	s1,s1,716 # 80008050 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000d8c:	8b26                	mv	s6,s1
    80000d8e:	00006a97          	auipc	s5,0x6
    80000d92:	272a8a93          	addi	s5,s5,626 # 80007000 <etext>
    80000d96:	04000937          	lui	s2,0x4000
    80000d9a:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000d9c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d9e:	0000da17          	auipc	s4,0xd
    80000da2:	cb2a0a13          	addi	s4,s4,-846 # 8000da50 <tickslock>
    char *pa = kalloc();
    80000da6:	be0ff0ef          	jal	ra,80000186 <kalloc>
    80000daa:	862a                	mv	a2,a0
    if(pa == 0)
    80000dac:	c121                	beqz	a0,80000dec <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80000dae:	416485b3          	sub	a1,s1,s6
    80000db2:	858d                	srai	a1,a1,0x3
    80000db4:	000ab783          	ld	a5,0(s5)
    80000db8:	02f585b3          	mul	a1,a1,a5
    80000dbc:	2585                	addiw	a1,a1,1
    80000dbe:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000dc2:	4719                	li	a4,6
    80000dc4:	6685                	lui	a3,0x1
    80000dc6:	40b905b3          	sub	a1,s2,a1
    80000dca:	854e                	mv	a0,s3
    80000dcc:	823ff0ef          	jal	ra,800005ee <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dd0:	16848493          	addi	s1,s1,360
    80000dd4:	fd4499e3          	bne	s1,s4,80000da6 <proc_mapstacks+0x38>
  }
}
    80000dd8:	70e2                	ld	ra,56(sp)
    80000dda:	7442                	ld	s0,48(sp)
    80000ddc:	74a2                	ld	s1,40(sp)
    80000dde:	7902                	ld	s2,32(sp)
    80000de0:	69e2                	ld	s3,24(sp)
    80000de2:	6a42                	ld	s4,16(sp)
    80000de4:	6aa2                	ld	s5,8(sp)
    80000de6:	6b02                	ld	s6,0(sp)
    80000de8:	6121                	addi	sp,sp,64
    80000dea:	8082                	ret
      panic("kalloc");
    80000dec:	00006517          	auipc	a0,0x6
    80000df0:	42450513          	addi	a0,a0,1060 # 80007210 <etext+0x210>
    80000df4:	65e040ef          	jal	ra,80005452 <panic>

0000000080000df8 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000df8:	7139                	addi	sp,sp,-64
    80000dfa:	fc06                	sd	ra,56(sp)
    80000dfc:	f822                	sd	s0,48(sp)
    80000dfe:	f426                	sd	s1,40(sp)
    80000e00:	f04a                	sd	s2,32(sp)
    80000e02:	ec4e                	sd	s3,24(sp)
    80000e04:	e852                	sd	s4,16(sp)
    80000e06:	e456                	sd	s5,8(sp)
    80000e08:	e05a                	sd	s6,0(sp)
    80000e0a:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80000e0c:	00006597          	auipc	a1,0x6
    80000e10:	40c58593          	addi	a1,a1,1036 # 80007218 <etext+0x218>
    80000e14:	00007517          	auipc	a0,0x7
    80000e18:	e0c50513          	addi	a0,a0,-500 # 80007c20 <pid_lock>
    80000e1c:	0c7040ef          	jal	ra,800056e2 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000e20:	00006597          	auipc	a1,0x6
    80000e24:	40058593          	addi	a1,a1,1024 # 80007220 <etext+0x220>
    80000e28:	00007517          	auipc	a0,0x7
    80000e2c:	e1050513          	addi	a0,a0,-496 # 80007c38 <wait_lock>
    80000e30:	0b3040ef          	jal	ra,800056e2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e34:	00007497          	auipc	s1,0x7
    80000e38:	21c48493          	addi	s1,s1,540 # 80008050 <proc>
      initlock(&p->lock, "proc");
    80000e3c:	00006b17          	auipc	s6,0x6
    80000e40:	3f4b0b13          	addi	s6,s6,1012 # 80007230 <etext+0x230>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000e44:	8aa6                	mv	s5,s1
    80000e46:	00006a17          	auipc	s4,0x6
    80000e4a:	1baa0a13          	addi	s4,s4,442 # 80007000 <etext>
    80000e4e:	04000937          	lui	s2,0x4000
    80000e52:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000e54:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e56:	0000d997          	auipc	s3,0xd
    80000e5a:	bfa98993          	addi	s3,s3,-1030 # 8000da50 <tickslock>
      initlock(&p->lock, "proc");
    80000e5e:	85da                	mv	a1,s6
    80000e60:	8526                	mv	a0,s1
    80000e62:	081040ef          	jal	ra,800056e2 <initlock>
      p->state = UNUSED;
    80000e66:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000e6a:	415487b3          	sub	a5,s1,s5
    80000e6e:	878d                	srai	a5,a5,0x3
    80000e70:	000a3703          	ld	a4,0(s4)
    80000e74:	02e787b3          	mul	a5,a5,a4
    80000e78:	2785                	addiw	a5,a5,1
    80000e7a:	00d7979b          	slliw	a5,a5,0xd
    80000e7e:	40f907b3          	sub	a5,s2,a5
    80000e82:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e84:	16848493          	addi	s1,s1,360
    80000e88:	fd349be3          	bne	s1,s3,80000e5e <procinit+0x66>
  }
}
    80000e8c:	70e2                	ld	ra,56(sp)
    80000e8e:	7442                	ld	s0,48(sp)
    80000e90:	74a2                	ld	s1,40(sp)
    80000e92:	7902                	ld	s2,32(sp)
    80000e94:	69e2                	ld	s3,24(sp)
    80000e96:	6a42                	ld	s4,16(sp)
    80000e98:	6aa2                	ld	s5,8(sp)
    80000e9a:	6b02                	ld	s6,0(sp)
    80000e9c:	6121                	addi	sp,sp,64
    80000e9e:	8082                	ret

0000000080000ea0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000ea0:	1141                	addi	sp,sp,-16
    80000ea2:	e422                	sd	s0,8(sp)
    80000ea4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000ea6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000ea8:	2501                	sext.w	a0,a0
    80000eaa:	6422                	ld	s0,8(sp)
    80000eac:	0141                	addi	sp,sp,16
    80000eae:	8082                	ret

0000000080000eb0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000eb0:	1141                	addi	sp,sp,-16
    80000eb2:	e422                	sd	s0,8(sp)
    80000eb4:	0800                	addi	s0,sp,16
    80000eb6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000eb8:	2781                	sext.w	a5,a5
    80000eba:	079e                	slli	a5,a5,0x7
  return c;
}
    80000ebc:	00007517          	auipc	a0,0x7
    80000ec0:	d9450513          	addi	a0,a0,-620 # 80007c50 <cpus>
    80000ec4:	953e                	add	a0,a0,a5
    80000ec6:	6422                	ld	s0,8(sp)
    80000ec8:	0141                	addi	sp,sp,16
    80000eca:	8082                	ret

0000000080000ecc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000ecc:	1101                	addi	sp,sp,-32
    80000ece:	ec06                	sd	ra,24(sp)
    80000ed0:	e822                	sd	s0,16(sp)
    80000ed2:	e426                	sd	s1,8(sp)
    80000ed4:	1000                	addi	s0,sp,32
  push_off();
    80000ed6:	04d040ef          	jal	ra,80005722 <push_off>
    80000eda:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000edc:	2781                	sext.w	a5,a5
    80000ede:	079e                	slli	a5,a5,0x7
    80000ee0:	00007717          	auipc	a4,0x7
    80000ee4:	d4070713          	addi	a4,a4,-704 # 80007c20 <pid_lock>
    80000ee8:	97ba                	add	a5,a5,a4
    80000eea:	7b84                	ld	s1,48(a5)
  pop_off();
    80000eec:	0bb040ef          	jal	ra,800057a6 <pop_off>
  return p;
}
    80000ef0:	8526                	mv	a0,s1
    80000ef2:	60e2                	ld	ra,24(sp)
    80000ef4:	6442                	ld	s0,16(sp)
    80000ef6:	64a2                	ld	s1,8(sp)
    80000ef8:	6105                	addi	sp,sp,32
    80000efa:	8082                	ret

0000000080000efc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000efc:	1141                	addi	sp,sp,-16
    80000efe:	e406                	sd	ra,8(sp)
    80000f00:	e022                	sd	s0,0(sp)
    80000f02:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000f04:	fc9ff0ef          	jal	ra,80000ecc <myproc>
    80000f08:	0f3040ef          	jal	ra,800057fa <release>

  if (first) {
    80000f0c:	00007797          	auipc	a5,0x7
    80000f10:	a547a783          	lw	a5,-1452(a5) # 80007960 <first.1>
    80000f14:	e799                	bnez	a5,80000f22 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000f16:	2bd000ef          	jal	ra,800019d2 <usertrapret>
}
    80000f1a:	60a2                	ld	ra,8(sp)
    80000f1c:	6402                	ld	s0,0(sp)
    80000f1e:	0141                	addi	sp,sp,16
    80000f20:	8082                	ret
    fsinit(ROOTDEV);
    80000f22:	4505                	li	a0,1
    80000f24:	688010ef          	jal	ra,800025ac <fsinit>
    first = 0;
    80000f28:	00007797          	auipc	a5,0x7
    80000f2c:	a207ac23          	sw	zero,-1480(a5) # 80007960 <first.1>
    __sync_synchronize();
    80000f30:	0ff0000f          	fence
    80000f34:	b7cd                	j	80000f16 <forkret+0x1a>

0000000080000f36 <allocpid>:
{
    80000f36:	1101                	addi	sp,sp,-32
    80000f38:	ec06                	sd	ra,24(sp)
    80000f3a:	e822                	sd	s0,16(sp)
    80000f3c:	e426                	sd	s1,8(sp)
    80000f3e:	e04a                	sd	s2,0(sp)
    80000f40:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000f42:	00007917          	auipc	s2,0x7
    80000f46:	cde90913          	addi	s2,s2,-802 # 80007c20 <pid_lock>
    80000f4a:	854a                	mv	a0,s2
    80000f4c:	017040ef          	jal	ra,80005762 <acquire>
  pid = nextpid;
    80000f50:	00007797          	auipc	a5,0x7
    80000f54:	a1478793          	addi	a5,a5,-1516 # 80007964 <nextpid>
    80000f58:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000f5a:	0014871b          	addiw	a4,s1,1
    80000f5e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000f60:	854a                	mv	a0,s2
    80000f62:	099040ef          	jal	ra,800057fa <release>
}
    80000f66:	8526                	mv	a0,s1
    80000f68:	60e2                	ld	ra,24(sp)
    80000f6a:	6442                	ld	s0,16(sp)
    80000f6c:	64a2                	ld	s1,8(sp)
    80000f6e:	6902                	ld	s2,0(sp)
    80000f70:	6105                	addi	sp,sp,32
    80000f72:	8082                	ret

0000000080000f74 <proc_pagetable>:
{
    80000f74:	1101                	addi	sp,sp,-32
    80000f76:	ec06                	sd	ra,24(sp)
    80000f78:	e822                	sd	s0,16(sp)
    80000f7a:	e426                	sd	s1,8(sp)
    80000f7c:	e04a                	sd	s2,0(sp)
    80000f7e:	1000                	addi	s0,sp,32
    80000f80:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000f82:	81fff0ef          	jal	ra,800007a0 <uvmcreate>
    80000f86:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000f88:	cd05                	beqz	a0,80000fc0 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000f8a:	4729                	li	a4,10
    80000f8c:	00005697          	auipc	a3,0x5
    80000f90:	07468693          	addi	a3,a3,116 # 80006000 <_trampoline>
    80000f94:	6605                	lui	a2,0x1
    80000f96:	040005b7          	lui	a1,0x4000
    80000f9a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f9c:	05b2                	slli	a1,a1,0xc
    80000f9e:	da0ff0ef          	jal	ra,8000053e <mappages>
    80000fa2:	02054663          	bltz	a0,80000fce <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000fa6:	4719                	li	a4,6
    80000fa8:	05893683          	ld	a3,88(s2)
    80000fac:	6605                	lui	a2,0x1
    80000fae:	020005b7          	lui	a1,0x2000
    80000fb2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000fb4:	05b6                	slli	a1,a1,0xd
    80000fb6:	8526                	mv	a0,s1
    80000fb8:	d86ff0ef          	jal	ra,8000053e <mappages>
    80000fbc:	00054f63          	bltz	a0,80000fda <proc_pagetable+0x66>
}
    80000fc0:	8526                	mv	a0,s1
    80000fc2:	60e2                	ld	ra,24(sp)
    80000fc4:	6442                	ld	s0,16(sp)
    80000fc6:	64a2                	ld	s1,8(sp)
    80000fc8:	6902                	ld	s2,0(sp)
    80000fca:	6105                	addi	sp,sp,32
    80000fcc:	8082                	ret
    uvmfree(pagetable, 0);
    80000fce:	4581                	li	a1,0
    80000fd0:	8526                	mv	a0,s1
    80000fd2:	991ff0ef          	jal	ra,80000962 <uvmfree>
    return 0;
    80000fd6:	4481                	li	s1,0
    80000fd8:	b7e5                	j	80000fc0 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000fda:	4681                	li	a3,0
    80000fdc:	4605                	li	a2,1
    80000fde:	040005b7          	lui	a1,0x4000
    80000fe2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000fe4:	05b2                	slli	a1,a1,0xc
    80000fe6:	8526                	mv	a0,s1
    80000fe8:	efcff0ef          	jal	ra,800006e4 <uvmunmap>
    uvmfree(pagetable, 0);
    80000fec:	4581                	li	a1,0
    80000fee:	8526                	mv	a0,s1
    80000ff0:	973ff0ef          	jal	ra,80000962 <uvmfree>
    return 0;
    80000ff4:	4481                	li	s1,0
    80000ff6:	b7e9                	j	80000fc0 <proc_pagetable+0x4c>

0000000080000ff8 <proc_freepagetable>:
{
    80000ff8:	1101                	addi	sp,sp,-32
    80000ffa:	ec06                	sd	ra,24(sp)
    80000ffc:	e822                	sd	s0,16(sp)
    80000ffe:	e426                	sd	s1,8(sp)
    80001000:	e04a                	sd	s2,0(sp)
    80001002:	1000                	addi	s0,sp,32
    80001004:	84aa                	mv	s1,a0
    80001006:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001008:	4681                	li	a3,0
    8000100a:	4605                	li	a2,1
    8000100c:	040005b7          	lui	a1,0x4000
    80001010:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001012:	05b2                	slli	a1,a1,0xc
    80001014:	ed0ff0ef          	jal	ra,800006e4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001018:	4681                	li	a3,0
    8000101a:	4605                	li	a2,1
    8000101c:	020005b7          	lui	a1,0x2000
    80001020:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001022:	05b6                	slli	a1,a1,0xd
    80001024:	8526                	mv	a0,s1
    80001026:	ebeff0ef          	jal	ra,800006e4 <uvmunmap>
  uvmfree(pagetable, sz);
    8000102a:	85ca                	mv	a1,s2
    8000102c:	8526                	mv	a0,s1
    8000102e:	935ff0ef          	jal	ra,80000962 <uvmfree>
}
    80001032:	60e2                	ld	ra,24(sp)
    80001034:	6442                	ld	s0,16(sp)
    80001036:	64a2                	ld	s1,8(sp)
    80001038:	6902                	ld	s2,0(sp)
    8000103a:	6105                	addi	sp,sp,32
    8000103c:	8082                	ret

000000008000103e <freeproc>:
{
    8000103e:	1101                	addi	sp,sp,-32
    80001040:	ec06                	sd	ra,24(sp)
    80001042:	e822                	sd	s0,16(sp)
    80001044:	e426                	sd	s1,8(sp)
    80001046:	1000                	addi	s0,sp,32
    80001048:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000104a:	6d28                	ld	a0,88(a0)
    8000104c:	c119                	beqz	a0,80001052 <freeproc+0x14>
    kfree((void*)p->trapframe);
    8000104e:	844ff0ef          	jal	ra,80000092 <kfree>
  p->trapframe = 0;
    80001052:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001056:	68a8                	ld	a0,80(s1)
    80001058:	c501                	beqz	a0,80001060 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    8000105a:	64ac                	ld	a1,72(s1)
    8000105c:	f9dff0ef          	jal	ra,80000ff8 <proc_freepagetable>
  p->pagetable = 0;
    80001060:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001064:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001068:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000106c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001070:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001074:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001078:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000107c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001080:	0004ac23          	sw	zero,24(s1)
}
    80001084:	60e2                	ld	ra,24(sp)
    80001086:	6442                	ld	s0,16(sp)
    80001088:	64a2                	ld	s1,8(sp)
    8000108a:	6105                	addi	sp,sp,32
    8000108c:	8082                	ret

000000008000108e <allocproc>:
{
    8000108e:	1101                	addi	sp,sp,-32
    80001090:	ec06                	sd	ra,24(sp)
    80001092:	e822                	sd	s0,16(sp)
    80001094:	e426                	sd	s1,8(sp)
    80001096:	e04a                	sd	s2,0(sp)
    80001098:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000109a:	00007497          	auipc	s1,0x7
    8000109e:	fb648493          	addi	s1,s1,-74 # 80008050 <proc>
    800010a2:	0000d917          	auipc	s2,0xd
    800010a6:	9ae90913          	addi	s2,s2,-1618 # 8000da50 <tickslock>
    acquire(&p->lock);
    800010aa:	8526                	mv	a0,s1
    800010ac:	6b6040ef          	jal	ra,80005762 <acquire>
    if(p->state == UNUSED) {
    800010b0:	4c9c                	lw	a5,24(s1)
    800010b2:	cb91                	beqz	a5,800010c6 <allocproc+0x38>
      release(&p->lock);
    800010b4:	8526                	mv	a0,s1
    800010b6:	744040ef          	jal	ra,800057fa <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800010ba:	16848493          	addi	s1,s1,360
    800010be:	ff2496e3          	bne	s1,s2,800010aa <allocproc+0x1c>
  return 0;
    800010c2:	4481                	li	s1,0
    800010c4:	a089                	j	80001106 <allocproc+0x78>
  p->pid = allocpid();
    800010c6:	e71ff0ef          	jal	ra,80000f36 <allocpid>
    800010ca:	d888                	sw	a0,48(s1)
  p->state = USED;
    800010cc:	4785                	li	a5,1
    800010ce:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800010d0:	8b6ff0ef          	jal	ra,80000186 <kalloc>
    800010d4:	892a                	mv	s2,a0
    800010d6:	eca8                	sd	a0,88(s1)
    800010d8:	cd15                	beqz	a0,80001114 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    800010da:	8526                	mv	a0,s1
    800010dc:	e99ff0ef          	jal	ra,80000f74 <proc_pagetable>
    800010e0:	892a                	mv	s2,a0
    800010e2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800010e4:	c121                	beqz	a0,80001124 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    800010e6:	07000613          	li	a2,112
    800010ea:	4581                	li	a1,0
    800010ec:	06048513          	addi	a0,s1,96
    800010f0:	8f0ff0ef          	jal	ra,800001e0 <memset>
  p->context.ra = (uint64)forkret;
    800010f4:	00000797          	auipc	a5,0x0
    800010f8:	e0878793          	addi	a5,a5,-504 # 80000efc <forkret>
    800010fc:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800010fe:	60bc                	ld	a5,64(s1)
    80001100:	6705                	lui	a4,0x1
    80001102:	97ba                	add	a5,a5,a4
    80001104:	f4bc                	sd	a5,104(s1)
}
    80001106:	8526                	mv	a0,s1
    80001108:	60e2                	ld	ra,24(sp)
    8000110a:	6442                	ld	s0,16(sp)
    8000110c:	64a2                	ld	s1,8(sp)
    8000110e:	6902                	ld	s2,0(sp)
    80001110:	6105                	addi	sp,sp,32
    80001112:	8082                	ret
    freeproc(p);
    80001114:	8526                	mv	a0,s1
    80001116:	f29ff0ef          	jal	ra,8000103e <freeproc>
    release(&p->lock);
    8000111a:	8526                	mv	a0,s1
    8000111c:	6de040ef          	jal	ra,800057fa <release>
    return 0;
    80001120:	84ca                	mv	s1,s2
    80001122:	b7d5                	j	80001106 <allocproc+0x78>
    freeproc(p);
    80001124:	8526                	mv	a0,s1
    80001126:	f19ff0ef          	jal	ra,8000103e <freeproc>
    release(&p->lock);
    8000112a:	8526                	mv	a0,s1
    8000112c:	6ce040ef          	jal	ra,800057fa <release>
    return 0;
    80001130:	84ca                	mv	s1,s2
    80001132:	bfd1                	j	80001106 <allocproc+0x78>

0000000080001134 <userinit>:
{
    80001134:	1101                	addi	sp,sp,-32
    80001136:	ec06                	sd	ra,24(sp)
    80001138:	e822                	sd	s0,16(sp)
    8000113a:	e426                	sd	s1,8(sp)
    8000113c:	1000                	addi	s0,sp,32
  p = allocproc();
    8000113e:	f51ff0ef          	jal	ra,8000108e <allocproc>
    80001142:	84aa                	mv	s1,a0
  initproc = p;
    80001144:	00007797          	auipc	a5,0x7
    80001148:	88a7be23          	sd	a0,-1892(a5) # 800079e0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    8000114c:	03400613          	li	a2,52
    80001150:	00007597          	auipc	a1,0x7
    80001154:	82058593          	addi	a1,a1,-2016 # 80007970 <initcode>
    80001158:	6928                	ld	a0,80(a0)
    8000115a:	e6cff0ef          	jal	ra,800007c6 <uvmfirst>
  p->sz = PGSIZE;
    8000115e:	6785                	lui	a5,0x1
    80001160:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001162:	6cb8                	ld	a4,88(s1)
    80001164:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001168:	6cb8                	ld	a4,88(s1)
    8000116a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    8000116c:	4641                	li	a2,16
    8000116e:	00006597          	auipc	a1,0x6
    80001172:	0ca58593          	addi	a1,a1,202 # 80007238 <etext+0x238>
    80001176:	15848513          	addi	a0,s1,344
    8000117a:	9acff0ef          	jal	ra,80000326 <safestrcpy>
  p->cwd = namei("/");
    8000117e:	00006517          	auipc	a0,0x6
    80001182:	0ca50513          	addi	a0,a0,202 # 80007248 <etext+0x248>
    80001186:	50d010ef          	jal	ra,80002e92 <namei>
    8000118a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000118e:	478d                	li	a5,3
    80001190:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001192:	8526                	mv	a0,s1
    80001194:	666040ef          	jal	ra,800057fa <release>
}
    80001198:	60e2                	ld	ra,24(sp)
    8000119a:	6442                	ld	s0,16(sp)
    8000119c:	64a2                	ld	s1,8(sp)
    8000119e:	6105                	addi	sp,sp,32
    800011a0:	8082                	ret

00000000800011a2 <growproc>:
{
    800011a2:	1101                	addi	sp,sp,-32
    800011a4:	ec06                	sd	ra,24(sp)
    800011a6:	e822                	sd	s0,16(sp)
    800011a8:	e426                	sd	s1,8(sp)
    800011aa:	e04a                	sd	s2,0(sp)
    800011ac:	1000                	addi	s0,sp,32
    800011ae:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800011b0:	d1dff0ef          	jal	ra,80000ecc <myproc>
    800011b4:	84aa                	mv	s1,a0
  sz = p->sz;
    800011b6:	652c                	ld	a1,72(a0)
  if(n > 0){
    800011b8:	01204c63          	bgtz	s2,800011d0 <growproc+0x2e>
  } else if(n < 0){
    800011bc:	02094463          	bltz	s2,800011e4 <growproc+0x42>
  p->sz = sz;
    800011c0:	e4ac                	sd	a1,72(s1)
  return 0;
    800011c2:	4501                	li	a0,0
}
    800011c4:	60e2                	ld	ra,24(sp)
    800011c6:	6442                	ld	s0,16(sp)
    800011c8:	64a2                	ld	s1,8(sp)
    800011ca:	6902                	ld	s2,0(sp)
    800011cc:	6105                	addi	sp,sp,32
    800011ce:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800011d0:	4691                	li	a3,4
    800011d2:	00b90633          	add	a2,s2,a1
    800011d6:	6928                	ld	a0,80(a0)
    800011d8:	e90ff0ef          	jal	ra,80000868 <uvmalloc>
    800011dc:	85aa                	mv	a1,a0
    800011de:	f16d                	bnez	a0,800011c0 <growproc+0x1e>
      return -1;
    800011e0:	557d                	li	a0,-1
    800011e2:	b7cd                	j	800011c4 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800011e4:	00b90633          	add	a2,s2,a1
    800011e8:	6928                	ld	a0,80(a0)
    800011ea:	e3aff0ef          	jal	ra,80000824 <uvmdealloc>
    800011ee:	85aa                	mv	a1,a0
    800011f0:	bfc1                	j	800011c0 <growproc+0x1e>

00000000800011f2 <fork>:
{
    800011f2:	7139                	addi	sp,sp,-64
    800011f4:	fc06                	sd	ra,56(sp)
    800011f6:	f822                	sd	s0,48(sp)
    800011f8:	f426                	sd	s1,40(sp)
    800011fa:	f04a                	sd	s2,32(sp)
    800011fc:	ec4e                	sd	s3,24(sp)
    800011fe:	e852                	sd	s4,16(sp)
    80001200:	e456                	sd	s5,8(sp)
    80001202:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001204:	cc9ff0ef          	jal	ra,80000ecc <myproc>
    80001208:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000120a:	e85ff0ef          	jal	ra,8000108e <allocproc>
    8000120e:	0e050663          	beqz	a0,800012fa <fork+0x108>
    80001212:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001214:	048ab603          	ld	a2,72(s5)
    80001218:	692c                	ld	a1,80(a0)
    8000121a:	050ab503          	ld	a0,80(s5)
    8000121e:	f76ff0ef          	jal	ra,80000994 <uvmcopy>
    80001222:	04054863          	bltz	a0,80001272 <fork+0x80>
  np->sz = p->sz;
    80001226:	048ab783          	ld	a5,72(s5)
    8000122a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    8000122e:	058ab683          	ld	a3,88(s5)
    80001232:	87b6                	mv	a5,a3
    80001234:	058a3703          	ld	a4,88(s4)
    80001238:	12068693          	addi	a3,a3,288
    8000123c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001240:	6788                	ld	a0,8(a5)
    80001242:	6b8c                	ld	a1,16(a5)
    80001244:	6f90                	ld	a2,24(a5)
    80001246:	01073023          	sd	a6,0(a4)
    8000124a:	e708                	sd	a0,8(a4)
    8000124c:	eb0c                	sd	a1,16(a4)
    8000124e:	ef10                	sd	a2,24(a4)
    80001250:	02078793          	addi	a5,a5,32
    80001254:	02070713          	addi	a4,a4,32
    80001258:	fed792e3          	bne	a5,a3,8000123c <fork+0x4a>
  np->trapframe->a0 = 0;
    8000125c:	058a3783          	ld	a5,88(s4)
    80001260:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001264:	0d0a8493          	addi	s1,s5,208
    80001268:	0d0a0913          	addi	s2,s4,208
    8000126c:	150a8993          	addi	s3,s5,336
    80001270:	a829                	j	8000128a <fork+0x98>
    freeproc(np);
    80001272:	8552                	mv	a0,s4
    80001274:	dcbff0ef          	jal	ra,8000103e <freeproc>
    release(&np->lock);
    80001278:	8552                	mv	a0,s4
    8000127a:	580040ef          	jal	ra,800057fa <release>
    return -1;
    8000127e:	597d                	li	s2,-1
    80001280:	a09d                	j	800012e6 <fork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001282:	04a1                	addi	s1,s1,8
    80001284:	0921                	addi	s2,s2,8
    80001286:	01348963          	beq	s1,s3,80001298 <fork+0xa6>
    if(p->ofile[i])
    8000128a:	6088                	ld	a0,0(s1)
    8000128c:	d97d                	beqz	a0,80001282 <fork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    8000128e:	1b2020ef          	jal	ra,80003440 <filedup>
    80001292:	00a93023          	sd	a0,0(s2)
    80001296:	b7f5                	j	80001282 <fork+0x90>
  np->cwd = idup(p->cwd);
    80001298:	150ab503          	ld	a0,336(s5)
    8000129c:	508010ef          	jal	ra,800027a4 <idup>
    800012a0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800012a4:	4641                	li	a2,16
    800012a6:	158a8593          	addi	a1,s5,344
    800012aa:	158a0513          	addi	a0,s4,344
    800012ae:	878ff0ef          	jal	ra,80000326 <safestrcpy>
  pid = np->pid;
    800012b2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    800012b6:	8552                	mv	a0,s4
    800012b8:	542040ef          	jal	ra,800057fa <release>
  acquire(&wait_lock);
    800012bc:	00007497          	auipc	s1,0x7
    800012c0:	97c48493          	addi	s1,s1,-1668 # 80007c38 <wait_lock>
    800012c4:	8526                	mv	a0,s1
    800012c6:	49c040ef          	jal	ra,80005762 <acquire>
  np->parent = p;
    800012ca:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800012ce:	8526                	mv	a0,s1
    800012d0:	52a040ef          	jal	ra,800057fa <release>
  acquire(&np->lock);
    800012d4:	8552                	mv	a0,s4
    800012d6:	48c040ef          	jal	ra,80005762 <acquire>
  np->state = RUNNABLE;
    800012da:	478d                	li	a5,3
    800012dc:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800012e0:	8552                	mv	a0,s4
    800012e2:	518040ef          	jal	ra,800057fa <release>
}
    800012e6:	854a                	mv	a0,s2
    800012e8:	70e2                	ld	ra,56(sp)
    800012ea:	7442                	ld	s0,48(sp)
    800012ec:	74a2                	ld	s1,40(sp)
    800012ee:	7902                	ld	s2,32(sp)
    800012f0:	69e2                	ld	s3,24(sp)
    800012f2:	6a42                	ld	s4,16(sp)
    800012f4:	6aa2                	ld	s5,8(sp)
    800012f6:	6121                	addi	sp,sp,64
    800012f8:	8082                	ret
    return -1;
    800012fa:	597d                	li	s2,-1
    800012fc:	b7ed                	j	800012e6 <fork+0xf4>

00000000800012fe <scheduler>:
{
    800012fe:	715d                	addi	sp,sp,-80
    80001300:	e486                	sd	ra,72(sp)
    80001302:	e0a2                	sd	s0,64(sp)
    80001304:	fc26                	sd	s1,56(sp)
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f44e                	sd	s3,40(sp)
    8000130a:	f052                	sd	s4,32(sp)
    8000130c:	ec56                	sd	s5,24(sp)
    8000130e:	e85a                	sd	s6,16(sp)
    80001310:	e45e                	sd	s7,8(sp)
    80001312:	e062                	sd	s8,0(sp)
    80001314:	0880                	addi	s0,sp,80
    80001316:	8792                	mv	a5,tp
  int id = r_tp();
    80001318:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000131a:	00779b13          	slli	s6,a5,0x7
    8000131e:	00007717          	auipc	a4,0x7
    80001322:	90270713          	addi	a4,a4,-1790 # 80007c20 <pid_lock>
    80001326:	975a                	add	a4,a4,s6
    80001328:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000132c:	00007717          	auipc	a4,0x7
    80001330:	92c70713          	addi	a4,a4,-1748 # 80007c58 <cpus+0x8>
    80001334:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001336:	4c11                	li	s8,4
        c->proc = p;
    80001338:	079e                	slli	a5,a5,0x7
    8000133a:	00007a17          	auipc	s4,0x7
    8000133e:	8e6a0a13          	addi	s4,s4,-1818 # 80007c20 <pid_lock>
    80001342:	9a3e                	add	s4,s4,a5
        found = 1;
    80001344:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001346:	0000c997          	auipc	s3,0xc
    8000134a:	70a98993          	addi	s3,s3,1802 # 8000da50 <tickslock>
    8000134e:	a0a9                	j	80001398 <scheduler+0x9a>
      release(&p->lock);
    80001350:	8526                	mv	a0,s1
    80001352:	4a8040ef          	jal	ra,800057fa <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001356:	16848493          	addi	s1,s1,360
    8000135a:	03348563          	beq	s1,s3,80001384 <scheduler+0x86>
      acquire(&p->lock);
    8000135e:	8526                	mv	a0,s1
    80001360:	402040ef          	jal	ra,80005762 <acquire>
      if(p->state == RUNNABLE) {
    80001364:	4c9c                	lw	a5,24(s1)
    80001366:	ff2795e3          	bne	a5,s2,80001350 <scheduler+0x52>
        p->state = RUNNING;
    8000136a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000136e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001372:	06048593          	addi	a1,s1,96
    80001376:	855a                	mv	a0,s6
    80001378:	5b4000ef          	jal	ra,8000192c <swtch>
        c->proc = 0;
    8000137c:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001380:	8ade                	mv	s5,s7
    80001382:	b7f9                	j	80001350 <scheduler+0x52>
    if(found == 0) {
    80001384:	000a9a63          	bnez	s5,80001398 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001388:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000138c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001390:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001394:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001398:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000139c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013a0:	10079073          	csrw	sstatus,a5
    int found = 0;
    800013a4:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800013a6:	00007497          	auipc	s1,0x7
    800013aa:	caa48493          	addi	s1,s1,-854 # 80008050 <proc>
      if(p->state == RUNNABLE) {
    800013ae:	490d                	li	s2,3
    800013b0:	b77d                	j	8000135e <scheduler+0x60>

00000000800013b2 <sched>:
{
    800013b2:	7179                	addi	sp,sp,-48
    800013b4:	f406                	sd	ra,40(sp)
    800013b6:	f022                	sd	s0,32(sp)
    800013b8:	ec26                	sd	s1,24(sp)
    800013ba:	e84a                	sd	s2,16(sp)
    800013bc:	e44e                	sd	s3,8(sp)
    800013be:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800013c0:	b0dff0ef          	jal	ra,80000ecc <myproc>
    800013c4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800013c6:	332040ef          	jal	ra,800056f8 <holding>
    800013ca:	c92d                	beqz	a0,8000143c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800013cc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800013ce:	2781                	sext.w	a5,a5
    800013d0:	079e                	slli	a5,a5,0x7
    800013d2:	00007717          	auipc	a4,0x7
    800013d6:	84e70713          	addi	a4,a4,-1970 # 80007c20 <pid_lock>
    800013da:	97ba                	add	a5,a5,a4
    800013dc:	0a87a703          	lw	a4,168(a5)
    800013e0:	4785                	li	a5,1
    800013e2:	06f71363          	bne	a4,a5,80001448 <sched+0x96>
  if(p->state == RUNNING)
    800013e6:	4c98                	lw	a4,24(s1)
    800013e8:	4791                	li	a5,4
    800013ea:	06f70563          	beq	a4,a5,80001454 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013ee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800013f2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800013f4:	e7b5                	bnez	a5,80001460 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800013f6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800013f8:	00007917          	auipc	s2,0x7
    800013fc:	82890913          	addi	s2,s2,-2008 # 80007c20 <pid_lock>
    80001400:	2781                	sext.w	a5,a5
    80001402:	079e                	slli	a5,a5,0x7
    80001404:	97ca                	add	a5,a5,s2
    80001406:	0ac7a983          	lw	s3,172(a5)
    8000140a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000140c:	2781                	sext.w	a5,a5
    8000140e:	079e                	slli	a5,a5,0x7
    80001410:	00007597          	auipc	a1,0x7
    80001414:	84858593          	addi	a1,a1,-1976 # 80007c58 <cpus+0x8>
    80001418:	95be                	add	a1,a1,a5
    8000141a:	06048513          	addi	a0,s1,96
    8000141e:	50e000ef          	jal	ra,8000192c <swtch>
    80001422:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001424:	2781                	sext.w	a5,a5
    80001426:	079e                	slli	a5,a5,0x7
    80001428:	993e                	add	s2,s2,a5
    8000142a:	0b392623          	sw	s3,172(s2)
}
    8000142e:	70a2                	ld	ra,40(sp)
    80001430:	7402                	ld	s0,32(sp)
    80001432:	64e2                	ld	s1,24(sp)
    80001434:	6942                	ld	s2,16(sp)
    80001436:	69a2                	ld	s3,8(sp)
    80001438:	6145                	addi	sp,sp,48
    8000143a:	8082                	ret
    panic("sched p->lock");
    8000143c:	00006517          	auipc	a0,0x6
    80001440:	e1450513          	addi	a0,a0,-492 # 80007250 <etext+0x250>
    80001444:	00e040ef          	jal	ra,80005452 <panic>
    panic("sched locks");
    80001448:	00006517          	auipc	a0,0x6
    8000144c:	e1850513          	addi	a0,a0,-488 # 80007260 <etext+0x260>
    80001450:	002040ef          	jal	ra,80005452 <panic>
    panic("sched running");
    80001454:	00006517          	auipc	a0,0x6
    80001458:	e1c50513          	addi	a0,a0,-484 # 80007270 <etext+0x270>
    8000145c:	7f7030ef          	jal	ra,80005452 <panic>
    panic("sched interruptible");
    80001460:	00006517          	auipc	a0,0x6
    80001464:	e2050513          	addi	a0,a0,-480 # 80007280 <etext+0x280>
    80001468:	7eb030ef          	jal	ra,80005452 <panic>

000000008000146c <yield>:
{
    8000146c:	1101                	addi	sp,sp,-32
    8000146e:	ec06                	sd	ra,24(sp)
    80001470:	e822                	sd	s0,16(sp)
    80001472:	e426                	sd	s1,8(sp)
    80001474:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001476:	a57ff0ef          	jal	ra,80000ecc <myproc>
    8000147a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000147c:	2e6040ef          	jal	ra,80005762 <acquire>
  p->state = RUNNABLE;
    80001480:	478d                	li	a5,3
    80001482:	cc9c                	sw	a5,24(s1)
  sched();
    80001484:	f2fff0ef          	jal	ra,800013b2 <sched>
  release(&p->lock);
    80001488:	8526                	mv	a0,s1
    8000148a:	370040ef          	jal	ra,800057fa <release>
}
    8000148e:	60e2                	ld	ra,24(sp)
    80001490:	6442                	ld	s0,16(sp)
    80001492:	64a2                	ld	s1,8(sp)
    80001494:	6105                	addi	sp,sp,32
    80001496:	8082                	ret

0000000080001498 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001498:	7179                	addi	sp,sp,-48
    8000149a:	f406                	sd	ra,40(sp)
    8000149c:	f022                	sd	s0,32(sp)
    8000149e:	ec26                	sd	s1,24(sp)
    800014a0:	e84a                	sd	s2,16(sp)
    800014a2:	e44e                	sd	s3,8(sp)
    800014a4:	1800                	addi	s0,sp,48
    800014a6:	89aa                	mv	s3,a0
    800014a8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800014aa:	a23ff0ef          	jal	ra,80000ecc <myproc>
    800014ae:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800014b0:	2b2040ef          	jal	ra,80005762 <acquire>
  release(lk);
    800014b4:	854a                	mv	a0,s2
    800014b6:	344040ef          	jal	ra,800057fa <release>

  // Go to sleep.
  p->chan = chan;
    800014ba:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800014be:	4789                	li	a5,2
    800014c0:	cc9c                	sw	a5,24(s1)

  sched();
    800014c2:	ef1ff0ef          	jal	ra,800013b2 <sched>

  // Tidy up.
  p->chan = 0;
    800014c6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800014ca:	8526                	mv	a0,s1
    800014cc:	32e040ef          	jal	ra,800057fa <release>
  acquire(lk);
    800014d0:	854a                	mv	a0,s2
    800014d2:	290040ef          	jal	ra,80005762 <acquire>
}
    800014d6:	70a2                	ld	ra,40(sp)
    800014d8:	7402                	ld	s0,32(sp)
    800014da:	64e2                	ld	s1,24(sp)
    800014dc:	6942                	ld	s2,16(sp)
    800014de:	69a2                	ld	s3,8(sp)
    800014e0:	6145                	addi	sp,sp,48
    800014e2:	8082                	ret

00000000800014e4 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800014e4:	7139                	addi	sp,sp,-64
    800014e6:	fc06                	sd	ra,56(sp)
    800014e8:	f822                	sd	s0,48(sp)
    800014ea:	f426                	sd	s1,40(sp)
    800014ec:	f04a                	sd	s2,32(sp)
    800014ee:	ec4e                	sd	s3,24(sp)
    800014f0:	e852                	sd	s4,16(sp)
    800014f2:	e456                	sd	s5,8(sp)
    800014f4:	0080                	addi	s0,sp,64
    800014f6:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800014f8:	00007497          	auipc	s1,0x7
    800014fc:	b5848493          	addi	s1,s1,-1192 # 80008050 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001500:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001502:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001504:	0000c917          	auipc	s2,0xc
    80001508:	54c90913          	addi	s2,s2,1356 # 8000da50 <tickslock>
    8000150c:	a801                	j	8000151c <wakeup+0x38>
      }
      release(&p->lock);
    8000150e:	8526                	mv	a0,s1
    80001510:	2ea040ef          	jal	ra,800057fa <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001514:	16848493          	addi	s1,s1,360
    80001518:	03248263          	beq	s1,s2,8000153c <wakeup+0x58>
    if(p != myproc()){
    8000151c:	9b1ff0ef          	jal	ra,80000ecc <myproc>
    80001520:	fea48ae3          	beq	s1,a0,80001514 <wakeup+0x30>
      acquire(&p->lock);
    80001524:	8526                	mv	a0,s1
    80001526:	23c040ef          	jal	ra,80005762 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000152a:	4c9c                	lw	a5,24(s1)
    8000152c:	ff3791e3          	bne	a5,s3,8000150e <wakeup+0x2a>
    80001530:	709c                	ld	a5,32(s1)
    80001532:	fd479ee3          	bne	a5,s4,8000150e <wakeup+0x2a>
        p->state = RUNNABLE;
    80001536:	0154ac23          	sw	s5,24(s1)
    8000153a:	bfd1                	j	8000150e <wakeup+0x2a>
    }
  }
}
    8000153c:	70e2                	ld	ra,56(sp)
    8000153e:	7442                	ld	s0,48(sp)
    80001540:	74a2                	ld	s1,40(sp)
    80001542:	7902                	ld	s2,32(sp)
    80001544:	69e2                	ld	s3,24(sp)
    80001546:	6a42                	ld	s4,16(sp)
    80001548:	6aa2                	ld	s5,8(sp)
    8000154a:	6121                	addi	sp,sp,64
    8000154c:	8082                	ret

000000008000154e <reparent>:
{
    8000154e:	7179                	addi	sp,sp,-48
    80001550:	f406                	sd	ra,40(sp)
    80001552:	f022                	sd	s0,32(sp)
    80001554:	ec26                	sd	s1,24(sp)
    80001556:	e84a                	sd	s2,16(sp)
    80001558:	e44e                	sd	s3,8(sp)
    8000155a:	e052                	sd	s4,0(sp)
    8000155c:	1800                	addi	s0,sp,48
    8000155e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001560:	00007497          	auipc	s1,0x7
    80001564:	af048493          	addi	s1,s1,-1296 # 80008050 <proc>
      pp->parent = initproc;
    80001568:	00006a17          	auipc	s4,0x6
    8000156c:	478a0a13          	addi	s4,s4,1144 # 800079e0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001570:	0000c997          	auipc	s3,0xc
    80001574:	4e098993          	addi	s3,s3,1248 # 8000da50 <tickslock>
    80001578:	a029                	j	80001582 <reparent+0x34>
    8000157a:	16848493          	addi	s1,s1,360
    8000157e:	01348b63          	beq	s1,s3,80001594 <reparent+0x46>
    if(pp->parent == p){
    80001582:	7c9c                	ld	a5,56(s1)
    80001584:	ff279be3          	bne	a5,s2,8000157a <reparent+0x2c>
      pp->parent = initproc;
    80001588:	000a3503          	ld	a0,0(s4)
    8000158c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000158e:	f57ff0ef          	jal	ra,800014e4 <wakeup>
    80001592:	b7e5                	j	8000157a <reparent+0x2c>
}
    80001594:	70a2                	ld	ra,40(sp)
    80001596:	7402                	ld	s0,32(sp)
    80001598:	64e2                	ld	s1,24(sp)
    8000159a:	6942                	ld	s2,16(sp)
    8000159c:	69a2                	ld	s3,8(sp)
    8000159e:	6a02                	ld	s4,0(sp)
    800015a0:	6145                	addi	sp,sp,48
    800015a2:	8082                	ret

00000000800015a4 <exit>:
{
    800015a4:	7179                	addi	sp,sp,-48
    800015a6:	f406                	sd	ra,40(sp)
    800015a8:	f022                	sd	s0,32(sp)
    800015aa:	ec26                	sd	s1,24(sp)
    800015ac:	e84a                	sd	s2,16(sp)
    800015ae:	e44e                	sd	s3,8(sp)
    800015b0:	e052                	sd	s4,0(sp)
    800015b2:	1800                	addi	s0,sp,48
    800015b4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800015b6:	917ff0ef          	jal	ra,80000ecc <myproc>
    800015ba:	89aa                	mv	s3,a0
  if(p == initproc)
    800015bc:	00006797          	auipc	a5,0x6
    800015c0:	4247b783          	ld	a5,1060(a5) # 800079e0 <initproc>
    800015c4:	0d050493          	addi	s1,a0,208
    800015c8:	15050913          	addi	s2,a0,336
    800015cc:	00a79f63          	bne	a5,a0,800015ea <exit+0x46>
    panic("init exiting");
    800015d0:	00006517          	auipc	a0,0x6
    800015d4:	cc850513          	addi	a0,a0,-824 # 80007298 <etext+0x298>
    800015d8:	67b030ef          	jal	ra,80005452 <panic>
      fileclose(f);
    800015dc:	6ab010ef          	jal	ra,80003486 <fileclose>
      p->ofile[fd] = 0;
    800015e0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800015e4:	04a1                	addi	s1,s1,8
    800015e6:	01248563          	beq	s1,s2,800015f0 <exit+0x4c>
    if(p->ofile[fd]){
    800015ea:	6088                	ld	a0,0(s1)
    800015ec:	f965                	bnez	a0,800015dc <exit+0x38>
    800015ee:	bfdd                	j	800015e4 <exit+0x40>
  begin_op();
    800015f0:	27f010ef          	jal	ra,8000306e <begin_op>
  iput(p->cwd);
    800015f4:	1509b503          	ld	a0,336(s3)
    800015f8:	360010ef          	jal	ra,80002958 <iput>
  end_op();
    800015fc:	2e1010ef          	jal	ra,800030dc <end_op>
  p->cwd = 0;
    80001600:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001604:	00006497          	auipc	s1,0x6
    80001608:	63448493          	addi	s1,s1,1588 # 80007c38 <wait_lock>
    8000160c:	8526                	mv	a0,s1
    8000160e:	154040ef          	jal	ra,80005762 <acquire>
  reparent(p);
    80001612:	854e                	mv	a0,s3
    80001614:	f3bff0ef          	jal	ra,8000154e <reparent>
  wakeup(p->parent);
    80001618:	0389b503          	ld	a0,56(s3)
    8000161c:	ec9ff0ef          	jal	ra,800014e4 <wakeup>
  acquire(&p->lock);
    80001620:	854e                	mv	a0,s3
    80001622:	140040ef          	jal	ra,80005762 <acquire>
  p->xstate = status;
    80001626:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000162a:	4795                	li	a5,5
    8000162c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001630:	8526                	mv	a0,s1
    80001632:	1c8040ef          	jal	ra,800057fa <release>
  sched();
    80001636:	d7dff0ef          	jal	ra,800013b2 <sched>
  panic("zombie exit");
    8000163a:	00006517          	auipc	a0,0x6
    8000163e:	c6e50513          	addi	a0,a0,-914 # 800072a8 <etext+0x2a8>
    80001642:	611030ef          	jal	ra,80005452 <panic>

0000000080001646 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001646:	7179                	addi	sp,sp,-48
    80001648:	f406                	sd	ra,40(sp)
    8000164a:	f022                	sd	s0,32(sp)
    8000164c:	ec26                	sd	s1,24(sp)
    8000164e:	e84a                	sd	s2,16(sp)
    80001650:	e44e                	sd	s3,8(sp)
    80001652:	1800                	addi	s0,sp,48
    80001654:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001656:	00007497          	auipc	s1,0x7
    8000165a:	9fa48493          	addi	s1,s1,-1542 # 80008050 <proc>
    8000165e:	0000c997          	auipc	s3,0xc
    80001662:	3f298993          	addi	s3,s3,1010 # 8000da50 <tickslock>
    acquire(&p->lock);
    80001666:	8526                	mv	a0,s1
    80001668:	0fa040ef          	jal	ra,80005762 <acquire>
    if(p->pid == pid){
    8000166c:	589c                	lw	a5,48(s1)
    8000166e:	01278b63          	beq	a5,s2,80001684 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001672:	8526                	mv	a0,s1
    80001674:	186040ef          	jal	ra,800057fa <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001678:	16848493          	addi	s1,s1,360
    8000167c:	ff3495e3          	bne	s1,s3,80001666 <kill+0x20>
  }
  return -1;
    80001680:	557d                	li	a0,-1
    80001682:	a819                	j	80001698 <kill+0x52>
      p->killed = 1;
    80001684:	4785                	li	a5,1
    80001686:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001688:	4c98                	lw	a4,24(s1)
    8000168a:	4789                	li	a5,2
    8000168c:	00f70d63          	beq	a4,a5,800016a6 <kill+0x60>
      release(&p->lock);
    80001690:	8526                	mv	a0,s1
    80001692:	168040ef          	jal	ra,800057fa <release>
      return 0;
    80001696:	4501                	li	a0,0
}
    80001698:	70a2                	ld	ra,40(sp)
    8000169a:	7402                	ld	s0,32(sp)
    8000169c:	64e2                	ld	s1,24(sp)
    8000169e:	6942                	ld	s2,16(sp)
    800016a0:	69a2                	ld	s3,8(sp)
    800016a2:	6145                	addi	sp,sp,48
    800016a4:	8082                	ret
        p->state = RUNNABLE;
    800016a6:	478d                	li	a5,3
    800016a8:	cc9c                	sw	a5,24(s1)
    800016aa:	b7dd                	j	80001690 <kill+0x4a>

00000000800016ac <setkilled>:

void
setkilled(struct proc *p)
{
    800016ac:	1101                	addi	sp,sp,-32
    800016ae:	ec06                	sd	ra,24(sp)
    800016b0:	e822                	sd	s0,16(sp)
    800016b2:	e426                	sd	s1,8(sp)
    800016b4:	1000                	addi	s0,sp,32
    800016b6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800016b8:	0aa040ef          	jal	ra,80005762 <acquire>
  p->killed = 1;
    800016bc:	4785                	li	a5,1
    800016be:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800016c0:	8526                	mv	a0,s1
    800016c2:	138040ef          	jal	ra,800057fa <release>
}
    800016c6:	60e2                	ld	ra,24(sp)
    800016c8:	6442                	ld	s0,16(sp)
    800016ca:	64a2                	ld	s1,8(sp)
    800016cc:	6105                	addi	sp,sp,32
    800016ce:	8082                	ret

00000000800016d0 <killed>:

int
killed(struct proc *p)
{
    800016d0:	1101                	addi	sp,sp,-32
    800016d2:	ec06                	sd	ra,24(sp)
    800016d4:	e822                	sd	s0,16(sp)
    800016d6:	e426                	sd	s1,8(sp)
    800016d8:	e04a                	sd	s2,0(sp)
    800016da:	1000                	addi	s0,sp,32
    800016dc:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800016de:	084040ef          	jal	ra,80005762 <acquire>
  k = p->killed;
    800016e2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800016e6:	8526                	mv	a0,s1
    800016e8:	112040ef          	jal	ra,800057fa <release>
  return k;
}
    800016ec:	854a                	mv	a0,s2
    800016ee:	60e2                	ld	ra,24(sp)
    800016f0:	6442                	ld	s0,16(sp)
    800016f2:	64a2                	ld	s1,8(sp)
    800016f4:	6902                	ld	s2,0(sp)
    800016f6:	6105                	addi	sp,sp,32
    800016f8:	8082                	ret

00000000800016fa <wait>:
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001714:	fb8ff0ef          	jal	ra,80000ecc <myproc>
    80001718:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000171a:	00006517          	auipc	a0,0x6
    8000171e:	51e50513          	addi	a0,a0,1310 # 80007c38 <wait_lock>
    80001722:	040040ef          	jal	ra,80005762 <acquire>
    havekids = 0;
    80001726:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001728:	4a15                	li	s4,5
        havekids = 1;
    8000172a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000172c:	0000c997          	auipc	s3,0xc
    80001730:	32498993          	addi	s3,s3,804 # 8000da50 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001734:	00006c17          	auipc	s8,0x6
    80001738:	504c0c13          	addi	s8,s8,1284 # 80007c38 <wait_lock>
    havekids = 0;
    8000173c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000173e:	00007497          	auipc	s1,0x7
    80001742:	91248493          	addi	s1,s1,-1774 # 80008050 <proc>
    80001746:	a899                	j	8000179c <wait+0xa2>
          pid = pp->pid;
    80001748:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000174c:	000b0c63          	beqz	s6,80001764 <wait+0x6a>
    80001750:	4691                	li	a3,4
    80001752:	02c48613          	addi	a2,s1,44
    80001756:	85da                	mv	a1,s6
    80001758:	05093503          	ld	a0,80(s2)
    8000175c:	b14ff0ef          	jal	ra,80000a70 <copyout>
    80001760:	00054f63          	bltz	a0,8000177e <wait+0x84>
          freeproc(pp);
    80001764:	8526                	mv	a0,s1
    80001766:	8d9ff0ef          	jal	ra,8000103e <freeproc>
          release(&pp->lock);
    8000176a:	8526                	mv	a0,s1
    8000176c:	08e040ef          	jal	ra,800057fa <release>
          release(&wait_lock);
    80001770:	00006517          	auipc	a0,0x6
    80001774:	4c850513          	addi	a0,a0,1224 # 80007c38 <wait_lock>
    80001778:	082040ef          	jal	ra,800057fa <release>
          return pid;
    8000177c:	a891                	j	800017d0 <wait+0xd6>
            release(&pp->lock);
    8000177e:	8526                	mv	a0,s1
    80001780:	07a040ef          	jal	ra,800057fa <release>
            release(&wait_lock);
    80001784:	00006517          	auipc	a0,0x6
    80001788:	4b450513          	addi	a0,a0,1204 # 80007c38 <wait_lock>
    8000178c:	06e040ef          	jal	ra,800057fa <release>
            return -1;
    80001790:	59fd                	li	s3,-1
    80001792:	a83d                	j	800017d0 <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001794:	16848493          	addi	s1,s1,360
    80001798:	03348063          	beq	s1,s3,800017b8 <wait+0xbe>
      if(pp->parent == p){
    8000179c:	7c9c                	ld	a5,56(s1)
    8000179e:	ff279be3          	bne	a5,s2,80001794 <wait+0x9a>
        acquire(&pp->lock);
    800017a2:	8526                	mv	a0,s1
    800017a4:	7bf030ef          	jal	ra,80005762 <acquire>
        if(pp->state == ZOMBIE){
    800017a8:	4c9c                	lw	a5,24(s1)
    800017aa:	f9478fe3          	beq	a5,s4,80001748 <wait+0x4e>
        release(&pp->lock);
    800017ae:	8526                	mv	a0,s1
    800017b0:	04a040ef          	jal	ra,800057fa <release>
        havekids = 1;
    800017b4:	8756                	mv	a4,s5
    800017b6:	bff9                	j	80001794 <wait+0x9a>
    if(!havekids || killed(p)){
    800017b8:	c709                	beqz	a4,800017c2 <wait+0xc8>
    800017ba:	854a                	mv	a0,s2
    800017bc:	f15ff0ef          	jal	ra,800016d0 <killed>
    800017c0:	c50d                	beqz	a0,800017ea <wait+0xf0>
      release(&wait_lock);
    800017c2:	00006517          	auipc	a0,0x6
    800017c6:	47650513          	addi	a0,a0,1142 # 80007c38 <wait_lock>
    800017ca:	030040ef          	jal	ra,800057fa <release>
      return -1;
    800017ce:	59fd                	li	s3,-1
}
    800017d0:	854e                	mv	a0,s3
    800017d2:	60a6                	ld	ra,72(sp)
    800017d4:	6406                	ld	s0,64(sp)
    800017d6:	74e2                	ld	s1,56(sp)
    800017d8:	7942                	ld	s2,48(sp)
    800017da:	79a2                	ld	s3,40(sp)
    800017dc:	7a02                	ld	s4,32(sp)
    800017de:	6ae2                	ld	s5,24(sp)
    800017e0:	6b42                	ld	s6,16(sp)
    800017e2:	6ba2                	ld	s7,8(sp)
    800017e4:	6c02                	ld	s8,0(sp)
    800017e6:	6161                	addi	sp,sp,80
    800017e8:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800017ea:	85e2                	mv	a1,s8
    800017ec:	854a                	mv	a0,s2
    800017ee:	cabff0ef          	jal	ra,80001498 <sleep>
    havekids = 0;
    800017f2:	b7a9                	j	8000173c <wait+0x42>

00000000800017f4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800017f4:	7179                	addi	sp,sp,-48
    800017f6:	f406                	sd	ra,40(sp)
    800017f8:	f022                	sd	s0,32(sp)
    800017fa:	ec26                	sd	s1,24(sp)
    800017fc:	e84a                	sd	s2,16(sp)
    800017fe:	e44e                	sd	s3,8(sp)
    80001800:	e052                	sd	s4,0(sp)
    80001802:	1800                	addi	s0,sp,48
    80001804:	84aa                	mv	s1,a0
    80001806:	892e                	mv	s2,a1
    80001808:	89b2                	mv	s3,a2
    8000180a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000180c:	ec0ff0ef          	jal	ra,80000ecc <myproc>
  if(user_dst){
    80001810:	cc99                	beqz	s1,8000182e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80001812:	86d2                	mv	a3,s4
    80001814:	864e                	mv	a2,s3
    80001816:	85ca                	mv	a1,s2
    80001818:	6928                	ld	a0,80(a0)
    8000181a:	a56ff0ef          	jal	ra,80000a70 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000181e:	70a2                	ld	ra,40(sp)
    80001820:	7402                	ld	s0,32(sp)
    80001822:	64e2                	ld	s1,24(sp)
    80001824:	6942                	ld	s2,16(sp)
    80001826:	69a2                	ld	s3,8(sp)
    80001828:	6a02                	ld	s4,0(sp)
    8000182a:	6145                	addi	sp,sp,48
    8000182c:	8082                	ret
    memmove((char *)dst, src, len);
    8000182e:	000a061b          	sext.w	a2,s4
    80001832:	85ce                	mv	a1,s3
    80001834:	854a                	mv	a0,s2
    80001836:	a07fe0ef          	jal	ra,8000023c <memmove>
    return 0;
    8000183a:	8526                	mv	a0,s1
    8000183c:	b7cd                	j	8000181e <either_copyout+0x2a>

000000008000183e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000183e:	7179                	addi	sp,sp,-48
    80001840:	f406                	sd	ra,40(sp)
    80001842:	f022                	sd	s0,32(sp)
    80001844:	ec26                	sd	s1,24(sp)
    80001846:	e84a                	sd	s2,16(sp)
    80001848:	e44e                	sd	s3,8(sp)
    8000184a:	e052                	sd	s4,0(sp)
    8000184c:	1800                	addi	s0,sp,48
    8000184e:	892a                	mv	s2,a0
    80001850:	84ae                	mv	s1,a1
    80001852:	89b2                	mv	s3,a2
    80001854:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001856:	e76ff0ef          	jal	ra,80000ecc <myproc>
  if(user_src){
    8000185a:	cc99                	beqz	s1,80001878 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000185c:	86d2                	mv	a3,s4
    8000185e:	864e                	mv	a2,s3
    80001860:	85ca                	mv	a1,s2
    80001862:	6928                	ld	a0,80(a0)
    80001864:	ac4ff0ef          	jal	ra,80000b28 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001868:	70a2                	ld	ra,40(sp)
    8000186a:	7402                	ld	s0,32(sp)
    8000186c:	64e2                	ld	s1,24(sp)
    8000186e:	6942                	ld	s2,16(sp)
    80001870:	69a2                	ld	s3,8(sp)
    80001872:	6a02                	ld	s4,0(sp)
    80001874:	6145                	addi	sp,sp,48
    80001876:	8082                	ret
    memmove(dst, (char*)src, len);
    80001878:	000a061b          	sext.w	a2,s4
    8000187c:	85ce                	mv	a1,s3
    8000187e:	854a                	mv	a0,s2
    80001880:	9bdfe0ef          	jal	ra,8000023c <memmove>
    return 0;
    80001884:	8526                	mv	a0,s1
    80001886:	b7cd                	j	80001868 <either_copyin+0x2a>

0000000080001888 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001888:	715d                	addi	sp,sp,-80
    8000188a:	e486                	sd	ra,72(sp)
    8000188c:	e0a2                	sd	s0,64(sp)
    8000188e:	fc26                	sd	s1,56(sp)
    80001890:	f84a                	sd	s2,48(sp)
    80001892:	f44e                	sd	s3,40(sp)
    80001894:	f052                	sd	s4,32(sp)
    80001896:	ec56                	sd	s5,24(sp)
    80001898:	e85a                	sd	s6,16(sp)
    8000189a:	e45e                	sd	s7,8(sp)
    8000189c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000189e:	00005517          	auipc	a0,0x5
    800018a2:	7da50513          	addi	a0,a0,2010 # 80007078 <etext+0x78>
    800018a6:	0f9030ef          	jal	ra,8000519e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800018aa:	00007497          	auipc	s1,0x7
    800018ae:	8fe48493          	addi	s1,s1,-1794 # 800081a8 <proc+0x158>
    800018b2:	0000c917          	auipc	s2,0xc
    800018b6:	2f690913          	addi	s2,s2,758 # 8000dba8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800018ba:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800018bc:	00006997          	auipc	s3,0x6
    800018c0:	9fc98993          	addi	s3,s3,-1540 # 800072b8 <etext+0x2b8>
    printf("%d %s %s", p->pid, state, p->name);
    800018c4:	00006a97          	auipc	s5,0x6
    800018c8:	9fca8a93          	addi	s5,s5,-1540 # 800072c0 <etext+0x2c0>
    printf("\n");
    800018cc:	00005a17          	auipc	s4,0x5
    800018d0:	7aca0a13          	addi	s4,s4,1964 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800018d4:	00006b97          	auipc	s7,0x6
    800018d8:	a2cb8b93          	addi	s7,s7,-1492 # 80007300 <states.0>
    800018dc:	a829                	j	800018f6 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800018de:	ed86a583          	lw	a1,-296(a3)
    800018e2:	8556                	mv	a0,s5
    800018e4:	0bb030ef          	jal	ra,8000519e <printf>
    printf("\n");
    800018e8:	8552                	mv	a0,s4
    800018ea:	0b5030ef          	jal	ra,8000519e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800018ee:	16848493          	addi	s1,s1,360
    800018f2:	03248263          	beq	s1,s2,80001916 <procdump+0x8e>
    if(p->state == UNUSED)
    800018f6:	86a6                	mv	a3,s1
    800018f8:	ec04a783          	lw	a5,-320(s1)
    800018fc:	dbed                	beqz	a5,800018ee <procdump+0x66>
      state = "???";
    800018fe:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001900:	fcfb6fe3          	bltu	s6,a5,800018de <procdump+0x56>
    80001904:	02079713          	slli	a4,a5,0x20
    80001908:	01d75793          	srli	a5,a4,0x1d
    8000190c:	97de                	add	a5,a5,s7
    8000190e:	6390                	ld	a2,0(a5)
    80001910:	f679                	bnez	a2,800018de <procdump+0x56>
      state = "???";
    80001912:	864e                	mv	a2,s3
    80001914:	b7e9                	j	800018de <procdump+0x56>
  }
}
    80001916:	60a6                	ld	ra,72(sp)
    80001918:	6406                	ld	s0,64(sp)
    8000191a:	74e2                	ld	s1,56(sp)
    8000191c:	7942                	ld	s2,48(sp)
    8000191e:	79a2                	ld	s3,40(sp)
    80001920:	7a02                	ld	s4,32(sp)
    80001922:	6ae2                	ld	s5,24(sp)
    80001924:	6b42                	ld	s6,16(sp)
    80001926:	6ba2                	ld	s7,8(sp)
    80001928:	6161                	addi	sp,sp,80
    8000192a:	8082                	ret

000000008000192c <swtch>:
    8000192c:	00153023          	sd	ra,0(a0)
    80001930:	00253423          	sd	sp,8(a0)
    80001934:	e900                	sd	s0,16(a0)
    80001936:	ed04                	sd	s1,24(a0)
    80001938:	03253023          	sd	s2,32(a0)
    8000193c:	03353423          	sd	s3,40(a0)
    80001940:	03453823          	sd	s4,48(a0)
    80001944:	03553c23          	sd	s5,56(a0)
    80001948:	05653023          	sd	s6,64(a0)
    8000194c:	05753423          	sd	s7,72(a0)
    80001950:	05853823          	sd	s8,80(a0)
    80001954:	05953c23          	sd	s9,88(a0)
    80001958:	07a53023          	sd	s10,96(a0)
    8000195c:	07b53423          	sd	s11,104(a0)
    80001960:	0005b083          	ld	ra,0(a1)
    80001964:	0085b103          	ld	sp,8(a1)
    80001968:	6980                	ld	s0,16(a1)
    8000196a:	6d84                	ld	s1,24(a1)
    8000196c:	0205b903          	ld	s2,32(a1)
    80001970:	0285b983          	ld	s3,40(a1)
    80001974:	0305ba03          	ld	s4,48(a1)
    80001978:	0385ba83          	ld	s5,56(a1)
    8000197c:	0405bb03          	ld	s6,64(a1)
    80001980:	0485bb83          	ld	s7,72(a1)
    80001984:	0505bc03          	ld	s8,80(a1)
    80001988:	0585bc83          	ld	s9,88(a1)
    8000198c:	0605bd03          	ld	s10,96(a1)
    80001990:	0685bd83          	ld	s11,104(a1)
    80001994:	8082                	ret

0000000080001996 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001996:	1141                	addi	sp,sp,-16
    80001998:	e406                	sd	ra,8(sp)
    8000199a:	e022                	sd	s0,0(sp)
    8000199c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000199e:	00006597          	auipc	a1,0x6
    800019a2:	99258593          	addi	a1,a1,-1646 # 80007330 <states.0+0x30>
    800019a6:	0000c517          	auipc	a0,0xc
    800019aa:	0aa50513          	addi	a0,a0,170 # 8000da50 <tickslock>
    800019ae:	535030ef          	jal	ra,800056e2 <initlock>
}
    800019b2:	60a2                	ld	ra,8(sp)
    800019b4:	6402                	ld	s0,0(sp)
    800019b6:	0141                	addi	sp,sp,16
    800019b8:	8082                	ret

00000000800019ba <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800019ba:	1141                	addi	sp,sp,-16
    800019bc:	e422                	sd	s0,8(sp)
    800019be:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800019c0:	00003797          	auipc	a5,0x3
    800019c4:	d8078793          	addi	a5,a5,-640 # 80004740 <kernelvec>
    800019c8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800019cc:	6422                	ld	s0,8(sp)
    800019ce:	0141                	addi	sp,sp,16
    800019d0:	8082                	ret

00000000800019d2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800019d2:	1141                	addi	sp,sp,-16
    800019d4:	e406                	sd	ra,8(sp)
    800019d6:	e022                	sd	s0,0(sp)
    800019d8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800019da:	cf2ff0ef          	jal	ra,80000ecc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800019de:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800019e2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800019e4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800019e8:	00004697          	auipc	a3,0x4
    800019ec:	61868693          	addi	a3,a3,1560 # 80006000 <_trampoline>
    800019f0:	00004717          	auipc	a4,0x4
    800019f4:	61070713          	addi	a4,a4,1552 # 80006000 <_trampoline>
    800019f8:	8f15                	sub	a4,a4,a3
    800019fa:	040007b7          	lui	a5,0x4000
    800019fe:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001a00:	07b2                	slli	a5,a5,0xc
    80001a02:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a04:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001a08:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001a0a:	18002673          	csrr	a2,satp
    80001a0e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001a10:	6d30                	ld	a2,88(a0)
    80001a12:	6138                	ld	a4,64(a0)
    80001a14:	6585                	lui	a1,0x1
    80001a16:	972e                	add	a4,a4,a1
    80001a18:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001a1a:	6d38                	ld	a4,88(a0)
    80001a1c:	00000617          	auipc	a2,0x0
    80001a20:	10c60613          	addi	a2,a2,268 # 80001b28 <usertrap>
    80001a24:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001a26:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a28:	8612                	mv	a2,tp
    80001a2a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a2c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001a30:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001a34:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a38:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001a3c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001a3e:	6f18                	ld	a4,24(a4)
    80001a40:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a44:	6928                	ld	a0,80(a0)
    80001a46:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a48:	00004717          	auipc	a4,0x4
    80001a4c:	65470713          	addi	a4,a4,1620 # 8000609c <userret>
    80001a50:	8f15                	sub	a4,a4,a3
    80001a52:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a54:	577d                	li	a4,-1
    80001a56:	177e                	slli	a4,a4,0x3f
    80001a58:	8d59                	or	a0,a0,a4
    80001a5a:	9782                	jalr	a5
}
    80001a5c:	60a2                	ld	ra,8(sp)
    80001a5e:	6402                	ld	s0,0(sp)
    80001a60:	0141                	addi	sp,sp,16
    80001a62:	8082                	ret

0000000080001a64 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001a64:	1101                	addi	sp,sp,-32
    80001a66:	ec06                	sd	ra,24(sp)
    80001a68:	e822                	sd	s0,16(sp)
    80001a6a:	e426                	sd	s1,8(sp)
    80001a6c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001a6e:	c32ff0ef          	jal	ra,80000ea0 <cpuid>
    80001a72:	cd19                	beqz	a0,80001a90 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001a74:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001a78:	000f4737          	lui	a4,0xf4
    80001a7c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001a80:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001a82:	14d79073          	csrw	0x14d,a5
}
    80001a86:	60e2                	ld	ra,24(sp)
    80001a88:	6442                	ld	s0,16(sp)
    80001a8a:	64a2                	ld	s1,8(sp)
    80001a8c:	6105                	addi	sp,sp,32
    80001a8e:	8082                	ret
    acquire(&tickslock);
    80001a90:	0000c497          	auipc	s1,0xc
    80001a94:	fc048493          	addi	s1,s1,-64 # 8000da50 <tickslock>
    80001a98:	8526                	mv	a0,s1
    80001a9a:	4c9030ef          	jal	ra,80005762 <acquire>
    ticks++;
    80001a9e:	00006517          	auipc	a0,0x6
    80001aa2:	f4a50513          	addi	a0,a0,-182 # 800079e8 <ticks>
    80001aa6:	411c                	lw	a5,0(a0)
    80001aa8:	2785                	addiw	a5,a5,1
    80001aaa:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001aac:	a39ff0ef          	jal	ra,800014e4 <wakeup>
    release(&tickslock);
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	549030ef          	jal	ra,800057fa <release>
    80001ab6:	bf7d                	j	80001a74 <clockintr+0x10>

0000000080001ab8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001ab8:	1101                	addi	sp,sp,-32
    80001aba:	ec06                	sd	ra,24(sp)
    80001abc:	e822                	sd	s0,16(sp)
    80001abe:	e426                	sd	s1,8(sp)
    80001ac0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ac2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001ac6:	57fd                	li	a5,-1
    80001ac8:	17fe                	slli	a5,a5,0x3f
    80001aca:	07a5                	addi	a5,a5,9
    80001acc:	00f70d63          	beq	a4,a5,80001ae6 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001ad0:	57fd                	li	a5,-1
    80001ad2:	17fe                	slli	a5,a5,0x3f
    80001ad4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001ad6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001ad8:	04f70463          	beq	a4,a5,80001b20 <devintr+0x68>
  }
}
    80001adc:	60e2                	ld	ra,24(sp)
    80001ade:	6442                	ld	s0,16(sp)
    80001ae0:	64a2                	ld	s1,8(sp)
    80001ae2:	6105                	addi	sp,sp,32
    80001ae4:	8082                	ret
    int irq = plic_claim();
    80001ae6:	503020ef          	jal	ra,800047e8 <plic_claim>
    80001aea:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001aec:	47a9                	li	a5,10
    80001aee:	02f50363          	beq	a0,a5,80001b14 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001af2:	4785                	li	a5,1
    80001af4:	02f50363          	beq	a0,a5,80001b1a <devintr+0x62>
    return 1;
    80001af8:	4505                	li	a0,1
    } else if(irq){
    80001afa:	d0ed                	beqz	s1,80001adc <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001afc:	85a6                	mv	a1,s1
    80001afe:	00006517          	auipc	a0,0x6
    80001b02:	83a50513          	addi	a0,a0,-1990 # 80007338 <states.0+0x38>
    80001b06:	698030ef          	jal	ra,8000519e <printf>
      plic_complete(irq);
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	4fd020ef          	jal	ra,80004808 <plic_complete>
    return 1;
    80001b10:	4505                	li	a0,1
    80001b12:	b7e9                	j	80001adc <devintr+0x24>
      uartintr();
    80001b14:	393030ef          	jal	ra,800056a6 <uartintr>
    80001b18:	bfcd                	j	80001b0a <devintr+0x52>
      virtio_disk_intr();
    80001b1a:	15a030ef          	jal	ra,80004c74 <virtio_disk_intr>
    80001b1e:	b7f5                	j	80001b0a <devintr+0x52>
    clockintr();
    80001b20:	f45ff0ef          	jal	ra,80001a64 <clockintr>
    return 2;
    80001b24:	4509                	li	a0,2
    80001b26:	bf5d                	j	80001adc <devintr+0x24>

0000000080001b28 <usertrap>:
{
    80001b28:	1101                	addi	sp,sp,-32
    80001b2a:	ec06                	sd	ra,24(sp)
    80001b2c:	e822                	sd	s0,16(sp)
    80001b2e:	e426                	sd	s1,8(sp)
    80001b30:	e04a                	sd	s2,0(sp)
    80001b32:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b34:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001b38:	1007f793          	andi	a5,a5,256
    80001b3c:	ef85                	bnez	a5,80001b74 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b3e:	00003797          	auipc	a5,0x3
    80001b42:	c0278793          	addi	a5,a5,-1022 # 80004740 <kernelvec>
    80001b46:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001b4a:	b82ff0ef          	jal	ra,80000ecc <myproc>
    80001b4e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001b50:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b52:	14102773          	csrr	a4,sepc
    80001b56:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b58:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001b5c:	47a1                	li	a5,8
    80001b5e:	02f70163          	beq	a4,a5,80001b80 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001b62:	f57ff0ef          	jal	ra,80001ab8 <devintr>
    80001b66:	892a                	mv	s2,a0
    80001b68:	c135                	beqz	a0,80001bcc <usertrap+0xa4>
  if(killed(p))
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	b65ff0ef          	jal	ra,800016d0 <killed>
    80001b70:	cd1d                	beqz	a0,80001bae <usertrap+0x86>
    80001b72:	a81d                	j	80001ba8 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001b74:	00005517          	auipc	a0,0x5
    80001b78:	7e450513          	addi	a0,a0,2020 # 80007358 <states.0+0x58>
    80001b7c:	0d7030ef          	jal	ra,80005452 <panic>
    if(killed(p))
    80001b80:	b51ff0ef          	jal	ra,800016d0 <killed>
    80001b84:	e121                	bnez	a0,80001bc4 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001b86:	6cb8                	ld	a4,88(s1)
    80001b88:	6f1c                	ld	a5,24(a4)
    80001b8a:	0791                	addi	a5,a5,4
    80001b8c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b8e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001b92:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b96:	10079073          	csrw	sstatus,a5
    syscall();
    80001b9a:	248000ef          	jal	ra,80001de2 <syscall>
  if(killed(p))
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	b31ff0ef          	jal	ra,800016d0 <killed>
    80001ba4:	c901                	beqz	a0,80001bb4 <usertrap+0x8c>
    80001ba6:	4901                	li	s2,0
    exit(-1);
    80001ba8:	557d                	li	a0,-1
    80001baa:	9fbff0ef          	jal	ra,800015a4 <exit>
  if(which_dev == 2)
    80001bae:	4789                	li	a5,2
    80001bb0:	04f90563          	beq	s2,a5,80001bfa <usertrap+0xd2>
  usertrapret();
    80001bb4:	e1fff0ef          	jal	ra,800019d2 <usertrapret>
}
    80001bb8:	60e2                	ld	ra,24(sp)
    80001bba:	6442                	ld	s0,16(sp)
    80001bbc:	64a2                	ld	s1,8(sp)
    80001bbe:	6902                	ld	s2,0(sp)
    80001bc0:	6105                	addi	sp,sp,32
    80001bc2:	8082                	ret
      exit(-1);
    80001bc4:	557d                	li	a0,-1
    80001bc6:	9dfff0ef          	jal	ra,800015a4 <exit>
    80001bca:	bf75                	j	80001b86 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bcc:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001bd0:	5890                	lw	a2,48(s1)
    80001bd2:	00005517          	auipc	a0,0x5
    80001bd6:	7a650513          	addi	a0,a0,1958 # 80007378 <states.0+0x78>
    80001bda:	5c4030ef          	jal	ra,8000519e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bde:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001be2:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001be6:	00005517          	auipc	a0,0x5
    80001bea:	7c250513          	addi	a0,a0,1986 # 800073a8 <states.0+0xa8>
    80001bee:	5b0030ef          	jal	ra,8000519e <printf>
    setkilled(p);
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	ab9ff0ef          	jal	ra,800016ac <setkilled>
    80001bf8:	b75d                	j	80001b9e <usertrap+0x76>
    yield();
    80001bfa:	873ff0ef          	jal	ra,8000146c <yield>
    80001bfe:	bf5d                	j	80001bb4 <usertrap+0x8c>

0000000080001c00 <kerneltrap>:
{
    80001c00:	7179                	addi	sp,sp,-48
    80001c02:	f406                	sd	ra,40(sp)
    80001c04:	f022                	sd	s0,32(sp)
    80001c06:	ec26                	sd	s1,24(sp)
    80001c08:	e84a                	sd	s2,16(sp)
    80001c0a:	e44e                	sd	s3,8(sp)
    80001c0c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001c0e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c12:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c16:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001c1a:	1004f793          	andi	a5,s1,256
    80001c1e:	c795                	beqz	a5,80001c4a <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c20:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001c24:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001c26:	eb85                	bnez	a5,80001c56 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001c28:	e91ff0ef          	jal	ra,80001ab8 <devintr>
    80001c2c:	c91d                	beqz	a0,80001c62 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001c2e:	4789                	li	a5,2
    80001c30:	04f50a63          	beq	a0,a5,80001c84 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001c34:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c38:	10049073          	csrw	sstatus,s1
}
    80001c3c:	70a2                	ld	ra,40(sp)
    80001c3e:	7402                	ld	s0,32(sp)
    80001c40:	64e2                	ld	s1,24(sp)
    80001c42:	6942                	ld	s2,16(sp)
    80001c44:	69a2                	ld	s3,8(sp)
    80001c46:	6145                	addi	sp,sp,48
    80001c48:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001c4a:	00005517          	auipc	a0,0x5
    80001c4e:	78650513          	addi	a0,a0,1926 # 800073d0 <states.0+0xd0>
    80001c52:	001030ef          	jal	ra,80005452 <panic>
    panic("kerneltrap: interrupts enabled");
    80001c56:	00005517          	auipc	a0,0x5
    80001c5a:	7a250513          	addi	a0,a0,1954 # 800073f8 <states.0+0xf8>
    80001c5e:	7f4030ef          	jal	ra,80005452 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001c62:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001c66:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001c6a:	85ce                	mv	a1,s3
    80001c6c:	00005517          	auipc	a0,0x5
    80001c70:	7ac50513          	addi	a0,a0,1964 # 80007418 <states.0+0x118>
    80001c74:	52a030ef          	jal	ra,8000519e <printf>
    panic("kerneltrap");
    80001c78:	00005517          	auipc	a0,0x5
    80001c7c:	7c850513          	addi	a0,a0,1992 # 80007440 <states.0+0x140>
    80001c80:	7d2030ef          	jal	ra,80005452 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001c84:	a48ff0ef          	jal	ra,80000ecc <myproc>
    80001c88:	d555                	beqz	a0,80001c34 <kerneltrap+0x34>
    yield();
    80001c8a:	fe2ff0ef          	jal	ra,8000146c <yield>
    80001c8e:	b75d                	j	80001c34 <kerneltrap+0x34>

0000000080001c90 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001c90:	1101                	addi	sp,sp,-32
    80001c92:	ec06                	sd	ra,24(sp)
    80001c94:	e822                	sd	s0,16(sp)
    80001c96:	e426                	sd	s1,8(sp)
    80001c98:	1000                	addi	s0,sp,32
    80001c9a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c9c:	a30ff0ef          	jal	ra,80000ecc <myproc>
  switch (n) {
    80001ca0:	4795                	li	a5,5
    80001ca2:	0497e163          	bltu	a5,s1,80001ce4 <argraw+0x54>
    80001ca6:	048a                	slli	s1,s1,0x2
    80001ca8:	00005717          	auipc	a4,0x5
    80001cac:	7d070713          	addi	a4,a4,2000 # 80007478 <states.0+0x178>
    80001cb0:	94ba                	add	s1,s1,a4
    80001cb2:	409c                	lw	a5,0(s1)
    80001cb4:	97ba                	add	a5,a5,a4
    80001cb6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001cb8:	6d3c                	ld	a5,88(a0)
    80001cba:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001cbc:	60e2                	ld	ra,24(sp)
    80001cbe:	6442                	ld	s0,16(sp)
    80001cc0:	64a2                	ld	s1,8(sp)
    80001cc2:	6105                	addi	sp,sp,32
    80001cc4:	8082                	ret
    return p->trapframe->a1;
    80001cc6:	6d3c                	ld	a5,88(a0)
    80001cc8:	7fa8                	ld	a0,120(a5)
    80001cca:	bfcd                	j	80001cbc <argraw+0x2c>
    return p->trapframe->a2;
    80001ccc:	6d3c                	ld	a5,88(a0)
    80001cce:	63c8                	ld	a0,128(a5)
    80001cd0:	b7f5                	j	80001cbc <argraw+0x2c>
    return p->trapframe->a3;
    80001cd2:	6d3c                	ld	a5,88(a0)
    80001cd4:	67c8                	ld	a0,136(a5)
    80001cd6:	b7dd                	j	80001cbc <argraw+0x2c>
    return p->trapframe->a4;
    80001cd8:	6d3c                	ld	a5,88(a0)
    80001cda:	6bc8                	ld	a0,144(a5)
    80001cdc:	b7c5                	j	80001cbc <argraw+0x2c>
    return p->trapframe->a5;
    80001cde:	6d3c                	ld	a5,88(a0)
    80001ce0:	6fc8                	ld	a0,152(a5)
    80001ce2:	bfe9                	j	80001cbc <argraw+0x2c>
  panic("argraw");
    80001ce4:	00005517          	auipc	a0,0x5
    80001ce8:	76c50513          	addi	a0,a0,1900 # 80007450 <states.0+0x150>
    80001cec:	766030ef          	jal	ra,80005452 <panic>

0000000080001cf0 <fetchaddr>:
{
    80001cf0:	1101                	addi	sp,sp,-32
    80001cf2:	ec06                	sd	ra,24(sp)
    80001cf4:	e822                	sd	s0,16(sp)
    80001cf6:	e426                	sd	s1,8(sp)
    80001cf8:	e04a                	sd	s2,0(sp)
    80001cfa:	1000                	addi	s0,sp,32
    80001cfc:	84aa                	mv	s1,a0
    80001cfe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001d00:	9ccff0ef          	jal	ra,80000ecc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001d04:	653c                	ld	a5,72(a0)
    80001d06:	02f4f663          	bgeu	s1,a5,80001d32 <fetchaddr+0x42>
    80001d0a:	00848713          	addi	a4,s1,8
    80001d0e:	02e7e463          	bltu	a5,a4,80001d36 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001d12:	46a1                	li	a3,8
    80001d14:	8626                	mv	a2,s1
    80001d16:	85ca                	mv	a1,s2
    80001d18:	6928                	ld	a0,80(a0)
    80001d1a:	e0ffe0ef          	jal	ra,80000b28 <copyin>
    80001d1e:	00a03533          	snez	a0,a0
    80001d22:	40a00533          	neg	a0,a0
}
    80001d26:	60e2                	ld	ra,24(sp)
    80001d28:	6442                	ld	s0,16(sp)
    80001d2a:	64a2                	ld	s1,8(sp)
    80001d2c:	6902                	ld	s2,0(sp)
    80001d2e:	6105                	addi	sp,sp,32
    80001d30:	8082                	ret
    return -1;
    80001d32:	557d                	li	a0,-1
    80001d34:	bfcd                	j	80001d26 <fetchaddr+0x36>
    80001d36:	557d                	li	a0,-1
    80001d38:	b7fd                	j	80001d26 <fetchaddr+0x36>

0000000080001d3a <fetchstr>:
{
    80001d3a:	7179                	addi	sp,sp,-48
    80001d3c:	f406                	sd	ra,40(sp)
    80001d3e:	f022                	sd	s0,32(sp)
    80001d40:	ec26                	sd	s1,24(sp)
    80001d42:	e84a                	sd	s2,16(sp)
    80001d44:	e44e                	sd	s3,8(sp)
    80001d46:	1800                	addi	s0,sp,48
    80001d48:	892a                	mv	s2,a0
    80001d4a:	84ae                	mv	s1,a1
    80001d4c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001d4e:	97eff0ef          	jal	ra,80000ecc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001d52:	86ce                	mv	a3,s3
    80001d54:	864a                	mv	a2,s2
    80001d56:	85a6                	mv	a1,s1
    80001d58:	6928                	ld	a0,80(a0)
    80001d5a:	e55fe0ef          	jal	ra,80000bae <copyinstr>
    80001d5e:	00054c63          	bltz	a0,80001d76 <fetchstr+0x3c>
  return strlen(buf);
    80001d62:	8526                	mv	a0,s1
    80001d64:	df4fe0ef          	jal	ra,80000358 <strlen>
}
    80001d68:	70a2                	ld	ra,40(sp)
    80001d6a:	7402                	ld	s0,32(sp)
    80001d6c:	64e2                	ld	s1,24(sp)
    80001d6e:	6942                	ld	s2,16(sp)
    80001d70:	69a2                	ld	s3,8(sp)
    80001d72:	6145                	addi	sp,sp,48
    80001d74:	8082                	ret
    return -1;
    80001d76:	557d                	li	a0,-1
    80001d78:	bfc5                	j	80001d68 <fetchstr+0x2e>

0000000080001d7a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001d7a:	1101                	addi	sp,sp,-32
    80001d7c:	ec06                	sd	ra,24(sp)
    80001d7e:	e822                	sd	s0,16(sp)
    80001d80:	e426                	sd	s1,8(sp)
    80001d82:	1000                	addi	s0,sp,32
    80001d84:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001d86:	f0bff0ef          	jal	ra,80001c90 <argraw>
    80001d8a:	c088                	sw	a0,0(s1)
}
    80001d8c:	60e2                	ld	ra,24(sp)
    80001d8e:	6442                	ld	s0,16(sp)
    80001d90:	64a2                	ld	s1,8(sp)
    80001d92:	6105                	addi	sp,sp,32
    80001d94:	8082                	ret

0000000080001d96 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001d96:	1101                	addi	sp,sp,-32
    80001d98:	ec06                	sd	ra,24(sp)
    80001d9a:	e822                	sd	s0,16(sp)
    80001d9c:	e426                	sd	s1,8(sp)
    80001d9e:	1000                	addi	s0,sp,32
    80001da0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001da2:	eefff0ef          	jal	ra,80001c90 <argraw>
    80001da6:	e088                	sd	a0,0(s1)
}
    80001da8:	60e2                	ld	ra,24(sp)
    80001daa:	6442                	ld	s0,16(sp)
    80001dac:	64a2                	ld	s1,8(sp)
    80001dae:	6105                	addi	sp,sp,32
    80001db0:	8082                	ret

0000000080001db2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001db2:	7179                	addi	sp,sp,-48
    80001db4:	f406                	sd	ra,40(sp)
    80001db6:	f022                	sd	s0,32(sp)
    80001db8:	ec26                	sd	s1,24(sp)
    80001dba:	e84a                	sd	s2,16(sp)
    80001dbc:	1800                	addi	s0,sp,48
    80001dbe:	84ae                	mv	s1,a1
    80001dc0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001dc2:	fd840593          	addi	a1,s0,-40
    80001dc6:	fd1ff0ef          	jal	ra,80001d96 <argaddr>
  return fetchstr(addr, buf, max);
    80001dca:	864a                	mv	a2,s2
    80001dcc:	85a6                	mv	a1,s1
    80001dce:	fd843503          	ld	a0,-40(s0)
    80001dd2:	f69ff0ef          	jal	ra,80001d3a <fetchstr>
}
    80001dd6:	70a2                	ld	ra,40(sp)
    80001dd8:	7402                	ld	s0,32(sp)
    80001dda:	64e2                	ld	s1,24(sp)
    80001ddc:	6942                	ld	s2,16(sp)
    80001dde:	6145                	addi	sp,sp,48
    80001de0:	8082                	ret

0000000080001de2 <syscall>:
#endif
};

void
syscall(void)
{
    80001de2:	1101                	addi	sp,sp,-32
    80001de4:	ec06                	sd	ra,24(sp)
    80001de6:	e822                	sd	s0,16(sp)
    80001de8:	e426                	sd	s1,8(sp)
    80001dea:	e04a                	sd	s2,0(sp)
    80001dec:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001dee:	8deff0ef          	jal	ra,80000ecc <myproc>
    80001df2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001df4:	05853903          	ld	s2,88(a0)
    80001df8:	0a893783          	ld	a5,168(s2)
    80001dfc:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001e00:	37fd                	addiw	a5,a5,-1
    80001e02:	02100713          	li	a4,33
    80001e06:	00f76f63          	bltu	a4,a5,80001e24 <syscall+0x42>
    80001e0a:	00369713          	slli	a4,a3,0x3
    80001e0e:	00005797          	auipc	a5,0x5
    80001e12:	68278793          	addi	a5,a5,1666 # 80007490 <syscalls>
    80001e16:	97ba                	add	a5,a5,a4
    80001e18:	639c                	ld	a5,0(a5)
    80001e1a:	c789                	beqz	a5,80001e24 <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001e1c:	9782                	jalr	a5
    80001e1e:	06a93823          	sd	a0,112(s2)
    80001e22:	a829                	j	80001e3c <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001e24:	15848613          	addi	a2,s1,344
    80001e28:	588c                	lw	a1,48(s1)
    80001e2a:	00005517          	auipc	a0,0x5
    80001e2e:	62e50513          	addi	a0,a0,1582 # 80007458 <states.0+0x158>
    80001e32:	36c030ef          	jal	ra,8000519e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001e36:	6cbc                	ld	a5,88(s1)
    80001e38:	577d                	li	a4,-1
    80001e3a:	fbb8                	sd	a4,112(a5)
  }
}
    80001e3c:	60e2                	ld	ra,24(sp)
    80001e3e:	6442                	ld	s0,16(sp)
    80001e40:	64a2                	ld	s1,8(sp)
    80001e42:	6902                	ld	s2,0(sp)
    80001e44:	6105                	addi	sp,sp,32
    80001e46:	8082                	ret

0000000080001e48 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001e48:	1101                	addi	sp,sp,-32
    80001e4a:	ec06                	sd	ra,24(sp)
    80001e4c:	e822                	sd	s0,16(sp)
    80001e4e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001e50:	fec40593          	addi	a1,s0,-20
    80001e54:	4501                	li	a0,0
    80001e56:	f25ff0ef          	jal	ra,80001d7a <argint>
  exit(n);
    80001e5a:	fec42503          	lw	a0,-20(s0)
    80001e5e:	f46ff0ef          	jal	ra,800015a4 <exit>
  return 0;  // not reached
}
    80001e62:	4501                	li	a0,0
    80001e64:	60e2                	ld	ra,24(sp)
    80001e66:	6442                	ld	s0,16(sp)
    80001e68:	6105                	addi	sp,sp,32
    80001e6a:	8082                	ret

0000000080001e6c <sys_getpid>:

uint64
sys_getpid(void)
{
    80001e6c:	1141                	addi	sp,sp,-16
    80001e6e:	e406                	sd	ra,8(sp)
    80001e70:	e022                	sd	s0,0(sp)
    80001e72:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001e74:	858ff0ef          	jal	ra,80000ecc <myproc>
}
    80001e78:	5908                	lw	a0,48(a0)
    80001e7a:	60a2                	ld	ra,8(sp)
    80001e7c:	6402                	ld	s0,0(sp)
    80001e7e:	0141                	addi	sp,sp,16
    80001e80:	8082                	ret

0000000080001e82 <sys_fork>:

uint64
sys_fork(void)
{
    80001e82:	1141                	addi	sp,sp,-16
    80001e84:	e406                	sd	ra,8(sp)
    80001e86:	e022                	sd	s0,0(sp)
    80001e88:	0800                	addi	s0,sp,16
  return fork();
    80001e8a:	b68ff0ef          	jal	ra,800011f2 <fork>
}
    80001e8e:	60a2                	ld	ra,8(sp)
    80001e90:	6402                	ld	s0,0(sp)
    80001e92:	0141                	addi	sp,sp,16
    80001e94:	8082                	ret

0000000080001e96 <sys_wait>:

uint64
sys_wait(void)
{
    80001e96:	1101                	addi	sp,sp,-32
    80001e98:	ec06                	sd	ra,24(sp)
    80001e9a:	e822                	sd	s0,16(sp)
    80001e9c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001e9e:	fe840593          	addi	a1,s0,-24
    80001ea2:	4501                	li	a0,0
    80001ea4:	ef3ff0ef          	jal	ra,80001d96 <argaddr>
  return wait(p);
    80001ea8:	fe843503          	ld	a0,-24(s0)
    80001eac:	84fff0ef          	jal	ra,800016fa <wait>
}
    80001eb0:	60e2                	ld	ra,24(sp)
    80001eb2:	6442                	ld	s0,16(sp)
    80001eb4:	6105                	addi	sp,sp,32
    80001eb6:	8082                	ret

0000000080001eb8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001eb8:	7179                	addi	sp,sp,-48
    80001eba:	f406                	sd	ra,40(sp)
    80001ebc:	f022                	sd	s0,32(sp)
    80001ebe:	ec26                	sd	s1,24(sp)
    80001ec0:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001ec2:	fdc40593          	addi	a1,s0,-36
    80001ec6:	4501                	li	a0,0
    80001ec8:	eb3ff0ef          	jal	ra,80001d7a <argint>
  addr = myproc()->sz;
    80001ecc:	800ff0ef          	jal	ra,80000ecc <myproc>
    80001ed0:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001ed2:	fdc42503          	lw	a0,-36(s0)
    80001ed6:	accff0ef          	jal	ra,800011a2 <growproc>
    80001eda:	00054863          	bltz	a0,80001eea <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001ede:	8526                	mv	a0,s1
    80001ee0:	70a2                	ld	ra,40(sp)
    80001ee2:	7402                	ld	s0,32(sp)
    80001ee4:	64e2                	ld	s1,24(sp)
    80001ee6:	6145                	addi	sp,sp,48
    80001ee8:	8082                	ret
    return -1;
    80001eea:	54fd                	li	s1,-1
    80001eec:	bfcd                	j	80001ede <sys_sbrk+0x26>

0000000080001eee <sys_sleep>:

uint64
sys_sleep(void)
{
    80001eee:	7139                	addi	sp,sp,-64
    80001ef0:	fc06                	sd	ra,56(sp)
    80001ef2:	f822                	sd	s0,48(sp)
    80001ef4:	f426                	sd	s1,40(sp)
    80001ef6:	f04a                	sd	s2,32(sp)
    80001ef8:	ec4e                	sd	s3,24(sp)
    80001efa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001efc:	fcc40593          	addi	a1,s0,-52
    80001f00:	4501                	li	a0,0
    80001f02:	e79ff0ef          	jal	ra,80001d7a <argint>
  if(n < 0)
    80001f06:	fcc42783          	lw	a5,-52(s0)
    80001f0a:	0607c563          	bltz	a5,80001f74 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001f0e:	0000c517          	auipc	a0,0xc
    80001f12:	b4250513          	addi	a0,a0,-1214 # 8000da50 <tickslock>
    80001f16:	04d030ef          	jal	ra,80005762 <acquire>
  ticks0 = ticks;
    80001f1a:	00006917          	auipc	s2,0x6
    80001f1e:	ace92903          	lw	s2,-1330(s2) # 800079e8 <ticks>
  while(ticks - ticks0 < n){
    80001f22:	fcc42783          	lw	a5,-52(s0)
    80001f26:	cb8d                	beqz	a5,80001f58 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001f28:	0000c997          	auipc	s3,0xc
    80001f2c:	b2898993          	addi	s3,s3,-1240 # 8000da50 <tickslock>
    80001f30:	00006497          	auipc	s1,0x6
    80001f34:	ab848493          	addi	s1,s1,-1352 # 800079e8 <ticks>
    if(killed(myproc())){
    80001f38:	f95fe0ef          	jal	ra,80000ecc <myproc>
    80001f3c:	f94ff0ef          	jal	ra,800016d0 <killed>
    80001f40:	ed0d                	bnez	a0,80001f7a <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001f42:	85ce                	mv	a1,s3
    80001f44:	8526                	mv	a0,s1
    80001f46:	d52ff0ef          	jal	ra,80001498 <sleep>
  while(ticks - ticks0 < n){
    80001f4a:	409c                	lw	a5,0(s1)
    80001f4c:	412787bb          	subw	a5,a5,s2
    80001f50:	fcc42703          	lw	a4,-52(s0)
    80001f54:	fee7e2e3          	bltu	a5,a4,80001f38 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80001f58:	0000c517          	auipc	a0,0xc
    80001f5c:	af850513          	addi	a0,a0,-1288 # 8000da50 <tickslock>
    80001f60:	09b030ef          	jal	ra,800057fa <release>
  return 0;
    80001f64:	4501                	li	a0,0
}
    80001f66:	70e2                	ld	ra,56(sp)
    80001f68:	7442                	ld	s0,48(sp)
    80001f6a:	74a2                	ld	s1,40(sp)
    80001f6c:	7902                	ld	s2,32(sp)
    80001f6e:	69e2                	ld	s3,24(sp)
    80001f70:	6121                	addi	sp,sp,64
    80001f72:	8082                	ret
    n = 0;
    80001f74:	fc042623          	sw	zero,-52(s0)
    80001f78:	bf59                	j	80001f0e <sys_sleep+0x20>
      release(&tickslock);
    80001f7a:	0000c517          	auipc	a0,0xc
    80001f7e:	ad650513          	addi	a0,a0,-1322 # 8000da50 <tickslock>
    80001f82:	079030ef          	jal	ra,800057fa <release>
      return -1;
    80001f86:	557d                	li	a0,-1
    80001f88:	bff9                	j	80001f66 <sys_sleep+0x78>

0000000080001f8a <sys_pgpte>:


#ifdef LAB_PGTBL
int
sys_pgpte(void)
{
    80001f8a:	7179                	addi	sp,sp,-48
    80001f8c:	f406                	sd	ra,40(sp)
    80001f8e:	f022                	sd	s0,32(sp)
    80001f90:	ec26                	sd	s1,24(sp)
    80001f92:	1800                	addi	s0,sp,48
  uint64 va;
  struct proc *p;

  p = myproc();
    80001f94:	f39fe0ef          	jal	ra,80000ecc <myproc>
    80001f98:	84aa                	mv	s1,a0
  argaddr(0, &va);
    80001f9a:	fd840593          	addi	a1,s0,-40
    80001f9e:	4501                	li	a0,0
    80001fa0:	df7ff0ef          	jal	ra,80001d96 <argaddr>
  pte_t *pte = pgpte(p->pagetable, va);
    80001fa4:	fd843583          	ld	a1,-40(s0)
    80001fa8:	68a8                	ld	a0,80(s1)
    80001faa:	daffe0ef          	jal	ra,80000d58 <pgpte>
    80001fae:	87aa                	mv	a5,a0
  if(pte != 0) {
      return (uint64) *pte;
  }
  return 0;
    80001fb0:	4501                	li	a0,0
  if(pte != 0) {
    80001fb2:	c391                	beqz	a5,80001fb6 <sys_pgpte+0x2c>
      return (uint64) *pte;
    80001fb4:	4388                	lw	a0,0(a5)
}
    80001fb6:	70a2                	ld	ra,40(sp)
    80001fb8:	7402                	ld	s0,32(sp)
    80001fba:	64e2                	ld	s1,24(sp)
    80001fbc:	6145                	addi	sp,sp,48
    80001fbe:	8082                	ret

0000000080001fc0 <sys_kpgtbl>:
#endif

#ifdef LAB_PGTBL
int
sys_kpgtbl(void)
{
    80001fc0:	1141                	addi	sp,sp,-16
    80001fc2:	e406                	sd	ra,8(sp)
    80001fc4:	e022                	sd	s0,0(sp)
    80001fc6:	0800                	addi	s0,sp,16
  struct proc *p;

  p = myproc();
    80001fc8:	f05fe0ef          	jal	ra,80000ecc <myproc>
  vmprint(p->pagetable);
    80001fcc:	6928                	ld	a0,80(a0)
    80001fce:	d5dfe0ef          	jal	ra,80000d2a <vmprint>
  return 0;
}
    80001fd2:	4501                	li	a0,0
    80001fd4:	60a2                	ld	ra,8(sp)
    80001fd6:	6402                	ld	s0,0(sp)
    80001fd8:	0141                	addi	sp,sp,16
    80001fda:	8082                	ret

0000000080001fdc <sys_kill>:
#endif


uint64
sys_kill(void)
{
    80001fdc:	1101                	addi	sp,sp,-32
    80001fde:	ec06                	sd	ra,24(sp)
    80001fe0:	e822                	sd	s0,16(sp)
    80001fe2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001fe4:	fec40593          	addi	a1,s0,-20
    80001fe8:	4501                	li	a0,0
    80001fea:	d91ff0ef          	jal	ra,80001d7a <argint>
  return kill(pid);
    80001fee:	fec42503          	lw	a0,-20(s0)
    80001ff2:	e54ff0ef          	jal	ra,80001646 <kill>
}
    80001ff6:	60e2                	ld	ra,24(sp)
    80001ff8:	6442                	ld	s0,16(sp)
    80001ffa:	6105                	addi	sp,sp,32
    80001ffc:	8082                	ret

0000000080001ffe <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001ffe:	1101                	addi	sp,sp,-32
    80002000:	ec06                	sd	ra,24(sp)
    80002002:	e822                	sd	s0,16(sp)
    80002004:	e426                	sd	s1,8(sp)
    80002006:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002008:	0000c517          	auipc	a0,0xc
    8000200c:	a4850513          	addi	a0,a0,-1464 # 8000da50 <tickslock>
    80002010:	752030ef          	jal	ra,80005762 <acquire>
  xticks = ticks;
    80002014:	00006497          	auipc	s1,0x6
    80002018:	9d44a483          	lw	s1,-1580(s1) # 800079e8 <ticks>
  release(&tickslock);
    8000201c:	0000c517          	auipc	a0,0xc
    80002020:	a3450513          	addi	a0,a0,-1484 # 8000da50 <tickslock>
    80002024:	7d6030ef          	jal	ra,800057fa <release>
  return xticks;
}
    80002028:	02049513          	slli	a0,s1,0x20
    8000202c:	9101                	srli	a0,a0,0x20
    8000202e:	60e2                	ld	ra,24(sp)
    80002030:	6442                	ld	s0,16(sp)
    80002032:	64a2                	ld	s1,8(sp)
    80002034:	6105                	addi	sp,sp,32
    80002036:	8082                	ret

0000000080002038 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002038:	7179                	addi	sp,sp,-48
    8000203a:	f406                	sd	ra,40(sp)
    8000203c:	f022                	sd	s0,32(sp)
    8000203e:	ec26                	sd	s1,24(sp)
    80002040:	e84a                	sd	s2,16(sp)
    80002042:	e44e                	sd	s3,8(sp)
    80002044:	e052                	sd	s4,0(sp)
    80002046:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002048:	00005597          	auipc	a1,0x5
    8000204c:	56058593          	addi	a1,a1,1376 # 800075a8 <syscalls+0x118>
    80002050:	0000c517          	auipc	a0,0xc
    80002054:	a1850513          	addi	a0,a0,-1512 # 8000da68 <bcache>
    80002058:	68a030ef          	jal	ra,800056e2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000205c:	00014797          	auipc	a5,0x14
    80002060:	a0c78793          	addi	a5,a5,-1524 # 80015a68 <bcache+0x8000>
    80002064:	00014717          	auipc	a4,0x14
    80002068:	c6c70713          	addi	a4,a4,-916 # 80015cd0 <bcache+0x8268>
    8000206c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002070:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002074:	0000c497          	auipc	s1,0xc
    80002078:	a0c48493          	addi	s1,s1,-1524 # 8000da80 <bcache+0x18>
    b->next = bcache.head.next;
    8000207c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000207e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002080:	00005a17          	auipc	s4,0x5
    80002084:	530a0a13          	addi	s4,s4,1328 # 800075b0 <syscalls+0x120>
    b->next = bcache.head.next;
    80002088:	2b893783          	ld	a5,696(s2)
    8000208c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000208e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002092:	85d2                	mv	a1,s4
    80002094:	01048513          	addi	a0,s1,16
    80002098:	228010ef          	jal	ra,800032c0 <initsleeplock>
    bcache.head.next->prev = b;
    8000209c:	2b893783          	ld	a5,696(s2)
    800020a0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800020a2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800020a6:	45848493          	addi	s1,s1,1112
    800020aa:	fd349fe3          	bne	s1,s3,80002088 <binit+0x50>
  }
}
    800020ae:	70a2                	ld	ra,40(sp)
    800020b0:	7402                	ld	s0,32(sp)
    800020b2:	64e2                	ld	s1,24(sp)
    800020b4:	6942                	ld	s2,16(sp)
    800020b6:	69a2                	ld	s3,8(sp)
    800020b8:	6a02                	ld	s4,0(sp)
    800020ba:	6145                	addi	sp,sp,48
    800020bc:	8082                	ret

00000000800020be <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800020be:	7179                	addi	sp,sp,-48
    800020c0:	f406                	sd	ra,40(sp)
    800020c2:	f022                	sd	s0,32(sp)
    800020c4:	ec26                	sd	s1,24(sp)
    800020c6:	e84a                	sd	s2,16(sp)
    800020c8:	e44e                	sd	s3,8(sp)
    800020ca:	1800                	addi	s0,sp,48
    800020cc:	892a                	mv	s2,a0
    800020ce:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800020d0:	0000c517          	auipc	a0,0xc
    800020d4:	99850513          	addi	a0,a0,-1640 # 8000da68 <bcache>
    800020d8:	68a030ef          	jal	ra,80005762 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800020dc:	00014497          	auipc	s1,0x14
    800020e0:	c444b483          	ld	s1,-956(s1) # 80015d20 <bcache+0x82b8>
    800020e4:	00014797          	auipc	a5,0x14
    800020e8:	bec78793          	addi	a5,a5,-1044 # 80015cd0 <bcache+0x8268>
    800020ec:	02f48b63          	beq	s1,a5,80002122 <bread+0x64>
    800020f0:	873e                	mv	a4,a5
    800020f2:	a021                	j	800020fa <bread+0x3c>
    800020f4:	68a4                	ld	s1,80(s1)
    800020f6:	02e48663          	beq	s1,a4,80002122 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800020fa:	449c                	lw	a5,8(s1)
    800020fc:	ff279ce3          	bne	a5,s2,800020f4 <bread+0x36>
    80002100:	44dc                	lw	a5,12(s1)
    80002102:	ff3799e3          	bne	a5,s3,800020f4 <bread+0x36>
      b->refcnt++;
    80002106:	40bc                	lw	a5,64(s1)
    80002108:	2785                	addiw	a5,a5,1
    8000210a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000210c:	0000c517          	auipc	a0,0xc
    80002110:	95c50513          	addi	a0,a0,-1700 # 8000da68 <bcache>
    80002114:	6e6030ef          	jal	ra,800057fa <release>
      acquiresleep(&b->lock);
    80002118:	01048513          	addi	a0,s1,16
    8000211c:	1da010ef          	jal	ra,800032f6 <acquiresleep>
      return b;
    80002120:	a889                	j	80002172 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002122:	00014497          	auipc	s1,0x14
    80002126:	bf64b483          	ld	s1,-1034(s1) # 80015d18 <bcache+0x82b0>
    8000212a:	00014797          	auipc	a5,0x14
    8000212e:	ba678793          	addi	a5,a5,-1114 # 80015cd0 <bcache+0x8268>
    80002132:	00f48863          	beq	s1,a5,80002142 <bread+0x84>
    80002136:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002138:	40bc                	lw	a5,64(s1)
    8000213a:	cb91                	beqz	a5,8000214e <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000213c:	64a4                	ld	s1,72(s1)
    8000213e:	fee49de3          	bne	s1,a4,80002138 <bread+0x7a>
  panic("bget: no buffers");
    80002142:	00005517          	auipc	a0,0x5
    80002146:	47650513          	addi	a0,a0,1142 # 800075b8 <syscalls+0x128>
    8000214a:	308030ef          	jal	ra,80005452 <panic>
      b->dev = dev;
    8000214e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002152:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002156:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000215a:	4785                	li	a5,1
    8000215c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000215e:	0000c517          	auipc	a0,0xc
    80002162:	90a50513          	addi	a0,a0,-1782 # 8000da68 <bcache>
    80002166:	694030ef          	jal	ra,800057fa <release>
      acquiresleep(&b->lock);
    8000216a:	01048513          	addi	a0,s1,16
    8000216e:	188010ef          	jal	ra,800032f6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002172:	409c                	lw	a5,0(s1)
    80002174:	cb89                	beqz	a5,80002186 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002176:	8526                	mv	a0,s1
    80002178:	70a2                	ld	ra,40(sp)
    8000217a:	7402                	ld	s0,32(sp)
    8000217c:	64e2                	ld	s1,24(sp)
    8000217e:	6942                	ld	s2,16(sp)
    80002180:	69a2                	ld	s3,8(sp)
    80002182:	6145                	addi	sp,sp,48
    80002184:	8082                	ret
    virtio_disk_rw(b, 0);
    80002186:	4581                	li	a1,0
    80002188:	8526                	mv	a0,s1
    8000218a:	0d1020ef          	jal	ra,80004a5a <virtio_disk_rw>
    b->valid = 1;
    8000218e:	4785                	li	a5,1
    80002190:	c09c                	sw	a5,0(s1)
  return b;
    80002192:	b7d5                	j	80002176 <bread+0xb8>

0000000080002194 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002194:	1101                	addi	sp,sp,-32
    80002196:	ec06                	sd	ra,24(sp)
    80002198:	e822                	sd	s0,16(sp)
    8000219a:	e426                	sd	s1,8(sp)
    8000219c:	1000                	addi	s0,sp,32
    8000219e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800021a0:	0541                	addi	a0,a0,16
    800021a2:	1d2010ef          	jal	ra,80003374 <holdingsleep>
    800021a6:	c911                	beqz	a0,800021ba <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800021a8:	4585                	li	a1,1
    800021aa:	8526                	mv	a0,s1
    800021ac:	0af020ef          	jal	ra,80004a5a <virtio_disk_rw>
}
    800021b0:	60e2                	ld	ra,24(sp)
    800021b2:	6442                	ld	s0,16(sp)
    800021b4:	64a2                	ld	s1,8(sp)
    800021b6:	6105                	addi	sp,sp,32
    800021b8:	8082                	ret
    panic("bwrite");
    800021ba:	00005517          	auipc	a0,0x5
    800021be:	41650513          	addi	a0,a0,1046 # 800075d0 <syscalls+0x140>
    800021c2:	290030ef          	jal	ra,80005452 <panic>

00000000800021c6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800021c6:	1101                	addi	sp,sp,-32
    800021c8:	ec06                	sd	ra,24(sp)
    800021ca:	e822                	sd	s0,16(sp)
    800021cc:	e426                	sd	s1,8(sp)
    800021ce:	e04a                	sd	s2,0(sp)
    800021d0:	1000                	addi	s0,sp,32
    800021d2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800021d4:	01050913          	addi	s2,a0,16
    800021d8:	854a                	mv	a0,s2
    800021da:	19a010ef          	jal	ra,80003374 <holdingsleep>
    800021de:	c13d                	beqz	a0,80002244 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    800021e0:	854a                	mv	a0,s2
    800021e2:	15a010ef          	jal	ra,8000333c <releasesleep>

  acquire(&bcache.lock);
    800021e6:	0000c517          	auipc	a0,0xc
    800021ea:	88250513          	addi	a0,a0,-1918 # 8000da68 <bcache>
    800021ee:	574030ef          	jal	ra,80005762 <acquire>
  b->refcnt--;
    800021f2:	40bc                	lw	a5,64(s1)
    800021f4:	37fd                	addiw	a5,a5,-1
    800021f6:	0007871b          	sext.w	a4,a5
    800021fa:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800021fc:	eb05                	bnez	a4,8000222c <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800021fe:	68bc                	ld	a5,80(s1)
    80002200:	64b8                	ld	a4,72(s1)
    80002202:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002204:	64bc                	ld	a5,72(s1)
    80002206:	68b8                	ld	a4,80(s1)
    80002208:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000220a:	00014797          	auipc	a5,0x14
    8000220e:	85e78793          	addi	a5,a5,-1954 # 80015a68 <bcache+0x8000>
    80002212:	2b87b703          	ld	a4,696(a5)
    80002216:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002218:	00014717          	auipc	a4,0x14
    8000221c:	ab870713          	addi	a4,a4,-1352 # 80015cd0 <bcache+0x8268>
    80002220:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002222:	2b87b703          	ld	a4,696(a5)
    80002226:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002228:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    8000222c:	0000c517          	auipc	a0,0xc
    80002230:	83c50513          	addi	a0,a0,-1988 # 8000da68 <bcache>
    80002234:	5c6030ef          	jal	ra,800057fa <release>
}
    80002238:	60e2                	ld	ra,24(sp)
    8000223a:	6442                	ld	s0,16(sp)
    8000223c:	64a2                	ld	s1,8(sp)
    8000223e:	6902                	ld	s2,0(sp)
    80002240:	6105                	addi	sp,sp,32
    80002242:	8082                	ret
    panic("brelse");
    80002244:	00005517          	auipc	a0,0x5
    80002248:	39450513          	addi	a0,a0,916 # 800075d8 <syscalls+0x148>
    8000224c:	206030ef          	jal	ra,80005452 <panic>

0000000080002250 <bpin>:

void
bpin(struct buf *b) {
    80002250:	1101                	addi	sp,sp,-32
    80002252:	ec06                	sd	ra,24(sp)
    80002254:	e822                	sd	s0,16(sp)
    80002256:	e426                	sd	s1,8(sp)
    80002258:	1000                	addi	s0,sp,32
    8000225a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000225c:	0000c517          	auipc	a0,0xc
    80002260:	80c50513          	addi	a0,a0,-2036 # 8000da68 <bcache>
    80002264:	4fe030ef          	jal	ra,80005762 <acquire>
  b->refcnt++;
    80002268:	40bc                	lw	a5,64(s1)
    8000226a:	2785                	addiw	a5,a5,1
    8000226c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000226e:	0000b517          	auipc	a0,0xb
    80002272:	7fa50513          	addi	a0,a0,2042 # 8000da68 <bcache>
    80002276:	584030ef          	jal	ra,800057fa <release>
}
    8000227a:	60e2                	ld	ra,24(sp)
    8000227c:	6442                	ld	s0,16(sp)
    8000227e:	64a2                	ld	s1,8(sp)
    80002280:	6105                	addi	sp,sp,32
    80002282:	8082                	ret

0000000080002284 <bunpin>:

void
bunpin(struct buf *b) {
    80002284:	1101                	addi	sp,sp,-32
    80002286:	ec06                	sd	ra,24(sp)
    80002288:	e822                	sd	s0,16(sp)
    8000228a:	e426                	sd	s1,8(sp)
    8000228c:	1000                	addi	s0,sp,32
    8000228e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002290:	0000b517          	auipc	a0,0xb
    80002294:	7d850513          	addi	a0,a0,2008 # 8000da68 <bcache>
    80002298:	4ca030ef          	jal	ra,80005762 <acquire>
  b->refcnt--;
    8000229c:	40bc                	lw	a5,64(s1)
    8000229e:	37fd                	addiw	a5,a5,-1
    800022a0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800022a2:	0000b517          	auipc	a0,0xb
    800022a6:	7c650513          	addi	a0,a0,1990 # 8000da68 <bcache>
    800022aa:	550030ef          	jal	ra,800057fa <release>
}
    800022ae:	60e2                	ld	ra,24(sp)
    800022b0:	6442                	ld	s0,16(sp)
    800022b2:	64a2                	ld	s1,8(sp)
    800022b4:	6105                	addi	sp,sp,32
    800022b6:	8082                	ret

00000000800022b8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800022b8:	1101                	addi	sp,sp,-32
    800022ba:	ec06                	sd	ra,24(sp)
    800022bc:	e822                	sd	s0,16(sp)
    800022be:	e426                	sd	s1,8(sp)
    800022c0:	e04a                	sd	s2,0(sp)
    800022c2:	1000                	addi	s0,sp,32
    800022c4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800022c6:	00d5d59b          	srliw	a1,a1,0xd
    800022ca:	00014797          	auipc	a5,0x14
    800022ce:	e7a7a783          	lw	a5,-390(a5) # 80016144 <sb+0x1c>
    800022d2:	9dbd                	addw	a1,a1,a5
    800022d4:	debff0ef          	jal	ra,800020be <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800022d8:	0074f713          	andi	a4,s1,7
    800022dc:	4785                	li	a5,1
    800022de:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800022e2:	14ce                	slli	s1,s1,0x33
    800022e4:	90d9                	srli	s1,s1,0x36
    800022e6:	00950733          	add	a4,a0,s1
    800022ea:	05874703          	lbu	a4,88(a4)
    800022ee:	00e7f6b3          	and	a3,a5,a4
    800022f2:	c29d                	beqz	a3,80002318 <bfree+0x60>
    800022f4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800022f6:	94aa                	add	s1,s1,a0
    800022f8:	fff7c793          	not	a5,a5
    800022fc:	8f7d                	and	a4,a4,a5
    800022fe:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002302:	6ef000ef          	jal	ra,800031f0 <log_write>
  brelse(bp);
    80002306:	854a                	mv	a0,s2
    80002308:	ebfff0ef          	jal	ra,800021c6 <brelse>
}
    8000230c:	60e2                	ld	ra,24(sp)
    8000230e:	6442                	ld	s0,16(sp)
    80002310:	64a2                	ld	s1,8(sp)
    80002312:	6902                	ld	s2,0(sp)
    80002314:	6105                	addi	sp,sp,32
    80002316:	8082                	ret
    panic("freeing free block");
    80002318:	00005517          	auipc	a0,0x5
    8000231c:	2c850513          	addi	a0,a0,712 # 800075e0 <syscalls+0x150>
    80002320:	132030ef          	jal	ra,80005452 <panic>

0000000080002324 <balloc>:
{
    80002324:	711d                	addi	sp,sp,-96
    80002326:	ec86                	sd	ra,88(sp)
    80002328:	e8a2                	sd	s0,80(sp)
    8000232a:	e4a6                	sd	s1,72(sp)
    8000232c:	e0ca                	sd	s2,64(sp)
    8000232e:	fc4e                	sd	s3,56(sp)
    80002330:	f852                	sd	s4,48(sp)
    80002332:	f456                	sd	s5,40(sp)
    80002334:	f05a                	sd	s6,32(sp)
    80002336:	ec5e                	sd	s7,24(sp)
    80002338:	e862                	sd	s8,16(sp)
    8000233a:	e466                	sd	s9,8(sp)
    8000233c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000233e:	00014797          	auipc	a5,0x14
    80002342:	dee7a783          	lw	a5,-530(a5) # 8001612c <sb+0x4>
    80002346:	cff1                	beqz	a5,80002422 <balloc+0xfe>
    80002348:	8baa                	mv	s7,a0
    8000234a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000234c:	00014b17          	auipc	s6,0x14
    80002350:	ddcb0b13          	addi	s6,s6,-548 # 80016128 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002354:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002356:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002358:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000235a:	6c89                	lui	s9,0x2
    8000235c:	a0b5                	j	800023c8 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000235e:	97ca                	add	a5,a5,s2
    80002360:	8e55                	or	a2,a2,a3
    80002362:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002366:	854a                	mv	a0,s2
    80002368:	689000ef          	jal	ra,800031f0 <log_write>
        brelse(bp);
    8000236c:	854a                	mv	a0,s2
    8000236e:	e59ff0ef          	jal	ra,800021c6 <brelse>
  bp = bread(dev, bno);
    80002372:	85a6                	mv	a1,s1
    80002374:	855e                	mv	a0,s7
    80002376:	d49ff0ef          	jal	ra,800020be <bread>
    8000237a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000237c:	40000613          	li	a2,1024
    80002380:	4581                	li	a1,0
    80002382:	05850513          	addi	a0,a0,88
    80002386:	e5bfd0ef          	jal	ra,800001e0 <memset>
  log_write(bp);
    8000238a:	854a                	mv	a0,s2
    8000238c:	665000ef          	jal	ra,800031f0 <log_write>
  brelse(bp);
    80002390:	854a                	mv	a0,s2
    80002392:	e35ff0ef          	jal	ra,800021c6 <brelse>
}
    80002396:	8526                	mv	a0,s1
    80002398:	60e6                	ld	ra,88(sp)
    8000239a:	6446                	ld	s0,80(sp)
    8000239c:	64a6                	ld	s1,72(sp)
    8000239e:	6906                	ld	s2,64(sp)
    800023a0:	79e2                	ld	s3,56(sp)
    800023a2:	7a42                	ld	s4,48(sp)
    800023a4:	7aa2                	ld	s5,40(sp)
    800023a6:	7b02                	ld	s6,32(sp)
    800023a8:	6be2                	ld	s7,24(sp)
    800023aa:	6c42                	ld	s8,16(sp)
    800023ac:	6ca2                	ld	s9,8(sp)
    800023ae:	6125                	addi	sp,sp,96
    800023b0:	8082                	ret
    brelse(bp);
    800023b2:	854a                	mv	a0,s2
    800023b4:	e13ff0ef          	jal	ra,800021c6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800023b8:	015c87bb          	addw	a5,s9,s5
    800023bc:	00078a9b          	sext.w	s5,a5
    800023c0:	004b2703          	lw	a4,4(s6)
    800023c4:	04eaff63          	bgeu	s5,a4,80002422 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    800023c8:	41fad79b          	sraiw	a5,s5,0x1f
    800023cc:	0137d79b          	srliw	a5,a5,0x13
    800023d0:	015787bb          	addw	a5,a5,s5
    800023d4:	40d7d79b          	sraiw	a5,a5,0xd
    800023d8:	01cb2583          	lw	a1,28(s6)
    800023dc:	9dbd                	addw	a1,a1,a5
    800023de:	855e                	mv	a0,s7
    800023e0:	cdfff0ef          	jal	ra,800020be <bread>
    800023e4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800023e6:	004b2503          	lw	a0,4(s6)
    800023ea:	000a849b          	sext.w	s1,s5
    800023ee:	8762                	mv	a4,s8
    800023f0:	fca4f1e3          	bgeu	s1,a0,800023b2 <balloc+0x8e>
      m = 1 << (bi % 8);
    800023f4:	00777693          	andi	a3,a4,7
    800023f8:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800023fc:	41f7579b          	sraiw	a5,a4,0x1f
    80002400:	01d7d79b          	srliw	a5,a5,0x1d
    80002404:	9fb9                	addw	a5,a5,a4
    80002406:	4037d79b          	sraiw	a5,a5,0x3
    8000240a:	00f90633          	add	a2,s2,a5
    8000240e:	05864603          	lbu	a2,88(a2)
    80002412:	00c6f5b3          	and	a1,a3,a2
    80002416:	d5a1                	beqz	a1,8000235e <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002418:	2705                	addiw	a4,a4,1
    8000241a:	2485                	addiw	s1,s1,1
    8000241c:	fd471ae3          	bne	a4,s4,800023f0 <balloc+0xcc>
    80002420:	bf49                	j	800023b2 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80002422:	00005517          	auipc	a0,0x5
    80002426:	1d650513          	addi	a0,a0,470 # 800075f8 <syscalls+0x168>
    8000242a:	575020ef          	jal	ra,8000519e <printf>
  return 0;
    8000242e:	4481                	li	s1,0
    80002430:	b79d                	j	80002396 <balloc+0x72>

0000000080002432 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002432:	7179                	addi	sp,sp,-48
    80002434:	f406                	sd	ra,40(sp)
    80002436:	f022                	sd	s0,32(sp)
    80002438:	ec26                	sd	s1,24(sp)
    8000243a:	e84a                	sd	s2,16(sp)
    8000243c:	e44e                	sd	s3,8(sp)
    8000243e:	e052                	sd	s4,0(sp)
    80002440:	1800                	addi	s0,sp,48
    80002442:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002444:	47ad                	li	a5,11
    80002446:	02b7e663          	bltu	a5,a1,80002472 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    8000244a:	02059793          	slli	a5,a1,0x20
    8000244e:	01e7d593          	srli	a1,a5,0x1e
    80002452:	00b504b3          	add	s1,a0,a1
    80002456:	0504a903          	lw	s2,80(s1)
    8000245a:	06091663          	bnez	s2,800024c6 <bmap+0x94>
      addr = balloc(ip->dev);
    8000245e:	4108                	lw	a0,0(a0)
    80002460:	ec5ff0ef          	jal	ra,80002324 <balloc>
    80002464:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002468:	04090f63          	beqz	s2,800024c6 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    8000246c:	0524a823          	sw	s2,80(s1)
    80002470:	a899                	j	800024c6 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002472:	ff45849b          	addiw	s1,a1,-12
    80002476:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000247a:	0ff00793          	li	a5,255
    8000247e:	06e7eb63          	bltu	a5,a4,800024f4 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002482:	08052903          	lw	s2,128(a0)
    80002486:	00091b63          	bnez	s2,8000249c <bmap+0x6a>
      addr = balloc(ip->dev);
    8000248a:	4108                	lw	a0,0(a0)
    8000248c:	e99ff0ef          	jal	ra,80002324 <balloc>
    80002490:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002494:	02090963          	beqz	s2,800024c6 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002498:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000249c:	85ca                	mv	a1,s2
    8000249e:	0009a503          	lw	a0,0(s3)
    800024a2:	c1dff0ef          	jal	ra,800020be <bread>
    800024a6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800024a8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800024ac:	02049713          	slli	a4,s1,0x20
    800024b0:	01e75593          	srli	a1,a4,0x1e
    800024b4:	00b784b3          	add	s1,a5,a1
    800024b8:	0004a903          	lw	s2,0(s1)
    800024bc:	00090e63          	beqz	s2,800024d8 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800024c0:	8552                	mv	a0,s4
    800024c2:	d05ff0ef          	jal	ra,800021c6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800024c6:	854a                	mv	a0,s2
    800024c8:	70a2                	ld	ra,40(sp)
    800024ca:	7402                	ld	s0,32(sp)
    800024cc:	64e2                	ld	s1,24(sp)
    800024ce:	6942                	ld	s2,16(sp)
    800024d0:	69a2                	ld	s3,8(sp)
    800024d2:	6a02                	ld	s4,0(sp)
    800024d4:	6145                	addi	sp,sp,48
    800024d6:	8082                	ret
      addr = balloc(ip->dev);
    800024d8:	0009a503          	lw	a0,0(s3)
    800024dc:	e49ff0ef          	jal	ra,80002324 <balloc>
    800024e0:	0005091b          	sext.w	s2,a0
      if(addr){
    800024e4:	fc090ee3          	beqz	s2,800024c0 <bmap+0x8e>
        a[bn] = addr;
    800024e8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800024ec:	8552                	mv	a0,s4
    800024ee:	503000ef          	jal	ra,800031f0 <log_write>
    800024f2:	b7f9                	j	800024c0 <bmap+0x8e>
  panic("bmap: out of range");
    800024f4:	00005517          	auipc	a0,0x5
    800024f8:	11c50513          	addi	a0,a0,284 # 80007610 <syscalls+0x180>
    800024fc:	757020ef          	jal	ra,80005452 <panic>

0000000080002500 <iget>:
{
    80002500:	7179                	addi	sp,sp,-48
    80002502:	f406                	sd	ra,40(sp)
    80002504:	f022                	sd	s0,32(sp)
    80002506:	ec26                	sd	s1,24(sp)
    80002508:	e84a                	sd	s2,16(sp)
    8000250a:	e44e                	sd	s3,8(sp)
    8000250c:	e052                	sd	s4,0(sp)
    8000250e:	1800                	addi	s0,sp,48
    80002510:	89aa                	mv	s3,a0
    80002512:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002514:	00014517          	auipc	a0,0x14
    80002518:	c3450513          	addi	a0,a0,-972 # 80016148 <itable>
    8000251c:	246030ef          	jal	ra,80005762 <acquire>
  empty = 0;
    80002520:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002522:	00014497          	auipc	s1,0x14
    80002526:	c3e48493          	addi	s1,s1,-962 # 80016160 <itable+0x18>
    8000252a:	00015697          	auipc	a3,0x15
    8000252e:	6c668693          	addi	a3,a3,1734 # 80017bf0 <log>
    80002532:	a039                	j	80002540 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002534:	02090963          	beqz	s2,80002566 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002538:	08848493          	addi	s1,s1,136
    8000253c:	02d48863          	beq	s1,a3,8000256c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002540:	449c                	lw	a5,8(s1)
    80002542:	fef059e3          	blez	a5,80002534 <iget+0x34>
    80002546:	4098                	lw	a4,0(s1)
    80002548:	ff3716e3          	bne	a4,s3,80002534 <iget+0x34>
    8000254c:	40d8                	lw	a4,4(s1)
    8000254e:	ff4713e3          	bne	a4,s4,80002534 <iget+0x34>
      ip->ref++;
    80002552:	2785                	addiw	a5,a5,1
    80002554:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002556:	00014517          	auipc	a0,0x14
    8000255a:	bf250513          	addi	a0,a0,-1038 # 80016148 <itable>
    8000255e:	29c030ef          	jal	ra,800057fa <release>
      return ip;
    80002562:	8926                	mv	s2,s1
    80002564:	a02d                	j	8000258e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002566:	fbe9                	bnez	a5,80002538 <iget+0x38>
    80002568:	8926                	mv	s2,s1
    8000256a:	b7f9                	j	80002538 <iget+0x38>
  if(empty == 0)
    8000256c:	02090a63          	beqz	s2,800025a0 <iget+0xa0>
  ip->dev = dev;
    80002570:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002574:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002578:	4785                	li	a5,1
    8000257a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000257e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002582:	00014517          	auipc	a0,0x14
    80002586:	bc650513          	addi	a0,a0,-1082 # 80016148 <itable>
    8000258a:	270030ef          	jal	ra,800057fa <release>
}
    8000258e:	854a                	mv	a0,s2
    80002590:	70a2                	ld	ra,40(sp)
    80002592:	7402                	ld	s0,32(sp)
    80002594:	64e2                	ld	s1,24(sp)
    80002596:	6942                	ld	s2,16(sp)
    80002598:	69a2                	ld	s3,8(sp)
    8000259a:	6a02                	ld	s4,0(sp)
    8000259c:	6145                	addi	sp,sp,48
    8000259e:	8082                	ret
    panic("iget: no inodes");
    800025a0:	00005517          	auipc	a0,0x5
    800025a4:	08850513          	addi	a0,a0,136 # 80007628 <syscalls+0x198>
    800025a8:	6ab020ef          	jal	ra,80005452 <panic>

00000000800025ac <fsinit>:
fsinit(int dev) {
    800025ac:	7179                	addi	sp,sp,-48
    800025ae:	f406                	sd	ra,40(sp)
    800025b0:	f022                	sd	s0,32(sp)
    800025b2:	ec26                	sd	s1,24(sp)
    800025b4:	e84a                	sd	s2,16(sp)
    800025b6:	e44e                	sd	s3,8(sp)
    800025b8:	1800                	addi	s0,sp,48
    800025ba:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800025bc:	4585                	li	a1,1
    800025be:	b01ff0ef          	jal	ra,800020be <bread>
    800025c2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800025c4:	00014997          	auipc	s3,0x14
    800025c8:	b6498993          	addi	s3,s3,-1180 # 80016128 <sb>
    800025cc:	02000613          	li	a2,32
    800025d0:	05850593          	addi	a1,a0,88
    800025d4:	854e                	mv	a0,s3
    800025d6:	c67fd0ef          	jal	ra,8000023c <memmove>
  brelse(bp);
    800025da:	8526                	mv	a0,s1
    800025dc:	bebff0ef          	jal	ra,800021c6 <brelse>
  if(sb.magic != FSMAGIC)
    800025e0:	0009a703          	lw	a4,0(s3)
    800025e4:	102037b7          	lui	a5,0x10203
    800025e8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800025ec:	02f71063          	bne	a4,a5,8000260c <fsinit+0x60>
  initlog(dev, &sb);
    800025f0:	00014597          	auipc	a1,0x14
    800025f4:	b3858593          	addi	a1,a1,-1224 # 80016128 <sb>
    800025f8:	854a                	mv	a0,s2
    800025fa:	1e3000ef          	jal	ra,80002fdc <initlog>
}
    800025fe:	70a2                	ld	ra,40(sp)
    80002600:	7402                	ld	s0,32(sp)
    80002602:	64e2                	ld	s1,24(sp)
    80002604:	6942                	ld	s2,16(sp)
    80002606:	69a2                	ld	s3,8(sp)
    80002608:	6145                	addi	sp,sp,48
    8000260a:	8082                	ret
    panic("invalid file system");
    8000260c:	00005517          	auipc	a0,0x5
    80002610:	02c50513          	addi	a0,a0,44 # 80007638 <syscalls+0x1a8>
    80002614:	63f020ef          	jal	ra,80005452 <panic>

0000000080002618 <iinit>:
{
    80002618:	7179                	addi	sp,sp,-48
    8000261a:	f406                	sd	ra,40(sp)
    8000261c:	f022                	sd	s0,32(sp)
    8000261e:	ec26                	sd	s1,24(sp)
    80002620:	e84a                	sd	s2,16(sp)
    80002622:	e44e                	sd	s3,8(sp)
    80002624:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002626:	00005597          	auipc	a1,0x5
    8000262a:	02a58593          	addi	a1,a1,42 # 80007650 <syscalls+0x1c0>
    8000262e:	00014517          	auipc	a0,0x14
    80002632:	b1a50513          	addi	a0,a0,-1254 # 80016148 <itable>
    80002636:	0ac030ef          	jal	ra,800056e2 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000263a:	00014497          	auipc	s1,0x14
    8000263e:	b3648493          	addi	s1,s1,-1226 # 80016170 <itable+0x28>
    80002642:	00015997          	auipc	s3,0x15
    80002646:	5be98993          	addi	s3,s3,1470 # 80017c00 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000264a:	00005917          	auipc	s2,0x5
    8000264e:	00e90913          	addi	s2,s2,14 # 80007658 <syscalls+0x1c8>
    80002652:	85ca                	mv	a1,s2
    80002654:	8526                	mv	a0,s1
    80002656:	46b000ef          	jal	ra,800032c0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000265a:	08848493          	addi	s1,s1,136
    8000265e:	ff349ae3          	bne	s1,s3,80002652 <iinit+0x3a>
}
    80002662:	70a2                	ld	ra,40(sp)
    80002664:	7402                	ld	s0,32(sp)
    80002666:	64e2                	ld	s1,24(sp)
    80002668:	6942                	ld	s2,16(sp)
    8000266a:	69a2                	ld	s3,8(sp)
    8000266c:	6145                	addi	sp,sp,48
    8000266e:	8082                	ret

0000000080002670 <ialloc>:
{
    80002670:	715d                	addi	sp,sp,-80
    80002672:	e486                	sd	ra,72(sp)
    80002674:	e0a2                	sd	s0,64(sp)
    80002676:	fc26                	sd	s1,56(sp)
    80002678:	f84a                	sd	s2,48(sp)
    8000267a:	f44e                	sd	s3,40(sp)
    8000267c:	f052                	sd	s4,32(sp)
    8000267e:	ec56                	sd	s5,24(sp)
    80002680:	e85a                	sd	s6,16(sp)
    80002682:	e45e                	sd	s7,8(sp)
    80002684:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002686:	00014717          	auipc	a4,0x14
    8000268a:	aae72703          	lw	a4,-1362(a4) # 80016134 <sb+0xc>
    8000268e:	4785                	li	a5,1
    80002690:	04e7f663          	bgeu	a5,a4,800026dc <ialloc+0x6c>
    80002694:	8aaa                	mv	s5,a0
    80002696:	8bae                	mv	s7,a1
    80002698:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000269a:	00014a17          	auipc	s4,0x14
    8000269e:	a8ea0a13          	addi	s4,s4,-1394 # 80016128 <sb>
    800026a2:	00048b1b          	sext.w	s6,s1
    800026a6:	0044d593          	srli	a1,s1,0x4
    800026aa:	018a2783          	lw	a5,24(s4)
    800026ae:	9dbd                	addw	a1,a1,a5
    800026b0:	8556                	mv	a0,s5
    800026b2:	a0dff0ef          	jal	ra,800020be <bread>
    800026b6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800026b8:	05850993          	addi	s3,a0,88
    800026bc:	00f4f793          	andi	a5,s1,15
    800026c0:	079a                	slli	a5,a5,0x6
    800026c2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800026c4:	00099783          	lh	a5,0(s3)
    800026c8:	cf85                	beqz	a5,80002700 <ialloc+0x90>
    brelse(bp);
    800026ca:	afdff0ef          	jal	ra,800021c6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800026ce:	0485                	addi	s1,s1,1
    800026d0:	00ca2703          	lw	a4,12(s4)
    800026d4:	0004879b          	sext.w	a5,s1
    800026d8:	fce7e5e3          	bltu	a5,a4,800026a2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800026dc:	00005517          	auipc	a0,0x5
    800026e0:	f8450513          	addi	a0,a0,-124 # 80007660 <syscalls+0x1d0>
    800026e4:	2bb020ef          	jal	ra,8000519e <printf>
  return 0;
    800026e8:	4501                	li	a0,0
}
    800026ea:	60a6                	ld	ra,72(sp)
    800026ec:	6406                	ld	s0,64(sp)
    800026ee:	74e2                	ld	s1,56(sp)
    800026f0:	7942                	ld	s2,48(sp)
    800026f2:	79a2                	ld	s3,40(sp)
    800026f4:	7a02                	ld	s4,32(sp)
    800026f6:	6ae2                	ld	s5,24(sp)
    800026f8:	6b42                	ld	s6,16(sp)
    800026fa:	6ba2                	ld	s7,8(sp)
    800026fc:	6161                	addi	sp,sp,80
    800026fe:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002700:	04000613          	li	a2,64
    80002704:	4581                	li	a1,0
    80002706:	854e                	mv	a0,s3
    80002708:	ad9fd0ef          	jal	ra,800001e0 <memset>
      dip->type = type;
    8000270c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002710:	854a                	mv	a0,s2
    80002712:	2df000ef          	jal	ra,800031f0 <log_write>
      brelse(bp);
    80002716:	854a                	mv	a0,s2
    80002718:	aafff0ef          	jal	ra,800021c6 <brelse>
      return iget(dev, inum);
    8000271c:	85da                	mv	a1,s6
    8000271e:	8556                	mv	a0,s5
    80002720:	de1ff0ef          	jal	ra,80002500 <iget>
    80002724:	b7d9                	j	800026ea <ialloc+0x7a>

0000000080002726 <iupdate>:
{
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	e426                	sd	s1,8(sp)
    8000272e:	e04a                	sd	s2,0(sp)
    80002730:	1000                	addi	s0,sp,32
    80002732:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002734:	415c                	lw	a5,4(a0)
    80002736:	0047d79b          	srliw	a5,a5,0x4
    8000273a:	00014597          	auipc	a1,0x14
    8000273e:	a065a583          	lw	a1,-1530(a1) # 80016140 <sb+0x18>
    80002742:	9dbd                	addw	a1,a1,a5
    80002744:	4108                	lw	a0,0(a0)
    80002746:	979ff0ef          	jal	ra,800020be <bread>
    8000274a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000274c:	05850793          	addi	a5,a0,88
    80002750:	40d8                	lw	a4,4(s1)
    80002752:	8b3d                	andi	a4,a4,15
    80002754:	071a                	slli	a4,a4,0x6
    80002756:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002758:	04449703          	lh	a4,68(s1)
    8000275c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002760:	04649703          	lh	a4,70(s1)
    80002764:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002768:	04849703          	lh	a4,72(s1)
    8000276c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002770:	04a49703          	lh	a4,74(s1)
    80002774:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002778:	44f8                	lw	a4,76(s1)
    8000277a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000277c:	03400613          	li	a2,52
    80002780:	05048593          	addi	a1,s1,80
    80002784:	00c78513          	addi	a0,a5,12
    80002788:	ab5fd0ef          	jal	ra,8000023c <memmove>
  log_write(bp);
    8000278c:	854a                	mv	a0,s2
    8000278e:	263000ef          	jal	ra,800031f0 <log_write>
  brelse(bp);
    80002792:	854a                	mv	a0,s2
    80002794:	a33ff0ef          	jal	ra,800021c6 <brelse>
}
    80002798:	60e2                	ld	ra,24(sp)
    8000279a:	6442                	ld	s0,16(sp)
    8000279c:	64a2                	ld	s1,8(sp)
    8000279e:	6902                	ld	s2,0(sp)
    800027a0:	6105                	addi	sp,sp,32
    800027a2:	8082                	ret

00000000800027a4 <idup>:
{
    800027a4:	1101                	addi	sp,sp,-32
    800027a6:	ec06                	sd	ra,24(sp)
    800027a8:	e822                	sd	s0,16(sp)
    800027aa:	e426                	sd	s1,8(sp)
    800027ac:	1000                	addi	s0,sp,32
    800027ae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800027b0:	00014517          	auipc	a0,0x14
    800027b4:	99850513          	addi	a0,a0,-1640 # 80016148 <itable>
    800027b8:	7ab020ef          	jal	ra,80005762 <acquire>
  ip->ref++;
    800027bc:	449c                	lw	a5,8(s1)
    800027be:	2785                	addiw	a5,a5,1
    800027c0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800027c2:	00014517          	auipc	a0,0x14
    800027c6:	98650513          	addi	a0,a0,-1658 # 80016148 <itable>
    800027ca:	030030ef          	jal	ra,800057fa <release>
}
    800027ce:	8526                	mv	a0,s1
    800027d0:	60e2                	ld	ra,24(sp)
    800027d2:	6442                	ld	s0,16(sp)
    800027d4:	64a2                	ld	s1,8(sp)
    800027d6:	6105                	addi	sp,sp,32
    800027d8:	8082                	ret

00000000800027da <ilock>:
{
    800027da:	1101                	addi	sp,sp,-32
    800027dc:	ec06                	sd	ra,24(sp)
    800027de:	e822                	sd	s0,16(sp)
    800027e0:	e426                	sd	s1,8(sp)
    800027e2:	e04a                	sd	s2,0(sp)
    800027e4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800027e6:	c105                	beqz	a0,80002806 <ilock+0x2c>
    800027e8:	84aa                	mv	s1,a0
    800027ea:	451c                	lw	a5,8(a0)
    800027ec:	00f05d63          	blez	a5,80002806 <ilock+0x2c>
  acquiresleep(&ip->lock);
    800027f0:	0541                	addi	a0,a0,16
    800027f2:	305000ef          	jal	ra,800032f6 <acquiresleep>
  if(ip->valid == 0){
    800027f6:	40bc                	lw	a5,64(s1)
    800027f8:	cf89                	beqz	a5,80002812 <ilock+0x38>
}
    800027fa:	60e2                	ld	ra,24(sp)
    800027fc:	6442                	ld	s0,16(sp)
    800027fe:	64a2                	ld	s1,8(sp)
    80002800:	6902                	ld	s2,0(sp)
    80002802:	6105                	addi	sp,sp,32
    80002804:	8082                	ret
    panic("ilock");
    80002806:	00005517          	auipc	a0,0x5
    8000280a:	e7250513          	addi	a0,a0,-398 # 80007678 <syscalls+0x1e8>
    8000280e:	445020ef          	jal	ra,80005452 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002812:	40dc                	lw	a5,4(s1)
    80002814:	0047d79b          	srliw	a5,a5,0x4
    80002818:	00014597          	auipc	a1,0x14
    8000281c:	9285a583          	lw	a1,-1752(a1) # 80016140 <sb+0x18>
    80002820:	9dbd                	addw	a1,a1,a5
    80002822:	4088                	lw	a0,0(s1)
    80002824:	89bff0ef          	jal	ra,800020be <bread>
    80002828:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000282a:	05850593          	addi	a1,a0,88
    8000282e:	40dc                	lw	a5,4(s1)
    80002830:	8bbd                	andi	a5,a5,15
    80002832:	079a                	slli	a5,a5,0x6
    80002834:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002836:	00059783          	lh	a5,0(a1)
    8000283a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000283e:	00259783          	lh	a5,2(a1)
    80002842:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002846:	00459783          	lh	a5,4(a1)
    8000284a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000284e:	00659783          	lh	a5,6(a1)
    80002852:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002856:	459c                	lw	a5,8(a1)
    80002858:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000285a:	03400613          	li	a2,52
    8000285e:	05b1                	addi	a1,a1,12
    80002860:	05048513          	addi	a0,s1,80
    80002864:	9d9fd0ef          	jal	ra,8000023c <memmove>
    brelse(bp);
    80002868:	854a                	mv	a0,s2
    8000286a:	95dff0ef          	jal	ra,800021c6 <brelse>
    ip->valid = 1;
    8000286e:	4785                	li	a5,1
    80002870:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002872:	04449783          	lh	a5,68(s1)
    80002876:	f3d1                	bnez	a5,800027fa <ilock+0x20>
      panic("ilock: no type");
    80002878:	00005517          	auipc	a0,0x5
    8000287c:	e0850513          	addi	a0,a0,-504 # 80007680 <syscalls+0x1f0>
    80002880:	3d3020ef          	jal	ra,80005452 <panic>

0000000080002884 <iunlock>:
{
    80002884:	1101                	addi	sp,sp,-32
    80002886:	ec06                	sd	ra,24(sp)
    80002888:	e822                	sd	s0,16(sp)
    8000288a:	e426                	sd	s1,8(sp)
    8000288c:	e04a                	sd	s2,0(sp)
    8000288e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002890:	c505                	beqz	a0,800028b8 <iunlock+0x34>
    80002892:	84aa                	mv	s1,a0
    80002894:	01050913          	addi	s2,a0,16
    80002898:	854a                	mv	a0,s2
    8000289a:	2db000ef          	jal	ra,80003374 <holdingsleep>
    8000289e:	cd09                	beqz	a0,800028b8 <iunlock+0x34>
    800028a0:	449c                	lw	a5,8(s1)
    800028a2:	00f05b63          	blez	a5,800028b8 <iunlock+0x34>
  releasesleep(&ip->lock);
    800028a6:	854a                	mv	a0,s2
    800028a8:	295000ef          	jal	ra,8000333c <releasesleep>
}
    800028ac:	60e2                	ld	ra,24(sp)
    800028ae:	6442                	ld	s0,16(sp)
    800028b0:	64a2                	ld	s1,8(sp)
    800028b2:	6902                	ld	s2,0(sp)
    800028b4:	6105                	addi	sp,sp,32
    800028b6:	8082                	ret
    panic("iunlock");
    800028b8:	00005517          	auipc	a0,0x5
    800028bc:	dd850513          	addi	a0,a0,-552 # 80007690 <syscalls+0x200>
    800028c0:	393020ef          	jal	ra,80005452 <panic>

00000000800028c4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800028c4:	7179                	addi	sp,sp,-48
    800028c6:	f406                	sd	ra,40(sp)
    800028c8:	f022                	sd	s0,32(sp)
    800028ca:	ec26                	sd	s1,24(sp)
    800028cc:	e84a                	sd	s2,16(sp)
    800028ce:	e44e                	sd	s3,8(sp)
    800028d0:	e052                	sd	s4,0(sp)
    800028d2:	1800                	addi	s0,sp,48
    800028d4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800028d6:	05050493          	addi	s1,a0,80
    800028da:	08050913          	addi	s2,a0,128
    800028de:	a021                	j	800028e6 <itrunc+0x22>
    800028e0:	0491                	addi	s1,s1,4
    800028e2:	01248b63          	beq	s1,s2,800028f8 <itrunc+0x34>
    if(ip->addrs[i]){
    800028e6:	408c                	lw	a1,0(s1)
    800028e8:	dde5                	beqz	a1,800028e0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800028ea:	0009a503          	lw	a0,0(s3)
    800028ee:	9cbff0ef          	jal	ra,800022b8 <bfree>
      ip->addrs[i] = 0;
    800028f2:	0004a023          	sw	zero,0(s1)
    800028f6:	b7ed                	j	800028e0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800028f8:	0809a583          	lw	a1,128(s3)
    800028fc:	ed91                	bnez	a1,80002918 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800028fe:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002902:	854e                	mv	a0,s3
    80002904:	e23ff0ef          	jal	ra,80002726 <iupdate>
}
    80002908:	70a2                	ld	ra,40(sp)
    8000290a:	7402                	ld	s0,32(sp)
    8000290c:	64e2                	ld	s1,24(sp)
    8000290e:	6942                	ld	s2,16(sp)
    80002910:	69a2                	ld	s3,8(sp)
    80002912:	6a02                	ld	s4,0(sp)
    80002914:	6145                	addi	sp,sp,48
    80002916:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002918:	0009a503          	lw	a0,0(s3)
    8000291c:	fa2ff0ef          	jal	ra,800020be <bread>
    80002920:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002922:	05850493          	addi	s1,a0,88
    80002926:	45850913          	addi	s2,a0,1112
    8000292a:	a021                	j	80002932 <itrunc+0x6e>
    8000292c:	0491                	addi	s1,s1,4
    8000292e:	01248963          	beq	s1,s2,80002940 <itrunc+0x7c>
      if(a[j])
    80002932:	408c                	lw	a1,0(s1)
    80002934:	dde5                	beqz	a1,8000292c <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80002936:	0009a503          	lw	a0,0(s3)
    8000293a:	97fff0ef          	jal	ra,800022b8 <bfree>
    8000293e:	b7fd                	j	8000292c <itrunc+0x68>
    brelse(bp);
    80002940:	8552                	mv	a0,s4
    80002942:	885ff0ef          	jal	ra,800021c6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002946:	0809a583          	lw	a1,128(s3)
    8000294a:	0009a503          	lw	a0,0(s3)
    8000294e:	96bff0ef          	jal	ra,800022b8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002952:	0809a023          	sw	zero,128(s3)
    80002956:	b765                	j	800028fe <itrunc+0x3a>

0000000080002958 <iput>:
{
    80002958:	1101                	addi	sp,sp,-32
    8000295a:	ec06                	sd	ra,24(sp)
    8000295c:	e822                	sd	s0,16(sp)
    8000295e:	e426                	sd	s1,8(sp)
    80002960:	e04a                	sd	s2,0(sp)
    80002962:	1000                	addi	s0,sp,32
    80002964:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002966:	00013517          	auipc	a0,0x13
    8000296a:	7e250513          	addi	a0,a0,2018 # 80016148 <itable>
    8000296e:	5f5020ef          	jal	ra,80005762 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002972:	4498                	lw	a4,8(s1)
    80002974:	4785                	li	a5,1
    80002976:	02f70163          	beq	a4,a5,80002998 <iput+0x40>
  ip->ref--;
    8000297a:	449c                	lw	a5,8(s1)
    8000297c:	37fd                	addiw	a5,a5,-1
    8000297e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002980:	00013517          	auipc	a0,0x13
    80002984:	7c850513          	addi	a0,a0,1992 # 80016148 <itable>
    80002988:	673020ef          	jal	ra,800057fa <release>
}
    8000298c:	60e2                	ld	ra,24(sp)
    8000298e:	6442                	ld	s0,16(sp)
    80002990:	64a2                	ld	s1,8(sp)
    80002992:	6902                	ld	s2,0(sp)
    80002994:	6105                	addi	sp,sp,32
    80002996:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002998:	40bc                	lw	a5,64(s1)
    8000299a:	d3e5                	beqz	a5,8000297a <iput+0x22>
    8000299c:	04a49783          	lh	a5,74(s1)
    800029a0:	ffe9                	bnez	a5,8000297a <iput+0x22>
    acquiresleep(&ip->lock);
    800029a2:	01048913          	addi	s2,s1,16
    800029a6:	854a                	mv	a0,s2
    800029a8:	14f000ef          	jal	ra,800032f6 <acquiresleep>
    release(&itable.lock);
    800029ac:	00013517          	auipc	a0,0x13
    800029b0:	79c50513          	addi	a0,a0,1948 # 80016148 <itable>
    800029b4:	647020ef          	jal	ra,800057fa <release>
    itrunc(ip);
    800029b8:	8526                	mv	a0,s1
    800029ba:	f0bff0ef          	jal	ra,800028c4 <itrunc>
    ip->type = 0;
    800029be:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800029c2:	8526                	mv	a0,s1
    800029c4:	d63ff0ef          	jal	ra,80002726 <iupdate>
    ip->valid = 0;
    800029c8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800029cc:	854a                	mv	a0,s2
    800029ce:	16f000ef          	jal	ra,8000333c <releasesleep>
    acquire(&itable.lock);
    800029d2:	00013517          	auipc	a0,0x13
    800029d6:	77650513          	addi	a0,a0,1910 # 80016148 <itable>
    800029da:	589020ef          	jal	ra,80005762 <acquire>
    800029de:	bf71                	j	8000297a <iput+0x22>

00000000800029e0 <iunlockput>:
{
    800029e0:	1101                	addi	sp,sp,-32
    800029e2:	ec06                	sd	ra,24(sp)
    800029e4:	e822                	sd	s0,16(sp)
    800029e6:	e426                	sd	s1,8(sp)
    800029e8:	1000                	addi	s0,sp,32
    800029ea:	84aa                	mv	s1,a0
  iunlock(ip);
    800029ec:	e99ff0ef          	jal	ra,80002884 <iunlock>
  iput(ip);
    800029f0:	8526                	mv	a0,s1
    800029f2:	f67ff0ef          	jal	ra,80002958 <iput>
}
    800029f6:	60e2                	ld	ra,24(sp)
    800029f8:	6442                	ld	s0,16(sp)
    800029fa:	64a2                	ld	s1,8(sp)
    800029fc:	6105                	addi	sp,sp,32
    800029fe:	8082                	ret

0000000080002a00 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002a00:	1141                	addi	sp,sp,-16
    80002a02:	e422                	sd	s0,8(sp)
    80002a04:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002a06:	411c                	lw	a5,0(a0)
    80002a08:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002a0a:	415c                	lw	a5,4(a0)
    80002a0c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002a0e:	04451783          	lh	a5,68(a0)
    80002a12:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002a16:	04a51783          	lh	a5,74(a0)
    80002a1a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002a1e:	04c56783          	lwu	a5,76(a0)
    80002a22:	e99c                	sd	a5,16(a1)
}
    80002a24:	6422                	ld	s0,8(sp)
    80002a26:	0141                	addi	sp,sp,16
    80002a28:	8082                	ret

0000000080002a2a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002a2a:	457c                	lw	a5,76(a0)
    80002a2c:	0cd7ef63          	bltu	a5,a3,80002b0a <readi+0xe0>
{
    80002a30:	7159                	addi	sp,sp,-112
    80002a32:	f486                	sd	ra,104(sp)
    80002a34:	f0a2                	sd	s0,96(sp)
    80002a36:	eca6                	sd	s1,88(sp)
    80002a38:	e8ca                	sd	s2,80(sp)
    80002a3a:	e4ce                	sd	s3,72(sp)
    80002a3c:	e0d2                	sd	s4,64(sp)
    80002a3e:	fc56                	sd	s5,56(sp)
    80002a40:	f85a                	sd	s6,48(sp)
    80002a42:	f45e                	sd	s7,40(sp)
    80002a44:	f062                	sd	s8,32(sp)
    80002a46:	ec66                	sd	s9,24(sp)
    80002a48:	e86a                	sd	s10,16(sp)
    80002a4a:	e46e                	sd	s11,8(sp)
    80002a4c:	1880                	addi	s0,sp,112
    80002a4e:	8b2a                	mv	s6,a0
    80002a50:	8bae                	mv	s7,a1
    80002a52:	8a32                	mv	s4,a2
    80002a54:	84b6                	mv	s1,a3
    80002a56:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002a58:	9f35                	addw	a4,a4,a3
    return 0;
    80002a5a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002a5c:	08d76663          	bltu	a4,a3,80002ae8 <readi+0xbe>
  if(off + n > ip->size)
    80002a60:	00e7f463          	bgeu	a5,a4,80002a68 <readi+0x3e>
    n = ip->size - off;
    80002a64:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a68:	080a8f63          	beqz	s5,80002b06 <readi+0xdc>
    80002a6c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a6e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002a72:	5c7d                	li	s8,-1
    80002a74:	a80d                	j	80002aa6 <readi+0x7c>
    80002a76:	020d1d93          	slli	s11,s10,0x20
    80002a7a:	020ddd93          	srli	s11,s11,0x20
    80002a7e:	05890613          	addi	a2,s2,88
    80002a82:	86ee                	mv	a3,s11
    80002a84:	963a                	add	a2,a2,a4
    80002a86:	85d2                	mv	a1,s4
    80002a88:	855e                	mv	a0,s7
    80002a8a:	d6bfe0ef          	jal	ra,800017f4 <either_copyout>
    80002a8e:	05850763          	beq	a0,s8,80002adc <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002a92:	854a                	mv	a0,s2
    80002a94:	f32ff0ef          	jal	ra,800021c6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a98:	013d09bb          	addw	s3,s10,s3
    80002a9c:	009d04bb          	addw	s1,s10,s1
    80002aa0:	9a6e                	add	s4,s4,s11
    80002aa2:	0559f163          	bgeu	s3,s5,80002ae4 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80002aa6:	00a4d59b          	srliw	a1,s1,0xa
    80002aaa:	855a                	mv	a0,s6
    80002aac:	987ff0ef          	jal	ra,80002432 <bmap>
    80002ab0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002ab4:	c985                	beqz	a1,80002ae4 <readi+0xba>
    bp = bread(ip->dev, addr);
    80002ab6:	000b2503          	lw	a0,0(s6)
    80002aba:	e04ff0ef          	jal	ra,800020be <bread>
    80002abe:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ac0:	3ff4f713          	andi	a4,s1,1023
    80002ac4:	40ec87bb          	subw	a5,s9,a4
    80002ac8:	413a86bb          	subw	a3,s5,s3
    80002acc:	8d3e                	mv	s10,a5
    80002ace:	2781                	sext.w	a5,a5
    80002ad0:	0006861b          	sext.w	a2,a3
    80002ad4:	faf671e3          	bgeu	a2,a5,80002a76 <readi+0x4c>
    80002ad8:	8d36                	mv	s10,a3
    80002ada:	bf71                	j	80002a76 <readi+0x4c>
      brelse(bp);
    80002adc:	854a                	mv	a0,s2
    80002ade:	ee8ff0ef          	jal	ra,800021c6 <brelse>
      tot = -1;
    80002ae2:	59fd                	li	s3,-1
  }
  return tot;
    80002ae4:	0009851b          	sext.w	a0,s3
}
    80002ae8:	70a6                	ld	ra,104(sp)
    80002aea:	7406                	ld	s0,96(sp)
    80002aec:	64e6                	ld	s1,88(sp)
    80002aee:	6946                	ld	s2,80(sp)
    80002af0:	69a6                	ld	s3,72(sp)
    80002af2:	6a06                	ld	s4,64(sp)
    80002af4:	7ae2                	ld	s5,56(sp)
    80002af6:	7b42                	ld	s6,48(sp)
    80002af8:	7ba2                	ld	s7,40(sp)
    80002afa:	7c02                	ld	s8,32(sp)
    80002afc:	6ce2                	ld	s9,24(sp)
    80002afe:	6d42                	ld	s10,16(sp)
    80002b00:	6da2                	ld	s11,8(sp)
    80002b02:	6165                	addi	sp,sp,112
    80002b04:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b06:	89d6                	mv	s3,s5
    80002b08:	bff1                	j	80002ae4 <readi+0xba>
    return 0;
    80002b0a:	4501                	li	a0,0
}
    80002b0c:	8082                	ret

0000000080002b0e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002b0e:	457c                	lw	a5,76(a0)
    80002b10:	0ed7ea63          	bltu	a5,a3,80002c04 <writei+0xf6>
{
    80002b14:	7159                	addi	sp,sp,-112
    80002b16:	f486                	sd	ra,104(sp)
    80002b18:	f0a2                	sd	s0,96(sp)
    80002b1a:	eca6                	sd	s1,88(sp)
    80002b1c:	e8ca                	sd	s2,80(sp)
    80002b1e:	e4ce                	sd	s3,72(sp)
    80002b20:	e0d2                	sd	s4,64(sp)
    80002b22:	fc56                	sd	s5,56(sp)
    80002b24:	f85a                	sd	s6,48(sp)
    80002b26:	f45e                	sd	s7,40(sp)
    80002b28:	f062                	sd	s8,32(sp)
    80002b2a:	ec66                	sd	s9,24(sp)
    80002b2c:	e86a                	sd	s10,16(sp)
    80002b2e:	e46e                	sd	s11,8(sp)
    80002b30:	1880                	addi	s0,sp,112
    80002b32:	8aaa                	mv	s5,a0
    80002b34:	8bae                	mv	s7,a1
    80002b36:	8a32                	mv	s4,a2
    80002b38:	8936                	mv	s2,a3
    80002b3a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002b3c:	00e687bb          	addw	a5,a3,a4
    80002b40:	0cd7e463          	bltu	a5,a3,80002c08 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002b44:	00043737          	lui	a4,0x43
    80002b48:	0cf76263          	bltu	a4,a5,80002c0c <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b4c:	0a0b0a63          	beqz	s6,80002c00 <writei+0xf2>
    80002b50:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b52:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002b56:	5c7d                	li	s8,-1
    80002b58:	a825                	j	80002b90 <writei+0x82>
    80002b5a:	020d1d93          	slli	s11,s10,0x20
    80002b5e:	020ddd93          	srli	s11,s11,0x20
    80002b62:	05848513          	addi	a0,s1,88
    80002b66:	86ee                	mv	a3,s11
    80002b68:	8652                	mv	a2,s4
    80002b6a:	85de                	mv	a1,s7
    80002b6c:	953a                	add	a0,a0,a4
    80002b6e:	cd1fe0ef          	jal	ra,8000183e <either_copyin>
    80002b72:	05850a63          	beq	a0,s8,80002bc6 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002b76:	8526                	mv	a0,s1
    80002b78:	678000ef          	jal	ra,800031f0 <log_write>
    brelse(bp);
    80002b7c:	8526                	mv	a0,s1
    80002b7e:	e48ff0ef          	jal	ra,800021c6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b82:	013d09bb          	addw	s3,s10,s3
    80002b86:	012d093b          	addw	s2,s10,s2
    80002b8a:	9a6e                	add	s4,s4,s11
    80002b8c:	0569f063          	bgeu	s3,s6,80002bcc <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002b90:	00a9559b          	srliw	a1,s2,0xa
    80002b94:	8556                	mv	a0,s5
    80002b96:	89dff0ef          	jal	ra,80002432 <bmap>
    80002b9a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002b9e:	c59d                	beqz	a1,80002bcc <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002ba0:	000aa503          	lw	a0,0(s5)
    80002ba4:	d1aff0ef          	jal	ra,800020be <bread>
    80002ba8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002baa:	3ff97713          	andi	a4,s2,1023
    80002bae:	40ec87bb          	subw	a5,s9,a4
    80002bb2:	413b06bb          	subw	a3,s6,s3
    80002bb6:	8d3e                	mv	s10,a5
    80002bb8:	2781                	sext.w	a5,a5
    80002bba:	0006861b          	sext.w	a2,a3
    80002bbe:	f8f67ee3          	bgeu	a2,a5,80002b5a <writei+0x4c>
    80002bc2:	8d36                	mv	s10,a3
    80002bc4:	bf59                	j	80002b5a <writei+0x4c>
      brelse(bp);
    80002bc6:	8526                	mv	a0,s1
    80002bc8:	dfeff0ef          	jal	ra,800021c6 <brelse>
  }

  if(off > ip->size)
    80002bcc:	04caa783          	lw	a5,76(s5)
    80002bd0:	0127f463          	bgeu	a5,s2,80002bd8 <writei+0xca>
    ip->size = off;
    80002bd4:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002bd8:	8556                	mv	a0,s5
    80002bda:	b4dff0ef          	jal	ra,80002726 <iupdate>

  return tot;
    80002bde:	0009851b          	sext.w	a0,s3
}
    80002be2:	70a6                	ld	ra,104(sp)
    80002be4:	7406                	ld	s0,96(sp)
    80002be6:	64e6                	ld	s1,88(sp)
    80002be8:	6946                	ld	s2,80(sp)
    80002bea:	69a6                	ld	s3,72(sp)
    80002bec:	6a06                	ld	s4,64(sp)
    80002bee:	7ae2                	ld	s5,56(sp)
    80002bf0:	7b42                	ld	s6,48(sp)
    80002bf2:	7ba2                	ld	s7,40(sp)
    80002bf4:	7c02                	ld	s8,32(sp)
    80002bf6:	6ce2                	ld	s9,24(sp)
    80002bf8:	6d42                	ld	s10,16(sp)
    80002bfa:	6da2                	ld	s11,8(sp)
    80002bfc:	6165                	addi	sp,sp,112
    80002bfe:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c00:	89da                	mv	s3,s6
    80002c02:	bfd9                	j	80002bd8 <writei+0xca>
    return -1;
    80002c04:	557d                	li	a0,-1
}
    80002c06:	8082                	ret
    return -1;
    80002c08:	557d                	li	a0,-1
    80002c0a:	bfe1                	j	80002be2 <writei+0xd4>
    return -1;
    80002c0c:	557d                	li	a0,-1
    80002c0e:	bfd1                	j	80002be2 <writei+0xd4>

0000000080002c10 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002c10:	1141                	addi	sp,sp,-16
    80002c12:	e406                	sd	ra,8(sp)
    80002c14:	e022                	sd	s0,0(sp)
    80002c16:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002c18:	4639                	li	a2,14
    80002c1a:	e92fd0ef          	jal	ra,800002ac <strncmp>
}
    80002c1e:	60a2                	ld	ra,8(sp)
    80002c20:	6402                	ld	s0,0(sp)
    80002c22:	0141                	addi	sp,sp,16
    80002c24:	8082                	ret

0000000080002c26 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002c26:	7139                	addi	sp,sp,-64
    80002c28:	fc06                	sd	ra,56(sp)
    80002c2a:	f822                	sd	s0,48(sp)
    80002c2c:	f426                	sd	s1,40(sp)
    80002c2e:	f04a                	sd	s2,32(sp)
    80002c30:	ec4e                	sd	s3,24(sp)
    80002c32:	e852                	sd	s4,16(sp)
    80002c34:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002c36:	04451703          	lh	a4,68(a0)
    80002c3a:	4785                	li	a5,1
    80002c3c:	00f71a63          	bne	a4,a5,80002c50 <dirlookup+0x2a>
    80002c40:	892a                	mv	s2,a0
    80002c42:	89ae                	mv	s3,a1
    80002c44:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c46:	457c                	lw	a5,76(a0)
    80002c48:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002c4a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c4c:	e39d                	bnez	a5,80002c72 <dirlookup+0x4c>
    80002c4e:	a095                	j	80002cb2 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002c50:	00005517          	auipc	a0,0x5
    80002c54:	a4850513          	addi	a0,a0,-1464 # 80007698 <syscalls+0x208>
    80002c58:	7fa020ef          	jal	ra,80005452 <panic>
      panic("dirlookup read");
    80002c5c:	00005517          	auipc	a0,0x5
    80002c60:	a5450513          	addi	a0,a0,-1452 # 800076b0 <syscalls+0x220>
    80002c64:	7ee020ef          	jal	ra,80005452 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c68:	24c1                	addiw	s1,s1,16
    80002c6a:	04c92783          	lw	a5,76(s2)
    80002c6e:	04f4f163          	bgeu	s1,a5,80002cb0 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002c72:	4741                	li	a4,16
    80002c74:	86a6                	mv	a3,s1
    80002c76:	fc040613          	addi	a2,s0,-64
    80002c7a:	4581                	li	a1,0
    80002c7c:	854a                	mv	a0,s2
    80002c7e:	dadff0ef          	jal	ra,80002a2a <readi>
    80002c82:	47c1                	li	a5,16
    80002c84:	fcf51ce3          	bne	a0,a5,80002c5c <dirlookup+0x36>
    if(de.inum == 0)
    80002c88:	fc045783          	lhu	a5,-64(s0)
    80002c8c:	dff1                	beqz	a5,80002c68 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002c8e:	fc240593          	addi	a1,s0,-62
    80002c92:	854e                	mv	a0,s3
    80002c94:	f7dff0ef          	jal	ra,80002c10 <namecmp>
    80002c98:	f961                	bnez	a0,80002c68 <dirlookup+0x42>
      if(poff)
    80002c9a:	000a0463          	beqz	s4,80002ca2 <dirlookup+0x7c>
        *poff = off;
    80002c9e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002ca2:	fc045583          	lhu	a1,-64(s0)
    80002ca6:	00092503          	lw	a0,0(s2)
    80002caa:	857ff0ef          	jal	ra,80002500 <iget>
    80002cae:	a011                	j	80002cb2 <dirlookup+0x8c>
  return 0;
    80002cb0:	4501                	li	a0,0
}
    80002cb2:	70e2                	ld	ra,56(sp)
    80002cb4:	7442                	ld	s0,48(sp)
    80002cb6:	74a2                	ld	s1,40(sp)
    80002cb8:	7902                	ld	s2,32(sp)
    80002cba:	69e2                	ld	s3,24(sp)
    80002cbc:	6a42                	ld	s4,16(sp)
    80002cbe:	6121                	addi	sp,sp,64
    80002cc0:	8082                	ret

0000000080002cc2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002cc2:	711d                	addi	sp,sp,-96
    80002cc4:	ec86                	sd	ra,88(sp)
    80002cc6:	e8a2                	sd	s0,80(sp)
    80002cc8:	e4a6                	sd	s1,72(sp)
    80002cca:	e0ca                	sd	s2,64(sp)
    80002ccc:	fc4e                	sd	s3,56(sp)
    80002cce:	f852                	sd	s4,48(sp)
    80002cd0:	f456                	sd	s5,40(sp)
    80002cd2:	f05a                	sd	s6,32(sp)
    80002cd4:	ec5e                	sd	s7,24(sp)
    80002cd6:	e862                	sd	s8,16(sp)
    80002cd8:	e466                	sd	s9,8(sp)
    80002cda:	e06a                	sd	s10,0(sp)
    80002cdc:	1080                	addi	s0,sp,96
    80002cde:	84aa                	mv	s1,a0
    80002ce0:	8b2e                	mv	s6,a1
    80002ce2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002ce4:	00054703          	lbu	a4,0(a0)
    80002ce8:	02f00793          	li	a5,47
    80002cec:	00f70f63          	beq	a4,a5,80002d0a <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002cf0:	9dcfe0ef          	jal	ra,80000ecc <myproc>
    80002cf4:	15053503          	ld	a0,336(a0)
    80002cf8:	aadff0ef          	jal	ra,800027a4 <idup>
    80002cfc:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002cfe:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002d02:	4cb5                	li	s9,13
  len = path - s;
    80002d04:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002d06:	4c05                	li	s8,1
    80002d08:	a879                	j	80002da6 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80002d0a:	4585                	li	a1,1
    80002d0c:	4505                	li	a0,1
    80002d0e:	ff2ff0ef          	jal	ra,80002500 <iget>
    80002d12:	8a2a                	mv	s4,a0
    80002d14:	b7ed                	j	80002cfe <namex+0x3c>
      iunlockput(ip);
    80002d16:	8552                	mv	a0,s4
    80002d18:	cc9ff0ef          	jal	ra,800029e0 <iunlockput>
      return 0;
    80002d1c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002d1e:	8552                	mv	a0,s4
    80002d20:	60e6                	ld	ra,88(sp)
    80002d22:	6446                	ld	s0,80(sp)
    80002d24:	64a6                	ld	s1,72(sp)
    80002d26:	6906                	ld	s2,64(sp)
    80002d28:	79e2                	ld	s3,56(sp)
    80002d2a:	7a42                	ld	s4,48(sp)
    80002d2c:	7aa2                	ld	s5,40(sp)
    80002d2e:	7b02                	ld	s6,32(sp)
    80002d30:	6be2                	ld	s7,24(sp)
    80002d32:	6c42                	ld	s8,16(sp)
    80002d34:	6ca2                	ld	s9,8(sp)
    80002d36:	6d02                	ld	s10,0(sp)
    80002d38:	6125                	addi	sp,sp,96
    80002d3a:	8082                	ret
      iunlock(ip);
    80002d3c:	8552                	mv	a0,s4
    80002d3e:	b47ff0ef          	jal	ra,80002884 <iunlock>
      return ip;
    80002d42:	bff1                	j	80002d1e <namex+0x5c>
      iunlockput(ip);
    80002d44:	8552                	mv	a0,s4
    80002d46:	c9bff0ef          	jal	ra,800029e0 <iunlockput>
      return 0;
    80002d4a:	8a4e                	mv	s4,s3
    80002d4c:	bfc9                	j	80002d1e <namex+0x5c>
  len = path - s;
    80002d4e:	40998633          	sub	a2,s3,s1
    80002d52:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80002d56:	09acd063          	bge	s9,s10,80002dd6 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80002d5a:	4639                	li	a2,14
    80002d5c:	85a6                	mv	a1,s1
    80002d5e:	8556                	mv	a0,s5
    80002d60:	cdcfd0ef          	jal	ra,8000023c <memmove>
    80002d64:	84ce                	mv	s1,s3
  while(*path == '/')
    80002d66:	0004c783          	lbu	a5,0(s1)
    80002d6a:	01279763          	bne	a5,s2,80002d78 <namex+0xb6>
    path++;
    80002d6e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002d70:	0004c783          	lbu	a5,0(s1)
    80002d74:	ff278de3          	beq	a5,s2,80002d6e <namex+0xac>
    ilock(ip);
    80002d78:	8552                	mv	a0,s4
    80002d7a:	a61ff0ef          	jal	ra,800027da <ilock>
    if(ip->type != T_DIR){
    80002d7e:	044a1783          	lh	a5,68(s4)
    80002d82:	f9879ae3          	bne	a5,s8,80002d16 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80002d86:	000b0563          	beqz	s6,80002d90 <namex+0xce>
    80002d8a:	0004c783          	lbu	a5,0(s1)
    80002d8e:	d7dd                	beqz	a5,80002d3c <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002d90:	865e                	mv	a2,s7
    80002d92:	85d6                	mv	a1,s5
    80002d94:	8552                	mv	a0,s4
    80002d96:	e91ff0ef          	jal	ra,80002c26 <dirlookup>
    80002d9a:	89aa                	mv	s3,a0
    80002d9c:	d545                	beqz	a0,80002d44 <namex+0x82>
    iunlockput(ip);
    80002d9e:	8552                	mv	a0,s4
    80002da0:	c41ff0ef          	jal	ra,800029e0 <iunlockput>
    ip = next;
    80002da4:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002da6:	0004c783          	lbu	a5,0(s1)
    80002daa:	01279763          	bne	a5,s2,80002db8 <namex+0xf6>
    path++;
    80002dae:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002db0:	0004c783          	lbu	a5,0(s1)
    80002db4:	ff278de3          	beq	a5,s2,80002dae <namex+0xec>
  if(*path == 0)
    80002db8:	cb8d                	beqz	a5,80002dea <namex+0x128>
  while(*path != '/' && *path != 0)
    80002dba:	0004c783          	lbu	a5,0(s1)
    80002dbe:	89a6                	mv	s3,s1
  len = path - s;
    80002dc0:	8d5e                	mv	s10,s7
    80002dc2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80002dc4:	01278963          	beq	a5,s2,80002dd6 <namex+0x114>
    80002dc8:	d3d9                	beqz	a5,80002d4e <namex+0x8c>
    path++;
    80002dca:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002dcc:	0009c783          	lbu	a5,0(s3)
    80002dd0:	ff279ce3          	bne	a5,s2,80002dc8 <namex+0x106>
    80002dd4:	bfad                	j	80002d4e <namex+0x8c>
    memmove(name, s, len);
    80002dd6:	2601                	sext.w	a2,a2
    80002dd8:	85a6                	mv	a1,s1
    80002dda:	8556                	mv	a0,s5
    80002ddc:	c60fd0ef          	jal	ra,8000023c <memmove>
    name[len] = 0;
    80002de0:	9d56                	add	s10,s10,s5
    80002de2:	000d0023          	sb	zero,0(s10)
    80002de6:	84ce                	mv	s1,s3
    80002de8:	bfbd                	j	80002d66 <namex+0xa4>
  if(nameiparent){
    80002dea:	f20b0ae3          	beqz	s6,80002d1e <namex+0x5c>
    iput(ip);
    80002dee:	8552                	mv	a0,s4
    80002df0:	b69ff0ef          	jal	ra,80002958 <iput>
    return 0;
    80002df4:	4a01                	li	s4,0
    80002df6:	b725                	j	80002d1e <namex+0x5c>

0000000080002df8 <dirlink>:
{
    80002df8:	7139                	addi	sp,sp,-64
    80002dfa:	fc06                	sd	ra,56(sp)
    80002dfc:	f822                	sd	s0,48(sp)
    80002dfe:	f426                	sd	s1,40(sp)
    80002e00:	f04a                	sd	s2,32(sp)
    80002e02:	ec4e                	sd	s3,24(sp)
    80002e04:	e852                	sd	s4,16(sp)
    80002e06:	0080                	addi	s0,sp,64
    80002e08:	892a                	mv	s2,a0
    80002e0a:	8a2e                	mv	s4,a1
    80002e0c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002e0e:	4601                	li	a2,0
    80002e10:	e17ff0ef          	jal	ra,80002c26 <dirlookup>
    80002e14:	e52d                	bnez	a0,80002e7e <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e16:	04c92483          	lw	s1,76(s2)
    80002e1a:	c48d                	beqz	s1,80002e44 <dirlink+0x4c>
    80002e1c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e1e:	4741                	li	a4,16
    80002e20:	86a6                	mv	a3,s1
    80002e22:	fc040613          	addi	a2,s0,-64
    80002e26:	4581                	li	a1,0
    80002e28:	854a                	mv	a0,s2
    80002e2a:	c01ff0ef          	jal	ra,80002a2a <readi>
    80002e2e:	47c1                	li	a5,16
    80002e30:	04f51b63          	bne	a0,a5,80002e86 <dirlink+0x8e>
    if(de.inum == 0)
    80002e34:	fc045783          	lhu	a5,-64(s0)
    80002e38:	c791                	beqz	a5,80002e44 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e3a:	24c1                	addiw	s1,s1,16
    80002e3c:	04c92783          	lw	a5,76(s2)
    80002e40:	fcf4efe3          	bltu	s1,a5,80002e1e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002e44:	4639                	li	a2,14
    80002e46:	85d2                	mv	a1,s4
    80002e48:	fc240513          	addi	a0,s0,-62
    80002e4c:	c9cfd0ef          	jal	ra,800002e8 <strncpy>
  de.inum = inum;
    80002e50:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e54:	4741                	li	a4,16
    80002e56:	86a6                	mv	a3,s1
    80002e58:	fc040613          	addi	a2,s0,-64
    80002e5c:	4581                	li	a1,0
    80002e5e:	854a                	mv	a0,s2
    80002e60:	cafff0ef          	jal	ra,80002b0e <writei>
    80002e64:	1541                	addi	a0,a0,-16
    80002e66:	00a03533          	snez	a0,a0
    80002e6a:	40a00533          	neg	a0,a0
}
    80002e6e:	70e2                	ld	ra,56(sp)
    80002e70:	7442                	ld	s0,48(sp)
    80002e72:	74a2                	ld	s1,40(sp)
    80002e74:	7902                	ld	s2,32(sp)
    80002e76:	69e2                	ld	s3,24(sp)
    80002e78:	6a42                	ld	s4,16(sp)
    80002e7a:	6121                	addi	sp,sp,64
    80002e7c:	8082                	ret
    iput(ip);
    80002e7e:	adbff0ef          	jal	ra,80002958 <iput>
    return -1;
    80002e82:	557d                	li	a0,-1
    80002e84:	b7ed                	j	80002e6e <dirlink+0x76>
      panic("dirlink read");
    80002e86:	00005517          	auipc	a0,0x5
    80002e8a:	83a50513          	addi	a0,a0,-1990 # 800076c0 <syscalls+0x230>
    80002e8e:	5c4020ef          	jal	ra,80005452 <panic>

0000000080002e92 <namei>:

struct inode*
namei(char *path)
{
    80002e92:	1101                	addi	sp,sp,-32
    80002e94:	ec06                	sd	ra,24(sp)
    80002e96:	e822                	sd	s0,16(sp)
    80002e98:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002e9a:	fe040613          	addi	a2,s0,-32
    80002e9e:	4581                	li	a1,0
    80002ea0:	e23ff0ef          	jal	ra,80002cc2 <namex>
}
    80002ea4:	60e2                	ld	ra,24(sp)
    80002ea6:	6442                	ld	s0,16(sp)
    80002ea8:	6105                	addi	sp,sp,32
    80002eaa:	8082                	ret

0000000080002eac <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002eac:	1141                	addi	sp,sp,-16
    80002eae:	e406                	sd	ra,8(sp)
    80002eb0:	e022                	sd	s0,0(sp)
    80002eb2:	0800                	addi	s0,sp,16
    80002eb4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002eb6:	4585                	li	a1,1
    80002eb8:	e0bff0ef          	jal	ra,80002cc2 <namex>
}
    80002ebc:	60a2                	ld	ra,8(sp)
    80002ebe:	6402                	ld	s0,0(sp)
    80002ec0:	0141                	addi	sp,sp,16
    80002ec2:	8082                	ret

0000000080002ec4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002ec4:	1101                	addi	sp,sp,-32
    80002ec6:	ec06                	sd	ra,24(sp)
    80002ec8:	e822                	sd	s0,16(sp)
    80002eca:	e426                	sd	s1,8(sp)
    80002ecc:	e04a                	sd	s2,0(sp)
    80002ece:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002ed0:	00015917          	auipc	s2,0x15
    80002ed4:	d2090913          	addi	s2,s2,-736 # 80017bf0 <log>
    80002ed8:	01892583          	lw	a1,24(s2)
    80002edc:	02892503          	lw	a0,40(s2)
    80002ee0:	9deff0ef          	jal	ra,800020be <bread>
    80002ee4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002ee6:	02c92683          	lw	a3,44(s2)
    80002eea:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002eec:	02d05863          	blez	a3,80002f1c <write_head+0x58>
    80002ef0:	00015797          	auipc	a5,0x15
    80002ef4:	d3078793          	addi	a5,a5,-720 # 80017c20 <log+0x30>
    80002ef8:	05c50713          	addi	a4,a0,92
    80002efc:	36fd                	addiw	a3,a3,-1
    80002efe:	02069613          	slli	a2,a3,0x20
    80002f02:	01e65693          	srli	a3,a2,0x1e
    80002f06:	00015617          	auipc	a2,0x15
    80002f0a:	d1e60613          	addi	a2,a2,-738 # 80017c24 <log+0x34>
    80002f0e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80002f10:	4390                	lw	a2,0(a5)
    80002f12:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002f14:	0791                	addi	a5,a5,4
    80002f16:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80002f18:	fed79ce3          	bne	a5,a3,80002f10 <write_head+0x4c>
  }
  bwrite(buf);
    80002f1c:	8526                	mv	a0,s1
    80002f1e:	a76ff0ef          	jal	ra,80002194 <bwrite>
  brelse(buf);
    80002f22:	8526                	mv	a0,s1
    80002f24:	aa2ff0ef          	jal	ra,800021c6 <brelse>
}
    80002f28:	60e2                	ld	ra,24(sp)
    80002f2a:	6442                	ld	s0,16(sp)
    80002f2c:	64a2                	ld	s1,8(sp)
    80002f2e:	6902                	ld	s2,0(sp)
    80002f30:	6105                	addi	sp,sp,32
    80002f32:	8082                	ret

0000000080002f34 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f34:	00015797          	auipc	a5,0x15
    80002f38:	ce87a783          	lw	a5,-792(a5) # 80017c1c <log+0x2c>
    80002f3c:	08f05f63          	blez	a5,80002fda <install_trans+0xa6>
{
    80002f40:	7139                	addi	sp,sp,-64
    80002f42:	fc06                	sd	ra,56(sp)
    80002f44:	f822                	sd	s0,48(sp)
    80002f46:	f426                	sd	s1,40(sp)
    80002f48:	f04a                	sd	s2,32(sp)
    80002f4a:	ec4e                	sd	s3,24(sp)
    80002f4c:	e852                	sd	s4,16(sp)
    80002f4e:	e456                	sd	s5,8(sp)
    80002f50:	e05a                	sd	s6,0(sp)
    80002f52:	0080                	addi	s0,sp,64
    80002f54:	8b2a                	mv	s6,a0
    80002f56:	00015a97          	auipc	s5,0x15
    80002f5a:	ccaa8a93          	addi	s5,s5,-822 # 80017c20 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f5e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002f60:	00015997          	auipc	s3,0x15
    80002f64:	c9098993          	addi	s3,s3,-880 # 80017bf0 <log>
    80002f68:	a829                	j	80002f82 <install_trans+0x4e>
    brelse(lbuf);
    80002f6a:	854a                	mv	a0,s2
    80002f6c:	a5aff0ef          	jal	ra,800021c6 <brelse>
    brelse(dbuf);
    80002f70:	8526                	mv	a0,s1
    80002f72:	a54ff0ef          	jal	ra,800021c6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f76:	2a05                	addiw	s4,s4,1
    80002f78:	0a91                	addi	s5,s5,4
    80002f7a:	02c9a783          	lw	a5,44(s3)
    80002f7e:	04fa5463          	bge	s4,a5,80002fc6 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002f82:	0189a583          	lw	a1,24(s3)
    80002f86:	014585bb          	addw	a1,a1,s4
    80002f8a:	2585                	addiw	a1,a1,1
    80002f8c:	0289a503          	lw	a0,40(s3)
    80002f90:	92eff0ef          	jal	ra,800020be <bread>
    80002f94:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002f96:	000aa583          	lw	a1,0(s5)
    80002f9a:	0289a503          	lw	a0,40(s3)
    80002f9e:	920ff0ef          	jal	ra,800020be <bread>
    80002fa2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002fa4:	40000613          	li	a2,1024
    80002fa8:	05890593          	addi	a1,s2,88
    80002fac:	05850513          	addi	a0,a0,88
    80002fb0:	a8cfd0ef          	jal	ra,8000023c <memmove>
    bwrite(dbuf);  // write dst to disk
    80002fb4:	8526                	mv	a0,s1
    80002fb6:	9deff0ef          	jal	ra,80002194 <bwrite>
    if(recovering == 0)
    80002fba:	fa0b18e3          	bnez	s6,80002f6a <install_trans+0x36>
      bunpin(dbuf);
    80002fbe:	8526                	mv	a0,s1
    80002fc0:	ac4ff0ef          	jal	ra,80002284 <bunpin>
    80002fc4:	b75d                	j	80002f6a <install_trans+0x36>
}
    80002fc6:	70e2                	ld	ra,56(sp)
    80002fc8:	7442                	ld	s0,48(sp)
    80002fca:	74a2                	ld	s1,40(sp)
    80002fcc:	7902                	ld	s2,32(sp)
    80002fce:	69e2                	ld	s3,24(sp)
    80002fd0:	6a42                	ld	s4,16(sp)
    80002fd2:	6aa2                	ld	s5,8(sp)
    80002fd4:	6b02                	ld	s6,0(sp)
    80002fd6:	6121                	addi	sp,sp,64
    80002fd8:	8082                	ret
    80002fda:	8082                	ret

0000000080002fdc <initlog>:
{
    80002fdc:	7179                	addi	sp,sp,-48
    80002fde:	f406                	sd	ra,40(sp)
    80002fe0:	f022                	sd	s0,32(sp)
    80002fe2:	ec26                	sd	s1,24(sp)
    80002fe4:	e84a                	sd	s2,16(sp)
    80002fe6:	e44e                	sd	s3,8(sp)
    80002fe8:	1800                	addi	s0,sp,48
    80002fea:	892a                	mv	s2,a0
    80002fec:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80002fee:	00015497          	auipc	s1,0x15
    80002ff2:	c0248493          	addi	s1,s1,-1022 # 80017bf0 <log>
    80002ff6:	00004597          	auipc	a1,0x4
    80002ffa:	6da58593          	addi	a1,a1,1754 # 800076d0 <syscalls+0x240>
    80002ffe:	8526                	mv	a0,s1
    80003000:	6e2020ef          	jal	ra,800056e2 <initlock>
  log.start = sb->logstart;
    80003004:	0149a583          	lw	a1,20(s3)
    80003008:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000300a:	0109a783          	lw	a5,16(s3)
    8000300e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003010:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003014:	854a                	mv	a0,s2
    80003016:	8a8ff0ef          	jal	ra,800020be <bread>
  log.lh.n = lh->n;
    8000301a:	4d34                	lw	a3,88(a0)
    8000301c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000301e:	02d05663          	blez	a3,8000304a <initlog+0x6e>
    80003022:	05c50793          	addi	a5,a0,92
    80003026:	00015717          	auipc	a4,0x15
    8000302a:	bfa70713          	addi	a4,a4,-1030 # 80017c20 <log+0x30>
    8000302e:	36fd                	addiw	a3,a3,-1
    80003030:	02069613          	slli	a2,a3,0x20
    80003034:	01e65693          	srli	a3,a2,0x1e
    80003038:	06050613          	addi	a2,a0,96
    8000303c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000303e:	4390                	lw	a2,0(a5)
    80003040:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003042:	0791                	addi	a5,a5,4
    80003044:	0711                	addi	a4,a4,4
    80003046:	fed79ce3          	bne	a5,a3,8000303e <initlog+0x62>
  brelse(buf);
    8000304a:	97cff0ef          	jal	ra,800021c6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000304e:	4505                	li	a0,1
    80003050:	ee5ff0ef          	jal	ra,80002f34 <install_trans>
  log.lh.n = 0;
    80003054:	00015797          	auipc	a5,0x15
    80003058:	bc07a423          	sw	zero,-1080(a5) # 80017c1c <log+0x2c>
  write_head(); // clear the log
    8000305c:	e69ff0ef          	jal	ra,80002ec4 <write_head>
}
    80003060:	70a2                	ld	ra,40(sp)
    80003062:	7402                	ld	s0,32(sp)
    80003064:	64e2                	ld	s1,24(sp)
    80003066:	6942                	ld	s2,16(sp)
    80003068:	69a2                	ld	s3,8(sp)
    8000306a:	6145                	addi	sp,sp,48
    8000306c:	8082                	ret

000000008000306e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000306e:	1101                	addi	sp,sp,-32
    80003070:	ec06                	sd	ra,24(sp)
    80003072:	e822                	sd	s0,16(sp)
    80003074:	e426                	sd	s1,8(sp)
    80003076:	e04a                	sd	s2,0(sp)
    80003078:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000307a:	00015517          	auipc	a0,0x15
    8000307e:	b7650513          	addi	a0,a0,-1162 # 80017bf0 <log>
    80003082:	6e0020ef          	jal	ra,80005762 <acquire>
  while(1){
    if(log.committing){
    80003086:	00015497          	auipc	s1,0x15
    8000308a:	b6a48493          	addi	s1,s1,-1174 # 80017bf0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000308e:	4979                	li	s2,30
    80003090:	a029                	j	8000309a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003092:	85a6                	mv	a1,s1
    80003094:	8526                	mv	a0,s1
    80003096:	c02fe0ef          	jal	ra,80001498 <sleep>
    if(log.committing){
    8000309a:	50dc                	lw	a5,36(s1)
    8000309c:	fbfd                	bnez	a5,80003092 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000309e:	5098                	lw	a4,32(s1)
    800030a0:	2705                	addiw	a4,a4,1
    800030a2:	0007069b          	sext.w	a3,a4
    800030a6:	0027179b          	slliw	a5,a4,0x2
    800030aa:	9fb9                	addw	a5,a5,a4
    800030ac:	0017979b          	slliw	a5,a5,0x1
    800030b0:	54d8                	lw	a4,44(s1)
    800030b2:	9fb9                	addw	a5,a5,a4
    800030b4:	00f95763          	bge	s2,a5,800030c2 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800030b8:	85a6                	mv	a1,s1
    800030ba:	8526                	mv	a0,s1
    800030bc:	bdcfe0ef          	jal	ra,80001498 <sleep>
    800030c0:	bfe9                	j	8000309a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800030c2:	00015517          	auipc	a0,0x15
    800030c6:	b2e50513          	addi	a0,a0,-1234 # 80017bf0 <log>
    800030ca:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800030cc:	72e020ef          	jal	ra,800057fa <release>
      break;
    }
  }
}
    800030d0:	60e2                	ld	ra,24(sp)
    800030d2:	6442                	ld	s0,16(sp)
    800030d4:	64a2                	ld	s1,8(sp)
    800030d6:	6902                	ld	s2,0(sp)
    800030d8:	6105                	addi	sp,sp,32
    800030da:	8082                	ret

00000000800030dc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800030dc:	7139                	addi	sp,sp,-64
    800030de:	fc06                	sd	ra,56(sp)
    800030e0:	f822                	sd	s0,48(sp)
    800030e2:	f426                	sd	s1,40(sp)
    800030e4:	f04a                	sd	s2,32(sp)
    800030e6:	ec4e                	sd	s3,24(sp)
    800030e8:	e852                	sd	s4,16(sp)
    800030ea:	e456                	sd	s5,8(sp)
    800030ec:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800030ee:	00015497          	auipc	s1,0x15
    800030f2:	b0248493          	addi	s1,s1,-1278 # 80017bf0 <log>
    800030f6:	8526                	mv	a0,s1
    800030f8:	66a020ef          	jal	ra,80005762 <acquire>
  log.outstanding -= 1;
    800030fc:	509c                	lw	a5,32(s1)
    800030fe:	37fd                	addiw	a5,a5,-1
    80003100:	0007891b          	sext.w	s2,a5
    80003104:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003106:	50dc                	lw	a5,36(s1)
    80003108:	ef9d                	bnez	a5,80003146 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    8000310a:	04091463          	bnez	s2,80003152 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000310e:	00015497          	auipc	s1,0x15
    80003112:	ae248493          	addi	s1,s1,-1310 # 80017bf0 <log>
    80003116:	4785                	li	a5,1
    80003118:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000311a:	8526                	mv	a0,s1
    8000311c:	6de020ef          	jal	ra,800057fa <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003120:	54dc                	lw	a5,44(s1)
    80003122:	04f04b63          	bgtz	a5,80003178 <end_op+0x9c>
    acquire(&log.lock);
    80003126:	00015497          	auipc	s1,0x15
    8000312a:	aca48493          	addi	s1,s1,-1334 # 80017bf0 <log>
    8000312e:	8526                	mv	a0,s1
    80003130:	632020ef          	jal	ra,80005762 <acquire>
    log.committing = 0;
    80003134:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003138:	8526                	mv	a0,s1
    8000313a:	baafe0ef          	jal	ra,800014e4 <wakeup>
    release(&log.lock);
    8000313e:	8526                	mv	a0,s1
    80003140:	6ba020ef          	jal	ra,800057fa <release>
}
    80003144:	a00d                	j	80003166 <end_op+0x8a>
    panic("log.committing");
    80003146:	00004517          	auipc	a0,0x4
    8000314a:	59250513          	addi	a0,a0,1426 # 800076d8 <syscalls+0x248>
    8000314e:	304020ef          	jal	ra,80005452 <panic>
    wakeup(&log);
    80003152:	00015497          	auipc	s1,0x15
    80003156:	a9e48493          	addi	s1,s1,-1378 # 80017bf0 <log>
    8000315a:	8526                	mv	a0,s1
    8000315c:	b88fe0ef          	jal	ra,800014e4 <wakeup>
  release(&log.lock);
    80003160:	8526                	mv	a0,s1
    80003162:	698020ef          	jal	ra,800057fa <release>
}
    80003166:	70e2                	ld	ra,56(sp)
    80003168:	7442                	ld	s0,48(sp)
    8000316a:	74a2                	ld	s1,40(sp)
    8000316c:	7902                	ld	s2,32(sp)
    8000316e:	69e2                	ld	s3,24(sp)
    80003170:	6a42                	ld	s4,16(sp)
    80003172:	6aa2                	ld	s5,8(sp)
    80003174:	6121                	addi	sp,sp,64
    80003176:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003178:	00015a97          	auipc	s5,0x15
    8000317c:	aa8a8a93          	addi	s5,s5,-1368 # 80017c20 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003180:	00015a17          	auipc	s4,0x15
    80003184:	a70a0a13          	addi	s4,s4,-1424 # 80017bf0 <log>
    80003188:	018a2583          	lw	a1,24(s4)
    8000318c:	012585bb          	addw	a1,a1,s2
    80003190:	2585                	addiw	a1,a1,1
    80003192:	028a2503          	lw	a0,40(s4)
    80003196:	f29fe0ef          	jal	ra,800020be <bread>
    8000319a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000319c:	000aa583          	lw	a1,0(s5)
    800031a0:	028a2503          	lw	a0,40(s4)
    800031a4:	f1bfe0ef          	jal	ra,800020be <bread>
    800031a8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800031aa:	40000613          	li	a2,1024
    800031ae:	05850593          	addi	a1,a0,88
    800031b2:	05848513          	addi	a0,s1,88
    800031b6:	886fd0ef          	jal	ra,8000023c <memmove>
    bwrite(to);  // write the log
    800031ba:	8526                	mv	a0,s1
    800031bc:	fd9fe0ef          	jal	ra,80002194 <bwrite>
    brelse(from);
    800031c0:	854e                	mv	a0,s3
    800031c2:	804ff0ef          	jal	ra,800021c6 <brelse>
    brelse(to);
    800031c6:	8526                	mv	a0,s1
    800031c8:	ffffe0ef          	jal	ra,800021c6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800031cc:	2905                	addiw	s2,s2,1
    800031ce:	0a91                	addi	s5,s5,4
    800031d0:	02ca2783          	lw	a5,44(s4)
    800031d4:	faf94ae3          	blt	s2,a5,80003188 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800031d8:	cedff0ef          	jal	ra,80002ec4 <write_head>
    install_trans(0); // Now install writes to home locations
    800031dc:	4501                	li	a0,0
    800031de:	d57ff0ef          	jal	ra,80002f34 <install_trans>
    log.lh.n = 0;
    800031e2:	00015797          	auipc	a5,0x15
    800031e6:	a207ad23          	sw	zero,-1478(a5) # 80017c1c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800031ea:	cdbff0ef          	jal	ra,80002ec4 <write_head>
    800031ee:	bf25                	j	80003126 <end_op+0x4a>

00000000800031f0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800031f0:	1101                	addi	sp,sp,-32
    800031f2:	ec06                	sd	ra,24(sp)
    800031f4:	e822                	sd	s0,16(sp)
    800031f6:	e426                	sd	s1,8(sp)
    800031f8:	e04a                	sd	s2,0(sp)
    800031fa:	1000                	addi	s0,sp,32
    800031fc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800031fe:	00015917          	auipc	s2,0x15
    80003202:	9f290913          	addi	s2,s2,-1550 # 80017bf0 <log>
    80003206:	854a                	mv	a0,s2
    80003208:	55a020ef          	jal	ra,80005762 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000320c:	02c92603          	lw	a2,44(s2)
    80003210:	47f5                	li	a5,29
    80003212:	06c7c363          	blt	a5,a2,80003278 <log_write+0x88>
    80003216:	00015797          	auipc	a5,0x15
    8000321a:	9f67a783          	lw	a5,-1546(a5) # 80017c0c <log+0x1c>
    8000321e:	37fd                	addiw	a5,a5,-1
    80003220:	04f65c63          	bge	a2,a5,80003278 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003224:	00015797          	auipc	a5,0x15
    80003228:	9ec7a783          	lw	a5,-1556(a5) # 80017c10 <log+0x20>
    8000322c:	04f05c63          	blez	a5,80003284 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003230:	4781                	li	a5,0
    80003232:	04c05f63          	blez	a2,80003290 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003236:	44cc                	lw	a1,12(s1)
    80003238:	00015717          	auipc	a4,0x15
    8000323c:	9e870713          	addi	a4,a4,-1560 # 80017c20 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003240:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003242:	4314                	lw	a3,0(a4)
    80003244:	04b68663          	beq	a3,a1,80003290 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003248:	2785                	addiw	a5,a5,1
    8000324a:	0711                	addi	a4,a4,4
    8000324c:	fef61be3          	bne	a2,a5,80003242 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003250:	0621                	addi	a2,a2,8
    80003252:	060a                	slli	a2,a2,0x2
    80003254:	00015797          	auipc	a5,0x15
    80003258:	99c78793          	addi	a5,a5,-1636 # 80017bf0 <log>
    8000325c:	97b2                	add	a5,a5,a2
    8000325e:	44d8                	lw	a4,12(s1)
    80003260:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003262:	8526                	mv	a0,s1
    80003264:	fedfe0ef          	jal	ra,80002250 <bpin>
    log.lh.n++;
    80003268:	00015717          	auipc	a4,0x15
    8000326c:	98870713          	addi	a4,a4,-1656 # 80017bf0 <log>
    80003270:	575c                	lw	a5,44(a4)
    80003272:	2785                	addiw	a5,a5,1
    80003274:	d75c                	sw	a5,44(a4)
    80003276:	a80d                	j	800032a8 <log_write+0xb8>
    panic("too big a transaction");
    80003278:	00004517          	auipc	a0,0x4
    8000327c:	47050513          	addi	a0,a0,1136 # 800076e8 <syscalls+0x258>
    80003280:	1d2020ef          	jal	ra,80005452 <panic>
    panic("log_write outside of trans");
    80003284:	00004517          	auipc	a0,0x4
    80003288:	47c50513          	addi	a0,a0,1148 # 80007700 <syscalls+0x270>
    8000328c:	1c6020ef          	jal	ra,80005452 <panic>
  log.lh.block[i] = b->blockno;
    80003290:	00878693          	addi	a3,a5,8
    80003294:	068a                	slli	a3,a3,0x2
    80003296:	00015717          	auipc	a4,0x15
    8000329a:	95a70713          	addi	a4,a4,-1702 # 80017bf0 <log>
    8000329e:	9736                	add	a4,a4,a3
    800032a0:	44d4                	lw	a3,12(s1)
    800032a2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800032a4:	faf60fe3          	beq	a2,a5,80003262 <log_write+0x72>
  }
  release(&log.lock);
    800032a8:	00015517          	auipc	a0,0x15
    800032ac:	94850513          	addi	a0,a0,-1720 # 80017bf0 <log>
    800032b0:	54a020ef          	jal	ra,800057fa <release>
}
    800032b4:	60e2                	ld	ra,24(sp)
    800032b6:	6442                	ld	s0,16(sp)
    800032b8:	64a2                	ld	s1,8(sp)
    800032ba:	6902                	ld	s2,0(sp)
    800032bc:	6105                	addi	sp,sp,32
    800032be:	8082                	ret

00000000800032c0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800032c0:	1101                	addi	sp,sp,-32
    800032c2:	ec06                	sd	ra,24(sp)
    800032c4:	e822                	sd	s0,16(sp)
    800032c6:	e426                	sd	s1,8(sp)
    800032c8:	e04a                	sd	s2,0(sp)
    800032ca:	1000                	addi	s0,sp,32
    800032cc:	84aa                	mv	s1,a0
    800032ce:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800032d0:	00004597          	auipc	a1,0x4
    800032d4:	45058593          	addi	a1,a1,1104 # 80007720 <syscalls+0x290>
    800032d8:	0521                	addi	a0,a0,8
    800032da:	408020ef          	jal	ra,800056e2 <initlock>
  lk->name = name;
    800032de:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800032e2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800032e6:	0204a423          	sw	zero,40(s1)
}
    800032ea:	60e2                	ld	ra,24(sp)
    800032ec:	6442                	ld	s0,16(sp)
    800032ee:	64a2                	ld	s1,8(sp)
    800032f0:	6902                	ld	s2,0(sp)
    800032f2:	6105                	addi	sp,sp,32
    800032f4:	8082                	ret

00000000800032f6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800032f6:	1101                	addi	sp,sp,-32
    800032f8:	ec06                	sd	ra,24(sp)
    800032fa:	e822                	sd	s0,16(sp)
    800032fc:	e426                	sd	s1,8(sp)
    800032fe:	e04a                	sd	s2,0(sp)
    80003300:	1000                	addi	s0,sp,32
    80003302:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003304:	00850913          	addi	s2,a0,8
    80003308:	854a                	mv	a0,s2
    8000330a:	458020ef          	jal	ra,80005762 <acquire>
  while (lk->locked) {
    8000330e:	409c                	lw	a5,0(s1)
    80003310:	c799                	beqz	a5,8000331e <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003312:	85ca                	mv	a1,s2
    80003314:	8526                	mv	a0,s1
    80003316:	982fe0ef          	jal	ra,80001498 <sleep>
  while (lk->locked) {
    8000331a:	409c                	lw	a5,0(s1)
    8000331c:	fbfd                	bnez	a5,80003312 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000331e:	4785                	li	a5,1
    80003320:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003322:	babfd0ef          	jal	ra,80000ecc <myproc>
    80003326:	591c                	lw	a5,48(a0)
    80003328:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000332a:	854a                	mv	a0,s2
    8000332c:	4ce020ef          	jal	ra,800057fa <release>
}
    80003330:	60e2                	ld	ra,24(sp)
    80003332:	6442                	ld	s0,16(sp)
    80003334:	64a2                	ld	s1,8(sp)
    80003336:	6902                	ld	s2,0(sp)
    80003338:	6105                	addi	sp,sp,32
    8000333a:	8082                	ret

000000008000333c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000333c:	1101                	addi	sp,sp,-32
    8000333e:	ec06                	sd	ra,24(sp)
    80003340:	e822                	sd	s0,16(sp)
    80003342:	e426                	sd	s1,8(sp)
    80003344:	e04a                	sd	s2,0(sp)
    80003346:	1000                	addi	s0,sp,32
    80003348:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000334a:	00850913          	addi	s2,a0,8
    8000334e:	854a                	mv	a0,s2
    80003350:	412020ef          	jal	ra,80005762 <acquire>
  lk->locked = 0;
    80003354:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003358:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000335c:	8526                	mv	a0,s1
    8000335e:	986fe0ef          	jal	ra,800014e4 <wakeup>
  release(&lk->lk);
    80003362:	854a                	mv	a0,s2
    80003364:	496020ef          	jal	ra,800057fa <release>
}
    80003368:	60e2                	ld	ra,24(sp)
    8000336a:	6442                	ld	s0,16(sp)
    8000336c:	64a2                	ld	s1,8(sp)
    8000336e:	6902                	ld	s2,0(sp)
    80003370:	6105                	addi	sp,sp,32
    80003372:	8082                	ret

0000000080003374 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003374:	7179                	addi	sp,sp,-48
    80003376:	f406                	sd	ra,40(sp)
    80003378:	f022                	sd	s0,32(sp)
    8000337a:	ec26                	sd	s1,24(sp)
    8000337c:	e84a                	sd	s2,16(sp)
    8000337e:	e44e                	sd	s3,8(sp)
    80003380:	1800                	addi	s0,sp,48
    80003382:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80003384:	00850913          	addi	s2,a0,8
    80003388:	854a                	mv	a0,s2
    8000338a:	3d8020ef          	jal	ra,80005762 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000338e:	409c                	lw	a5,0(s1)
    80003390:	ef89                	bnez	a5,800033aa <holdingsleep+0x36>
    80003392:	4481                	li	s1,0
  release(&lk->lk);
    80003394:	854a                	mv	a0,s2
    80003396:	464020ef          	jal	ra,800057fa <release>
  return r;
}
    8000339a:	8526                	mv	a0,s1
    8000339c:	70a2                	ld	ra,40(sp)
    8000339e:	7402                	ld	s0,32(sp)
    800033a0:	64e2                	ld	s1,24(sp)
    800033a2:	6942                	ld	s2,16(sp)
    800033a4:	69a2                	ld	s3,8(sp)
    800033a6:	6145                	addi	sp,sp,48
    800033a8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800033aa:	0284a983          	lw	s3,40(s1)
    800033ae:	b1ffd0ef          	jal	ra,80000ecc <myproc>
    800033b2:	5904                	lw	s1,48(a0)
    800033b4:	413484b3          	sub	s1,s1,s3
    800033b8:	0014b493          	seqz	s1,s1
    800033bc:	bfe1                	j	80003394 <holdingsleep+0x20>

00000000800033be <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800033be:	1141                	addi	sp,sp,-16
    800033c0:	e406                	sd	ra,8(sp)
    800033c2:	e022                	sd	s0,0(sp)
    800033c4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800033c6:	00004597          	auipc	a1,0x4
    800033ca:	36a58593          	addi	a1,a1,874 # 80007730 <syscalls+0x2a0>
    800033ce:	00015517          	auipc	a0,0x15
    800033d2:	96a50513          	addi	a0,a0,-1686 # 80017d38 <ftable>
    800033d6:	30c020ef          	jal	ra,800056e2 <initlock>
}
    800033da:	60a2                	ld	ra,8(sp)
    800033dc:	6402                	ld	s0,0(sp)
    800033de:	0141                	addi	sp,sp,16
    800033e0:	8082                	ret

00000000800033e2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800033e2:	1101                	addi	sp,sp,-32
    800033e4:	ec06                	sd	ra,24(sp)
    800033e6:	e822                	sd	s0,16(sp)
    800033e8:	e426                	sd	s1,8(sp)
    800033ea:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800033ec:	00015517          	auipc	a0,0x15
    800033f0:	94c50513          	addi	a0,a0,-1716 # 80017d38 <ftable>
    800033f4:	36e020ef          	jal	ra,80005762 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800033f8:	00015497          	auipc	s1,0x15
    800033fc:	95848493          	addi	s1,s1,-1704 # 80017d50 <ftable+0x18>
    80003400:	00016717          	auipc	a4,0x16
    80003404:	8f070713          	addi	a4,a4,-1808 # 80018cf0 <disk>
    if(f->ref == 0){
    80003408:	40dc                	lw	a5,4(s1)
    8000340a:	cf89                	beqz	a5,80003424 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000340c:	02848493          	addi	s1,s1,40
    80003410:	fee49ce3          	bne	s1,a4,80003408 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003414:	00015517          	auipc	a0,0x15
    80003418:	92450513          	addi	a0,a0,-1756 # 80017d38 <ftable>
    8000341c:	3de020ef          	jal	ra,800057fa <release>
  return 0;
    80003420:	4481                	li	s1,0
    80003422:	a809                	j	80003434 <filealloc+0x52>
      f->ref = 1;
    80003424:	4785                	li	a5,1
    80003426:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003428:	00015517          	auipc	a0,0x15
    8000342c:	91050513          	addi	a0,a0,-1776 # 80017d38 <ftable>
    80003430:	3ca020ef          	jal	ra,800057fa <release>
}
    80003434:	8526                	mv	a0,s1
    80003436:	60e2                	ld	ra,24(sp)
    80003438:	6442                	ld	s0,16(sp)
    8000343a:	64a2                	ld	s1,8(sp)
    8000343c:	6105                	addi	sp,sp,32
    8000343e:	8082                	ret

0000000080003440 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003440:	1101                	addi	sp,sp,-32
    80003442:	ec06                	sd	ra,24(sp)
    80003444:	e822                	sd	s0,16(sp)
    80003446:	e426                	sd	s1,8(sp)
    80003448:	1000                	addi	s0,sp,32
    8000344a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000344c:	00015517          	auipc	a0,0x15
    80003450:	8ec50513          	addi	a0,a0,-1812 # 80017d38 <ftable>
    80003454:	30e020ef          	jal	ra,80005762 <acquire>
  if(f->ref < 1)
    80003458:	40dc                	lw	a5,4(s1)
    8000345a:	02f05063          	blez	a5,8000347a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000345e:	2785                	addiw	a5,a5,1
    80003460:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003462:	00015517          	auipc	a0,0x15
    80003466:	8d650513          	addi	a0,a0,-1834 # 80017d38 <ftable>
    8000346a:	390020ef          	jal	ra,800057fa <release>
  return f;
}
    8000346e:	8526                	mv	a0,s1
    80003470:	60e2                	ld	ra,24(sp)
    80003472:	6442                	ld	s0,16(sp)
    80003474:	64a2                	ld	s1,8(sp)
    80003476:	6105                	addi	sp,sp,32
    80003478:	8082                	ret
    panic("filedup");
    8000347a:	00004517          	auipc	a0,0x4
    8000347e:	2be50513          	addi	a0,a0,702 # 80007738 <syscalls+0x2a8>
    80003482:	7d1010ef          	jal	ra,80005452 <panic>

0000000080003486 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003486:	7139                	addi	sp,sp,-64
    80003488:	fc06                	sd	ra,56(sp)
    8000348a:	f822                	sd	s0,48(sp)
    8000348c:	f426                	sd	s1,40(sp)
    8000348e:	f04a                	sd	s2,32(sp)
    80003490:	ec4e                	sd	s3,24(sp)
    80003492:	e852                	sd	s4,16(sp)
    80003494:	e456                	sd	s5,8(sp)
    80003496:	0080                	addi	s0,sp,64
    80003498:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000349a:	00015517          	auipc	a0,0x15
    8000349e:	89e50513          	addi	a0,a0,-1890 # 80017d38 <ftable>
    800034a2:	2c0020ef          	jal	ra,80005762 <acquire>
  if(f->ref < 1)
    800034a6:	40dc                	lw	a5,4(s1)
    800034a8:	04f05963          	blez	a5,800034fa <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    800034ac:	37fd                	addiw	a5,a5,-1
    800034ae:	0007871b          	sext.w	a4,a5
    800034b2:	c0dc                	sw	a5,4(s1)
    800034b4:	04e04963          	bgtz	a4,80003506 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800034b8:	0004a903          	lw	s2,0(s1)
    800034bc:	0094ca83          	lbu	s5,9(s1)
    800034c0:	0104ba03          	ld	s4,16(s1)
    800034c4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800034c8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800034cc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800034d0:	00015517          	auipc	a0,0x15
    800034d4:	86850513          	addi	a0,a0,-1944 # 80017d38 <ftable>
    800034d8:	322020ef          	jal	ra,800057fa <release>

  if(ff.type == FD_PIPE){
    800034dc:	4785                	li	a5,1
    800034de:	04f90363          	beq	s2,a5,80003524 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800034e2:	3979                	addiw	s2,s2,-2
    800034e4:	4785                	li	a5,1
    800034e6:	0327e663          	bltu	a5,s2,80003512 <fileclose+0x8c>
    begin_op();
    800034ea:	b85ff0ef          	jal	ra,8000306e <begin_op>
    iput(ff.ip);
    800034ee:	854e                	mv	a0,s3
    800034f0:	c68ff0ef          	jal	ra,80002958 <iput>
    end_op();
    800034f4:	be9ff0ef          	jal	ra,800030dc <end_op>
    800034f8:	a829                	j	80003512 <fileclose+0x8c>
    panic("fileclose");
    800034fa:	00004517          	auipc	a0,0x4
    800034fe:	24650513          	addi	a0,a0,582 # 80007740 <syscalls+0x2b0>
    80003502:	751010ef          	jal	ra,80005452 <panic>
    release(&ftable.lock);
    80003506:	00015517          	auipc	a0,0x15
    8000350a:	83250513          	addi	a0,a0,-1998 # 80017d38 <ftable>
    8000350e:	2ec020ef          	jal	ra,800057fa <release>
  }
}
    80003512:	70e2                	ld	ra,56(sp)
    80003514:	7442                	ld	s0,48(sp)
    80003516:	74a2                	ld	s1,40(sp)
    80003518:	7902                	ld	s2,32(sp)
    8000351a:	69e2                	ld	s3,24(sp)
    8000351c:	6a42                	ld	s4,16(sp)
    8000351e:	6aa2                	ld	s5,8(sp)
    80003520:	6121                	addi	sp,sp,64
    80003522:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003524:	85d6                	mv	a1,s5
    80003526:	8552                	mv	a0,s4
    80003528:	2ec000ef          	jal	ra,80003814 <pipeclose>
    8000352c:	b7dd                	j	80003512 <fileclose+0x8c>

000000008000352e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000352e:	715d                	addi	sp,sp,-80
    80003530:	e486                	sd	ra,72(sp)
    80003532:	e0a2                	sd	s0,64(sp)
    80003534:	fc26                	sd	s1,56(sp)
    80003536:	f84a                	sd	s2,48(sp)
    80003538:	f44e                	sd	s3,40(sp)
    8000353a:	0880                	addi	s0,sp,80
    8000353c:	84aa                	mv	s1,a0
    8000353e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003540:	98dfd0ef          	jal	ra,80000ecc <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003544:	409c                	lw	a5,0(s1)
    80003546:	37f9                	addiw	a5,a5,-2
    80003548:	4705                	li	a4,1
    8000354a:	02f76f63          	bltu	a4,a5,80003588 <filestat+0x5a>
    8000354e:	892a                	mv	s2,a0
    ilock(f->ip);
    80003550:	6c88                	ld	a0,24(s1)
    80003552:	a88ff0ef          	jal	ra,800027da <ilock>
    stati(f->ip, &st);
    80003556:	fb840593          	addi	a1,s0,-72
    8000355a:	6c88                	ld	a0,24(s1)
    8000355c:	ca4ff0ef          	jal	ra,80002a00 <stati>
    iunlock(f->ip);
    80003560:	6c88                	ld	a0,24(s1)
    80003562:	b22ff0ef          	jal	ra,80002884 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003566:	46e1                	li	a3,24
    80003568:	fb840613          	addi	a2,s0,-72
    8000356c:	85ce                	mv	a1,s3
    8000356e:	05093503          	ld	a0,80(s2)
    80003572:	cfefd0ef          	jal	ra,80000a70 <copyout>
    80003576:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000357a:	60a6                	ld	ra,72(sp)
    8000357c:	6406                	ld	s0,64(sp)
    8000357e:	74e2                	ld	s1,56(sp)
    80003580:	7942                	ld	s2,48(sp)
    80003582:	79a2                	ld	s3,40(sp)
    80003584:	6161                	addi	sp,sp,80
    80003586:	8082                	ret
  return -1;
    80003588:	557d                	li	a0,-1
    8000358a:	bfc5                	j	8000357a <filestat+0x4c>

000000008000358c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000358c:	7179                	addi	sp,sp,-48
    8000358e:	f406                	sd	ra,40(sp)
    80003590:	f022                	sd	s0,32(sp)
    80003592:	ec26                	sd	s1,24(sp)
    80003594:	e84a                	sd	s2,16(sp)
    80003596:	e44e                	sd	s3,8(sp)
    80003598:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000359a:	00854783          	lbu	a5,8(a0)
    8000359e:	cbc1                	beqz	a5,8000362e <fileread+0xa2>
    800035a0:	84aa                	mv	s1,a0
    800035a2:	89ae                	mv	s3,a1
    800035a4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800035a6:	411c                	lw	a5,0(a0)
    800035a8:	4705                	li	a4,1
    800035aa:	04e78363          	beq	a5,a4,800035f0 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800035ae:	470d                	li	a4,3
    800035b0:	04e78563          	beq	a5,a4,800035fa <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800035b4:	4709                	li	a4,2
    800035b6:	06e79663          	bne	a5,a4,80003622 <fileread+0x96>
    ilock(f->ip);
    800035ba:	6d08                	ld	a0,24(a0)
    800035bc:	a1eff0ef          	jal	ra,800027da <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800035c0:	874a                	mv	a4,s2
    800035c2:	5094                	lw	a3,32(s1)
    800035c4:	864e                	mv	a2,s3
    800035c6:	4585                	li	a1,1
    800035c8:	6c88                	ld	a0,24(s1)
    800035ca:	c60ff0ef          	jal	ra,80002a2a <readi>
    800035ce:	892a                	mv	s2,a0
    800035d0:	00a05563          	blez	a0,800035da <fileread+0x4e>
      f->off += r;
    800035d4:	509c                	lw	a5,32(s1)
    800035d6:	9fa9                	addw	a5,a5,a0
    800035d8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800035da:	6c88                	ld	a0,24(s1)
    800035dc:	aa8ff0ef          	jal	ra,80002884 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800035e0:	854a                	mv	a0,s2
    800035e2:	70a2                	ld	ra,40(sp)
    800035e4:	7402                	ld	s0,32(sp)
    800035e6:	64e2                	ld	s1,24(sp)
    800035e8:	6942                	ld	s2,16(sp)
    800035ea:	69a2                	ld	s3,8(sp)
    800035ec:	6145                	addi	sp,sp,48
    800035ee:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800035f0:	6908                	ld	a0,16(a0)
    800035f2:	34e000ef          	jal	ra,80003940 <piperead>
    800035f6:	892a                	mv	s2,a0
    800035f8:	b7e5                	j	800035e0 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800035fa:	02451783          	lh	a5,36(a0)
    800035fe:	03079693          	slli	a3,a5,0x30
    80003602:	92c1                	srli	a3,a3,0x30
    80003604:	4725                	li	a4,9
    80003606:	02d76663          	bltu	a4,a3,80003632 <fileread+0xa6>
    8000360a:	0792                	slli	a5,a5,0x4
    8000360c:	00014717          	auipc	a4,0x14
    80003610:	68c70713          	addi	a4,a4,1676 # 80017c98 <devsw>
    80003614:	97ba                	add	a5,a5,a4
    80003616:	639c                	ld	a5,0(a5)
    80003618:	cf99                	beqz	a5,80003636 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    8000361a:	4505                	li	a0,1
    8000361c:	9782                	jalr	a5
    8000361e:	892a                	mv	s2,a0
    80003620:	b7c1                	j	800035e0 <fileread+0x54>
    panic("fileread");
    80003622:	00004517          	auipc	a0,0x4
    80003626:	12e50513          	addi	a0,a0,302 # 80007750 <syscalls+0x2c0>
    8000362a:	629010ef          	jal	ra,80005452 <panic>
    return -1;
    8000362e:	597d                	li	s2,-1
    80003630:	bf45                	j	800035e0 <fileread+0x54>
      return -1;
    80003632:	597d                	li	s2,-1
    80003634:	b775                	j	800035e0 <fileread+0x54>
    80003636:	597d                	li	s2,-1
    80003638:	b765                	j	800035e0 <fileread+0x54>

000000008000363a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000363a:	715d                	addi	sp,sp,-80
    8000363c:	e486                	sd	ra,72(sp)
    8000363e:	e0a2                	sd	s0,64(sp)
    80003640:	fc26                	sd	s1,56(sp)
    80003642:	f84a                	sd	s2,48(sp)
    80003644:	f44e                	sd	s3,40(sp)
    80003646:	f052                	sd	s4,32(sp)
    80003648:	ec56                	sd	s5,24(sp)
    8000364a:	e85a                	sd	s6,16(sp)
    8000364c:	e45e                	sd	s7,8(sp)
    8000364e:	e062                	sd	s8,0(sp)
    80003650:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003652:	00954783          	lbu	a5,9(a0)
    80003656:	0e078863          	beqz	a5,80003746 <filewrite+0x10c>
    8000365a:	892a                	mv	s2,a0
    8000365c:	8b2e                	mv	s6,a1
    8000365e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003660:	411c                	lw	a5,0(a0)
    80003662:	4705                	li	a4,1
    80003664:	02e78263          	beq	a5,a4,80003688 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003668:	470d                	li	a4,3
    8000366a:	02e78463          	beq	a5,a4,80003692 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000366e:	4709                	li	a4,2
    80003670:	0ce79563          	bne	a5,a4,8000373a <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003674:	0ac05163          	blez	a2,80003716 <filewrite+0xdc>
    int i = 0;
    80003678:	4981                	li	s3,0
    8000367a:	6b85                	lui	s7,0x1
    8000367c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003680:	6c05                	lui	s8,0x1
    80003682:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003686:	a041                	j	80003706 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80003688:	6908                	ld	a0,16(a0)
    8000368a:	1e2000ef          	jal	ra,8000386c <pipewrite>
    8000368e:	8a2a                	mv	s4,a0
    80003690:	a071                	j	8000371c <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003692:	02451783          	lh	a5,36(a0)
    80003696:	03079693          	slli	a3,a5,0x30
    8000369a:	92c1                	srli	a3,a3,0x30
    8000369c:	4725                	li	a4,9
    8000369e:	0ad76663          	bltu	a4,a3,8000374a <filewrite+0x110>
    800036a2:	0792                	slli	a5,a5,0x4
    800036a4:	00014717          	auipc	a4,0x14
    800036a8:	5f470713          	addi	a4,a4,1524 # 80017c98 <devsw>
    800036ac:	97ba                	add	a5,a5,a4
    800036ae:	679c                	ld	a5,8(a5)
    800036b0:	cfd9                	beqz	a5,8000374e <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    800036b2:	4505                	li	a0,1
    800036b4:	9782                	jalr	a5
    800036b6:	8a2a                	mv	s4,a0
    800036b8:	a095                	j	8000371c <filewrite+0xe2>
    800036ba:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800036be:	9b1ff0ef          	jal	ra,8000306e <begin_op>
      ilock(f->ip);
    800036c2:	01893503          	ld	a0,24(s2)
    800036c6:	914ff0ef          	jal	ra,800027da <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800036ca:	8756                	mv	a4,s5
    800036cc:	02092683          	lw	a3,32(s2)
    800036d0:	01698633          	add	a2,s3,s6
    800036d4:	4585                	li	a1,1
    800036d6:	01893503          	ld	a0,24(s2)
    800036da:	c34ff0ef          	jal	ra,80002b0e <writei>
    800036de:	84aa                	mv	s1,a0
    800036e0:	00a05763          	blez	a0,800036ee <filewrite+0xb4>
        f->off += r;
    800036e4:	02092783          	lw	a5,32(s2)
    800036e8:	9fa9                	addw	a5,a5,a0
    800036ea:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800036ee:	01893503          	ld	a0,24(s2)
    800036f2:	992ff0ef          	jal	ra,80002884 <iunlock>
      end_op();
    800036f6:	9e7ff0ef          	jal	ra,800030dc <end_op>

      if(r != n1){
    800036fa:	009a9f63          	bne	s5,s1,80003718 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800036fe:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003702:	0149db63          	bge	s3,s4,80003718 <filewrite+0xde>
      int n1 = n - i;
    80003706:	413a04bb          	subw	s1,s4,s3
    8000370a:	0004879b          	sext.w	a5,s1
    8000370e:	fafbd6e3          	bge	s7,a5,800036ba <filewrite+0x80>
    80003712:	84e2                	mv	s1,s8
    80003714:	b75d                	j	800036ba <filewrite+0x80>
    int i = 0;
    80003716:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003718:	013a1f63          	bne	s4,s3,80003736 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000371c:	8552                	mv	a0,s4
    8000371e:	60a6                	ld	ra,72(sp)
    80003720:	6406                	ld	s0,64(sp)
    80003722:	74e2                	ld	s1,56(sp)
    80003724:	7942                	ld	s2,48(sp)
    80003726:	79a2                	ld	s3,40(sp)
    80003728:	7a02                	ld	s4,32(sp)
    8000372a:	6ae2                	ld	s5,24(sp)
    8000372c:	6b42                	ld	s6,16(sp)
    8000372e:	6ba2                	ld	s7,8(sp)
    80003730:	6c02                	ld	s8,0(sp)
    80003732:	6161                	addi	sp,sp,80
    80003734:	8082                	ret
    ret = (i == n ? n : -1);
    80003736:	5a7d                	li	s4,-1
    80003738:	b7d5                	j	8000371c <filewrite+0xe2>
    panic("filewrite");
    8000373a:	00004517          	auipc	a0,0x4
    8000373e:	02650513          	addi	a0,a0,38 # 80007760 <syscalls+0x2d0>
    80003742:	511010ef          	jal	ra,80005452 <panic>
    return -1;
    80003746:	5a7d                	li	s4,-1
    80003748:	bfd1                	j	8000371c <filewrite+0xe2>
      return -1;
    8000374a:	5a7d                	li	s4,-1
    8000374c:	bfc1                	j	8000371c <filewrite+0xe2>
    8000374e:	5a7d                	li	s4,-1
    80003750:	b7f1                	j	8000371c <filewrite+0xe2>

0000000080003752 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003752:	7179                	addi	sp,sp,-48
    80003754:	f406                	sd	ra,40(sp)
    80003756:	f022                	sd	s0,32(sp)
    80003758:	ec26                	sd	s1,24(sp)
    8000375a:	e84a                	sd	s2,16(sp)
    8000375c:	e44e                	sd	s3,8(sp)
    8000375e:	e052                	sd	s4,0(sp)
    80003760:	1800                	addi	s0,sp,48
    80003762:	84aa                	mv	s1,a0
    80003764:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003766:	0005b023          	sd	zero,0(a1)
    8000376a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000376e:	c75ff0ef          	jal	ra,800033e2 <filealloc>
    80003772:	e088                	sd	a0,0(s1)
    80003774:	cd35                	beqz	a0,800037f0 <pipealloc+0x9e>
    80003776:	c6dff0ef          	jal	ra,800033e2 <filealloc>
    8000377a:	00aa3023          	sd	a0,0(s4)
    8000377e:	c52d                	beqz	a0,800037e8 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003780:	a07fc0ef          	jal	ra,80000186 <kalloc>
    80003784:	892a                	mv	s2,a0
    80003786:	cd31                	beqz	a0,800037e2 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80003788:	4985                	li	s3,1
    8000378a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000378e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003792:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003796:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000379a:	00004597          	auipc	a1,0x4
    8000379e:	fd658593          	addi	a1,a1,-42 # 80007770 <syscalls+0x2e0>
    800037a2:	741010ef          	jal	ra,800056e2 <initlock>
  (*f0)->type = FD_PIPE;
    800037a6:	609c                	ld	a5,0(s1)
    800037a8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800037ac:	609c                	ld	a5,0(s1)
    800037ae:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800037b2:	609c                	ld	a5,0(s1)
    800037b4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800037b8:	609c                	ld	a5,0(s1)
    800037ba:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800037be:	000a3783          	ld	a5,0(s4)
    800037c2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800037c6:	000a3783          	ld	a5,0(s4)
    800037ca:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800037ce:	000a3783          	ld	a5,0(s4)
    800037d2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800037d6:	000a3783          	ld	a5,0(s4)
    800037da:	0127b823          	sd	s2,16(a5)
  return 0;
    800037de:	4501                	li	a0,0
    800037e0:	a005                	j	80003800 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800037e2:	6088                	ld	a0,0(s1)
    800037e4:	e501                	bnez	a0,800037ec <pipealloc+0x9a>
    800037e6:	a029                	j	800037f0 <pipealloc+0x9e>
    800037e8:	6088                	ld	a0,0(s1)
    800037ea:	c11d                	beqz	a0,80003810 <pipealloc+0xbe>
    fileclose(*f0);
    800037ec:	c9bff0ef          	jal	ra,80003486 <fileclose>
  if(*f1)
    800037f0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800037f4:	557d                	li	a0,-1
  if(*f1)
    800037f6:	c789                	beqz	a5,80003800 <pipealloc+0xae>
    fileclose(*f1);
    800037f8:	853e                	mv	a0,a5
    800037fa:	c8dff0ef          	jal	ra,80003486 <fileclose>
  return -1;
    800037fe:	557d                	li	a0,-1
}
    80003800:	70a2                	ld	ra,40(sp)
    80003802:	7402                	ld	s0,32(sp)
    80003804:	64e2                	ld	s1,24(sp)
    80003806:	6942                	ld	s2,16(sp)
    80003808:	69a2                	ld	s3,8(sp)
    8000380a:	6a02                	ld	s4,0(sp)
    8000380c:	6145                	addi	sp,sp,48
    8000380e:	8082                	ret
  return -1;
    80003810:	557d                	li	a0,-1
    80003812:	b7fd                	j	80003800 <pipealloc+0xae>

0000000080003814 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003814:	1101                	addi	sp,sp,-32
    80003816:	ec06                	sd	ra,24(sp)
    80003818:	e822                	sd	s0,16(sp)
    8000381a:	e426                	sd	s1,8(sp)
    8000381c:	e04a                	sd	s2,0(sp)
    8000381e:	1000                	addi	s0,sp,32
    80003820:	84aa                	mv	s1,a0
    80003822:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003824:	73f010ef          	jal	ra,80005762 <acquire>
  if(writable){
    80003828:	02090763          	beqz	s2,80003856 <pipeclose+0x42>
    pi->writeopen = 0;
    8000382c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003830:	21848513          	addi	a0,s1,536
    80003834:	cb1fd0ef          	jal	ra,800014e4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003838:	2204b783          	ld	a5,544(s1)
    8000383c:	e785                	bnez	a5,80003864 <pipeclose+0x50>
    release(&pi->lock);
    8000383e:	8526                	mv	a0,s1
    80003840:	7bb010ef          	jal	ra,800057fa <release>
    kfree((char*)pi);
    80003844:	8526                	mv	a0,s1
    80003846:	84dfc0ef          	jal	ra,80000092 <kfree>
  } else
    release(&pi->lock);
}
    8000384a:	60e2                	ld	ra,24(sp)
    8000384c:	6442                	ld	s0,16(sp)
    8000384e:	64a2                	ld	s1,8(sp)
    80003850:	6902                	ld	s2,0(sp)
    80003852:	6105                	addi	sp,sp,32
    80003854:	8082                	ret
    pi->readopen = 0;
    80003856:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000385a:	21c48513          	addi	a0,s1,540
    8000385e:	c87fd0ef          	jal	ra,800014e4 <wakeup>
    80003862:	bfd9                	j	80003838 <pipeclose+0x24>
    release(&pi->lock);
    80003864:	8526                	mv	a0,s1
    80003866:	795010ef          	jal	ra,800057fa <release>
}
    8000386a:	b7c5                	j	8000384a <pipeclose+0x36>

000000008000386c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000386c:	711d                	addi	sp,sp,-96
    8000386e:	ec86                	sd	ra,88(sp)
    80003870:	e8a2                	sd	s0,80(sp)
    80003872:	e4a6                	sd	s1,72(sp)
    80003874:	e0ca                	sd	s2,64(sp)
    80003876:	fc4e                	sd	s3,56(sp)
    80003878:	f852                	sd	s4,48(sp)
    8000387a:	f456                	sd	s5,40(sp)
    8000387c:	f05a                	sd	s6,32(sp)
    8000387e:	ec5e                	sd	s7,24(sp)
    80003880:	e862                	sd	s8,16(sp)
    80003882:	1080                	addi	s0,sp,96
    80003884:	84aa                	mv	s1,a0
    80003886:	8aae                	mv	s5,a1
    80003888:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000388a:	e42fd0ef          	jal	ra,80000ecc <myproc>
    8000388e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003890:	8526                	mv	a0,s1
    80003892:	6d1010ef          	jal	ra,80005762 <acquire>
  while(i < n){
    80003896:	09405c63          	blez	s4,8000392e <pipewrite+0xc2>
  int i = 0;
    8000389a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000389c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000389e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800038a2:	21c48b93          	addi	s7,s1,540
    800038a6:	a81d                	j	800038dc <pipewrite+0x70>
      release(&pi->lock);
    800038a8:	8526                	mv	a0,s1
    800038aa:	751010ef          	jal	ra,800057fa <release>
      return -1;
    800038ae:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800038b0:	854a                	mv	a0,s2
    800038b2:	60e6                	ld	ra,88(sp)
    800038b4:	6446                	ld	s0,80(sp)
    800038b6:	64a6                	ld	s1,72(sp)
    800038b8:	6906                	ld	s2,64(sp)
    800038ba:	79e2                	ld	s3,56(sp)
    800038bc:	7a42                	ld	s4,48(sp)
    800038be:	7aa2                	ld	s5,40(sp)
    800038c0:	7b02                	ld	s6,32(sp)
    800038c2:	6be2                	ld	s7,24(sp)
    800038c4:	6c42                	ld	s8,16(sp)
    800038c6:	6125                	addi	sp,sp,96
    800038c8:	8082                	ret
      wakeup(&pi->nread);
    800038ca:	8562                	mv	a0,s8
    800038cc:	c19fd0ef          	jal	ra,800014e4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800038d0:	85a6                	mv	a1,s1
    800038d2:	855e                	mv	a0,s7
    800038d4:	bc5fd0ef          	jal	ra,80001498 <sleep>
  while(i < n){
    800038d8:	05495c63          	bge	s2,s4,80003930 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    800038dc:	2204a783          	lw	a5,544(s1)
    800038e0:	d7e1                	beqz	a5,800038a8 <pipewrite+0x3c>
    800038e2:	854e                	mv	a0,s3
    800038e4:	dedfd0ef          	jal	ra,800016d0 <killed>
    800038e8:	f161                	bnez	a0,800038a8 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800038ea:	2184a783          	lw	a5,536(s1)
    800038ee:	21c4a703          	lw	a4,540(s1)
    800038f2:	2007879b          	addiw	a5,a5,512
    800038f6:	fcf70ae3          	beq	a4,a5,800038ca <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800038fa:	4685                	li	a3,1
    800038fc:	01590633          	add	a2,s2,s5
    80003900:	faf40593          	addi	a1,s0,-81
    80003904:	0509b503          	ld	a0,80(s3)
    80003908:	a20fd0ef          	jal	ra,80000b28 <copyin>
    8000390c:	03650263          	beq	a0,s6,80003930 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003910:	21c4a783          	lw	a5,540(s1)
    80003914:	0017871b          	addiw	a4,a5,1
    80003918:	20e4ae23          	sw	a4,540(s1)
    8000391c:	1ff7f793          	andi	a5,a5,511
    80003920:	97a6                	add	a5,a5,s1
    80003922:	faf44703          	lbu	a4,-81(s0)
    80003926:	00e78c23          	sb	a4,24(a5)
      i++;
    8000392a:	2905                	addiw	s2,s2,1
    8000392c:	b775                	j	800038d8 <pipewrite+0x6c>
  int i = 0;
    8000392e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80003930:	21848513          	addi	a0,s1,536
    80003934:	bb1fd0ef          	jal	ra,800014e4 <wakeup>
  release(&pi->lock);
    80003938:	8526                	mv	a0,s1
    8000393a:	6c1010ef          	jal	ra,800057fa <release>
  return i;
    8000393e:	bf8d                	j	800038b0 <pipewrite+0x44>

0000000080003940 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003940:	715d                	addi	sp,sp,-80
    80003942:	e486                	sd	ra,72(sp)
    80003944:	e0a2                	sd	s0,64(sp)
    80003946:	fc26                	sd	s1,56(sp)
    80003948:	f84a                	sd	s2,48(sp)
    8000394a:	f44e                	sd	s3,40(sp)
    8000394c:	f052                	sd	s4,32(sp)
    8000394e:	ec56                	sd	s5,24(sp)
    80003950:	e85a                	sd	s6,16(sp)
    80003952:	0880                	addi	s0,sp,80
    80003954:	84aa                	mv	s1,a0
    80003956:	892e                	mv	s2,a1
    80003958:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000395a:	d72fd0ef          	jal	ra,80000ecc <myproc>
    8000395e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003960:	8526                	mv	a0,s1
    80003962:	601010ef          	jal	ra,80005762 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003966:	2184a703          	lw	a4,536(s1)
    8000396a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000396e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003972:	02f71363          	bne	a4,a5,80003998 <piperead+0x58>
    80003976:	2244a783          	lw	a5,548(s1)
    8000397a:	cf99                	beqz	a5,80003998 <piperead+0x58>
    if(killed(pr)){
    8000397c:	8552                	mv	a0,s4
    8000397e:	d53fd0ef          	jal	ra,800016d0 <killed>
    80003982:	e149                	bnez	a0,80003a04 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003984:	85a6                	mv	a1,s1
    80003986:	854e                	mv	a0,s3
    80003988:	b11fd0ef          	jal	ra,80001498 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000398c:	2184a703          	lw	a4,536(s1)
    80003990:	21c4a783          	lw	a5,540(s1)
    80003994:	fef701e3          	beq	a4,a5,80003976 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003998:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000399a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000399c:	05505263          	blez	s5,800039e0 <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    800039a0:	2184a783          	lw	a5,536(s1)
    800039a4:	21c4a703          	lw	a4,540(s1)
    800039a8:	02f70c63          	beq	a4,a5,800039e0 <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800039ac:	0017871b          	addiw	a4,a5,1
    800039b0:	20e4ac23          	sw	a4,536(s1)
    800039b4:	1ff7f793          	andi	a5,a5,511
    800039b8:	97a6                	add	a5,a5,s1
    800039ba:	0187c783          	lbu	a5,24(a5)
    800039be:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800039c2:	4685                	li	a3,1
    800039c4:	fbf40613          	addi	a2,s0,-65
    800039c8:	85ca                	mv	a1,s2
    800039ca:	050a3503          	ld	a0,80(s4)
    800039ce:	8a2fd0ef          	jal	ra,80000a70 <copyout>
    800039d2:	01650763          	beq	a0,s6,800039e0 <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800039d6:	2985                	addiw	s3,s3,1
    800039d8:	0905                	addi	s2,s2,1
    800039da:	fd3a93e3          	bne	s5,s3,800039a0 <piperead+0x60>
    800039de:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800039e0:	21c48513          	addi	a0,s1,540
    800039e4:	b01fd0ef          	jal	ra,800014e4 <wakeup>
  release(&pi->lock);
    800039e8:	8526                	mv	a0,s1
    800039ea:	611010ef          	jal	ra,800057fa <release>
  return i;
}
    800039ee:	854e                	mv	a0,s3
    800039f0:	60a6                	ld	ra,72(sp)
    800039f2:	6406                	ld	s0,64(sp)
    800039f4:	74e2                	ld	s1,56(sp)
    800039f6:	7942                	ld	s2,48(sp)
    800039f8:	79a2                	ld	s3,40(sp)
    800039fa:	7a02                	ld	s4,32(sp)
    800039fc:	6ae2                	ld	s5,24(sp)
    800039fe:	6b42                	ld	s6,16(sp)
    80003a00:	6161                	addi	sp,sp,80
    80003a02:	8082                	ret
      release(&pi->lock);
    80003a04:	8526                	mv	a0,s1
    80003a06:	5f5010ef          	jal	ra,800057fa <release>
      return -1;
    80003a0a:	59fd                	li	s3,-1
    80003a0c:	b7cd                	j	800039ee <piperead+0xae>

0000000080003a0e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003a0e:	1141                	addi	sp,sp,-16
    80003a10:	e422                	sd	s0,8(sp)
    80003a12:	0800                	addi	s0,sp,16
    80003a14:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003a16:	8905                	andi	a0,a0,1
    80003a18:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003a1a:	8b89                	andi	a5,a5,2
    80003a1c:	c399                	beqz	a5,80003a22 <flags2perm+0x14>
      perm |= PTE_W;
    80003a1e:	00456513          	ori	a0,a0,4
    return perm;
}
    80003a22:	6422                	ld	s0,8(sp)
    80003a24:	0141                	addi	sp,sp,16
    80003a26:	8082                	ret

0000000080003a28 <exec>:

int
exec(char *path, char **argv)
{
    80003a28:	de010113          	addi	sp,sp,-544
    80003a2c:	20113c23          	sd	ra,536(sp)
    80003a30:	20813823          	sd	s0,528(sp)
    80003a34:	20913423          	sd	s1,520(sp)
    80003a38:	21213023          	sd	s2,512(sp)
    80003a3c:	ffce                	sd	s3,504(sp)
    80003a3e:	fbd2                	sd	s4,496(sp)
    80003a40:	f7d6                	sd	s5,488(sp)
    80003a42:	f3da                	sd	s6,480(sp)
    80003a44:	efde                	sd	s7,472(sp)
    80003a46:	ebe2                	sd	s8,464(sp)
    80003a48:	e7e6                	sd	s9,456(sp)
    80003a4a:	e3ea                	sd	s10,448(sp)
    80003a4c:	ff6e                	sd	s11,440(sp)
    80003a4e:	1400                	addi	s0,sp,544
    80003a50:	892a                	mv	s2,a0
    80003a52:	dea43423          	sd	a0,-536(s0)
    80003a56:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003a5a:	c72fd0ef          	jal	ra,80000ecc <myproc>
    80003a5e:	84aa                	mv	s1,a0

  begin_op();
    80003a60:	e0eff0ef          	jal	ra,8000306e <begin_op>

  if((ip = namei(path)) == 0){
    80003a64:	854a                	mv	a0,s2
    80003a66:	c2cff0ef          	jal	ra,80002e92 <namei>
    80003a6a:	c13d                	beqz	a0,80003ad0 <exec+0xa8>
    80003a6c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003a6e:	d6dfe0ef          	jal	ra,800027da <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003a72:	04000713          	li	a4,64
    80003a76:	4681                	li	a3,0
    80003a78:	e5040613          	addi	a2,s0,-432
    80003a7c:	4581                	li	a1,0
    80003a7e:	8556                	mv	a0,s5
    80003a80:	fabfe0ef          	jal	ra,80002a2a <readi>
    80003a84:	04000793          	li	a5,64
    80003a88:	00f51a63          	bne	a0,a5,80003a9c <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003a8c:	e5042703          	lw	a4,-432(s0)
    80003a90:	464c47b7          	lui	a5,0x464c4
    80003a94:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003a98:	04f70063          	beq	a4,a5,80003ad8 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003a9c:	8556                	mv	a0,s5
    80003a9e:	f43fe0ef          	jal	ra,800029e0 <iunlockput>
    end_op();
    80003aa2:	e3aff0ef          	jal	ra,800030dc <end_op>
  }
  return -1;
    80003aa6:	557d                	li	a0,-1
}
    80003aa8:	21813083          	ld	ra,536(sp)
    80003aac:	21013403          	ld	s0,528(sp)
    80003ab0:	20813483          	ld	s1,520(sp)
    80003ab4:	20013903          	ld	s2,512(sp)
    80003ab8:	79fe                	ld	s3,504(sp)
    80003aba:	7a5e                	ld	s4,496(sp)
    80003abc:	7abe                	ld	s5,488(sp)
    80003abe:	7b1e                	ld	s6,480(sp)
    80003ac0:	6bfe                	ld	s7,472(sp)
    80003ac2:	6c5e                	ld	s8,464(sp)
    80003ac4:	6cbe                	ld	s9,456(sp)
    80003ac6:	6d1e                	ld	s10,448(sp)
    80003ac8:	7dfa                	ld	s11,440(sp)
    80003aca:	22010113          	addi	sp,sp,544
    80003ace:	8082                	ret
    end_op();
    80003ad0:	e0cff0ef          	jal	ra,800030dc <end_op>
    return -1;
    80003ad4:	557d                	li	a0,-1
    80003ad6:	bfc9                	j	80003aa8 <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    80003ad8:	8526                	mv	a0,s1
    80003ada:	c9afd0ef          	jal	ra,80000f74 <proc_pagetable>
    80003ade:	8b2a                	mv	s6,a0
    80003ae0:	dd55                	beqz	a0,80003a9c <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003ae2:	e7042783          	lw	a5,-400(s0)
    80003ae6:	e8845703          	lhu	a4,-376(s0)
    80003aea:	c325                	beqz	a4,80003b4a <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003aec:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003aee:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80003af2:	6a05                	lui	s4,0x1
    80003af4:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80003af8:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80003afc:	6d85                	lui	s11,0x1
    80003afe:	7d7d                	lui	s10,0xfffff
    80003b00:	a409                	j	80003d02 <exec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80003b02:	00004517          	auipc	a0,0x4
    80003b06:	c7650513          	addi	a0,a0,-906 # 80007778 <syscalls+0x2e8>
    80003b0a:	149010ef          	jal	ra,80005452 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003b0e:	874a                	mv	a4,s2
    80003b10:	009c86bb          	addw	a3,s9,s1
    80003b14:	4581                	li	a1,0
    80003b16:	8556                	mv	a0,s5
    80003b18:	f13fe0ef          	jal	ra,80002a2a <readi>
    80003b1c:	2501                	sext.w	a0,a0
    80003b1e:	18a91163          	bne	s2,a0,80003ca0 <exec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80003b22:	009d84bb          	addw	s1,s11,s1
    80003b26:	013d09bb          	addw	s3,s10,s3
    80003b2a:	1b74fc63          	bgeu	s1,s7,80003ce2 <exec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80003b2e:	02049593          	slli	a1,s1,0x20
    80003b32:	9181                	srli	a1,a1,0x20
    80003b34:	95e2                	add	a1,a1,s8
    80003b36:	855a                	mv	a0,s6
    80003b38:	9c9fc0ef          	jal	ra,80000500 <walkaddr>
    80003b3c:	862a                	mv	a2,a0
    if(pa == 0)
    80003b3e:	d171                	beqz	a0,80003b02 <exec+0xda>
      n = PGSIZE;
    80003b40:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80003b42:	fd49f6e3          	bgeu	s3,s4,80003b0e <exec+0xe6>
      n = sz - i;
    80003b46:	894e                	mv	s2,s3
    80003b48:	b7d9                	j	80003b0e <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003b4a:	4901                	li	s2,0
  iunlockput(ip);
    80003b4c:	8556                	mv	a0,s5
    80003b4e:	e93fe0ef          	jal	ra,800029e0 <iunlockput>
  end_op();
    80003b52:	d8aff0ef          	jal	ra,800030dc <end_op>
  p = myproc();
    80003b56:	b76fd0ef          	jal	ra,80000ecc <myproc>
    80003b5a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80003b5c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003b60:	6785                	lui	a5,0x1
    80003b62:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80003b64:	97ca                	add	a5,a5,s2
    80003b66:	777d                	lui	a4,0xfffff
    80003b68:	8ff9                	and	a5,a5,a4
    80003b6a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003b6e:	4691                	li	a3,4
    80003b70:	6609                	lui	a2,0x2
    80003b72:	963e                	add	a2,a2,a5
    80003b74:	85be                	mv	a1,a5
    80003b76:	855a                	mv	a0,s6
    80003b78:	cf1fc0ef          	jal	ra,80000868 <uvmalloc>
    80003b7c:	8c2a                	mv	s8,a0
  ip = 0;
    80003b7e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003b80:	12050063          	beqz	a0,80003ca0 <exec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003b84:	75f9                	lui	a1,0xffffe
    80003b86:	95aa                	add	a1,a1,a0
    80003b88:	855a                	mv	a0,s6
    80003b8a:	ebdfc0ef          	jal	ra,80000a46 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003b8e:	7afd                	lui	s5,0xfffff
    80003b90:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80003b92:	df043783          	ld	a5,-528(s0)
    80003b96:	6388                	ld	a0,0(a5)
    80003b98:	c135                	beqz	a0,80003bfc <exec+0x1d4>
    80003b9a:	e9040993          	addi	s3,s0,-368
    80003b9e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80003ba2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003ba4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003ba6:	fb2fc0ef          	jal	ra,80000358 <strlen>
    80003baa:	0015079b          	addiw	a5,a0,1
    80003bae:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003bb2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003bb6:	11596a63          	bltu	s2,s5,80003cca <exec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003bba:	df043d83          	ld	s11,-528(s0)
    80003bbe:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80003bc2:	8552                	mv	a0,s4
    80003bc4:	f94fc0ef          	jal	ra,80000358 <strlen>
    80003bc8:	0015069b          	addiw	a3,a0,1
    80003bcc:	8652                	mv	a2,s4
    80003bce:	85ca                	mv	a1,s2
    80003bd0:	855a                	mv	a0,s6
    80003bd2:	e9ffc0ef          	jal	ra,80000a70 <copyout>
    80003bd6:	0e054e63          	bltz	a0,80003cd2 <exec+0x2aa>
    ustack[argc] = sp;
    80003bda:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003bde:	0485                	addi	s1,s1,1
    80003be0:	008d8793          	addi	a5,s11,8
    80003be4:	def43823          	sd	a5,-528(s0)
    80003be8:	008db503          	ld	a0,8(s11)
    80003bec:	c911                	beqz	a0,80003c00 <exec+0x1d8>
    if(argc >= MAXARG)
    80003bee:	09a1                	addi	s3,s3,8
    80003bf0:	fb3c9be3          	bne	s9,s3,80003ba6 <exec+0x17e>
  sz = sz1;
    80003bf4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003bf8:	4a81                	li	s5,0
    80003bfa:	a05d                	j	80003ca0 <exec+0x278>
  sp = sz;
    80003bfc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003bfe:	4481                	li	s1,0
  ustack[argc] = 0;
    80003c00:	00349793          	slli	a5,s1,0x3
    80003c04:	f9078793          	addi	a5,a5,-112
    80003c08:	97a2                	add	a5,a5,s0
    80003c0a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003c0e:	00148693          	addi	a3,s1,1
    80003c12:	068e                	slli	a3,a3,0x3
    80003c14:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003c18:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80003c1c:	01597663          	bgeu	s2,s5,80003c28 <exec+0x200>
  sz = sz1;
    80003c20:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003c24:	4a81                	li	s5,0
    80003c26:	a8ad                	j	80003ca0 <exec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003c28:	e9040613          	addi	a2,s0,-368
    80003c2c:	85ca                	mv	a1,s2
    80003c2e:	855a                	mv	a0,s6
    80003c30:	e41fc0ef          	jal	ra,80000a70 <copyout>
    80003c34:	0a054363          	bltz	a0,80003cda <exec+0x2b2>
  p->trapframe->a1 = sp;
    80003c38:	058bb783          	ld	a5,88(s7)
    80003c3c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003c40:	de843783          	ld	a5,-536(s0)
    80003c44:	0007c703          	lbu	a4,0(a5)
    80003c48:	cf11                	beqz	a4,80003c64 <exec+0x23c>
    80003c4a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003c4c:	02f00693          	li	a3,47
    80003c50:	a039                	j	80003c5e <exec+0x236>
      last = s+1;
    80003c52:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80003c56:	0785                	addi	a5,a5,1
    80003c58:	fff7c703          	lbu	a4,-1(a5)
    80003c5c:	c701                	beqz	a4,80003c64 <exec+0x23c>
    if(*s == '/')
    80003c5e:	fed71ce3          	bne	a4,a3,80003c56 <exec+0x22e>
    80003c62:	bfc5                	j	80003c52 <exec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80003c64:	4641                	li	a2,16
    80003c66:	de843583          	ld	a1,-536(s0)
    80003c6a:	158b8513          	addi	a0,s7,344
    80003c6e:	eb8fc0ef          	jal	ra,80000326 <safestrcpy>
  oldpagetable = p->pagetable;
    80003c72:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80003c76:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80003c7a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003c7e:	058bb783          	ld	a5,88(s7)
    80003c82:	e6843703          	ld	a4,-408(s0)
    80003c86:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003c88:	058bb783          	ld	a5,88(s7)
    80003c8c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003c90:	85ea                	mv	a1,s10
    80003c92:	b66fd0ef          	jal	ra,80000ff8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003c96:	0004851b          	sext.w	a0,s1
    80003c9a:	b539                	j	80003aa8 <exec+0x80>
    80003c9c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80003ca0:	df843583          	ld	a1,-520(s0)
    80003ca4:	855a                	mv	a0,s6
    80003ca6:	b52fd0ef          	jal	ra,80000ff8 <proc_freepagetable>
  if(ip){
    80003caa:	de0a99e3          	bnez	s5,80003a9c <exec+0x74>
  return -1;
    80003cae:	557d                	li	a0,-1
    80003cb0:	bbe5                	j	80003aa8 <exec+0x80>
    80003cb2:	df243c23          	sd	s2,-520(s0)
    80003cb6:	b7ed                	j	80003ca0 <exec+0x278>
    80003cb8:	df243c23          	sd	s2,-520(s0)
    80003cbc:	b7d5                	j	80003ca0 <exec+0x278>
    80003cbe:	df243c23          	sd	s2,-520(s0)
    80003cc2:	bff9                	j	80003ca0 <exec+0x278>
    80003cc4:	df243c23          	sd	s2,-520(s0)
    80003cc8:	bfe1                	j	80003ca0 <exec+0x278>
  sz = sz1;
    80003cca:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003cce:	4a81                	li	s5,0
    80003cd0:	bfc1                	j	80003ca0 <exec+0x278>
  sz = sz1;
    80003cd2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003cd6:	4a81                	li	s5,0
    80003cd8:	b7e1                	j	80003ca0 <exec+0x278>
  sz = sz1;
    80003cda:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003cde:	4a81                	li	s5,0
    80003ce0:	b7c1                	j	80003ca0 <exec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003ce2:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003ce6:	e0843783          	ld	a5,-504(s0)
    80003cea:	0017869b          	addiw	a3,a5,1
    80003cee:	e0d43423          	sd	a3,-504(s0)
    80003cf2:	e0043783          	ld	a5,-512(s0)
    80003cf6:	0387879b          	addiw	a5,a5,56
    80003cfa:	e8845703          	lhu	a4,-376(s0)
    80003cfe:	e4e6d7e3          	bge	a3,a4,80003b4c <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003d02:	2781                	sext.w	a5,a5
    80003d04:	e0f43023          	sd	a5,-512(s0)
    80003d08:	03800713          	li	a4,56
    80003d0c:	86be                	mv	a3,a5
    80003d0e:	e1840613          	addi	a2,s0,-488
    80003d12:	4581                	li	a1,0
    80003d14:	8556                	mv	a0,s5
    80003d16:	d15fe0ef          	jal	ra,80002a2a <readi>
    80003d1a:	03800793          	li	a5,56
    80003d1e:	f6f51fe3          	bne	a0,a5,80003c9c <exec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80003d22:	e1842783          	lw	a5,-488(s0)
    80003d26:	4705                	li	a4,1
    80003d28:	fae79fe3          	bne	a5,a4,80003ce6 <exec+0x2be>
    if(ph.memsz < ph.filesz)
    80003d2c:	e4043483          	ld	s1,-448(s0)
    80003d30:	e3843783          	ld	a5,-456(s0)
    80003d34:	f6f4efe3          	bltu	s1,a5,80003cb2 <exec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003d38:	e2843783          	ld	a5,-472(s0)
    80003d3c:	94be                	add	s1,s1,a5
    80003d3e:	f6f4ede3          	bltu	s1,a5,80003cb8 <exec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80003d42:	de043703          	ld	a4,-544(s0)
    80003d46:	8ff9                	and	a5,a5,a4
    80003d48:	fbbd                	bnez	a5,80003cbe <exec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003d4a:	e1c42503          	lw	a0,-484(s0)
    80003d4e:	cc1ff0ef          	jal	ra,80003a0e <flags2perm>
    80003d52:	86aa                	mv	a3,a0
    80003d54:	8626                	mv	a2,s1
    80003d56:	85ca                	mv	a1,s2
    80003d58:	855a                	mv	a0,s6
    80003d5a:	b0ffc0ef          	jal	ra,80000868 <uvmalloc>
    80003d5e:	dea43c23          	sd	a0,-520(s0)
    80003d62:	d12d                	beqz	a0,80003cc4 <exec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003d64:	e2843c03          	ld	s8,-472(s0)
    80003d68:	e2042c83          	lw	s9,-480(s0)
    80003d6c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003d70:	f60b89e3          	beqz	s7,80003ce2 <exec+0x2ba>
    80003d74:	89de                	mv	s3,s7
    80003d76:	4481                	li	s1,0
    80003d78:	bb5d                	j	80003b2e <exec+0x106>

0000000080003d7a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003d7a:	7179                	addi	sp,sp,-48
    80003d7c:	f406                	sd	ra,40(sp)
    80003d7e:	f022                	sd	s0,32(sp)
    80003d80:	ec26                	sd	s1,24(sp)
    80003d82:	e84a                	sd	s2,16(sp)
    80003d84:	1800                	addi	s0,sp,48
    80003d86:	892e                	mv	s2,a1
    80003d88:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003d8a:	fdc40593          	addi	a1,s0,-36
    80003d8e:	fedfd0ef          	jal	ra,80001d7a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003d92:	fdc42703          	lw	a4,-36(s0)
    80003d96:	47bd                	li	a5,15
    80003d98:	02e7e963          	bltu	a5,a4,80003dca <argfd+0x50>
    80003d9c:	930fd0ef          	jal	ra,80000ecc <myproc>
    80003da0:	fdc42703          	lw	a4,-36(s0)
    80003da4:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffde0ea>
    80003da8:	078e                	slli	a5,a5,0x3
    80003daa:	953e                	add	a0,a0,a5
    80003dac:	611c                	ld	a5,0(a0)
    80003dae:	c385                	beqz	a5,80003dce <argfd+0x54>
    return -1;
  if(pfd)
    80003db0:	00090463          	beqz	s2,80003db8 <argfd+0x3e>
    *pfd = fd;
    80003db4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003db8:	4501                	li	a0,0
  if(pf)
    80003dba:	c091                	beqz	s1,80003dbe <argfd+0x44>
    *pf = f;
    80003dbc:	e09c                	sd	a5,0(s1)
}
    80003dbe:	70a2                	ld	ra,40(sp)
    80003dc0:	7402                	ld	s0,32(sp)
    80003dc2:	64e2                	ld	s1,24(sp)
    80003dc4:	6942                	ld	s2,16(sp)
    80003dc6:	6145                	addi	sp,sp,48
    80003dc8:	8082                	ret
    return -1;
    80003dca:	557d                	li	a0,-1
    80003dcc:	bfcd                	j	80003dbe <argfd+0x44>
    80003dce:	557d                	li	a0,-1
    80003dd0:	b7fd                	j	80003dbe <argfd+0x44>

0000000080003dd2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003dd2:	1101                	addi	sp,sp,-32
    80003dd4:	ec06                	sd	ra,24(sp)
    80003dd6:	e822                	sd	s0,16(sp)
    80003dd8:	e426                	sd	s1,8(sp)
    80003dda:	1000                	addi	s0,sp,32
    80003ddc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003dde:	8eefd0ef          	jal	ra,80000ecc <myproc>
    80003de2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003de4:	0d050793          	addi	a5,a0,208
    80003de8:	4501                	li	a0,0
    80003dea:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003dec:	6398                	ld	a4,0(a5)
    80003dee:	cb19                	beqz	a4,80003e04 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003df0:	2505                	addiw	a0,a0,1
    80003df2:	07a1                	addi	a5,a5,8
    80003df4:	fed51ce3          	bne	a0,a3,80003dec <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003df8:	557d                	li	a0,-1
}
    80003dfa:	60e2                	ld	ra,24(sp)
    80003dfc:	6442                	ld	s0,16(sp)
    80003dfe:	64a2                	ld	s1,8(sp)
    80003e00:	6105                	addi	sp,sp,32
    80003e02:	8082                	ret
      p->ofile[fd] = f;
    80003e04:	01a50793          	addi	a5,a0,26
    80003e08:	078e                	slli	a5,a5,0x3
    80003e0a:	963e                	add	a2,a2,a5
    80003e0c:	e204                	sd	s1,0(a2)
      return fd;
    80003e0e:	b7f5                	j	80003dfa <fdalloc+0x28>

0000000080003e10 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003e10:	715d                	addi	sp,sp,-80
    80003e12:	e486                	sd	ra,72(sp)
    80003e14:	e0a2                	sd	s0,64(sp)
    80003e16:	fc26                	sd	s1,56(sp)
    80003e18:	f84a                	sd	s2,48(sp)
    80003e1a:	f44e                	sd	s3,40(sp)
    80003e1c:	f052                	sd	s4,32(sp)
    80003e1e:	ec56                	sd	s5,24(sp)
    80003e20:	e85a                	sd	s6,16(sp)
    80003e22:	0880                	addi	s0,sp,80
    80003e24:	8b2e                	mv	s6,a1
    80003e26:	89b2                	mv	s3,a2
    80003e28:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003e2a:	fb040593          	addi	a1,s0,-80
    80003e2e:	87eff0ef          	jal	ra,80002eac <nameiparent>
    80003e32:	84aa                	mv	s1,a0
    80003e34:	10050b63          	beqz	a0,80003f4a <create+0x13a>
    return 0;

  ilock(dp);
    80003e38:	9a3fe0ef          	jal	ra,800027da <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e3c:	4601                	li	a2,0
    80003e3e:	fb040593          	addi	a1,s0,-80
    80003e42:	8526                	mv	a0,s1
    80003e44:	de3fe0ef          	jal	ra,80002c26 <dirlookup>
    80003e48:	8aaa                	mv	s5,a0
    80003e4a:	c521                	beqz	a0,80003e92 <create+0x82>
    iunlockput(dp);
    80003e4c:	8526                	mv	a0,s1
    80003e4e:	b93fe0ef          	jal	ra,800029e0 <iunlockput>
    ilock(ip);
    80003e52:	8556                	mv	a0,s5
    80003e54:	987fe0ef          	jal	ra,800027da <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003e58:	000b059b          	sext.w	a1,s6
    80003e5c:	4789                	li	a5,2
    80003e5e:	02f59563          	bne	a1,a5,80003e88 <create+0x78>
    80003e62:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde114>
    80003e66:	37f9                	addiw	a5,a5,-2
    80003e68:	17c2                	slli	a5,a5,0x30
    80003e6a:	93c1                	srli	a5,a5,0x30
    80003e6c:	4705                	li	a4,1
    80003e6e:	00f76d63          	bltu	a4,a5,80003e88 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003e72:	8556                	mv	a0,s5
    80003e74:	60a6                	ld	ra,72(sp)
    80003e76:	6406                	ld	s0,64(sp)
    80003e78:	74e2                	ld	s1,56(sp)
    80003e7a:	7942                	ld	s2,48(sp)
    80003e7c:	79a2                	ld	s3,40(sp)
    80003e7e:	7a02                	ld	s4,32(sp)
    80003e80:	6ae2                	ld	s5,24(sp)
    80003e82:	6b42                	ld	s6,16(sp)
    80003e84:	6161                	addi	sp,sp,80
    80003e86:	8082                	ret
    iunlockput(ip);
    80003e88:	8556                	mv	a0,s5
    80003e8a:	b57fe0ef          	jal	ra,800029e0 <iunlockput>
    return 0;
    80003e8e:	4a81                	li	s5,0
    80003e90:	b7cd                	j	80003e72 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80003e92:	85da                	mv	a1,s6
    80003e94:	4088                	lw	a0,0(s1)
    80003e96:	fdafe0ef          	jal	ra,80002670 <ialloc>
    80003e9a:	8a2a                	mv	s4,a0
    80003e9c:	cd1d                	beqz	a0,80003eda <create+0xca>
  ilock(ip);
    80003e9e:	93dfe0ef          	jal	ra,800027da <ilock>
  ip->major = major;
    80003ea2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003ea6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003eaa:	4905                	li	s2,1
    80003eac:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003eb0:	8552                	mv	a0,s4
    80003eb2:	875fe0ef          	jal	ra,80002726 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003eb6:	000b059b          	sext.w	a1,s6
    80003eba:	03258563          	beq	a1,s2,80003ee4 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80003ebe:	004a2603          	lw	a2,4(s4)
    80003ec2:	fb040593          	addi	a1,s0,-80
    80003ec6:	8526                	mv	a0,s1
    80003ec8:	f31fe0ef          	jal	ra,80002df8 <dirlink>
    80003ecc:	06054363          	bltz	a0,80003f32 <create+0x122>
  iunlockput(dp);
    80003ed0:	8526                	mv	a0,s1
    80003ed2:	b0ffe0ef          	jal	ra,800029e0 <iunlockput>
  return ip;
    80003ed6:	8ad2                	mv	s5,s4
    80003ed8:	bf69                	j	80003e72 <create+0x62>
    iunlockput(dp);
    80003eda:	8526                	mv	a0,s1
    80003edc:	b05fe0ef          	jal	ra,800029e0 <iunlockput>
    return 0;
    80003ee0:	8ad2                	mv	s5,s4
    80003ee2:	bf41                	j	80003e72 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003ee4:	004a2603          	lw	a2,4(s4)
    80003ee8:	00004597          	auipc	a1,0x4
    80003eec:	8b058593          	addi	a1,a1,-1872 # 80007798 <syscalls+0x308>
    80003ef0:	8552                	mv	a0,s4
    80003ef2:	f07fe0ef          	jal	ra,80002df8 <dirlink>
    80003ef6:	02054e63          	bltz	a0,80003f32 <create+0x122>
    80003efa:	40d0                	lw	a2,4(s1)
    80003efc:	00004597          	auipc	a1,0x4
    80003f00:	8a458593          	addi	a1,a1,-1884 # 800077a0 <syscalls+0x310>
    80003f04:	8552                	mv	a0,s4
    80003f06:	ef3fe0ef          	jal	ra,80002df8 <dirlink>
    80003f0a:	02054463          	bltz	a0,80003f32 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80003f0e:	004a2603          	lw	a2,4(s4)
    80003f12:	fb040593          	addi	a1,s0,-80
    80003f16:	8526                	mv	a0,s1
    80003f18:	ee1fe0ef          	jal	ra,80002df8 <dirlink>
    80003f1c:	00054b63          	bltz	a0,80003f32 <create+0x122>
    dp->nlink++;  // for ".."
    80003f20:	04a4d783          	lhu	a5,74(s1)
    80003f24:	2785                	addiw	a5,a5,1
    80003f26:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	ffafe0ef          	jal	ra,80002726 <iupdate>
    80003f30:	b745                	j	80003ed0 <create+0xc0>
  ip->nlink = 0;
    80003f32:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003f36:	8552                	mv	a0,s4
    80003f38:	feefe0ef          	jal	ra,80002726 <iupdate>
  iunlockput(ip);
    80003f3c:	8552                	mv	a0,s4
    80003f3e:	aa3fe0ef          	jal	ra,800029e0 <iunlockput>
  iunlockput(dp);
    80003f42:	8526                	mv	a0,s1
    80003f44:	a9dfe0ef          	jal	ra,800029e0 <iunlockput>
  return 0;
    80003f48:	b72d                	j	80003e72 <create+0x62>
    return 0;
    80003f4a:	8aaa                	mv	s5,a0
    80003f4c:	b71d                	j	80003e72 <create+0x62>

0000000080003f4e <sys_dup>:
{
    80003f4e:	7179                	addi	sp,sp,-48
    80003f50:	f406                	sd	ra,40(sp)
    80003f52:	f022                	sd	s0,32(sp)
    80003f54:	ec26                	sd	s1,24(sp)
    80003f56:	e84a                	sd	s2,16(sp)
    80003f58:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80003f5a:	fd840613          	addi	a2,s0,-40
    80003f5e:	4581                	li	a1,0
    80003f60:	4501                	li	a0,0
    80003f62:	e19ff0ef          	jal	ra,80003d7a <argfd>
    return -1;
    80003f66:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80003f68:	00054f63          	bltz	a0,80003f86 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80003f6c:	fd843903          	ld	s2,-40(s0)
    80003f70:	854a                	mv	a0,s2
    80003f72:	e61ff0ef          	jal	ra,80003dd2 <fdalloc>
    80003f76:	84aa                	mv	s1,a0
    return -1;
    80003f78:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80003f7a:	00054663          	bltz	a0,80003f86 <sys_dup+0x38>
  filedup(f);
    80003f7e:	854a                	mv	a0,s2
    80003f80:	cc0ff0ef          	jal	ra,80003440 <filedup>
  return fd;
    80003f84:	87a6                	mv	a5,s1
}
    80003f86:	853e                	mv	a0,a5
    80003f88:	70a2                	ld	ra,40(sp)
    80003f8a:	7402                	ld	s0,32(sp)
    80003f8c:	64e2                	ld	s1,24(sp)
    80003f8e:	6942                	ld	s2,16(sp)
    80003f90:	6145                	addi	sp,sp,48
    80003f92:	8082                	ret

0000000080003f94 <sys_read>:
{
    80003f94:	7179                	addi	sp,sp,-48
    80003f96:	f406                	sd	ra,40(sp)
    80003f98:	f022                	sd	s0,32(sp)
    80003f9a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f9c:	fd840593          	addi	a1,s0,-40
    80003fa0:	4505                	li	a0,1
    80003fa2:	df5fd0ef          	jal	ra,80001d96 <argaddr>
  argint(2, &n);
    80003fa6:	fe440593          	addi	a1,s0,-28
    80003faa:	4509                	li	a0,2
    80003fac:	dcffd0ef          	jal	ra,80001d7a <argint>
  if(argfd(0, 0, &f) < 0)
    80003fb0:	fe840613          	addi	a2,s0,-24
    80003fb4:	4581                	li	a1,0
    80003fb6:	4501                	li	a0,0
    80003fb8:	dc3ff0ef          	jal	ra,80003d7a <argfd>
    80003fbc:	87aa                	mv	a5,a0
    return -1;
    80003fbe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003fc0:	0007ca63          	bltz	a5,80003fd4 <sys_read+0x40>
  return fileread(f, p, n);
    80003fc4:	fe442603          	lw	a2,-28(s0)
    80003fc8:	fd843583          	ld	a1,-40(s0)
    80003fcc:	fe843503          	ld	a0,-24(s0)
    80003fd0:	dbcff0ef          	jal	ra,8000358c <fileread>
}
    80003fd4:	70a2                	ld	ra,40(sp)
    80003fd6:	7402                	ld	s0,32(sp)
    80003fd8:	6145                	addi	sp,sp,48
    80003fda:	8082                	ret

0000000080003fdc <sys_write>:
{
    80003fdc:	7179                	addi	sp,sp,-48
    80003fde:	f406                	sd	ra,40(sp)
    80003fe0:	f022                	sd	s0,32(sp)
    80003fe2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003fe4:	fd840593          	addi	a1,s0,-40
    80003fe8:	4505                	li	a0,1
    80003fea:	dadfd0ef          	jal	ra,80001d96 <argaddr>
  argint(2, &n);
    80003fee:	fe440593          	addi	a1,s0,-28
    80003ff2:	4509                	li	a0,2
    80003ff4:	d87fd0ef          	jal	ra,80001d7a <argint>
  if(argfd(0, 0, &f) < 0)
    80003ff8:	fe840613          	addi	a2,s0,-24
    80003ffc:	4581                	li	a1,0
    80003ffe:	4501                	li	a0,0
    80004000:	d7bff0ef          	jal	ra,80003d7a <argfd>
    80004004:	87aa                	mv	a5,a0
    return -1;
    80004006:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004008:	0007ca63          	bltz	a5,8000401c <sys_write+0x40>
  return filewrite(f, p, n);
    8000400c:	fe442603          	lw	a2,-28(s0)
    80004010:	fd843583          	ld	a1,-40(s0)
    80004014:	fe843503          	ld	a0,-24(s0)
    80004018:	e22ff0ef          	jal	ra,8000363a <filewrite>
}
    8000401c:	70a2                	ld	ra,40(sp)
    8000401e:	7402                	ld	s0,32(sp)
    80004020:	6145                	addi	sp,sp,48
    80004022:	8082                	ret

0000000080004024 <sys_close>:
{
    80004024:	1101                	addi	sp,sp,-32
    80004026:	ec06                	sd	ra,24(sp)
    80004028:	e822                	sd	s0,16(sp)
    8000402a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000402c:	fe040613          	addi	a2,s0,-32
    80004030:	fec40593          	addi	a1,s0,-20
    80004034:	4501                	li	a0,0
    80004036:	d45ff0ef          	jal	ra,80003d7a <argfd>
    return -1;
    8000403a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000403c:	02054063          	bltz	a0,8000405c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004040:	e8dfc0ef          	jal	ra,80000ecc <myproc>
    80004044:	fec42783          	lw	a5,-20(s0)
    80004048:	07e9                	addi	a5,a5,26
    8000404a:	078e                	slli	a5,a5,0x3
    8000404c:	953e                	add	a0,a0,a5
    8000404e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004052:	fe043503          	ld	a0,-32(s0)
    80004056:	c30ff0ef          	jal	ra,80003486 <fileclose>
  return 0;
    8000405a:	4781                	li	a5,0
}
    8000405c:	853e                	mv	a0,a5
    8000405e:	60e2                	ld	ra,24(sp)
    80004060:	6442                	ld	s0,16(sp)
    80004062:	6105                	addi	sp,sp,32
    80004064:	8082                	ret

0000000080004066 <sys_fstat>:
{
    80004066:	1101                	addi	sp,sp,-32
    80004068:	ec06                	sd	ra,24(sp)
    8000406a:	e822                	sd	s0,16(sp)
    8000406c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000406e:	fe040593          	addi	a1,s0,-32
    80004072:	4505                	li	a0,1
    80004074:	d23fd0ef          	jal	ra,80001d96 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004078:	fe840613          	addi	a2,s0,-24
    8000407c:	4581                	li	a1,0
    8000407e:	4501                	li	a0,0
    80004080:	cfbff0ef          	jal	ra,80003d7a <argfd>
    80004084:	87aa                	mv	a5,a0
    return -1;
    80004086:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004088:	0007c863          	bltz	a5,80004098 <sys_fstat+0x32>
  return filestat(f, st);
    8000408c:	fe043583          	ld	a1,-32(s0)
    80004090:	fe843503          	ld	a0,-24(s0)
    80004094:	c9aff0ef          	jal	ra,8000352e <filestat>
}
    80004098:	60e2                	ld	ra,24(sp)
    8000409a:	6442                	ld	s0,16(sp)
    8000409c:	6105                	addi	sp,sp,32
    8000409e:	8082                	ret

00000000800040a0 <sys_link>:
{
    800040a0:	7169                	addi	sp,sp,-304
    800040a2:	f606                	sd	ra,296(sp)
    800040a4:	f222                	sd	s0,288(sp)
    800040a6:	ee26                	sd	s1,280(sp)
    800040a8:	ea4a                	sd	s2,272(sp)
    800040aa:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800040ac:	08000613          	li	a2,128
    800040b0:	ed040593          	addi	a1,s0,-304
    800040b4:	4501                	li	a0,0
    800040b6:	cfdfd0ef          	jal	ra,80001db2 <argstr>
    return -1;
    800040ba:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800040bc:	0c054663          	bltz	a0,80004188 <sys_link+0xe8>
    800040c0:	08000613          	li	a2,128
    800040c4:	f5040593          	addi	a1,s0,-176
    800040c8:	4505                	li	a0,1
    800040ca:	ce9fd0ef          	jal	ra,80001db2 <argstr>
    return -1;
    800040ce:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800040d0:	0a054c63          	bltz	a0,80004188 <sys_link+0xe8>
  begin_op();
    800040d4:	f9bfe0ef          	jal	ra,8000306e <begin_op>
  if((ip = namei(old)) == 0){
    800040d8:	ed040513          	addi	a0,s0,-304
    800040dc:	db7fe0ef          	jal	ra,80002e92 <namei>
    800040e0:	84aa                	mv	s1,a0
    800040e2:	c525                	beqz	a0,8000414a <sys_link+0xaa>
  ilock(ip);
    800040e4:	ef6fe0ef          	jal	ra,800027da <ilock>
  if(ip->type == T_DIR){
    800040e8:	04449703          	lh	a4,68(s1)
    800040ec:	4785                	li	a5,1
    800040ee:	06f70263          	beq	a4,a5,80004152 <sys_link+0xb2>
  ip->nlink++;
    800040f2:	04a4d783          	lhu	a5,74(s1)
    800040f6:	2785                	addiw	a5,a5,1
    800040f8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800040fc:	8526                	mv	a0,s1
    800040fe:	e28fe0ef          	jal	ra,80002726 <iupdate>
  iunlock(ip);
    80004102:	8526                	mv	a0,s1
    80004104:	f80fe0ef          	jal	ra,80002884 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004108:	fd040593          	addi	a1,s0,-48
    8000410c:	f5040513          	addi	a0,s0,-176
    80004110:	d9dfe0ef          	jal	ra,80002eac <nameiparent>
    80004114:	892a                	mv	s2,a0
    80004116:	c921                	beqz	a0,80004166 <sys_link+0xc6>
  ilock(dp);
    80004118:	ec2fe0ef          	jal	ra,800027da <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000411c:	00092703          	lw	a4,0(s2)
    80004120:	409c                	lw	a5,0(s1)
    80004122:	02f71f63          	bne	a4,a5,80004160 <sys_link+0xc0>
    80004126:	40d0                	lw	a2,4(s1)
    80004128:	fd040593          	addi	a1,s0,-48
    8000412c:	854a                	mv	a0,s2
    8000412e:	ccbfe0ef          	jal	ra,80002df8 <dirlink>
    80004132:	02054763          	bltz	a0,80004160 <sys_link+0xc0>
  iunlockput(dp);
    80004136:	854a                	mv	a0,s2
    80004138:	8a9fe0ef          	jal	ra,800029e0 <iunlockput>
  iput(ip);
    8000413c:	8526                	mv	a0,s1
    8000413e:	81bfe0ef          	jal	ra,80002958 <iput>
  end_op();
    80004142:	f9bfe0ef          	jal	ra,800030dc <end_op>
  return 0;
    80004146:	4781                	li	a5,0
    80004148:	a081                	j	80004188 <sys_link+0xe8>
    end_op();
    8000414a:	f93fe0ef          	jal	ra,800030dc <end_op>
    return -1;
    8000414e:	57fd                	li	a5,-1
    80004150:	a825                	j	80004188 <sys_link+0xe8>
    iunlockput(ip);
    80004152:	8526                	mv	a0,s1
    80004154:	88dfe0ef          	jal	ra,800029e0 <iunlockput>
    end_op();
    80004158:	f85fe0ef          	jal	ra,800030dc <end_op>
    return -1;
    8000415c:	57fd                	li	a5,-1
    8000415e:	a02d                	j	80004188 <sys_link+0xe8>
    iunlockput(dp);
    80004160:	854a                	mv	a0,s2
    80004162:	87ffe0ef          	jal	ra,800029e0 <iunlockput>
  ilock(ip);
    80004166:	8526                	mv	a0,s1
    80004168:	e72fe0ef          	jal	ra,800027da <ilock>
  ip->nlink--;
    8000416c:	04a4d783          	lhu	a5,74(s1)
    80004170:	37fd                	addiw	a5,a5,-1
    80004172:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004176:	8526                	mv	a0,s1
    80004178:	daefe0ef          	jal	ra,80002726 <iupdate>
  iunlockput(ip);
    8000417c:	8526                	mv	a0,s1
    8000417e:	863fe0ef          	jal	ra,800029e0 <iunlockput>
  end_op();
    80004182:	f5bfe0ef          	jal	ra,800030dc <end_op>
  return -1;
    80004186:	57fd                	li	a5,-1
}
    80004188:	853e                	mv	a0,a5
    8000418a:	70b2                	ld	ra,296(sp)
    8000418c:	7412                	ld	s0,288(sp)
    8000418e:	64f2                	ld	s1,280(sp)
    80004190:	6952                	ld	s2,272(sp)
    80004192:	6155                	addi	sp,sp,304
    80004194:	8082                	ret

0000000080004196 <sys_unlink>:
{
    80004196:	7151                	addi	sp,sp,-240
    80004198:	f586                	sd	ra,232(sp)
    8000419a:	f1a2                	sd	s0,224(sp)
    8000419c:	eda6                	sd	s1,216(sp)
    8000419e:	e9ca                	sd	s2,208(sp)
    800041a0:	e5ce                	sd	s3,200(sp)
    800041a2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800041a4:	08000613          	li	a2,128
    800041a8:	f3040593          	addi	a1,s0,-208
    800041ac:	4501                	li	a0,0
    800041ae:	c05fd0ef          	jal	ra,80001db2 <argstr>
    800041b2:	12054b63          	bltz	a0,800042e8 <sys_unlink+0x152>
  begin_op();
    800041b6:	eb9fe0ef          	jal	ra,8000306e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800041ba:	fb040593          	addi	a1,s0,-80
    800041be:	f3040513          	addi	a0,s0,-208
    800041c2:	cebfe0ef          	jal	ra,80002eac <nameiparent>
    800041c6:	84aa                	mv	s1,a0
    800041c8:	c54d                	beqz	a0,80004272 <sys_unlink+0xdc>
  ilock(dp);
    800041ca:	e10fe0ef          	jal	ra,800027da <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800041ce:	00003597          	auipc	a1,0x3
    800041d2:	5ca58593          	addi	a1,a1,1482 # 80007798 <syscalls+0x308>
    800041d6:	fb040513          	addi	a0,s0,-80
    800041da:	a37fe0ef          	jal	ra,80002c10 <namecmp>
    800041de:	10050a63          	beqz	a0,800042f2 <sys_unlink+0x15c>
    800041e2:	00003597          	auipc	a1,0x3
    800041e6:	5be58593          	addi	a1,a1,1470 # 800077a0 <syscalls+0x310>
    800041ea:	fb040513          	addi	a0,s0,-80
    800041ee:	a23fe0ef          	jal	ra,80002c10 <namecmp>
    800041f2:	10050063          	beqz	a0,800042f2 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800041f6:	f2c40613          	addi	a2,s0,-212
    800041fa:	fb040593          	addi	a1,s0,-80
    800041fe:	8526                	mv	a0,s1
    80004200:	a27fe0ef          	jal	ra,80002c26 <dirlookup>
    80004204:	892a                	mv	s2,a0
    80004206:	0e050663          	beqz	a0,800042f2 <sys_unlink+0x15c>
  ilock(ip);
    8000420a:	dd0fe0ef          	jal	ra,800027da <ilock>
  if(ip->nlink < 1)
    8000420e:	04a91783          	lh	a5,74(s2)
    80004212:	06f05463          	blez	a5,8000427a <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004216:	04491703          	lh	a4,68(s2)
    8000421a:	4785                	li	a5,1
    8000421c:	06f70563          	beq	a4,a5,80004286 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004220:	4641                	li	a2,16
    80004222:	4581                	li	a1,0
    80004224:	fc040513          	addi	a0,s0,-64
    80004228:	fb9fb0ef          	jal	ra,800001e0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000422c:	4741                	li	a4,16
    8000422e:	f2c42683          	lw	a3,-212(s0)
    80004232:	fc040613          	addi	a2,s0,-64
    80004236:	4581                	li	a1,0
    80004238:	8526                	mv	a0,s1
    8000423a:	8d5fe0ef          	jal	ra,80002b0e <writei>
    8000423e:	47c1                	li	a5,16
    80004240:	08f51563          	bne	a0,a5,800042ca <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004244:	04491703          	lh	a4,68(s2)
    80004248:	4785                	li	a5,1
    8000424a:	08f70663          	beq	a4,a5,800042d6 <sys_unlink+0x140>
  iunlockput(dp);
    8000424e:	8526                	mv	a0,s1
    80004250:	f90fe0ef          	jal	ra,800029e0 <iunlockput>
  ip->nlink--;
    80004254:	04a95783          	lhu	a5,74(s2)
    80004258:	37fd                	addiw	a5,a5,-1
    8000425a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000425e:	854a                	mv	a0,s2
    80004260:	cc6fe0ef          	jal	ra,80002726 <iupdate>
  iunlockput(ip);
    80004264:	854a                	mv	a0,s2
    80004266:	f7afe0ef          	jal	ra,800029e0 <iunlockput>
  end_op();
    8000426a:	e73fe0ef          	jal	ra,800030dc <end_op>
  return 0;
    8000426e:	4501                	li	a0,0
    80004270:	a079                	j	800042fe <sys_unlink+0x168>
    end_op();
    80004272:	e6bfe0ef          	jal	ra,800030dc <end_op>
    return -1;
    80004276:	557d                	li	a0,-1
    80004278:	a059                	j	800042fe <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000427a:	00003517          	auipc	a0,0x3
    8000427e:	52e50513          	addi	a0,a0,1326 # 800077a8 <syscalls+0x318>
    80004282:	1d0010ef          	jal	ra,80005452 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004286:	04c92703          	lw	a4,76(s2)
    8000428a:	02000793          	li	a5,32
    8000428e:	f8e7f9e3          	bgeu	a5,a4,80004220 <sys_unlink+0x8a>
    80004292:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004296:	4741                	li	a4,16
    80004298:	86ce                	mv	a3,s3
    8000429a:	f1840613          	addi	a2,s0,-232
    8000429e:	4581                	li	a1,0
    800042a0:	854a                	mv	a0,s2
    800042a2:	f88fe0ef          	jal	ra,80002a2a <readi>
    800042a6:	47c1                	li	a5,16
    800042a8:	00f51b63          	bne	a0,a5,800042be <sys_unlink+0x128>
    if(de.inum != 0)
    800042ac:	f1845783          	lhu	a5,-232(s0)
    800042b0:	ef95                	bnez	a5,800042ec <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800042b2:	29c1                	addiw	s3,s3,16
    800042b4:	04c92783          	lw	a5,76(s2)
    800042b8:	fcf9efe3          	bltu	s3,a5,80004296 <sys_unlink+0x100>
    800042bc:	b795                	j	80004220 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800042be:	00003517          	auipc	a0,0x3
    800042c2:	50250513          	addi	a0,a0,1282 # 800077c0 <syscalls+0x330>
    800042c6:	18c010ef          	jal	ra,80005452 <panic>
    panic("unlink: writei");
    800042ca:	00003517          	auipc	a0,0x3
    800042ce:	50e50513          	addi	a0,a0,1294 # 800077d8 <syscalls+0x348>
    800042d2:	180010ef          	jal	ra,80005452 <panic>
    dp->nlink--;
    800042d6:	04a4d783          	lhu	a5,74(s1)
    800042da:	37fd                	addiw	a5,a5,-1
    800042dc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800042e0:	8526                	mv	a0,s1
    800042e2:	c44fe0ef          	jal	ra,80002726 <iupdate>
    800042e6:	b7a5                	j	8000424e <sys_unlink+0xb8>
    return -1;
    800042e8:	557d                	li	a0,-1
    800042ea:	a811                	j	800042fe <sys_unlink+0x168>
    iunlockput(ip);
    800042ec:	854a                	mv	a0,s2
    800042ee:	ef2fe0ef          	jal	ra,800029e0 <iunlockput>
  iunlockput(dp);
    800042f2:	8526                	mv	a0,s1
    800042f4:	eecfe0ef          	jal	ra,800029e0 <iunlockput>
  end_op();
    800042f8:	de5fe0ef          	jal	ra,800030dc <end_op>
  return -1;
    800042fc:	557d                	li	a0,-1
}
    800042fe:	70ae                	ld	ra,232(sp)
    80004300:	740e                	ld	s0,224(sp)
    80004302:	64ee                	ld	s1,216(sp)
    80004304:	694e                	ld	s2,208(sp)
    80004306:	69ae                	ld	s3,200(sp)
    80004308:	616d                	addi	sp,sp,240
    8000430a:	8082                	ret

000000008000430c <sys_open>:

uint64
sys_open(void)
{
    8000430c:	7131                	addi	sp,sp,-192
    8000430e:	fd06                	sd	ra,184(sp)
    80004310:	f922                	sd	s0,176(sp)
    80004312:	f526                	sd	s1,168(sp)
    80004314:	f14a                	sd	s2,160(sp)
    80004316:	ed4e                	sd	s3,152(sp)
    80004318:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000431a:	f4c40593          	addi	a1,s0,-180
    8000431e:	4505                	li	a0,1
    80004320:	a5bfd0ef          	jal	ra,80001d7a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004324:	08000613          	li	a2,128
    80004328:	f5040593          	addi	a1,s0,-176
    8000432c:	4501                	li	a0,0
    8000432e:	a85fd0ef          	jal	ra,80001db2 <argstr>
    80004332:	87aa                	mv	a5,a0
    return -1;
    80004334:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004336:	0807cd63          	bltz	a5,800043d0 <sys_open+0xc4>

  begin_op();
    8000433a:	d35fe0ef          	jal	ra,8000306e <begin_op>

  if(omode & O_CREATE){
    8000433e:	f4c42783          	lw	a5,-180(s0)
    80004342:	2007f793          	andi	a5,a5,512
    80004346:	c3c5                	beqz	a5,800043e6 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004348:	4681                	li	a3,0
    8000434a:	4601                	li	a2,0
    8000434c:	4589                	li	a1,2
    8000434e:	f5040513          	addi	a0,s0,-176
    80004352:	abfff0ef          	jal	ra,80003e10 <create>
    80004356:	84aa                	mv	s1,a0
    if(ip == 0){
    80004358:	c159                	beqz	a0,800043de <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000435a:	04449703          	lh	a4,68(s1)
    8000435e:	478d                	li	a5,3
    80004360:	00f71763          	bne	a4,a5,8000436e <sys_open+0x62>
    80004364:	0464d703          	lhu	a4,70(s1)
    80004368:	47a5                	li	a5,9
    8000436a:	0ae7e963          	bltu	a5,a4,8000441c <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000436e:	874ff0ef          	jal	ra,800033e2 <filealloc>
    80004372:	89aa                	mv	s3,a0
    80004374:	0c050963          	beqz	a0,80004446 <sys_open+0x13a>
    80004378:	a5bff0ef          	jal	ra,80003dd2 <fdalloc>
    8000437c:	892a                	mv	s2,a0
    8000437e:	0c054163          	bltz	a0,80004440 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004382:	04449703          	lh	a4,68(s1)
    80004386:	478d                	li	a5,3
    80004388:	0af70163          	beq	a4,a5,8000442a <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000438c:	4789                	li	a5,2
    8000438e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004392:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004396:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000439a:	f4c42783          	lw	a5,-180(s0)
    8000439e:	0017c713          	xori	a4,a5,1
    800043a2:	8b05                	andi	a4,a4,1
    800043a4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800043a8:	0037f713          	andi	a4,a5,3
    800043ac:	00e03733          	snez	a4,a4
    800043b0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800043b4:	4007f793          	andi	a5,a5,1024
    800043b8:	c791                	beqz	a5,800043c4 <sys_open+0xb8>
    800043ba:	04449703          	lh	a4,68(s1)
    800043be:	4789                	li	a5,2
    800043c0:	06f70c63          	beq	a4,a5,80004438 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    800043c4:	8526                	mv	a0,s1
    800043c6:	cbefe0ef          	jal	ra,80002884 <iunlock>
  end_op();
    800043ca:	d13fe0ef          	jal	ra,800030dc <end_op>

  return fd;
    800043ce:	854a                	mv	a0,s2
}
    800043d0:	70ea                	ld	ra,184(sp)
    800043d2:	744a                	ld	s0,176(sp)
    800043d4:	74aa                	ld	s1,168(sp)
    800043d6:	790a                	ld	s2,160(sp)
    800043d8:	69ea                	ld	s3,152(sp)
    800043da:	6129                	addi	sp,sp,192
    800043dc:	8082                	ret
      end_op();
    800043de:	cfffe0ef          	jal	ra,800030dc <end_op>
      return -1;
    800043e2:	557d                	li	a0,-1
    800043e4:	b7f5                	j	800043d0 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    800043e6:	f5040513          	addi	a0,s0,-176
    800043ea:	aa9fe0ef          	jal	ra,80002e92 <namei>
    800043ee:	84aa                	mv	s1,a0
    800043f0:	c115                	beqz	a0,80004414 <sys_open+0x108>
    ilock(ip);
    800043f2:	be8fe0ef          	jal	ra,800027da <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800043f6:	04449703          	lh	a4,68(s1)
    800043fa:	4785                	li	a5,1
    800043fc:	f4f71fe3          	bne	a4,a5,8000435a <sys_open+0x4e>
    80004400:	f4c42783          	lw	a5,-180(s0)
    80004404:	d7ad                	beqz	a5,8000436e <sys_open+0x62>
      iunlockput(ip);
    80004406:	8526                	mv	a0,s1
    80004408:	dd8fe0ef          	jal	ra,800029e0 <iunlockput>
      end_op();
    8000440c:	cd1fe0ef          	jal	ra,800030dc <end_op>
      return -1;
    80004410:	557d                	li	a0,-1
    80004412:	bf7d                	j	800043d0 <sys_open+0xc4>
      end_op();
    80004414:	cc9fe0ef          	jal	ra,800030dc <end_op>
      return -1;
    80004418:	557d                	li	a0,-1
    8000441a:	bf5d                	j	800043d0 <sys_open+0xc4>
    iunlockput(ip);
    8000441c:	8526                	mv	a0,s1
    8000441e:	dc2fe0ef          	jal	ra,800029e0 <iunlockput>
    end_op();
    80004422:	cbbfe0ef          	jal	ra,800030dc <end_op>
    return -1;
    80004426:	557d                	li	a0,-1
    80004428:	b765                	j	800043d0 <sys_open+0xc4>
    f->type = FD_DEVICE;
    8000442a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000442e:	04649783          	lh	a5,70(s1)
    80004432:	02f99223          	sh	a5,36(s3)
    80004436:	b785                	j	80004396 <sys_open+0x8a>
    itrunc(ip);
    80004438:	8526                	mv	a0,s1
    8000443a:	c8afe0ef          	jal	ra,800028c4 <itrunc>
    8000443e:	b759                	j	800043c4 <sys_open+0xb8>
      fileclose(f);
    80004440:	854e                	mv	a0,s3
    80004442:	844ff0ef          	jal	ra,80003486 <fileclose>
    iunlockput(ip);
    80004446:	8526                	mv	a0,s1
    80004448:	d98fe0ef          	jal	ra,800029e0 <iunlockput>
    end_op();
    8000444c:	c91fe0ef          	jal	ra,800030dc <end_op>
    return -1;
    80004450:	557d                	li	a0,-1
    80004452:	bfbd                	j	800043d0 <sys_open+0xc4>

0000000080004454 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004454:	7175                	addi	sp,sp,-144
    80004456:	e506                	sd	ra,136(sp)
    80004458:	e122                	sd	s0,128(sp)
    8000445a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000445c:	c13fe0ef          	jal	ra,8000306e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004460:	08000613          	li	a2,128
    80004464:	f7040593          	addi	a1,s0,-144
    80004468:	4501                	li	a0,0
    8000446a:	949fd0ef          	jal	ra,80001db2 <argstr>
    8000446e:	02054363          	bltz	a0,80004494 <sys_mkdir+0x40>
    80004472:	4681                	li	a3,0
    80004474:	4601                	li	a2,0
    80004476:	4585                	li	a1,1
    80004478:	f7040513          	addi	a0,s0,-144
    8000447c:	995ff0ef          	jal	ra,80003e10 <create>
    80004480:	c911                	beqz	a0,80004494 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004482:	d5efe0ef          	jal	ra,800029e0 <iunlockput>
  end_op();
    80004486:	c57fe0ef          	jal	ra,800030dc <end_op>
  return 0;
    8000448a:	4501                	li	a0,0
}
    8000448c:	60aa                	ld	ra,136(sp)
    8000448e:	640a                	ld	s0,128(sp)
    80004490:	6149                	addi	sp,sp,144
    80004492:	8082                	ret
    end_op();
    80004494:	c49fe0ef          	jal	ra,800030dc <end_op>
    return -1;
    80004498:	557d                	li	a0,-1
    8000449a:	bfcd                	j	8000448c <sys_mkdir+0x38>

000000008000449c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000449c:	7135                	addi	sp,sp,-160
    8000449e:	ed06                	sd	ra,152(sp)
    800044a0:	e922                	sd	s0,144(sp)
    800044a2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800044a4:	bcbfe0ef          	jal	ra,8000306e <begin_op>
  argint(1, &major);
    800044a8:	f6c40593          	addi	a1,s0,-148
    800044ac:	4505                	li	a0,1
    800044ae:	8cdfd0ef          	jal	ra,80001d7a <argint>
  argint(2, &minor);
    800044b2:	f6840593          	addi	a1,s0,-152
    800044b6:	4509                	li	a0,2
    800044b8:	8c3fd0ef          	jal	ra,80001d7a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800044bc:	08000613          	li	a2,128
    800044c0:	f7040593          	addi	a1,s0,-144
    800044c4:	4501                	li	a0,0
    800044c6:	8edfd0ef          	jal	ra,80001db2 <argstr>
    800044ca:	02054563          	bltz	a0,800044f4 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800044ce:	f6841683          	lh	a3,-152(s0)
    800044d2:	f6c41603          	lh	a2,-148(s0)
    800044d6:	458d                	li	a1,3
    800044d8:	f7040513          	addi	a0,s0,-144
    800044dc:	935ff0ef          	jal	ra,80003e10 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800044e0:	c911                	beqz	a0,800044f4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800044e2:	cfefe0ef          	jal	ra,800029e0 <iunlockput>
  end_op();
    800044e6:	bf7fe0ef          	jal	ra,800030dc <end_op>
  return 0;
    800044ea:	4501                	li	a0,0
}
    800044ec:	60ea                	ld	ra,152(sp)
    800044ee:	644a                	ld	s0,144(sp)
    800044f0:	610d                	addi	sp,sp,160
    800044f2:	8082                	ret
    end_op();
    800044f4:	be9fe0ef          	jal	ra,800030dc <end_op>
    return -1;
    800044f8:	557d                	li	a0,-1
    800044fa:	bfcd                	j	800044ec <sys_mknod+0x50>

00000000800044fc <sys_chdir>:

uint64
sys_chdir(void)
{
    800044fc:	7135                	addi	sp,sp,-160
    800044fe:	ed06                	sd	ra,152(sp)
    80004500:	e922                	sd	s0,144(sp)
    80004502:	e526                	sd	s1,136(sp)
    80004504:	e14a                	sd	s2,128(sp)
    80004506:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004508:	9c5fc0ef          	jal	ra,80000ecc <myproc>
    8000450c:	892a                	mv	s2,a0

  begin_op();
    8000450e:	b61fe0ef          	jal	ra,8000306e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004512:	08000613          	li	a2,128
    80004516:	f6040593          	addi	a1,s0,-160
    8000451a:	4501                	li	a0,0
    8000451c:	897fd0ef          	jal	ra,80001db2 <argstr>
    80004520:	04054163          	bltz	a0,80004562 <sys_chdir+0x66>
    80004524:	f6040513          	addi	a0,s0,-160
    80004528:	96bfe0ef          	jal	ra,80002e92 <namei>
    8000452c:	84aa                	mv	s1,a0
    8000452e:	c915                	beqz	a0,80004562 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004530:	aaafe0ef          	jal	ra,800027da <ilock>
  if(ip->type != T_DIR){
    80004534:	04449703          	lh	a4,68(s1)
    80004538:	4785                	li	a5,1
    8000453a:	02f71863          	bne	a4,a5,8000456a <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000453e:	8526                	mv	a0,s1
    80004540:	b44fe0ef          	jal	ra,80002884 <iunlock>
  iput(p->cwd);
    80004544:	15093503          	ld	a0,336(s2)
    80004548:	c10fe0ef          	jal	ra,80002958 <iput>
  end_op();
    8000454c:	b91fe0ef          	jal	ra,800030dc <end_op>
  p->cwd = ip;
    80004550:	14993823          	sd	s1,336(s2)
  return 0;
    80004554:	4501                	li	a0,0
}
    80004556:	60ea                	ld	ra,152(sp)
    80004558:	644a                	ld	s0,144(sp)
    8000455a:	64aa                	ld	s1,136(sp)
    8000455c:	690a                	ld	s2,128(sp)
    8000455e:	610d                	addi	sp,sp,160
    80004560:	8082                	ret
    end_op();
    80004562:	b7bfe0ef          	jal	ra,800030dc <end_op>
    return -1;
    80004566:	557d                	li	a0,-1
    80004568:	b7fd                	j	80004556 <sys_chdir+0x5a>
    iunlockput(ip);
    8000456a:	8526                	mv	a0,s1
    8000456c:	c74fe0ef          	jal	ra,800029e0 <iunlockput>
    end_op();
    80004570:	b6dfe0ef          	jal	ra,800030dc <end_op>
    return -1;
    80004574:	557d                	li	a0,-1
    80004576:	b7c5                	j	80004556 <sys_chdir+0x5a>

0000000080004578 <sys_exec>:

uint64
sys_exec(void)
{
    80004578:	7145                	addi	sp,sp,-464
    8000457a:	e786                	sd	ra,456(sp)
    8000457c:	e3a2                	sd	s0,448(sp)
    8000457e:	ff26                	sd	s1,440(sp)
    80004580:	fb4a                	sd	s2,432(sp)
    80004582:	f74e                	sd	s3,424(sp)
    80004584:	f352                	sd	s4,416(sp)
    80004586:	ef56                	sd	s5,408(sp)
    80004588:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000458a:	e3840593          	addi	a1,s0,-456
    8000458e:	4505                	li	a0,1
    80004590:	807fd0ef          	jal	ra,80001d96 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004594:	08000613          	li	a2,128
    80004598:	f4040593          	addi	a1,s0,-192
    8000459c:	4501                	li	a0,0
    8000459e:	815fd0ef          	jal	ra,80001db2 <argstr>
    800045a2:	87aa                	mv	a5,a0
    return -1;
    800045a4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800045a6:	0a07c563          	bltz	a5,80004650 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    800045aa:	10000613          	li	a2,256
    800045ae:	4581                	li	a1,0
    800045b0:	e4040513          	addi	a0,s0,-448
    800045b4:	c2dfb0ef          	jal	ra,800001e0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800045b8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800045bc:	89a6                	mv	s3,s1
    800045be:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800045c0:	02000a13          	li	s4,32
    800045c4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800045c8:	00391513          	slli	a0,s2,0x3
    800045cc:	e3040593          	addi	a1,s0,-464
    800045d0:	e3843783          	ld	a5,-456(s0)
    800045d4:	953e                	add	a0,a0,a5
    800045d6:	f1afd0ef          	jal	ra,80001cf0 <fetchaddr>
    800045da:	02054663          	bltz	a0,80004606 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800045de:	e3043783          	ld	a5,-464(s0)
    800045e2:	cf8d                	beqz	a5,8000461c <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800045e4:	ba3fb0ef          	jal	ra,80000186 <kalloc>
    800045e8:	85aa                	mv	a1,a0
    800045ea:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800045ee:	cd01                	beqz	a0,80004606 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800045f0:	6605                	lui	a2,0x1
    800045f2:	e3043503          	ld	a0,-464(s0)
    800045f6:	f44fd0ef          	jal	ra,80001d3a <fetchstr>
    800045fa:	00054663          	bltz	a0,80004606 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800045fe:	0905                	addi	s2,s2,1
    80004600:	09a1                	addi	s3,s3,8
    80004602:	fd4911e3          	bne	s2,s4,800045c4 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004606:	f4040913          	addi	s2,s0,-192
    8000460a:	6088                	ld	a0,0(s1)
    8000460c:	c129                	beqz	a0,8000464e <sys_exec+0xd6>
    kfree(argv[i]);
    8000460e:	a85fb0ef          	jal	ra,80000092 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004612:	04a1                	addi	s1,s1,8
    80004614:	ff249be3          	bne	s1,s2,8000460a <sys_exec+0x92>
  return -1;
    80004618:	557d                	li	a0,-1
    8000461a:	a81d                	j	80004650 <sys_exec+0xd8>
      argv[i] = 0;
    8000461c:	0a8e                	slli	s5,s5,0x3
    8000461e:	fc0a8793          	addi	a5,s5,-64
    80004622:	00878ab3          	add	s5,a5,s0
    80004626:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000462a:	e4040593          	addi	a1,s0,-448
    8000462e:	f4040513          	addi	a0,s0,-192
    80004632:	bf6ff0ef          	jal	ra,80003a28 <exec>
    80004636:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004638:	f4040993          	addi	s3,s0,-192
    8000463c:	6088                	ld	a0,0(s1)
    8000463e:	c511                	beqz	a0,8000464a <sys_exec+0xd2>
    kfree(argv[i]);
    80004640:	a53fb0ef          	jal	ra,80000092 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004644:	04a1                	addi	s1,s1,8
    80004646:	ff349be3          	bne	s1,s3,8000463c <sys_exec+0xc4>
  return ret;
    8000464a:	854a                	mv	a0,s2
    8000464c:	a011                	j	80004650 <sys_exec+0xd8>
  return -1;
    8000464e:	557d                	li	a0,-1
}
    80004650:	60be                	ld	ra,456(sp)
    80004652:	641e                	ld	s0,448(sp)
    80004654:	74fa                	ld	s1,440(sp)
    80004656:	795a                	ld	s2,432(sp)
    80004658:	79ba                	ld	s3,424(sp)
    8000465a:	7a1a                	ld	s4,416(sp)
    8000465c:	6afa                	ld	s5,408(sp)
    8000465e:	6179                	addi	sp,sp,464
    80004660:	8082                	ret

0000000080004662 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004662:	7139                	addi	sp,sp,-64
    80004664:	fc06                	sd	ra,56(sp)
    80004666:	f822                	sd	s0,48(sp)
    80004668:	f426                	sd	s1,40(sp)
    8000466a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000466c:	861fc0ef          	jal	ra,80000ecc <myproc>
    80004670:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004672:	fd840593          	addi	a1,s0,-40
    80004676:	4501                	li	a0,0
    80004678:	f1efd0ef          	jal	ra,80001d96 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000467c:	fc840593          	addi	a1,s0,-56
    80004680:	fd040513          	addi	a0,s0,-48
    80004684:	8ceff0ef          	jal	ra,80003752 <pipealloc>
    return -1;
    80004688:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000468a:	0a054463          	bltz	a0,80004732 <sys_pipe+0xd0>
  fd0 = -1;
    8000468e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004692:	fd043503          	ld	a0,-48(s0)
    80004696:	f3cff0ef          	jal	ra,80003dd2 <fdalloc>
    8000469a:	fca42223          	sw	a0,-60(s0)
    8000469e:	08054163          	bltz	a0,80004720 <sys_pipe+0xbe>
    800046a2:	fc843503          	ld	a0,-56(s0)
    800046a6:	f2cff0ef          	jal	ra,80003dd2 <fdalloc>
    800046aa:	fca42023          	sw	a0,-64(s0)
    800046ae:	06054063          	bltz	a0,8000470e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800046b2:	4691                	li	a3,4
    800046b4:	fc440613          	addi	a2,s0,-60
    800046b8:	fd843583          	ld	a1,-40(s0)
    800046bc:	68a8                	ld	a0,80(s1)
    800046be:	bb2fc0ef          	jal	ra,80000a70 <copyout>
    800046c2:	00054e63          	bltz	a0,800046de <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800046c6:	4691                	li	a3,4
    800046c8:	fc040613          	addi	a2,s0,-64
    800046cc:	fd843583          	ld	a1,-40(s0)
    800046d0:	0591                	addi	a1,a1,4
    800046d2:	68a8                	ld	a0,80(s1)
    800046d4:	b9cfc0ef          	jal	ra,80000a70 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800046d8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800046da:	04055c63          	bgez	a0,80004732 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800046de:	fc442783          	lw	a5,-60(s0)
    800046e2:	07e9                	addi	a5,a5,26
    800046e4:	078e                	slli	a5,a5,0x3
    800046e6:	97a6                	add	a5,a5,s1
    800046e8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800046ec:	fc042783          	lw	a5,-64(s0)
    800046f0:	07e9                	addi	a5,a5,26
    800046f2:	078e                	slli	a5,a5,0x3
    800046f4:	94be                	add	s1,s1,a5
    800046f6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800046fa:	fd043503          	ld	a0,-48(s0)
    800046fe:	d89fe0ef          	jal	ra,80003486 <fileclose>
    fileclose(wf);
    80004702:	fc843503          	ld	a0,-56(s0)
    80004706:	d81fe0ef          	jal	ra,80003486 <fileclose>
    return -1;
    8000470a:	57fd                	li	a5,-1
    8000470c:	a01d                	j	80004732 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000470e:	fc442783          	lw	a5,-60(s0)
    80004712:	0007c763          	bltz	a5,80004720 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80004716:	07e9                	addi	a5,a5,26
    80004718:	078e                	slli	a5,a5,0x3
    8000471a:	97a6                	add	a5,a5,s1
    8000471c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80004720:	fd043503          	ld	a0,-48(s0)
    80004724:	d63fe0ef          	jal	ra,80003486 <fileclose>
    fileclose(wf);
    80004728:	fc843503          	ld	a0,-56(s0)
    8000472c:	d5bfe0ef          	jal	ra,80003486 <fileclose>
    return -1;
    80004730:	57fd                	li	a5,-1
}
    80004732:	853e                	mv	a0,a5
    80004734:	70e2                	ld	ra,56(sp)
    80004736:	7442                	ld	s0,48(sp)
    80004738:	74a2                	ld	s1,40(sp)
    8000473a:	6121                	addi	sp,sp,64
    8000473c:	8082                	ret
	...

0000000080004740 <kernelvec>:
    80004740:	7111                	addi	sp,sp,-256
    80004742:	e006                	sd	ra,0(sp)
    80004744:	e40a                	sd	sp,8(sp)
    80004746:	e80e                	sd	gp,16(sp)
    80004748:	ec12                	sd	tp,24(sp)
    8000474a:	f016                	sd	t0,32(sp)
    8000474c:	f41a                	sd	t1,40(sp)
    8000474e:	f81e                	sd	t2,48(sp)
    80004750:	e4aa                	sd	a0,72(sp)
    80004752:	e8ae                	sd	a1,80(sp)
    80004754:	ecb2                	sd	a2,88(sp)
    80004756:	f0b6                	sd	a3,96(sp)
    80004758:	f4ba                	sd	a4,104(sp)
    8000475a:	f8be                	sd	a5,112(sp)
    8000475c:	fcc2                	sd	a6,120(sp)
    8000475e:	e146                	sd	a7,128(sp)
    80004760:	edf2                	sd	t3,216(sp)
    80004762:	f1f6                	sd	t4,224(sp)
    80004764:	f5fa                	sd	t5,232(sp)
    80004766:	f9fe                	sd	t6,240(sp)
    80004768:	c98fd0ef          	jal	ra,80001c00 <kerneltrap>
    8000476c:	6082                	ld	ra,0(sp)
    8000476e:	6122                	ld	sp,8(sp)
    80004770:	61c2                	ld	gp,16(sp)
    80004772:	7282                	ld	t0,32(sp)
    80004774:	7322                	ld	t1,40(sp)
    80004776:	73c2                	ld	t2,48(sp)
    80004778:	6526                	ld	a0,72(sp)
    8000477a:	65c6                	ld	a1,80(sp)
    8000477c:	6666                	ld	a2,88(sp)
    8000477e:	7686                	ld	a3,96(sp)
    80004780:	7726                	ld	a4,104(sp)
    80004782:	77c6                	ld	a5,112(sp)
    80004784:	7866                	ld	a6,120(sp)
    80004786:	688a                	ld	a7,128(sp)
    80004788:	6e6e                	ld	t3,216(sp)
    8000478a:	7e8e                	ld	t4,224(sp)
    8000478c:	7f2e                	ld	t5,232(sp)
    8000478e:	7fce                	ld	t6,240(sp)
    80004790:	6111                	addi	sp,sp,256
    80004792:	10200073          	sret
	...

000000008000479e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000479e:	1141                	addi	sp,sp,-16
    800047a0:	e422                	sd	s0,8(sp)
    800047a2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800047a4:	0c0007b7          	lui	a5,0xc000
    800047a8:	4705                	li	a4,1
    800047aa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800047ac:	c3d8                	sw	a4,4(a5)
}
    800047ae:	6422                	ld	s0,8(sp)
    800047b0:	0141                	addi	sp,sp,16
    800047b2:	8082                	ret

00000000800047b4 <plicinithart>:

void
plicinithart(void)
{
    800047b4:	1141                	addi	sp,sp,-16
    800047b6:	e406                	sd	ra,8(sp)
    800047b8:	e022                	sd	s0,0(sp)
    800047ba:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800047bc:	ee4fc0ef          	jal	ra,80000ea0 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800047c0:	0085171b          	slliw	a4,a0,0x8
    800047c4:	0c0027b7          	lui	a5,0xc002
    800047c8:	97ba                	add	a5,a5,a4
    800047ca:	40200713          	li	a4,1026
    800047ce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800047d2:	00d5151b          	slliw	a0,a0,0xd
    800047d6:	0c2017b7          	lui	a5,0xc201
    800047da:	97aa                	add	a5,a5,a0
    800047dc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800047e0:	60a2                	ld	ra,8(sp)
    800047e2:	6402                	ld	s0,0(sp)
    800047e4:	0141                	addi	sp,sp,16
    800047e6:	8082                	ret

00000000800047e8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800047e8:	1141                	addi	sp,sp,-16
    800047ea:	e406                	sd	ra,8(sp)
    800047ec:	e022                	sd	s0,0(sp)
    800047ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800047f0:	eb0fc0ef          	jal	ra,80000ea0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800047f4:	00d5151b          	slliw	a0,a0,0xd
    800047f8:	0c2017b7          	lui	a5,0xc201
    800047fc:	97aa                	add	a5,a5,a0
  return irq;
}
    800047fe:	43c8                	lw	a0,4(a5)
    80004800:	60a2                	ld	ra,8(sp)
    80004802:	6402                	ld	s0,0(sp)
    80004804:	0141                	addi	sp,sp,16
    80004806:	8082                	ret

0000000080004808 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004808:	1101                	addi	sp,sp,-32
    8000480a:	ec06                	sd	ra,24(sp)
    8000480c:	e822                	sd	s0,16(sp)
    8000480e:	e426                	sd	s1,8(sp)
    80004810:	1000                	addi	s0,sp,32
    80004812:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004814:	e8cfc0ef          	jal	ra,80000ea0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80004818:	00d5151b          	slliw	a0,a0,0xd
    8000481c:	0c2017b7          	lui	a5,0xc201
    80004820:	97aa                	add	a5,a5,a0
    80004822:	c3c4                	sw	s1,4(a5)
}
    80004824:	60e2                	ld	ra,24(sp)
    80004826:	6442                	ld	s0,16(sp)
    80004828:	64a2                	ld	s1,8(sp)
    8000482a:	6105                	addi	sp,sp,32
    8000482c:	8082                	ret

000000008000482e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000482e:	1141                	addi	sp,sp,-16
    80004830:	e406                	sd	ra,8(sp)
    80004832:	e022                	sd	s0,0(sp)
    80004834:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80004836:	479d                	li	a5,7
    80004838:	04a7ca63          	blt	a5,a0,8000488c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000483c:	00014797          	auipc	a5,0x14
    80004840:	4b478793          	addi	a5,a5,1204 # 80018cf0 <disk>
    80004844:	97aa                	add	a5,a5,a0
    80004846:	0187c783          	lbu	a5,24(a5)
    8000484a:	e7b9                	bnez	a5,80004898 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000484c:	00451693          	slli	a3,a0,0x4
    80004850:	00014797          	auipc	a5,0x14
    80004854:	4a078793          	addi	a5,a5,1184 # 80018cf0 <disk>
    80004858:	6398                	ld	a4,0(a5)
    8000485a:	9736                	add	a4,a4,a3
    8000485c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004860:	6398                	ld	a4,0(a5)
    80004862:	9736                	add	a4,a4,a3
    80004864:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004868:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000486c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004870:	97aa                	add	a5,a5,a0
    80004872:	4705                	li	a4,1
    80004874:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004878:	00014517          	auipc	a0,0x14
    8000487c:	49050513          	addi	a0,a0,1168 # 80018d08 <disk+0x18>
    80004880:	c65fc0ef          	jal	ra,800014e4 <wakeup>
}
    80004884:	60a2                	ld	ra,8(sp)
    80004886:	6402                	ld	s0,0(sp)
    80004888:	0141                	addi	sp,sp,16
    8000488a:	8082                	ret
    panic("free_desc 1");
    8000488c:	00003517          	auipc	a0,0x3
    80004890:	f5c50513          	addi	a0,a0,-164 # 800077e8 <syscalls+0x358>
    80004894:	3bf000ef          	jal	ra,80005452 <panic>
    panic("free_desc 2");
    80004898:	00003517          	auipc	a0,0x3
    8000489c:	f6050513          	addi	a0,a0,-160 # 800077f8 <syscalls+0x368>
    800048a0:	3b3000ef          	jal	ra,80005452 <panic>

00000000800048a4 <virtio_disk_init>:
{
    800048a4:	1101                	addi	sp,sp,-32
    800048a6:	ec06                	sd	ra,24(sp)
    800048a8:	e822                	sd	s0,16(sp)
    800048aa:	e426                	sd	s1,8(sp)
    800048ac:	e04a                	sd	s2,0(sp)
    800048ae:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800048b0:	00003597          	auipc	a1,0x3
    800048b4:	f5858593          	addi	a1,a1,-168 # 80007808 <syscalls+0x378>
    800048b8:	00014517          	auipc	a0,0x14
    800048bc:	56050513          	addi	a0,a0,1376 # 80018e18 <disk+0x128>
    800048c0:	623000ef          	jal	ra,800056e2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800048c4:	100017b7          	lui	a5,0x10001
    800048c8:	4398                	lw	a4,0(a5)
    800048ca:	2701                	sext.w	a4,a4
    800048cc:	747277b7          	lui	a5,0x74727
    800048d0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800048d4:	12f71f63          	bne	a4,a5,80004a12 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800048d8:	100017b7          	lui	a5,0x10001
    800048dc:	43dc                	lw	a5,4(a5)
    800048de:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800048e0:	4709                	li	a4,2
    800048e2:	12e79863          	bne	a5,a4,80004a12 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800048e6:	100017b7          	lui	a5,0x10001
    800048ea:	479c                	lw	a5,8(a5)
    800048ec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800048ee:	12e79263          	bne	a5,a4,80004a12 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800048f2:	100017b7          	lui	a5,0x10001
    800048f6:	47d8                	lw	a4,12(a5)
    800048f8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800048fa:	554d47b7          	lui	a5,0x554d4
    800048fe:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004902:	10f71863          	bne	a4,a5,80004a12 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004906:	100017b7          	lui	a5,0x10001
    8000490a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000490e:	4705                	li	a4,1
    80004910:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004912:	470d                	li	a4,3
    80004914:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004916:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004918:	c7ffe6b7          	lui	a3,0xc7ffe
    8000491c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd82f>
    80004920:	8f75                	and	a4,a4,a3
    80004922:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004924:	472d                	li	a4,11
    80004926:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80004928:	5bbc                	lw	a5,112(a5)
    8000492a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000492e:	8ba1                	andi	a5,a5,8
    80004930:	0e078763          	beqz	a5,80004a1e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004934:	100017b7          	lui	a5,0x10001
    80004938:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000493c:	43fc                	lw	a5,68(a5)
    8000493e:	2781                	sext.w	a5,a5
    80004940:	0e079563          	bnez	a5,80004a2a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004944:	100017b7          	lui	a5,0x10001
    80004948:	5bdc                	lw	a5,52(a5)
    8000494a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000494c:	0e078563          	beqz	a5,80004a36 <virtio_disk_init+0x192>
  if(max < NUM)
    80004950:	471d                	li	a4,7
    80004952:	0ef77863          	bgeu	a4,a5,80004a42 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80004956:	831fb0ef          	jal	ra,80000186 <kalloc>
    8000495a:	00014497          	auipc	s1,0x14
    8000495e:	39648493          	addi	s1,s1,918 # 80018cf0 <disk>
    80004962:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004964:	823fb0ef          	jal	ra,80000186 <kalloc>
    80004968:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000496a:	81dfb0ef          	jal	ra,80000186 <kalloc>
    8000496e:	87aa                	mv	a5,a0
    80004970:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004972:	6088                	ld	a0,0(s1)
    80004974:	cd69                	beqz	a0,80004a4e <virtio_disk_init+0x1aa>
    80004976:	00014717          	auipc	a4,0x14
    8000497a:	38273703          	ld	a4,898(a4) # 80018cf8 <disk+0x8>
    8000497e:	cb61                	beqz	a4,80004a4e <virtio_disk_init+0x1aa>
    80004980:	c7f9                	beqz	a5,80004a4e <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80004982:	6605                	lui	a2,0x1
    80004984:	4581                	li	a1,0
    80004986:	85bfb0ef          	jal	ra,800001e0 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000498a:	00014497          	auipc	s1,0x14
    8000498e:	36648493          	addi	s1,s1,870 # 80018cf0 <disk>
    80004992:	6605                	lui	a2,0x1
    80004994:	4581                	li	a1,0
    80004996:	6488                	ld	a0,8(s1)
    80004998:	849fb0ef          	jal	ra,800001e0 <memset>
  memset(disk.used, 0, PGSIZE);
    8000499c:	6605                	lui	a2,0x1
    8000499e:	4581                	li	a1,0
    800049a0:	6888                	ld	a0,16(s1)
    800049a2:	83ffb0ef          	jal	ra,800001e0 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800049a6:	100017b7          	lui	a5,0x10001
    800049aa:	4721                	li	a4,8
    800049ac:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800049ae:	4098                	lw	a4,0(s1)
    800049b0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800049b4:	40d8                	lw	a4,4(s1)
    800049b6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800049ba:	6498                	ld	a4,8(s1)
    800049bc:	0007069b          	sext.w	a3,a4
    800049c0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800049c4:	9701                	srai	a4,a4,0x20
    800049c6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800049ca:	6898                	ld	a4,16(s1)
    800049cc:	0007069b          	sext.w	a3,a4
    800049d0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800049d4:	9701                	srai	a4,a4,0x20
    800049d6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800049da:	4705                	li	a4,1
    800049dc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800049de:	00e48c23          	sb	a4,24(s1)
    800049e2:	00e48ca3          	sb	a4,25(s1)
    800049e6:	00e48d23          	sb	a4,26(s1)
    800049ea:	00e48da3          	sb	a4,27(s1)
    800049ee:	00e48e23          	sb	a4,28(s1)
    800049f2:	00e48ea3          	sb	a4,29(s1)
    800049f6:	00e48f23          	sb	a4,30(s1)
    800049fa:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800049fe:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a02:	0727a823          	sw	s2,112(a5)
}
    80004a06:	60e2                	ld	ra,24(sp)
    80004a08:	6442                	ld	s0,16(sp)
    80004a0a:	64a2                	ld	s1,8(sp)
    80004a0c:	6902                	ld	s2,0(sp)
    80004a0e:	6105                	addi	sp,sp,32
    80004a10:	8082                	ret
    panic("could not find virtio disk");
    80004a12:	00003517          	auipc	a0,0x3
    80004a16:	e0650513          	addi	a0,a0,-506 # 80007818 <syscalls+0x388>
    80004a1a:	239000ef          	jal	ra,80005452 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004a1e:	00003517          	auipc	a0,0x3
    80004a22:	e1a50513          	addi	a0,a0,-486 # 80007838 <syscalls+0x3a8>
    80004a26:	22d000ef          	jal	ra,80005452 <panic>
    panic("virtio disk should not be ready");
    80004a2a:	00003517          	auipc	a0,0x3
    80004a2e:	e2e50513          	addi	a0,a0,-466 # 80007858 <syscalls+0x3c8>
    80004a32:	221000ef          	jal	ra,80005452 <panic>
    panic("virtio disk has no queue 0");
    80004a36:	00003517          	auipc	a0,0x3
    80004a3a:	e4250513          	addi	a0,a0,-446 # 80007878 <syscalls+0x3e8>
    80004a3e:	215000ef          	jal	ra,80005452 <panic>
    panic("virtio disk max queue too short");
    80004a42:	00003517          	auipc	a0,0x3
    80004a46:	e5650513          	addi	a0,a0,-426 # 80007898 <syscalls+0x408>
    80004a4a:	209000ef          	jal	ra,80005452 <panic>
    panic("virtio disk kalloc");
    80004a4e:	00003517          	auipc	a0,0x3
    80004a52:	e6a50513          	addi	a0,a0,-406 # 800078b8 <syscalls+0x428>
    80004a56:	1fd000ef          	jal	ra,80005452 <panic>

0000000080004a5a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004a5a:	7119                	addi	sp,sp,-128
    80004a5c:	fc86                	sd	ra,120(sp)
    80004a5e:	f8a2                	sd	s0,112(sp)
    80004a60:	f4a6                	sd	s1,104(sp)
    80004a62:	f0ca                	sd	s2,96(sp)
    80004a64:	ecce                	sd	s3,88(sp)
    80004a66:	e8d2                	sd	s4,80(sp)
    80004a68:	e4d6                	sd	s5,72(sp)
    80004a6a:	e0da                	sd	s6,64(sp)
    80004a6c:	fc5e                	sd	s7,56(sp)
    80004a6e:	f862                	sd	s8,48(sp)
    80004a70:	f466                	sd	s9,40(sp)
    80004a72:	f06a                	sd	s10,32(sp)
    80004a74:	ec6e                	sd	s11,24(sp)
    80004a76:	0100                	addi	s0,sp,128
    80004a78:	8aaa                	mv	s5,a0
    80004a7a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004a7c:	00c52d03          	lw	s10,12(a0)
    80004a80:	001d1d1b          	slliw	s10,s10,0x1
    80004a84:	1d02                	slli	s10,s10,0x20
    80004a86:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80004a8a:	00014517          	auipc	a0,0x14
    80004a8e:	38e50513          	addi	a0,a0,910 # 80018e18 <disk+0x128>
    80004a92:	4d1000ef          	jal	ra,80005762 <acquire>
  for(int i = 0; i < 3; i++){
    80004a96:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004a98:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004a9a:	00014b97          	auipc	s7,0x14
    80004a9e:	256b8b93          	addi	s7,s7,598 # 80018cf0 <disk>
  for(int i = 0; i < 3; i++){
    80004aa2:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004aa4:	00014c97          	auipc	s9,0x14
    80004aa8:	374c8c93          	addi	s9,s9,884 # 80018e18 <disk+0x128>
    80004aac:	a8a9                	j	80004b06 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004aae:	00fb8733          	add	a4,s7,a5
    80004ab2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80004ab6:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004ab8:	0207c563          	bltz	a5,80004ae2 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80004abc:	2905                	addiw	s2,s2,1
    80004abe:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004ac0:	05690863          	beq	s2,s6,80004b10 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80004ac4:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004ac6:	00014717          	auipc	a4,0x14
    80004aca:	22a70713          	addi	a4,a4,554 # 80018cf0 <disk>
    80004ace:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004ad0:	01874683          	lbu	a3,24(a4)
    80004ad4:	fee9                	bnez	a3,80004aae <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80004ad6:	2785                	addiw	a5,a5,1
    80004ad8:	0705                	addi	a4,a4,1
    80004ada:	fe979be3          	bne	a5,s1,80004ad0 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80004ade:	57fd                	li	a5,-1
    80004ae0:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004ae2:	01205b63          	blez	s2,80004af8 <virtio_disk_rw+0x9e>
    80004ae6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80004ae8:	000a2503          	lw	a0,0(s4)
    80004aec:	d43ff0ef          	jal	ra,8000482e <free_desc>
      for(int j = 0; j < i; j++)
    80004af0:	2d85                	addiw	s11,s11,1
    80004af2:	0a11                	addi	s4,s4,4
    80004af4:	ff2d9ae3          	bne	s11,s2,80004ae8 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004af8:	85e6                	mv	a1,s9
    80004afa:	00014517          	auipc	a0,0x14
    80004afe:	20e50513          	addi	a0,a0,526 # 80018d08 <disk+0x18>
    80004b02:	997fc0ef          	jal	ra,80001498 <sleep>
  for(int i = 0; i < 3; i++){
    80004b06:	f8040a13          	addi	s4,s0,-128
{
    80004b0a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80004b0c:	894e                	mv	s2,s3
    80004b0e:	bf5d                	j	80004ac4 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004b10:	f8042503          	lw	a0,-128(s0)
    80004b14:	00a50713          	addi	a4,a0,10
    80004b18:	0712                	slli	a4,a4,0x4

  if(write)
    80004b1a:	00014797          	auipc	a5,0x14
    80004b1e:	1d678793          	addi	a5,a5,470 # 80018cf0 <disk>
    80004b22:	00e786b3          	add	a3,a5,a4
    80004b26:	01803633          	snez	a2,s8
    80004b2a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004b2c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80004b30:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004b34:	f6070613          	addi	a2,a4,-160
    80004b38:	6394                	ld	a3,0(a5)
    80004b3a:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004b3c:	00870593          	addi	a1,a4,8
    80004b40:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004b42:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004b44:	0007b803          	ld	a6,0(a5)
    80004b48:	9642                	add	a2,a2,a6
    80004b4a:	46c1                	li	a3,16
    80004b4c:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004b4e:	4585                	li	a1,1
    80004b50:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80004b54:	f8442683          	lw	a3,-124(s0)
    80004b58:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004b5c:	0692                	slli	a3,a3,0x4
    80004b5e:	9836                	add	a6,a6,a3
    80004b60:	058a8613          	addi	a2,s5,88
    80004b64:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80004b68:	0007b803          	ld	a6,0(a5)
    80004b6c:	96c2                	add	a3,a3,a6
    80004b6e:	40000613          	li	a2,1024
    80004b72:	c690                	sw	a2,8(a3)
  if(write)
    80004b74:	001c3613          	seqz	a2,s8
    80004b78:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004b7c:	00166613          	ori	a2,a2,1
    80004b80:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80004b84:	f8842603          	lw	a2,-120(s0)
    80004b88:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004b8c:	00250693          	addi	a3,a0,2
    80004b90:	0692                	slli	a3,a3,0x4
    80004b92:	96be                	add	a3,a3,a5
    80004b94:	58fd                	li	a7,-1
    80004b96:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004b9a:	0612                	slli	a2,a2,0x4
    80004b9c:	9832                	add	a6,a6,a2
    80004b9e:	f9070713          	addi	a4,a4,-112
    80004ba2:	973e                	add	a4,a4,a5
    80004ba4:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80004ba8:	6398                	ld	a4,0(a5)
    80004baa:	9732                	add	a4,a4,a2
    80004bac:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004bae:	4609                	li	a2,2
    80004bb0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80004bb4:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004bb8:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80004bbc:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004bc0:	6794                	ld	a3,8(a5)
    80004bc2:	0026d703          	lhu	a4,2(a3)
    80004bc6:	8b1d                	andi	a4,a4,7
    80004bc8:	0706                	slli	a4,a4,0x1
    80004bca:	96ba                	add	a3,a3,a4
    80004bcc:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004bd0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004bd4:	6798                	ld	a4,8(a5)
    80004bd6:	00275783          	lhu	a5,2(a4)
    80004bda:	2785                	addiw	a5,a5,1
    80004bdc:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004be0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004be4:	100017b7          	lui	a5,0x10001
    80004be8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004bec:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80004bf0:	00014917          	auipc	s2,0x14
    80004bf4:	22890913          	addi	s2,s2,552 # 80018e18 <disk+0x128>
  while(b->disk == 1) {
    80004bf8:	4485                	li	s1,1
    80004bfa:	00b79a63          	bne	a5,a1,80004c0e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80004bfe:	85ca                	mv	a1,s2
    80004c00:	8556                	mv	a0,s5
    80004c02:	897fc0ef          	jal	ra,80001498 <sleep>
  while(b->disk == 1) {
    80004c06:	004aa783          	lw	a5,4(s5)
    80004c0a:	fe978ae3          	beq	a5,s1,80004bfe <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80004c0e:	f8042903          	lw	s2,-128(s0)
    80004c12:	00290713          	addi	a4,s2,2
    80004c16:	0712                	slli	a4,a4,0x4
    80004c18:	00014797          	auipc	a5,0x14
    80004c1c:	0d878793          	addi	a5,a5,216 # 80018cf0 <disk>
    80004c20:	97ba                	add	a5,a5,a4
    80004c22:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004c26:	00014997          	auipc	s3,0x14
    80004c2a:	0ca98993          	addi	s3,s3,202 # 80018cf0 <disk>
    80004c2e:	00491713          	slli	a4,s2,0x4
    80004c32:	0009b783          	ld	a5,0(s3)
    80004c36:	97ba                	add	a5,a5,a4
    80004c38:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004c3c:	854a                	mv	a0,s2
    80004c3e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004c42:	bedff0ef          	jal	ra,8000482e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004c46:	8885                	andi	s1,s1,1
    80004c48:	f0fd                	bnez	s1,80004c2e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004c4a:	00014517          	auipc	a0,0x14
    80004c4e:	1ce50513          	addi	a0,a0,462 # 80018e18 <disk+0x128>
    80004c52:	3a9000ef          	jal	ra,800057fa <release>
}
    80004c56:	70e6                	ld	ra,120(sp)
    80004c58:	7446                	ld	s0,112(sp)
    80004c5a:	74a6                	ld	s1,104(sp)
    80004c5c:	7906                	ld	s2,96(sp)
    80004c5e:	69e6                	ld	s3,88(sp)
    80004c60:	6a46                	ld	s4,80(sp)
    80004c62:	6aa6                	ld	s5,72(sp)
    80004c64:	6b06                	ld	s6,64(sp)
    80004c66:	7be2                	ld	s7,56(sp)
    80004c68:	7c42                	ld	s8,48(sp)
    80004c6a:	7ca2                	ld	s9,40(sp)
    80004c6c:	7d02                	ld	s10,32(sp)
    80004c6e:	6de2                	ld	s11,24(sp)
    80004c70:	6109                	addi	sp,sp,128
    80004c72:	8082                	ret

0000000080004c74 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004c74:	1101                	addi	sp,sp,-32
    80004c76:	ec06                	sd	ra,24(sp)
    80004c78:	e822                	sd	s0,16(sp)
    80004c7a:	e426                	sd	s1,8(sp)
    80004c7c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004c7e:	00014497          	auipc	s1,0x14
    80004c82:	07248493          	addi	s1,s1,114 # 80018cf0 <disk>
    80004c86:	00014517          	auipc	a0,0x14
    80004c8a:	19250513          	addi	a0,a0,402 # 80018e18 <disk+0x128>
    80004c8e:	2d5000ef          	jal	ra,80005762 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004c92:	10001737          	lui	a4,0x10001
    80004c96:	533c                	lw	a5,96(a4)
    80004c98:	8b8d                	andi	a5,a5,3
    80004c9a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80004c9c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004ca0:	689c                	ld	a5,16(s1)
    80004ca2:	0204d703          	lhu	a4,32(s1)
    80004ca6:	0027d783          	lhu	a5,2(a5)
    80004caa:	04f70663          	beq	a4,a5,80004cf6 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80004cae:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004cb2:	6898                	ld	a4,16(s1)
    80004cb4:	0204d783          	lhu	a5,32(s1)
    80004cb8:	8b9d                	andi	a5,a5,7
    80004cba:	078e                	slli	a5,a5,0x3
    80004cbc:	97ba                	add	a5,a5,a4
    80004cbe:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004cc0:	00278713          	addi	a4,a5,2
    80004cc4:	0712                	slli	a4,a4,0x4
    80004cc6:	9726                	add	a4,a4,s1
    80004cc8:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80004ccc:	e321                	bnez	a4,80004d0c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004cce:	0789                	addi	a5,a5,2
    80004cd0:	0792                	slli	a5,a5,0x4
    80004cd2:	97a6                	add	a5,a5,s1
    80004cd4:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004cd6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004cda:	80bfc0ef          	jal	ra,800014e4 <wakeup>

    disk.used_idx += 1;
    80004cde:	0204d783          	lhu	a5,32(s1)
    80004ce2:	2785                	addiw	a5,a5,1
    80004ce4:	17c2                	slli	a5,a5,0x30
    80004ce6:	93c1                	srli	a5,a5,0x30
    80004ce8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004cec:	6898                	ld	a4,16(s1)
    80004cee:	00275703          	lhu	a4,2(a4)
    80004cf2:	faf71ee3          	bne	a4,a5,80004cae <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80004cf6:	00014517          	auipc	a0,0x14
    80004cfa:	12250513          	addi	a0,a0,290 # 80018e18 <disk+0x128>
    80004cfe:	2fd000ef          	jal	ra,800057fa <release>
}
    80004d02:	60e2                	ld	ra,24(sp)
    80004d04:	6442                	ld	s0,16(sp)
    80004d06:	64a2                	ld	s1,8(sp)
    80004d08:	6105                	addi	sp,sp,32
    80004d0a:	8082                	ret
      panic("virtio_disk_intr status");
    80004d0c:	00003517          	auipc	a0,0x3
    80004d10:	bc450513          	addi	a0,a0,-1084 # 800078d0 <syscalls+0x440>
    80004d14:	73e000ef          	jal	ra,80005452 <panic>

0000000080004d18 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004d18:	1141                	addi	sp,sp,-16
    80004d1a:	e422                	sd	s0,8(sp)
    80004d1c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004d1e:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004d22:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004d26:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004d2a:	30a027f3          	csrr	a5,0x30a

  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63));
    80004d2e:	577d                	li	a4,-1
    80004d30:	177e                	slli	a4,a4,0x3f
    80004d32:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004d34:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004d38:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004d3c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004d40:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004d44:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004d48:	000f4737          	lui	a4,0xf4
    80004d4c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004d50:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004d52:	14d79073          	csrw	0x14d,a5
}
    80004d56:	6422                	ld	s0,8(sp)
    80004d58:	0141                	addi	sp,sp,16
    80004d5a:	8082                	ret

0000000080004d5c <start>:
{
    80004d5c:	1141                	addi	sp,sp,-16
    80004d5e:	e406                	sd	ra,8(sp)
    80004d60:	e022                	sd	s0,0(sp)
    80004d62:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004d64:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004d68:	7779                	lui	a4,0xffffe
    80004d6a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd8cf>
    80004d6e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004d70:	6705                	lui	a4,0x1
    80004d72:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004d76:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004d78:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004d7c:	ffffb797          	auipc	a5,0xffffb
    80004d80:	60678793          	addi	a5,a5,1542 # 80000382 <main>
    80004d84:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004d88:	4781                	li	a5,0
    80004d8a:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004d8e:	67c1                	lui	a5,0x10
    80004d90:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004d92:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004d96:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004d9a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004d9e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004da2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004da6:	57fd                	li	a5,-1
    80004da8:	83a9                	srli	a5,a5,0xa
    80004daa:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004dae:	47bd                	li	a5,15
    80004db0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004db4:	f65ff0ef          	jal	ra,80004d18 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004db8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004dbc:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004dbe:	823e                	mv	tp,a5
  asm volatile("mret");
    80004dc0:	30200073          	mret
}
    80004dc4:	60a2                	ld	ra,8(sp)
    80004dc6:	6402                	ld	s0,0(sp)
    80004dc8:	0141                	addi	sp,sp,16
    80004dca:	8082                	ret

0000000080004dcc <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004dcc:	715d                	addi	sp,sp,-80
    80004dce:	e486                	sd	ra,72(sp)
    80004dd0:	e0a2                	sd	s0,64(sp)
    80004dd2:	fc26                	sd	s1,56(sp)
    80004dd4:	f84a                	sd	s2,48(sp)
    80004dd6:	f44e                	sd	s3,40(sp)
    80004dd8:	f052                	sd	s4,32(sp)
    80004dda:	ec56                	sd	s5,24(sp)
    80004ddc:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004dde:	04c05363          	blez	a2,80004e24 <consolewrite+0x58>
    80004de2:	8a2a                	mv	s4,a0
    80004de4:	84ae                	mv	s1,a1
    80004de6:	89b2                	mv	s3,a2
    80004de8:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004dea:	5afd                	li	s5,-1
    80004dec:	4685                	li	a3,1
    80004dee:	8626                	mv	a2,s1
    80004df0:	85d2                	mv	a1,s4
    80004df2:	fbf40513          	addi	a0,s0,-65
    80004df6:	a49fc0ef          	jal	ra,8000183e <either_copyin>
    80004dfa:	01550b63          	beq	a0,s5,80004e10 <consolewrite+0x44>
      break;
    uartputc(c);
    80004dfe:	fbf44503          	lbu	a0,-65(s0)
    80004e02:	7da000ef          	jal	ra,800055dc <uartputc>
  for(i = 0; i < n; i++){
    80004e06:	2905                	addiw	s2,s2,1
    80004e08:	0485                	addi	s1,s1,1
    80004e0a:	ff2991e3          	bne	s3,s2,80004dec <consolewrite+0x20>
    80004e0e:	894e                	mv	s2,s3
  }

  return i;
}
    80004e10:	854a                	mv	a0,s2
    80004e12:	60a6                	ld	ra,72(sp)
    80004e14:	6406                	ld	s0,64(sp)
    80004e16:	74e2                	ld	s1,56(sp)
    80004e18:	7942                	ld	s2,48(sp)
    80004e1a:	79a2                	ld	s3,40(sp)
    80004e1c:	7a02                	ld	s4,32(sp)
    80004e1e:	6ae2                	ld	s5,24(sp)
    80004e20:	6161                	addi	sp,sp,80
    80004e22:	8082                	ret
  for(i = 0; i < n; i++){
    80004e24:	4901                	li	s2,0
    80004e26:	b7ed                	j	80004e10 <consolewrite+0x44>

0000000080004e28 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004e28:	7159                	addi	sp,sp,-112
    80004e2a:	f486                	sd	ra,104(sp)
    80004e2c:	f0a2                	sd	s0,96(sp)
    80004e2e:	eca6                	sd	s1,88(sp)
    80004e30:	e8ca                	sd	s2,80(sp)
    80004e32:	e4ce                	sd	s3,72(sp)
    80004e34:	e0d2                	sd	s4,64(sp)
    80004e36:	fc56                	sd	s5,56(sp)
    80004e38:	f85a                	sd	s6,48(sp)
    80004e3a:	f45e                	sd	s7,40(sp)
    80004e3c:	f062                	sd	s8,32(sp)
    80004e3e:	ec66                	sd	s9,24(sp)
    80004e40:	e86a                	sd	s10,16(sp)
    80004e42:	1880                	addi	s0,sp,112
    80004e44:	8aaa                	mv	s5,a0
    80004e46:	8a2e                	mv	s4,a1
    80004e48:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004e4a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004e4e:	0001c517          	auipc	a0,0x1c
    80004e52:	fe250513          	addi	a0,a0,-30 # 80020e30 <cons>
    80004e56:	10d000ef          	jal	ra,80005762 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004e5a:	0001c497          	auipc	s1,0x1c
    80004e5e:	fd648493          	addi	s1,s1,-42 # 80020e30 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004e62:	0001c917          	auipc	s2,0x1c
    80004e66:	06690913          	addi	s2,s2,102 # 80020ec8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80004e6a:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004e6c:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80004e6e:	4ca9                	li	s9,10
  while(n > 0){
    80004e70:	07305363          	blez	s3,80004ed6 <consoleread+0xae>
    while(cons.r == cons.w){
    80004e74:	0984a783          	lw	a5,152(s1)
    80004e78:	09c4a703          	lw	a4,156(s1)
    80004e7c:	02f71163          	bne	a4,a5,80004e9e <consoleread+0x76>
      if(killed(myproc())){
    80004e80:	84cfc0ef          	jal	ra,80000ecc <myproc>
    80004e84:	84dfc0ef          	jal	ra,800016d0 <killed>
    80004e88:	e125                	bnez	a0,80004ee8 <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    80004e8a:	85a6                	mv	a1,s1
    80004e8c:	854a                	mv	a0,s2
    80004e8e:	e0afc0ef          	jal	ra,80001498 <sleep>
    while(cons.r == cons.w){
    80004e92:	0984a783          	lw	a5,152(s1)
    80004e96:	09c4a703          	lw	a4,156(s1)
    80004e9a:	fef703e3          	beq	a4,a5,80004e80 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004e9e:	0017871b          	addiw	a4,a5,1
    80004ea2:	08e4ac23          	sw	a4,152(s1)
    80004ea6:	07f7f713          	andi	a4,a5,127
    80004eaa:	9726                	add	a4,a4,s1
    80004eac:	01874703          	lbu	a4,24(a4)
    80004eb0:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80004eb4:	057d0f63          	beq	s10,s7,80004f12 <consoleread+0xea>
    cbuf = c;
    80004eb8:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004ebc:	4685                	li	a3,1
    80004ebe:	f9f40613          	addi	a2,s0,-97
    80004ec2:	85d2                	mv	a1,s4
    80004ec4:	8556                	mv	a0,s5
    80004ec6:	92ffc0ef          	jal	ra,800017f4 <either_copyout>
    80004eca:	01850663          	beq	a0,s8,80004ed6 <consoleread+0xae>
    dst++;
    80004ece:	0a05                	addi	s4,s4,1
    --n;
    80004ed0:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80004ed2:	f99d1fe3          	bne	s10,s9,80004e70 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80004ed6:	0001c517          	auipc	a0,0x1c
    80004eda:	f5a50513          	addi	a0,a0,-166 # 80020e30 <cons>
    80004ede:	11d000ef          	jal	ra,800057fa <release>

  return target - n;
    80004ee2:	413b053b          	subw	a0,s6,s3
    80004ee6:	a801                	j	80004ef6 <consoleread+0xce>
        release(&cons.lock);
    80004ee8:	0001c517          	auipc	a0,0x1c
    80004eec:	f4850513          	addi	a0,a0,-184 # 80020e30 <cons>
    80004ef0:	10b000ef          	jal	ra,800057fa <release>
        return -1;
    80004ef4:	557d                	li	a0,-1
}
    80004ef6:	70a6                	ld	ra,104(sp)
    80004ef8:	7406                	ld	s0,96(sp)
    80004efa:	64e6                	ld	s1,88(sp)
    80004efc:	6946                	ld	s2,80(sp)
    80004efe:	69a6                	ld	s3,72(sp)
    80004f00:	6a06                	ld	s4,64(sp)
    80004f02:	7ae2                	ld	s5,56(sp)
    80004f04:	7b42                	ld	s6,48(sp)
    80004f06:	7ba2                	ld	s7,40(sp)
    80004f08:	7c02                	ld	s8,32(sp)
    80004f0a:	6ce2                	ld	s9,24(sp)
    80004f0c:	6d42                	ld	s10,16(sp)
    80004f0e:	6165                	addi	sp,sp,112
    80004f10:	8082                	ret
      if(n < target){
    80004f12:	0009871b          	sext.w	a4,s3
    80004f16:	fd6770e3          	bgeu	a4,s6,80004ed6 <consoleread+0xae>
        cons.r--;
    80004f1a:	0001c717          	auipc	a4,0x1c
    80004f1e:	faf72723          	sw	a5,-82(a4) # 80020ec8 <cons+0x98>
    80004f22:	bf55                	j	80004ed6 <consoleread+0xae>

0000000080004f24 <consputc>:
{
    80004f24:	1141                	addi	sp,sp,-16
    80004f26:	e406                	sd	ra,8(sp)
    80004f28:	e022                	sd	s0,0(sp)
    80004f2a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80004f2c:	10000793          	li	a5,256
    80004f30:	00f50863          	beq	a0,a5,80004f40 <consputc+0x1c>
    uartputc_sync(c);
    80004f34:	5d2000ef          	jal	ra,80005506 <uartputc_sync>
}
    80004f38:	60a2                	ld	ra,8(sp)
    80004f3a:	6402                	ld	s0,0(sp)
    80004f3c:	0141                	addi	sp,sp,16
    80004f3e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80004f40:	4521                	li	a0,8
    80004f42:	5c4000ef          	jal	ra,80005506 <uartputc_sync>
    80004f46:	02000513          	li	a0,32
    80004f4a:	5bc000ef          	jal	ra,80005506 <uartputc_sync>
    80004f4e:	4521                	li	a0,8
    80004f50:	5b6000ef          	jal	ra,80005506 <uartputc_sync>
    80004f54:	b7d5                	j	80004f38 <consputc+0x14>

0000000080004f56 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80004f56:	1101                	addi	sp,sp,-32
    80004f58:	ec06                	sd	ra,24(sp)
    80004f5a:	e822                	sd	s0,16(sp)
    80004f5c:	e426                	sd	s1,8(sp)
    80004f5e:	e04a                	sd	s2,0(sp)
    80004f60:	1000                	addi	s0,sp,32
    80004f62:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80004f64:	0001c517          	auipc	a0,0x1c
    80004f68:	ecc50513          	addi	a0,a0,-308 # 80020e30 <cons>
    80004f6c:	7f6000ef          	jal	ra,80005762 <acquire>

  switch(c){
    80004f70:	47d5                	li	a5,21
    80004f72:	0af48063          	beq	s1,a5,80005012 <consoleintr+0xbc>
    80004f76:	0297c663          	blt	a5,s1,80004fa2 <consoleintr+0x4c>
    80004f7a:	47a1                	li	a5,8
    80004f7c:	0cf48f63          	beq	s1,a5,8000505a <consoleintr+0x104>
    80004f80:	47c1                	li	a5,16
    80004f82:	10f49063          	bne	s1,a5,80005082 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    80004f86:	903fc0ef          	jal	ra,80001888 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    80004f8a:	0001c517          	auipc	a0,0x1c
    80004f8e:	ea650513          	addi	a0,a0,-346 # 80020e30 <cons>
    80004f92:	069000ef          	jal	ra,800057fa <release>
}
    80004f96:	60e2                	ld	ra,24(sp)
    80004f98:	6442                	ld	s0,16(sp)
    80004f9a:	64a2                	ld	s1,8(sp)
    80004f9c:	6902                	ld	s2,0(sp)
    80004f9e:	6105                	addi	sp,sp,32
    80004fa0:	8082                	ret
  switch(c){
    80004fa2:	07f00793          	li	a5,127
    80004fa6:	0af48a63          	beq	s1,a5,8000505a <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004faa:	0001c717          	auipc	a4,0x1c
    80004fae:	e8670713          	addi	a4,a4,-378 # 80020e30 <cons>
    80004fb2:	0a072783          	lw	a5,160(a4)
    80004fb6:	09872703          	lw	a4,152(a4)
    80004fba:	9f99                	subw	a5,a5,a4
    80004fbc:	07f00713          	li	a4,127
    80004fc0:	fcf765e3          	bltu	a4,a5,80004f8a <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    80004fc4:	47b5                	li	a5,13
    80004fc6:	0cf48163          	beq	s1,a5,80005088 <consoleintr+0x132>
      consputc(c);
    80004fca:	8526                	mv	a0,s1
    80004fcc:	f59ff0ef          	jal	ra,80004f24 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80004fd0:	0001c797          	auipc	a5,0x1c
    80004fd4:	e6078793          	addi	a5,a5,-416 # 80020e30 <cons>
    80004fd8:	0a07a683          	lw	a3,160(a5)
    80004fdc:	0016871b          	addiw	a4,a3,1
    80004fe0:	0007061b          	sext.w	a2,a4
    80004fe4:	0ae7a023          	sw	a4,160(a5)
    80004fe8:	07f6f693          	andi	a3,a3,127
    80004fec:	97b6                	add	a5,a5,a3
    80004fee:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80004ff2:	47a9                	li	a5,10
    80004ff4:	0af48f63          	beq	s1,a5,800050b2 <consoleintr+0x15c>
    80004ff8:	4791                	li	a5,4
    80004ffa:	0af48c63          	beq	s1,a5,800050b2 <consoleintr+0x15c>
    80004ffe:	0001c797          	auipc	a5,0x1c
    80005002:	eca7a783          	lw	a5,-310(a5) # 80020ec8 <cons+0x98>
    80005006:	9f1d                	subw	a4,a4,a5
    80005008:	08000793          	li	a5,128
    8000500c:	f6f71fe3          	bne	a4,a5,80004f8a <consoleintr+0x34>
    80005010:	a04d                	j	800050b2 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80005012:	0001c717          	auipc	a4,0x1c
    80005016:	e1e70713          	addi	a4,a4,-482 # 80020e30 <cons>
    8000501a:	0a072783          	lw	a5,160(a4)
    8000501e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005022:	0001c497          	auipc	s1,0x1c
    80005026:	e0e48493          	addi	s1,s1,-498 # 80020e30 <cons>
    while(cons.e != cons.w &&
    8000502a:	4929                	li	s2,10
    8000502c:	f4f70fe3          	beq	a4,a5,80004f8a <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005030:	37fd                	addiw	a5,a5,-1
    80005032:	07f7f713          	andi	a4,a5,127
    80005036:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005038:	01874703          	lbu	a4,24(a4)
    8000503c:	f52707e3          	beq	a4,s2,80004f8a <consoleintr+0x34>
      cons.e--;
    80005040:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005044:	10000513          	li	a0,256
    80005048:	eddff0ef          	jal	ra,80004f24 <consputc>
    while(cons.e != cons.w &&
    8000504c:	0a04a783          	lw	a5,160(s1)
    80005050:	09c4a703          	lw	a4,156(s1)
    80005054:	fcf71ee3          	bne	a4,a5,80005030 <consoleintr+0xda>
    80005058:	bf0d                	j	80004f8a <consoleintr+0x34>
    if(cons.e != cons.w){
    8000505a:	0001c717          	auipc	a4,0x1c
    8000505e:	dd670713          	addi	a4,a4,-554 # 80020e30 <cons>
    80005062:	0a072783          	lw	a5,160(a4)
    80005066:	09c72703          	lw	a4,156(a4)
    8000506a:	f2f700e3          	beq	a4,a5,80004f8a <consoleintr+0x34>
      cons.e--;
    8000506e:	37fd                	addiw	a5,a5,-1
    80005070:	0001c717          	auipc	a4,0x1c
    80005074:	e6f72023          	sw	a5,-416(a4) # 80020ed0 <cons+0xa0>
      consputc(BACKSPACE);
    80005078:	10000513          	li	a0,256
    8000507c:	ea9ff0ef          	jal	ra,80004f24 <consputc>
    80005080:	b729                	j	80004f8a <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005082:	f00484e3          	beqz	s1,80004f8a <consoleintr+0x34>
    80005086:	b715                	j	80004faa <consoleintr+0x54>
      consputc(c);
    80005088:	4529                	li	a0,10
    8000508a:	e9bff0ef          	jal	ra,80004f24 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000508e:	0001c797          	auipc	a5,0x1c
    80005092:	da278793          	addi	a5,a5,-606 # 80020e30 <cons>
    80005096:	0a07a703          	lw	a4,160(a5)
    8000509a:	0017069b          	addiw	a3,a4,1
    8000509e:	0006861b          	sext.w	a2,a3
    800050a2:	0ad7a023          	sw	a3,160(a5)
    800050a6:	07f77713          	andi	a4,a4,127
    800050aa:	97ba                	add	a5,a5,a4
    800050ac:	4729                	li	a4,10
    800050ae:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800050b2:	0001c797          	auipc	a5,0x1c
    800050b6:	e0c7ad23          	sw	a2,-486(a5) # 80020ecc <cons+0x9c>
        wakeup(&cons.r);
    800050ba:	0001c517          	auipc	a0,0x1c
    800050be:	e0e50513          	addi	a0,a0,-498 # 80020ec8 <cons+0x98>
    800050c2:	c22fc0ef          	jal	ra,800014e4 <wakeup>
    800050c6:	b5d1                	j	80004f8a <consoleintr+0x34>

00000000800050c8 <consoleinit>:

void
consoleinit(void)
{
    800050c8:	1141                	addi	sp,sp,-16
    800050ca:	e406                	sd	ra,8(sp)
    800050cc:	e022                	sd	s0,0(sp)
    800050ce:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800050d0:	00003597          	auipc	a1,0x3
    800050d4:	81858593          	addi	a1,a1,-2024 # 800078e8 <syscalls+0x458>
    800050d8:	0001c517          	auipc	a0,0x1c
    800050dc:	d5850513          	addi	a0,a0,-680 # 80020e30 <cons>
    800050e0:	602000ef          	jal	ra,800056e2 <initlock>

  uartinit();
    800050e4:	3d6000ef          	jal	ra,800054ba <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800050e8:	00013797          	auipc	a5,0x13
    800050ec:	bb078793          	addi	a5,a5,-1104 # 80017c98 <devsw>
    800050f0:	00000717          	auipc	a4,0x0
    800050f4:	d3870713          	addi	a4,a4,-712 # 80004e28 <consoleread>
    800050f8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800050fa:	00000717          	auipc	a4,0x0
    800050fe:	cd270713          	addi	a4,a4,-814 # 80004dcc <consolewrite>
    80005102:	ef98                	sd	a4,24(a5)
}
    80005104:	60a2                	ld	ra,8(sp)
    80005106:	6402                	ld	s0,0(sp)
    80005108:	0141                	addi	sp,sp,16
    8000510a:	8082                	ret

000000008000510c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000510c:	7179                	addi	sp,sp,-48
    8000510e:	f406                	sd	ra,40(sp)
    80005110:	f022                	sd	s0,32(sp)
    80005112:	ec26                	sd	s1,24(sp)
    80005114:	e84a                	sd	s2,16(sp)
    80005116:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005118:	c219                	beqz	a2,8000511e <printint+0x12>
    8000511a:	06054e63          	bltz	a0,80005196 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000511e:	4881                	li	a7,0
    80005120:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005124:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005126:	00002617          	auipc	a2,0x2
    8000512a:	7ea60613          	addi	a2,a2,2026 # 80007910 <digits>
    8000512e:	883e                	mv	a6,a5
    80005130:	2785                	addiw	a5,a5,1
    80005132:	02b57733          	remu	a4,a0,a1
    80005136:	9732                	add	a4,a4,a2
    80005138:	00074703          	lbu	a4,0(a4)
    8000513c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80005140:	872a                	mv	a4,a0
    80005142:	02b55533          	divu	a0,a0,a1
    80005146:	0685                	addi	a3,a3,1
    80005148:	feb773e3          	bgeu	a4,a1,8000512e <printint+0x22>

  if(sign)
    8000514c:	00088a63          	beqz	a7,80005160 <printint+0x54>
    buf[i++] = '-';
    80005150:	1781                	addi	a5,a5,-32
    80005152:	97a2                	add	a5,a5,s0
    80005154:	02d00713          	li	a4,45
    80005158:	fee78823          	sb	a4,-16(a5)
    8000515c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005160:	02f05563          	blez	a5,8000518a <printint+0x7e>
    80005164:	fd040713          	addi	a4,s0,-48
    80005168:	00f704b3          	add	s1,a4,a5
    8000516c:	fff70913          	addi	s2,a4,-1
    80005170:	993e                	add	s2,s2,a5
    80005172:	37fd                	addiw	a5,a5,-1
    80005174:	1782                	slli	a5,a5,0x20
    80005176:	9381                	srli	a5,a5,0x20
    80005178:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000517c:	fff4c503          	lbu	a0,-1(s1)
    80005180:	da5ff0ef          	jal	ra,80004f24 <consputc>
  while(--i >= 0)
    80005184:	14fd                	addi	s1,s1,-1
    80005186:	ff249be3          	bne	s1,s2,8000517c <printint+0x70>
}
    8000518a:	70a2                	ld	ra,40(sp)
    8000518c:	7402                	ld	s0,32(sp)
    8000518e:	64e2                	ld	s1,24(sp)
    80005190:	6942                	ld	s2,16(sp)
    80005192:	6145                	addi	sp,sp,48
    80005194:	8082                	ret
    x = -xx;
    80005196:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000519a:	4885                	li	a7,1
    x = -xx;
    8000519c:	b751                	j	80005120 <printint+0x14>

000000008000519e <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000519e:	7155                	addi	sp,sp,-208
    800051a0:	e506                	sd	ra,136(sp)
    800051a2:	e122                	sd	s0,128(sp)
    800051a4:	fca6                	sd	s1,120(sp)
    800051a6:	f8ca                	sd	s2,112(sp)
    800051a8:	f4ce                	sd	s3,104(sp)
    800051aa:	f0d2                	sd	s4,96(sp)
    800051ac:	ecd6                	sd	s5,88(sp)
    800051ae:	e8da                	sd	s6,80(sp)
    800051b0:	e4de                	sd	s7,72(sp)
    800051b2:	e0e2                	sd	s8,64(sp)
    800051b4:	fc66                	sd	s9,56(sp)
    800051b6:	f86a                	sd	s10,48(sp)
    800051b8:	f46e                	sd	s11,40(sp)
    800051ba:	0900                	addi	s0,sp,144
    800051bc:	8a2a                	mv	s4,a0
    800051be:	e40c                	sd	a1,8(s0)
    800051c0:	e810                	sd	a2,16(s0)
    800051c2:	ec14                	sd	a3,24(s0)
    800051c4:	f018                	sd	a4,32(s0)
    800051c6:	f41c                	sd	a5,40(s0)
    800051c8:	03043823          	sd	a6,48(s0)
    800051cc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800051d0:	0001c797          	auipc	a5,0x1c
    800051d4:	d207a783          	lw	a5,-736(a5) # 80020ef0 <pr+0x18>
    800051d8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800051dc:	eb9d                	bnez	a5,80005212 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800051de:	00840793          	addi	a5,s0,8
    800051e2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800051e6:	00054503          	lbu	a0,0(a0)
    800051ea:	24050463          	beqz	a0,80005432 <printf+0x294>
    800051ee:	4981                	li	s3,0
    if(cx != '%'){
    800051f0:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800051f4:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800051f8:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    800051fc:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005200:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005204:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005208:	00002b97          	auipc	s7,0x2
    8000520c:	708b8b93          	addi	s7,s7,1800 # 80007910 <digits>
    80005210:	a081                	j	80005250 <printf+0xb2>
    acquire(&pr.lock);
    80005212:	0001c517          	auipc	a0,0x1c
    80005216:	cc650513          	addi	a0,a0,-826 # 80020ed8 <pr>
    8000521a:	548000ef          	jal	ra,80005762 <acquire>
  va_start(ap, fmt);
    8000521e:	00840793          	addi	a5,s0,8
    80005222:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005226:	000a4503          	lbu	a0,0(s4)
    8000522a:	f171                	bnez	a0,800051ee <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    8000522c:	0001c517          	auipc	a0,0x1c
    80005230:	cac50513          	addi	a0,a0,-852 # 80020ed8 <pr>
    80005234:	5c6000ef          	jal	ra,800057fa <release>
    80005238:	aaed                	j	80005432 <printf+0x294>
      consputc(cx);
    8000523a:	cebff0ef          	jal	ra,80004f24 <consputc>
      continue;
    8000523e:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005240:	0014899b          	addiw	s3,s1,1
    80005244:	013a07b3          	add	a5,s4,s3
    80005248:	0007c503          	lbu	a0,0(a5)
    8000524c:	1c050f63          	beqz	a0,8000542a <printf+0x28c>
    if(cx != '%'){
    80005250:	ff5515e3          	bne	a0,s5,8000523a <printf+0x9c>
    i++;
    80005254:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005258:	009a07b3          	add	a5,s4,s1
    8000525c:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005260:	1c090563          	beqz	s2,8000542a <printf+0x28c>
    80005264:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005268:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000526a:	c789                	beqz	a5,80005274 <printf+0xd6>
    8000526c:	009a0733          	add	a4,s4,s1
    80005270:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005274:	03690463          	beq	s2,s6,8000529c <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80005278:	03890e63          	beq	s2,s8,800052b4 <printf+0x116>
    } else if(c0 == 'u'){
    8000527c:	0b990d63          	beq	s2,s9,80005336 <printf+0x198>
    } else if(c0 == 'x'){
    80005280:	11a90363          	beq	s2,s10,80005386 <printf+0x1e8>
    } else if(c0 == 'p'){
    80005284:	13b90b63          	beq	s2,s11,800053ba <printf+0x21c>
    } else if(c0 == 's'){
    80005288:	07300793          	li	a5,115
    8000528c:	16f90363          	beq	s2,a5,800053f2 <printf+0x254>
    } else if(c0 == '%'){
    80005290:	03591c63          	bne	s2,s5,800052c8 <printf+0x12a>
      consputc('%');
    80005294:	8556                	mv	a0,s5
    80005296:	c8fff0ef          	jal	ra,80004f24 <consputc>
    8000529a:	b75d                	j	80005240 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    8000529c:	f8843783          	ld	a5,-120(s0)
    800052a0:	00878713          	addi	a4,a5,8
    800052a4:	f8e43423          	sd	a4,-120(s0)
    800052a8:	4605                	li	a2,1
    800052aa:	45a9                	li	a1,10
    800052ac:	4388                	lw	a0,0(a5)
    800052ae:	e5fff0ef          	jal	ra,8000510c <printint>
    800052b2:	b779                	j	80005240 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800052b4:	03678163          	beq	a5,s6,800052d6 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800052b8:	03878d63          	beq	a5,s8,800052f2 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800052bc:	09978963          	beq	a5,s9,8000534e <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800052c0:	03878b63          	beq	a5,s8,800052f6 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800052c4:	0da78d63          	beq	a5,s10,8000539e <printf+0x200>
      consputc('%');
    800052c8:	8556                	mv	a0,s5
    800052ca:	c5bff0ef          	jal	ra,80004f24 <consputc>
      consputc(c0);
    800052ce:	854a                	mv	a0,s2
    800052d0:	c55ff0ef          	jal	ra,80004f24 <consputc>
    800052d4:	b7b5                	j	80005240 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800052d6:	f8843783          	ld	a5,-120(s0)
    800052da:	00878713          	addi	a4,a5,8
    800052de:	f8e43423          	sd	a4,-120(s0)
    800052e2:	4605                	li	a2,1
    800052e4:	45a9                	li	a1,10
    800052e6:	6388                	ld	a0,0(a5)
    800052e8:	e25ff0ef          	jal	ra,8000510c <printint>
      i += 1;
    800052ec:	0029849b          	addiw	s1,s3,2
    800052f0:	bf81                	j	80005240 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800052f2:	03668463          	beq	a3,s6,8000531a <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800052f6:	07968a63          	beq	a3,s9,8000536a <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800052fa:	fda697e3          	bne	a3,s10,800052c8 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    800052fe:	f8843783          	ld	a5,-120(s0)
    80005302:	00878713          	addi	a4,a5,8
    80005306:	f8e43423          	sd	a4,-120(s0)
    8000530a:	4601                	li	a2,0
    8000530c:	45c1                	li	a1,16
    8000530e:	6388                	ld	a0,0(a5)
    80005310:	dfdff0ef          	jal	ra,8000510c <printint>
      i += 2;
    80005314:	0039849b          	addiw	s1,s3,3
    80005318:	b725                	j	80005240 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    8000531a:	f8843783          	ld	a5,-120(s0)
    8000531e:	00878713          	addi	a4,a5,8
    80005322:	f8e43423          	sd	a4,-120(s0)
    80005326:	4605                	li	a2,1
    80005328:	45a9                	li	a1,10
    8000532a:	6388                	ld	a0,0(a5)
    8000532c:	de1ff0ef          	jal	ra,8000510c <printint>
      i += 2;
    80005330:	0039849b          	addiw	s1,s3,3
    80005334:	b731                	j	80005240 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80005336:	f8843783          	ld	a5,-120(s0)
    8000533a:	00878713          	addi	a4,a5,8
    8000533e:	f8e43423          	sd	a4,-120(s0)
    80005342:	4601                	li	a2,0
    80005344:	45a9                	li	a1,10
    80005346:	4388                	lw	a0,0(a5)
    80005348:	dc5ff0ef          	jal	ra,8000510c <printint>
    8000534c:	bdd5                	j	80005240 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000534e:	f8843783          	ld	a5,-120(s0)
    80005352:	00878713          	addi	a4,a5,8
    80005356:	f8e43423          	sd	a4,-120(s0)
    8000535a:	4601                	li	a2,0
    8000535c:	45a9                	li	a1,10
    8000535e:	6388                	ld	a0,0(a5)
    80005360:	dadff0ef          	jal	ra,8000510c <printint>
      i += 1;
    80005364:	0029849b          	addiw	s1,s3,2
    80005368:	bde1                	j	80005240 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000536a:	f8843783          	ld	a5,-120(s0)
    8000536e:	00878713          	addi	a4,a5,8
    80005372:	f8e43423          	sd	a4,-120(s0)
    80005376:	4601                	li	a2,0
    80005378:	45a9                	li	a1,10
    8000537a:	6388                	ld	a0,0(a5)
    8000537c:	d91ff0ef          	jal	ra,8000510c <printint>
      i += 2;
    80005380:	0039849b          	addiw	s1,s3,3
    80005384:	bd75                	j	80005240 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    80005386:	f8843783          	ld	a5,-120(s0)
    8000538a:	00878713          	addi	a4,a5,8
    8000538e:	f8e43423          	sd	a4,-120(s0)
    80005392:	4601                	li	a2,0
    80005394:	45c1                	li	a1,16
    80005396:	4388                	lw	a0,0(a5)
    80005398:	d75ff0ef          	jal	ra,8000510c <printint>
    8000539c:	b555                	j	80005240 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    8000539e:	f8843783          	ld	a5,-120(s0)
    800053a2:	00878713          	addi	a4,a5,8
    800053a6:	f8e43423          	sd	a4,-120(s0)
    800053aa:	4601                	li	a2,0
    800053ac:	45c1                	li	a1,16
    800053ae:	6388                	ld	a0,0(a5)
    800053b0:	d5dff0ef          	jal	ra,8000510c <printint>
      i += 1;
    800053b4:	0029849b          	addiw	s1,s3,2
    800053b8:	b561                	j	80005240 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800053ba:	f8843783          	ld	a5,-120(s0)
    800053be:	00878713          	addi	a4,a5,8
    800053c2:	f8e43423          	sd	a4,-120(s0)
    800053c6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800053ca:	03000513          	li	a0,48
    800053ce:	b57ff0ef          	jal	ra,80004f24 <consputc>
  consputc('x');
    800053d2:	856a                	mv	a0,s10
    800053d4:	b51ff0ef          	jal	ra,80004f24 <consputc>
    800053d8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800053da:	03c9d793          	srli	a5,s3,0x3c
    800053de:	97de                	add	a5,a5,s7
    800053e0:	0007c503          	lbu	a0,0(a5)
    800053e4:	b41ff0ef          	jal	ra,80004f24 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800053e8:	0992                	slli	s3,s3,0x4
    800053ea:	397d                	addiw	s2,s2,-1
    800053ec:	fe0917e3          	bnez	s2,800053da <printf+0x23c>
    800053f0:	bd81                	j	80005240 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    800053f2:	f8843783          	ld	a5,-120(s0)
    800053f6:	00878713          	addi	a4,a5,8
    800053fa:	f8e43423          	sd	a4,-120(s0)
    800053fe:	0007b903          	ld	s2,0(a5)
    80005402:	00090d63          	beqz	s2,8000541c <printf+0x27e>
      for(; *s; s++)
    80005406:	00094503          	lbu	a0,0(s2)
    8000540a:	e2050be3          	beqz	a0,80005240 <printf+0xa2>
        consputc(*s);
    8000540e:	b17ff0ef          	jal	ra,80004f24 <consputc>
      for(; *s; s++)
    80005412:	0905                	addi	s2,s2,1
    80005414:	00094503          	lbu	a0,0(s2)
    80005418:	f97d                	bnez	a0,8000540e <printf+0x270>
    8000541a:	b51d                	j	80005240 <printf+0xa2>
        s = "(null)";
    8000541c:	00002917          	auipc	s2,0x2
    80005420:	4d490913          	addi	s2,s2,1236 # 800078f0 <syscalls+0x460>
      for(; *s; s++)
    80005424:	02800513          	li	a0,40
    80005428:	b7dd                	j	8000540e <printf+0x270>
  if(locking)
    8000542a:	f7843783          	ld	a5,-136(s0)
    8000542e:	de079fe3          	bnez	a5,8000522c <printf+0x8e>

  return 0;
}
    80005432:	4501                	li	a0,0
    80005434:	60aa                	ld	ra,136(sp)
    80005436:	640a                	ld	s0,128(sp)
    80005438:	74e6                	ld	s1,120(sp)
    8000543a:	7946                	ld	s2,112(sp)
    8000543c:	79a6                	ld	s3,104(sp)
    8000543e:	7a06                	ld	s4,96(sp)
    80005440:	6ae6                	ld	s5,88(sp)
    80005442:	6b46                	ld	s6,80(sp)
    80005444:	6ba6                	ld	s7,72(sp)
    80005446:	6c06                	ld	s8,64(sp)
    80005448:	7ce2                	ld	s9,56(sp)
    8000544a:	7d42                	ld	s10,48(sp)
    8000544c:	7da2                	ld	s11,40(sp)
    8000544e:	6169                	addi	sp,sp,208
    80005450:	8082                	ret

0000000080005452 <panic>:

void
panic(char *s)
{
    80005452:	1101                	addi	sp,sp,-32
    80005454:	ec06                	sd	ra,24(sp)
    80005456:	e822                	sd	s0,16(sp)
    80005458:	e426                	sd	s1,8(sp)
    8000545a:	1000                	addi	s0,sp,32
    8000545c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000545e:	0001c797          	auipc	a5,0x1c
    80005462:	a807a923          	sw	zero,-1390(a5) # 80020ef0 <pr+0x18>
  printf("panic: ");
    80005466:	00002517          	auipc	a0,0x2
    8000546a:	49250513          	addi	a0,a0,1170 # 800078f8 <syscalls+0x468>
    8000546e:	d31ff0ef          	jal	ra,8000519e <printf>
  printf("%s\n", s);
    80005472:	85a6                	mv	a1,s1
    80005474:	00002517          	auipc	a0,0x2
    80005478:	48c50513          	addi	a0,a0,1164 # 80007900 <syscalls+0x470>
    8000547c:	d23ff0ef          	jal	ra,8000519e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005480:	4785                	li	a5,1
    80005482:	00002717          	auipc	a4,0x2
    80005486:	56f72523          	sw	a5,1386(a4) # 800079ec <panicked>
  for(;;)
    8000548a:	a001                	j	8000548a <panic+0x38>

000000008000548c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000548c:	1101                	addi	sp,sp,-32
    8000548e:	ec06                	sd	ra,24(sp)
    80005490:	e822                	sd	s0,16(sp)
    80005492:	e426                	sd	s1,8(sp)
    80005494:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005496:	0001c497          	auipc	s1,0x1c
    8000549a:	a4248493          	addi	s1,s1,-1470 # 80020ed8 <pr>
    8000549e:	00002597          	auipc	a1,0x2
    800054a2:	46a58593          	addi	a1,a1,1130 # 80007908 <syscalls+0x478>
    800054a6:	8526                	mv	a0,s1
    800054a8:	23a000ef          	jal	ra,800056e2 <initlock>
  pr.locking = 1;
    800054ac:	4785                	li	a5,1
    800054ae:	cc9c                	sw	a5,24(s1)
}
    800054b0:	60e2                	ld	ra,24(sp)
    800054b2:	6442                	ld	s0,16(sp)
    800054b4:	64a2                	ld	s1,8(sp)
    800054b6:	6105                	addi	sp,sp,32
    800054b8:	8082                	ret

00000000800054ba <uartinit>:

void uartstart();

void
uartinit(void)
{
    800054ba:	1141                	addi	sp,sp,-16
    800054bc:	e406                	sd	ra,8(sp)
    800054be:	e022                	sd	s0,0(sp)
    800054c0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800054c2:	100007b7          	lui	a5,0x10000
    800054c6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800054ca:	f8000713          	li	a4,-128
    800054ce:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800054d2:	470d                	li	a4,3
    800054d4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800054d8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800054dc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800054e0:	469d                	li	a3,7
    800054e2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800054e6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800054ea:	00002597          	auipc	a1,0x2
    800054ee:	43e58593          	addi	a1,a1,1086 # 80007928 <digits+0x18>
    800054f2:	0001c517          	auipc	a0,0x1c
    800054f6:	a0650513          	addi	a0,a0,-1530 # 80020ef8 <uart_tx_lock>
    800054fa:	1e8000ef          	jal	ra,800056e2 <initlock>
}
    800054fe:	60a2                	ld	ra,8(sp)
    80005500:	6402                	ld	s0,0(sp)
    80005502:	0141                	addi	sp,sp,16
    80005504:	8082                	ret

0000000080005506 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005506:	1101                	addi	sp,sp,-32
    80005508:	ec06                	sd	ra,24(sp)
    8000550a:	e822                	sd	s0,16(sp)
    8000550c:	e426                	sd	s1,8(sp)
    8000550e:	1000                	addi	s0,sp,32
    80005510:	84aa                	mv	s1,a0
  push_off();
    80005512:	210000ef          	jal	ra,80005722 <push_off>

  if(panicked){
    80005516:	00002797          	auipc	a5,0x2
    8000551a:	4d67a783          	lw	a5,1238(a5) # 800079ec <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000551e:	10000737          	lui	a4,0x10000
  if(panicked){
    80005522:	c391                	beqz	a5,80005526 <uartputc_sync+0x20>
    for(;;)
    80005524:	a001                	j	80005524 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005526:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000552a:	0207f793          	andi	a5,a5,32
    8000552e:	dfe5                	beqz	a5,80005526 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80005530:	0ff4f513          	zext.b	a0,s1
    80005534:	100007b7          	lui	a5,0x10000
    80005538:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000553c:	26a000ef          	jal	ra,800057a6 <pop_off>
}
    80005540:	60e2                	ld	ra,24(sp)
    80005542:	6442                	ld	s0,16(sp)
    80005544:	64a2                	ld	s1,8(sp)
    80005546:	6105                	addi	sp,sp,32
    80005548:	8082                	ret

000000008000554a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000554a:	00002797          	auipc	a5,0x2
    8000554e:	4a67b783          	ld	a5,1190(a5) # 800079f0 <uart_tx_r>
    80005552:	00002717          	auipc	a4,0x2
    80005556:	4a673703          	ld	a4,1190(a4) # 800079f8 <uart_tx_w>
    8000555a:	06f70c63          	beq	a4,a5,800055d2 <uartstart+0x88>
{
    8000555e:	7139                	addi	sp,sp,-64
    80005560:	fc06                	sd	ra,56(sp)
    80005562:	f822                	sd	s0,48(sp)
    80005564:	f426                	sd	s1,40(sp)
    80005566:	f04a                	sd	s2,32(sp)
    80005568:	ec4e                	sd	s3,24(sp)
    8000556a:	e852                	sd	s4,16(sp)
    8000556c:	e456                	sd	s5,8(sp)
    8000556e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }

    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005570:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }

    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005574:	0001ca17          	auipc	s4,0x1c
    80005578:	984a0a13          	addi	s4,s4,-1660 # 80020ef8 <uart_tx_lock>
    uart_tx_r += 1;
    8000557c:	00002497          	auipc	s1,0x2
    80005580:	47448493          	addi	s1,s1,1140 # 800079f0 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80005584:	00002997          	auipc	s3,0x2
    80005588:	47498993          	addi	s3,s3,1140 # 800079f8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000558c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80005590:	02077713          	andi	a4,a4,32
    80005594:	c715                	beqz	a4,800055c0 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005596:	01f7f713          	andi	a4,a5,31
    8000559a:	9752                	add	a4,a4,s4
    8000559c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800055a0:	0785                	addi	a5,a5,1
    800055a2:	e09c                	sd	a5,0(s1)

    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800055a4:	8526                	mv	a0,s1
    800055a6:	f3ffb0ef          	jal	ra,800014e4 <wakeup>

    WriteReg(THR, c);
    800055aa:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800055ae:	609c                	ld	a5,0(s1)
    800055b0:	0009b703          	ld	a4,0(s3)
    800055b4:	fcf71ce3          	bne	a4,a5,8000558c <uartstart+0x42>
      ReadReg(ISR);
    800055b8:	100007b7          	lui	a5,0x10000
    800055bc:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    800055c0:	70e2                	ld	ra,56(sp)
    800055c2:	7442                	ld	s0,48(sp)
    800055c4:	74a2                	ld	s1,40(sp)
    800055c6:	7902                	ld	s2,32(sp)
    800055c8:	69e2                	ld	s3,24(sp)
    800055ca:	6a42                	ld	s4,16(sp)
    800055cc:	6aa2                	ld	s5,8(sp)
    800055ce:	6121                	addi	sp,sp,64
    800055d0:	8082                	ret
      ReadReg(ISR);
    800055d2:	100007b7          	lui	a5,0x10000
    800055d6:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    800055da:	8082                	ret

00000000800055dc <uartputc>:
{
    800055dc:	7179                	addi	sp,sp,-48
    800055de:	f406                	sd	ra,40(sp)
    800055e0:	f022                	sd	s0,32(sp)
    800055e2:	ec26                	sd	s1,24(sp)
    800055e4:	e84a                	sd	s2,16(sp)
    800055e6:	e44e                	sd	s3,8(sp)
    800055e8:	e052                	sd	s4,0(sp)
    800055ea:	1800                	addi	s0,sp,48
    800055ec:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800055ee:	0001c517          	auipc	a0,0x1c
    800055f2:	90a50513          	addi	a0,a0,-1782 # 80020ef8 <uart_tx_lock>
    800055f6:	16c000ef          	jal	ra,80005762 <acquire>
  if(panicked){
    800055fa:	00002797          	auipc	a5,0x2
    800055fe:	3f27a783          	lw	a5,1010(a5) # 800079ec <panicked>
    80005602:	efbd                	bnez	a5,80005680 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005604:	00002717          	auipc	a4,0x2
    80005608:	3f473703          	ld	a4,1012(a4) # 800079f8 <uart_tx_w>
    8000560c:	00002797          	auipc	a5,0x2
    80005610:	3e47b783          	ld	a5,996(a5) # 800079f0 <uart_tx_r>
    80005614:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005618:	0001c997          	auipc	s3,0x1c
    8000561c:	8e098993          	addi	s3,s3,-1824 # 80020ef8 <uart_tx_lock>
    80005620:	00002497          	auipc	s1,0x2
    80005624:	3d048493          	addi	s1,s1,976 # 800079f0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005628:	00002917          	auipc	s2,0x2
    8000562c:	3d090913          	addi	s2,s2,976 # 800079f8 <uart_tx_w>
    80005630:	00e79d63          	bne	a5,a4,8000564a <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005634:	85ce                	mv	a1,s3
    80005636:	8526                	mv	a0,s1
    80005638:	e61fb0ef          	jal	ra,80001498 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000563c:	00093703          	ld	a4,0(s2)
    80005640:	609c                	ld	a5,0(s1)
    80005642:	02078793          	addi	a5,a5,32
    80005646:	fee787e3          	beq	a5,a4,80005634 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000564a:	0001c497          	auipc	s1,0x1c
    8000564e:	8ae48493          	addi	s1,s1,-1874 # 80020ef8 <uart_tx_lock>
    80005652:	01f77793          	andi	a5,a4,31
    80005656:	97a6                	add	a5,a5,s1
    80005658:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    8000565c:	0705                	addi	a4,a4,1
    8000565e:	00002797          	auipc	a5,0x2
    80005662:	38e7bd23          	sd	a4,922(a5) # 800079f8 <uart_tx_w>
  uartstart();
    80005666:	ee5ff0ef          	jal	ra,8000554a <uartstart>
  release(&uart_tx_lock);
    8000566a:	8526                	mv	a0,s1
    8000566c:	18e000ef          	jal	ra,800057fa <release>
}
    80005670:	70a2                	ld	ra,40(sp)
    80005672:	7402                	ld	s0,32(sp)
    80005674:	64e2                	ld	s1,24(sp)
    80005676:	6942                	ld	s2,16(sp)
    80005678:	69a2                	ld	s3,8(sp)
    8000567a:	6a02                	ld	s4,0(sp)
    8000567c:	6145                	addi	sp,sp,48
    8000567e:	8082                	ret
    for(;;)
    80005680:	a001                	j	80005680 <uartputc+0xa4>

0000000080005682 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005682:	1141                	addi	sp,sp,-16
    80005684:	e422                	sd	s0,8(sp)
    80005686:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80005688:	100007b7          	lui	a5,0x10000
    8000568c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80005690:	8b85                	andi	a5,a5,1
    80005692:	cb81                	beqz	a5,800056a2 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80005694:	100007b7          	lui	a5,0x10000
    80005698:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000569c:	6422                	ld	s0,8(sp)
    8000569e:	0141                	addi	sp,sp,16
    800056a0:	8082                	ret
    return -1;
    800056a2:	557d                	li	a0,-1
    800056a4:	bfe5                	j	8000569c <uartgetc+0x1a>

00000000800056a6 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800056a6:	1101                	addi	sp,sp,-32
    800056a8:	ec06                	sd	ra,24(sp)
    800056aa:	e822                	sd	s0,16(sp)
    800056ac:	e426                	sd	s1,8(sp)
    800056ae:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800056b0:	54fd                	li	s1,-1
    800056b2:	a019                	j	800056b8 <uartintr+0x12>
      break;
    consoleintr(c);
    800056b4:	8a3ff0ef          	jal	ra,80004f56 <consoleintr>
    int c = uartgetc();
    800056b8:	fcbff0ef          	jal	ra,80005682 <uartgetc>
    if(c == -1)
    800056bc:	fe951ce3          	bne	a0,s1,800056b4 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800056c0:	0001c497          	auipc	s1,0x1c
    800056c4:	83848493          	addi	s1,s1,-1992 # 80020ef8 <uart_tx_lock>
    800056c8:	8526                	mv	a0,s1
    800056ca:	098000ef          	jal	ra,80005762 <acquire>
  uartstart();
    800056ce:	e7dff0ef          	jal	ra,8000554a <uartstart>
  release(&uart_tx_lock);
    800056d2:	8526                	mv	a0,s1
    800056d4:	126000ef          	jal	ra,800057fa <release>
}
    800056d8:	60e2                	ld	ra,24(sp)
    800056da:	6442                	ld	s0,16(sp)
    800056dc:	64a2                	ld	s1,8(sp)
    800056de:	6105                	addi	sp,sp,32
    800056e0:	8082                	ret

00000000800056e2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800056e2:	1141                	addi	sp,sp,-16
    800056e4:	e422                	sd	s0,8(sp)
    800056e6:	0800                	addi	s0,sp,16
  lk->name = name;
    800056e8:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800056ea:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800056ee:	00053823          	sd	zero,16(a0)
}
    800056f2:	6422                	ld	s0,8(sp)
    800056f4:	0141                	addi	sp,sp,16
    800056f6:	8082                	ret

00000000800056f8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800056f8:	411c                	lw	a5,0(a0)
    800056fa:	e399                	bnez	a5,80005700 <holding+0x8>
    800056fc:	4501                	li	a0,0
  return r;
}
    800056fe:	8082                	ret
{
    80005700:	1101                	addi	sp,sp,-32
    80005702:	ec06                	sd	ra,24(sp)
    80005704:	e822                	sd	s0,16(sp)
    80005706:	e426                	sd	s1,8(sp)
    80005708:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    8000570a:	6904                	ld	s1,16(a0)
    8000570c:	fa4fb0ef          	jal	ra,80000eb0 <mycpu>
    80005710:	40a48533          	sub	a0,s1,a0
    80005714:	00153513          	seqz	a0,a0
}
    80005718:	60e2                	ld	ra,24(sp)
    8000571a:	6442                	ld	s0,16(sp)
    8000571c:	64a2                	ld	s1,8(sp)
    8000571e:	6105                	addi	sp,sp,32
    80005720:	8082                	ret

0000000080005722 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005722:	1101                	addi	sp,sp,-32
    80005724:	ec06                	sd	ra,24(sp)
    80005726:	e822                	sd	s0,16(sp)
    80005728:	e426                	sd	s1,8(sp)
    8000572a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000572c:	100024f3          	csrr	s1,sstatus
    80005730:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005734:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005736:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    8000573a:	f76fb0ef          	jal	ra,80000eb0 <mycpu>
    8000573e:	5d3c                	lw	a5,120(a0)
    80005740:	cb99                	beqz	a5,80005756 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005742:	f6efb0ef          	jal	ra,80000eb0 <mycpu>
    80005746:	5d3c                	lw	a5,120(a0)
    80005748:	2785                	addiw	a5,a5,1
    8000574a:	dd3c                	sw	a5,120(a0)
}
    8000574c:	60e2                	ld	ra,24(sp)
    8000574e:	6442                	ld	s0,16(sp)
    80005750:	64a2                	ld	s1,8(sp)
    80005752:	6105                	addi	sp,sp,32
    80005754:	8082                	ret
    mycpu()->intena = old;
    80005756:	f5afb0ef          	jal	ra,80000eb0 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    8000575a:	8085                	srli	s1,s1,0x1
    8000575c:	8885                	andi	s1,s1,1
    8000575e:	dd64                	sw	s1,124(a0)
    80005760:	b7cd                	j	80005742 <push_off+0x20>

0000000080005762 <acquire>:
{
    80005762:	1101                	addi	sp,sp,-32
    80005764:	ec06                	sd	ra,24(sp)
    80005766:	e822                	sd	s0,16(sp)
    80005768:	e426                	sd	s1,8(sp)
    8000576a:	1000                	addi	s0,sp,32
    8000576c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    8000576e:	fb5ff0ef          	jal	ra,80005722 <push_off>
  if(holding(lk))
    80005772:	8526                	mv	a0,s1
    80005774:	f85ff0ef          	jal	ra,800056f8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005778:	4705                	li	a4,1
  if(holding(lk))
    8000577a:	e105                	bnez	a0,8000579a <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000577c:	87ba                	mv	a5,a4
    8000577e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005782:	2781                	sext.w	a5,a5
    80005784:	ffe5                	bnez	a5,8000577c <acquire+0x1a>
  __sync_synchronize();
    80005786:	0ff0000f          	fence
  lk->cpu = mycpu();
    8000578a:	f26fb0ef          	jal	ra,80000eb0 <mycpu>
    8000578e:	e888                	sd	a0,16(s1)
}
    80005790:	60e2                	ld	ra,24(sp)
    80005792:	6442                	ld	s0,16(sp)
    80005794:	64a2                	ld	s1,8(sp)
    80005796:	6105                	addi	sp,sp,32
    80005798:	8082                	ret
    panic("acquire");
    8000579a:	00002517          	auipc	a0,0x2
    8000579e:	19650513          	addi	a0,a0,406 # 80007930 <digits+0x20>
    800057a2:	cb1ff0ef          	jal	ra,80005452 <panic>

00000000800057a6 <pop_off>:

void
pop_off(void)
{
    800057a6:	1141                	addi	sp,sp,-16
    800057a8:	e406                	sd	ra,8(sp)
    800057aa:	e022                	sd	s0,0(sp)
    800057ac:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800057ae:	f02fb0ef          	jal	ra,80000eb0 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800057b2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800057b6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800057b8:	e78d                	bnez	a5,800057e2 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800057ba:	5d3c                	lw	a5,120(a0)
    800057bc:	02f05963          	blez	a5,800057ee <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    800057c0:	37fd                	addiw	a5,a5,-1
    800057c2:	0007871b          	sext.w	a4,a5
    800057c6:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800057c8:	eb09                	bnez	a4,800057da <pop_off+0x34>
    800057ca:	5d7c                	lw	a5,124(a0)
    800057cc:	c799                	beqz	a5,800057da <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800057ce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800057d2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800057d6:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800057da:	60a2                	ld	ra,8(sp)
    800057dc:	6402                	ld	s0,0(sp)
    800057de:	0141                	addi	sp,sp,16
    800057e0:	8082                	ret
    panic("pop_off - interruptible");
    800057e2:	00002517          	auipc	a0,0x2
    800057e6:	15650513          	addi	a0,a0,342 # 80007938 <digits+0x28>
    800057ea:	c69ff0ef          	jal	ra,80005452 <panic>
    panic("pop_off");
    800057ee:	00002517          	auipc	a0,0x2
    800057f2:	16250513          	addi	a0,a0,354 # 80007950 <digits+0x40>
    800057f6:	c5dff0ef          	jal	ra,80005452 <panic>

00000000800057fa <release>:
{
    800057fa:	1101                	addi	sp,sp,-32
    800057fc:	ec06                	sd	ra,24(sp)
    800057fe:	e822                	sd	s0,16(sp)
    80005800:	e426                	sd	s1,8(sp)
    80005802:	1000                	addi	s0,sp,32
    80005804:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005806:	ef3ff0ef          	jal	ra,800056f8 <holding>
    8000580a:	c105                	beqz	a0,8000582a <release+0x30>
  lk->cpu = 0;
    8000580c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005810:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80005814:	0f50000f          	fence	iorw,ow
    80005818:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8000581c:	f8bff0ef          	jal	ra,800057a6 <pop_off>
}
    80005820:	60e2                	ld	ra,24(sp)
    80005822:	6442                	ld	s0,16(sp)
    80005824:	64a2                	ld	s1,8(sp)
    80005826:	6105                	addi	sp,sp,32
    80005828:	8082                	ret
    panic("release");
    8000582a:	00002517          	auipc	a0,0x2
    8000582e:	12e50513          	addi	a0,a0,302 # 80007958 <digits+0x48>
    80005832:	c21ff0ef          	jal	ra,80005452 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
