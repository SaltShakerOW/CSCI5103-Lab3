
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	a5013103          	ld	sp,-1456(sp) # 80007a50 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	6f7040ef          	jal	ra,80004f0c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <superinit>:
  superinit(); //allocate space for superpages before regular pages
  freerange(end, (void*)PHYSTOP - (uint64)NSUPERPAGES * SUPERPGSIZE); //modification made here to ensure space for 60 superpages
}

void
superinit() {
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
  initlock(&supermem.lock, "supermem");
    80000024:	00007597          	auipc	a1,0x7
    80000028:	fec58593          	addi	a1,a1,-20 # 80007010 <etext+0x10>
    8000002c:	00008517          	auipc	a0,0x8
    80000030:	a7450513          	addi	a0,a0,-1420 # 80007aa0 <supermem>
    80000034:	05f050ef          	jal	ra,80005892 <initlock>
  supermem.nfree = 0; //reset number of free superpages

  uint64 top = PHYSTOP; //start allocation at top of memory space
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    80000038:	00008697          	auipc	a3,0x8
    8000003c:	a8068693          	addi	a3,a3,-1408 # 80007ab8 <supermem+0x18>
  initlock(&supermem.lock, "supermem");
    80000040:	4705                	li	a4,1
  uint64 top = PHYSTOP; //start allocation at top of memory space
    80000042:	47c5                	li	a5,17
    80000044:	07ee                	slli	a5,a5,0x1b
    top -= SUPERPGSIZE;
    80000046:	ffe00537          	lui	a0,0xffe00
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    8000004a:	10100613          	li	a2,257
    8000004e:	065e                	slli	a2,a2,0x17
    top -= SUPERPGSIZE;
    80000050:	97aa                	add	a5,a5,a0
    top = top & ~((uint64)SUPERPGSIZE - 1); //superpage boundary alignment
    supermem.superpages[supermem.nfree] = (void*)top; //add superpage address to pool
    80000052:	e29c                	sd	a5,0(a3)
    supermem.nfree++; //increase number of free superpages
    80000054:	0007059b          	sext.w	a1,a4
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    80000058:	0705                	addi	a4,a4,1
    8000005a:	06a1                	addi	a3,a3,8
    8000005c:	fec79ae3          	bne	a5,a2,80000050 <superinit+0x34>
    80000060:	00008797          	auipc	a5,0x8
    80000064:	c2b7ac23          	sw	a1,-968(a5) # 80007c98 <supermem+0x1f8>
  }
}
    80000068:	60a2                	ld	ra,8(sp)
    8000006a:	6402                	ld	s0,0(sp)
    8000006c:	0141                	addi	sp,sp,16
    8000006e:	8082                	ret

0000000080000070 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000070:	7179                	addi	sp,sp,-48
    80000072:	f406                	sd	ra,40(sp)
    80000074:	f022                	sd	s0,32(sp)
    80000076:	ec26                	sd	s1,24(sp)
    80000078:	e84a                	sd	s2,16(sp)
    8000007a:	e44e                	sd	s3,8(sp)
    8000007c:	1800                	addi	s0,sp,48
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    8000007e:	03451793          	slli	a5,a0,0x34
    80000082:	ebb1                	bnez	a5,800000d6 <kfree+0x66>
    80000084:	84aa                	mv	s1,a0
    80000086:	00021797          	auipc	a5,0x21
    8000008a:	f4a78793          	addi	a5,a5,-182 # 80020fd0 <end>
    8000008e:	04f56463          	bltu	a0,a5,800000d6 <kfree+0x66>
    80000092:	47c5                	li	a5,17
    80000094:	07ee                	slli	a5,a5,0x1b
    80000096:	04f57063          	bgeu	a0,a5,800000d6 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000009a:	6605                	lui	a2,0x1
    8000009c:	4585                	li	a1,1
    8000009e:	214000ef          	jal	ra,800002b2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800000a2:	00008997          	auipc	s3,0x8
    800000a6:	9fe98993          	addi	s3,s3,-1538 # 80007aa0 <supermem>
    800000aa:	00008917          	auipc	s2,0x8
    800000ae:	bf690913          	addi	s2,s2,-1034 # 80007ca0 <kmem>
    800000b2:	854a                	mv	a0,s2
    800000b4:	05f050ef          	jal	ra,80005912 <acquire>
  r->next = kmem.freelist;
    800000b8:	2189b783          	ld	a5,536(s3)
    800000bc:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800000be:	2099bc23          	sd	s1,536(s3)
  release(&kmem.lock);
    800000c2:	854a                	mv	a0,s2
    800000c4:	0e7050ef          	jal	ra,800059aa <release>
}
    800000c8:	70a2                	ld	ra,40(sp)
    800000ca:	7402                	ld	s0,32(sp)
    800000cc:	64e2                	ld	s1,24(sp)
    800000ce:	6942                	ld	s2,16(sp)
    800000d0:	69a2                	ld	s3,8(sp)
    800000d2:	6145                	addi	sp,sp,48
    800000d4:	8082                	ret
    panic("kfree");
    800000d6:	00007517          	auipc	a0,0x7
    800000da:	f4a50513          	addi	a0,a0,-182 # 80007020 <etext+0x20>
    800000de:	524050ef          	jal	ra,80005602 <panic>

00000000800000e2 <freerange>:
{
    800000e2:	7179                	addi	sp,sp,-48
    800000e4:	f406                	sd	ra,40(sp)
    800000e6:	f022                	sd	s0,32(sp)
    800000e8:	ec26                	sd	s1,24(sp)
    800000ea:	e84a                	sd	s2,16(sp)
    800000ec:	e44e                	sd	s3,8(sp)
    800000ee:	e052                	sd	s4,0(sp)
    800000f0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000f2:	6785                	lui	a5,0x1
    800000f4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    800000f8:	00e504b3          	add	s1,a0,a4
    800000fc:	777d                	lui	a4,0xfffff
    800000fe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000100:	94be                	add	s1,s1,a5
    80000102:	0095ec63          	bltu	a1,s1,8000011a <freerange+0x38>
    80000106:	892e                	mv	s2,a1
    kfree(p);
    80000108:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    8000010a:	6985                	lui	s3,0x1
    kfree(p);
    8000010c:	01448533          	add	a0,s1,s4
    80000110:	f61ff0ef          	jal	ra,80000070 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000114:	94ce                	add	s1,s1,s3
    80000116:	fe997be3          	bgeu	s2,s1,8000010c <freerange+0x2a>
}
    8000011a:	70a2                	ld	ra,40(sp)
    8000011c:	7402                	ld	s0,32(sp)
    8000011e:	64e2                	ld	s1,24(sp)
    80000120:	6942                	ld	s2,16(sp)
    80000122:	69a2                	ld	s3,8(sp)
    80000124:	6a02                	ld	s4,0(sp)
    80000126:	6145                	addi	sp,sp,48
    80000128:	8082                	ret

000000008000012a <kinit>:
{
    8000012a:	1141                	addi	sp,sp,-16
    8000012c:	e406                	sd	ra,8(sp)
    8000012e:	e022                	sd	s0,0(sp)
    80000130:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000132:	00007597          	auipc	a1,0x7
    80000136:	ef658593          	addi	a1,a1,-266 # 80007028 <etext+0x28>
    8000013a:	00008517          	auipc	a0,0x8
    8000013e:	b6650513          	addi	a0,a0,-1178 # 80007ca0 <kmem>
    80000142:	750050ef          	jal	ra,80005892 <initlock>
  superinit(); //allocate space for superpages before regular pages
    80000146:	ed7ff0ef          	jal	ra,8000001c <superinit>
  freerange(end, (void*)PHYSTOP - (uint64)NSUPERPAGES * SUPERPGSIZE); //modification made here to ensure space for 60 superpages
    8000014a:	10100593          	li	a1,257
    8000014e:	05de                	slli	a1,a1,0x17
    80000150:	00021517          	auipc	a0,0x21
    80000154:	e8050513          	addi	a0,a0,-384 # 80020fd0 <end>
    80000158:	f8bff0ef          	jal	ra,800000e2 <freerange>
}
    8000015c:	60a2                	ld	ra,8(sp)
    8000015e:	6402                	ld	s0,0(sp)
    80000160:	0141                	addi	sp,sp,16
    80000162:	8082                	ret

0000000080000164 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000164:	1101                	addi	sp,sp,-32
    80000166:	ec06                	sd	ra,24(sp)
    80000168:	e822                	sd	s0,16(sp)
    8000016a:	e426                	sd	s1,8(sp)
    8000016c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000016e:	00008517          	auipc	a0,0x8
    80000172:	b3250513          	addi	a0,a0,-1230 # 80007ca0 <kmem>
    80000176:	79c050ef          	jal	ra,80005912 <acquire>
  r = kmem.freelist;
    8000017a:	00008497          	auipc	s1,0x8
    8000017e:	b3e4b483          	ld	s1,-1218(s1) # 80007cb8 <kmem+0x18>
  if (r) {
    80000182:	c49d                	beqz	s1,800001b0 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000184:	609c                	ld	a5,0(s1)
    80000186:	00008717          	auipc	a4,0x8
    8000018a:	b2f73923          	sd	a5,-1230(a4) # 80007cb8 <kmem+0x18>
  }
  release(&kmem.lock);
    8000018e:	00008517          	auipc	a0,0x8
    80000192:	b1250513          	addi	a0,a0,-1262 # 80007ca0 <kmem>
    80000196:	015050ef          	jal	ra,800059aa <release>

  if (r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000019a:	6605                	lui	a2,0x1
    8000019c:	4595                	li	a1,5
    8000019e:	8526                	mv	a0,s1
    800001a0:	112000ef          	jal	ra,800002b2 <memset>
  }
  return (void*)r;
}
    800001a4:	8526                	mv	a0,s1
    800001a6:	60e2                	ld	ra,24(sp)
    800001a8:	6442                	ld	s0,16(sp)
    800001aa:	64a2                	ld	s1,8(sp)
    800001ac:	6105                	addi	sp,sp,32
    800001ae:	8082                	ret
  release(&kmem.lock);
    800001b0:	00008517          	auipc	a0,0x8
    800001b4:	af050513          	addi	a0,a0,-1296 # 80007ca0 <kmem>
    800001b8:	7f2050ef          	jal	ra,800059aa <release>
  if (r) {
    800001bc:	b7e5                	j	800001a4 <kalloc+0x40>

00000000800001be <superalloc>:

void *
superalloc(void) {
    800001be:	1101                	addi	sp,sp,-32
    800001c0:	ec06                	sd	ra,24(sp)
    800001c2:	e822                	sd	s0,16(sp)
    800001c4:	e426                	sd	s1,8(sp)
    800001c6:	1000                	addi	s0,sp,32
  acquire(&supermem.lock);
    800001c8:	00008497          	auipc	s1,0x8
    800001cc:	8d848493          	addi	s1,s1,-1832 # 80007aa0 <supermem>
    800001d0:	8526                	mv	a0,s1
    800001d2:	740050ef          	jal	ra,80005912 <acquire>
  if (supermem.nfree == 0) { //no free superpages
    800001d6:	1f84a783          	lw	a5,504(s1)
    800001da:	cf8d                	beqz	a5,80000214 <superalloc+0x56>
    release(&supermem.lock);
    return 0;
  }
  supermem.nfree--;
    800001dc:	fff7871b          	addiw	a4,a5,-1
    800001e0:	0007079b          	sext.w	a5,a4
    800001e4:	00008517          	auipc	a0,0x8
    800001e8:	8bc50513          	addi	a0,a0,-1860 # 80007aa0 <supermem>
    800001ec:	1ee52c23          	sw	a4,504(a0)
  void *pg = supermem.superpages[supermem.nfree];
    800001f0:	0789                	addi	a5,a5,2
    800001f2:	078e                	slli	a5,a5,0x3
    800001f4:	97aa                	add	a5,a5,a0
    800001f6:	6784                	ld	s1,8(a5)
  release(&supermem.lock);
    800001f8:	7b2050ef          	jal	ra,800059aa <release>
  memset(pg, 5, SUPERPGSIZE);
    800001fc:	00200637          	lui	a2,0x200
    80000200:	4595                	li	a1,5
    80000202:	8526                	mv	a0,s1
    80000204:	0ae000ef          	jal	ra,800002b2 <memset>
  return pg;
}
    80000208:	8526                	mv	a0,s1
    8000020a:	60e2                	ld	ra,24(sp)
    8000020c:	6442                	ld	s0,16(sp)
    8000020e:	64a2                	ld	s1,8(sp)
    80000210:	6105                	addi	sp,sp,32
    80000212:	8082                	ret
    release(&supermem.lock);
    80000214:	8526                	mv	a0,s1
    80000216:	794050ef          	jal	ra,800059aa <release>
    return 0;
    8000021a:	4481                	li	s1,0
    8000021c:	b7f5                	j	80000208 <superalloc+0x4a>

000000008000021e <superfree>:

void
superfree(void *pa) {
    8000021e:	1101                	addi	sp,sp,-32
    80000220:	ec06                	sd	ra,24(sp)
    80000222:	e822                	sd	s0,16(sp)
    80000224:	e426                	sd	s1,8(sp)
    80000226:	e04a                	sd	s2,0(sp)
    80000228:	1000                	addi	s0,sp,32
  if ((uint64)pa % SUPERPGSIZE != 0) { //check if pa belongs to our address pool (address alignment)
    8000022a:	02b51793          	slli	a5,a0,0x2b
    8000022e:	e3a5                	bnez	a5,8000028e <superfree+0x70>
    80000230:	84aa                	mv	s1,a0
    panic("superfree: pa not 2MiB aligned");
  }
  if ((uint64)pa < PHYSTOP - (uint64)NSUPERPAGES * SUPERPGSIZE || (uint64)pa >= PHYSTOP) {
    80000232:	eff00793          	li	a5,-257
    80000236:	07de                	slli	a5,a5,0x17
    80000238:	97aa                	add	a5,a5,a0
    8000023a:	07800737          	lui	a4,0x7800
    8000023e:	04e7fe63          	bgeu	a5,a4,8000029a <superfree+0x7c>
    panic("superfree: pa outside of superpage pool range");
  }
  memset(pa, 1, SUPERPGSIZE); //set page to junk just like kfree
    80000242:	00200637          	lui	a2,0x200
    80000246:	4585                	li	a1,1
    80000248:	06a000ef          	jal	ra,800002b2 <memset>
  acquire(&supermem.lock);
    8000024c:	00008917          	auipc	s2,0x8
    80000250:	85490913          	addi	s2,s2,-1964 # 80007aa0 <supermem>
    80000254:	854a                	mv	a0,s2
    80000256:	6bc050ef          	jal	ra,80005912 <acquire>
  if (supermem.nfree >= NSUPERPAGES) {
    8000025a:	1f892783          	lw	a5,504(s2)
    8000025e:	03b00713          	li	a4,59
    80000262:	04f74263          	blt	a4,a5,800002a6 <superfree+0x88>
    panic("superfree: superpage pool overflow");
  }
  supermem.superpages[supermem.nfree] = pa;
    80000266:	00008517          	auipc	a0,0x8
    8000026a:	83a50513          	addi	a0,a0,-1990 # 80007aa0 <supermem>
    8000026e:	00278713          	addi	a4,a5,2
    80000272:	070e                	slli	a4,a4,0x3
    80000274:	972a                	add	a4,a4,a0
    80000276:	e704                	sd	s1,8(a4)
  supermem.nfree++;
    80000278:	2785                	addiw	a5,a5,1
    8000027a:	1ef52c23          	sw	a5,504(a0)
  release(&supermem.lock);
    8000027e:	72c050ef          	jal	ra,800059aa <release>
}
    80000282:	60e2                	ld	ra,24(sp)
    80000284:	6442                	ld	s0,16(sp)
    80000286:	64a2                	ld	s1,8(sp)
    80000288:	6902                	ld	s2,0(sp)
    8000028a:	6105                	addi	sp,sp,32
    8000028c:	8082                	ret
    panic("superfree: pa not 2MiB aligned");
    8000028e:	00007517          	auipc	a0,0x7
    80000292:	da250513          	addi	a0,a0,-606 # 80007030 <etext+0x30>
    80000296:	36c050ef          	jal	ra,80005602 <panic>
    panic("superfree: pa outside of superpage pool range");
    8000029a:	00007517          	auipc	a0,0x7
    8000029e:	db650513          	addi	a0,a0,-586 # 80007050 <etext+0x50>
    800002a2:	360050ef          	jal	ra,80005602 <panic>
    panic("superfree: superpage pool overflow");
    800002a6:	00007517          	auipc	a0,0x7
    800002aa:	dda50513          	addi	a0,a0,-550 # 80007080 <etext+0x80>
    800002ae:	354050ef          	jal	ra,80005602 <panic>

00000000800002b2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800002b2:	1141                	addi	sp,sp,-16
    800002b4:	e422                	sd	s0,8(sp)
    800002b6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800002b8:	ca19                	beqz	a2,800002ce <memset+0x1c>
    800002ba:	87aa                	mv	a5,a0
    800002bc:	1602                	slli	a2,a2,0x20
    800002be:	9201                	srli	a2,a2,0x20
    800002c0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    800002c4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800002c8:	0785                	addi	a5,a5,1
    800002ca:	fee79de3          	bne	a5,a4,800002c4 <memset+0x12>
  }
  return dst;
}
    800002ce:	6422                	ld	s0,8(sp)
    800002d0:	0141                	addi	sp,sp,16
    800002d2:	8082                	ret

00000000800002d4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800002d4:	1141                	addi	sp,sp,-16
    800002d6:	e422                	sd	s0,8(sp)
    800002d8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800002da:	ca05                	beqz	a2,8000030a <memcmp+0x36>
    800002dc:	fff6069b          	addiw	a3,a2,-1 # 1fffff <_entry-0x7fe00001>
    800002e0:	1682                	slli	a3,a3,0x20
    800002e2:	9281                	srli	a3,a3,0x20
    800002e4:	0685                	addi	a3,a3,1
    800002e6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800002e8:	00054783          	lbu	a5,0(a0)
    800002ec:	0005c703          	lbu	a4,0(a1)
    800002f0:	00e79863          	bne	a5,a4,80000300 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800002f4:	0505                	addi	a0,a0,1
    800002f6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800002f8:	fed518e3          	bne	a0,a3,800002e8 <memcmp+0x14>
  }

  return 0;
    800002fc:	4501                	li	a0,0
    800002fe:	a019                	j	80000304 <memcmp+0x30>
      return *s1 - *s2;
    80000300:	40e7853b          	subw	a0,a5,a4
}
    80000304:	6422                	ld	s0,8(sp)
    80000306:	0141                	addi	sp,sp,16
    80000308:	8082                	ret
  return 0;
    8000030a:	4501                	li	a0,0
    8000030c:	bfe5                	j	80000304 <memcmp+0x30>

000000008000030e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    8000030e:	1141                	addi	sp,sp,-16
    80000310:	e422                	sd	s0,8(sp)
    80000312:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000314:	c205                	beqz	a2,80000334 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000316:	02a5e263          	bltu	a1,a0,8000033a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000031a:	1602                	slli	a2,a2,0x20
    8000031c:	9201                	srli	a2,a2,0x20
    8000031e:	00c587b3          	add	a5,a1,a2
{
    80000322:	872a                	mv	a4,a0
      *d++ = *s++;
    80000324:	0585                	addi	a1,a1,1
    80000326:	0705                	addi	a4,a4,1 # 7800001 <_entry-0x787fffff>
    80000328:	fff5c683          	lbu	a3,-1(a1)
    8000032c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000330:	fef59ae3          	bne	a1,a5,80000324 <memmove+0x16>

  return dst;
}
    80000334:	6422                	ld	s0,8(sp)
    80000336:	0141                	addi	sp,sp,16
    80000338:	8082                	ret
  if(s < d && s + n > d){
    8000033a:	02061693          	slli	a3,a2,0x20
    8000033e:	9281                	srli	a3,a3,0x20
    80000340:	00d58733          	add	a4,a1,a3
    80000344:	fce57be3          	bgeu	a0,a4,8000031a <memmove+0xc>
    d += n;
    80000348:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000034a:	fff6079b          	addiw	a5,a2,-1
    8000034e:	1782                	slli	a5,a5,0x20
    80000350:	9381                	srli	a5,a5,0x20
    80000352:	fff7c793          	not	a5,a5
    80000356:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000358:	177d                	addi	a4,a4,-1
    8000035a:	16fd                	addi	a3,a3,-1
    8000035c:	00074603          	lbu	a2,0(a4)
    80000360:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000364:	fee79ae3          	bne	a5,a4,80000358 <memmove+0x4a>
    80000368:	b7f1                	j	80000334 <memmove+0x26>

000000008000036a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000036a:	1141                	addi	sp,sp,-16
    8000036c:	e406                	sd	ra,8(sp)
    8000036e:	e022                	sd	s0,0(sp)
    80000370:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000372:	f9dff0ef          	jal	ra,8000030e <memmove>
}
    80000376:	60a2                	ld	ra,8(sp)
    80000378:	6402                	ld	s0,0(sp)
    8000037a:	0141                	addi	sp,sp,16
    8000037c:	8082                	ret

000000008000037e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000037e:	1141                	addi	sp,sp,-16
    80000380:	e422                	sd	s0,8(sp)
    80000382:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000384:	ce11                	beqz	a2,800003a0 <strncmp+0x22>
    80000386:	00054783          	lbu	a5,0(a0)
    8000038a:	cf89                	beqz	a5,800003a4 <strncmp+0x26>
    8000038c:	0005c703          	lbu	a4,0(a1)
    80000390:	00f71a63          	bne	a4,a5,800003a4 <strncmp+0x26>
    n--, p++, q++;
    80000394:	367d                	addiw	a2,a2,-1
    80000396:	0505                	addi	a0,a0,1
    80000398:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000039a:	f675                	bnez	a2,80000386 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000039c:	4501                	li	a0,0
    8000039e:	a809                	j	800003b0 <strncmp+0x32>
    800003a0:	4501                	li	a0,0
    800003a2:	a039                	j	800003b0 <strncmp+0x32>
  if(n == 0)
    800003a4:	ca09                	beqz	a2,800003b6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800003a6:	00054503          	lbu	a0,0(a0)
    800003aa:	0005c783          	lbu	a5,0(a1)
    800003ae:	9d1d                	subw	a0,a0,a5
}
    800003b0:	6422                	ld	s0,8(sp)
    800003b2:	0141                	addi	sp,sp,16
    800003b4:	8082                	ret
    return 0;
    800003b6:	4501                	li	a0,0
    800003b8:	bfe5                	j	800003b0 <strncmp+0x32>

00000000800003ba <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800003ba:	1141                	addi	sp,sp,-16
    800003bc:	e422                	sd	s0,8(sp)
    800003be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800003c0:	872a                	mv	a4,a0
    800003c2:	8832                	mv	a6,a2
    800003c4:	367d                	addiw	a2,a2,-1
    800003c6:	01005963          	blez	a6,800003d8 <strncpy+0x1e>
    800003ca:	0705                	addi	a4,a4,1
    800003cc:	0005c783          	lbu	a5,0(a1)
    800003d0:	fef70fa3          	sb	a5,-1(a4)
    800003d4:	0585                	addi	a1,a1,1
    800003d6:	f7f5                	bnez	a5,800003c2 <strncpy+0x8>
    ;
  while(n-- > 0)
    800003d8:	86ba                	mv	a3,a4
    800003da:	00c05c63          	blez	a2,800003f2 <strncpy+0x38>
    *s++ = 0;
    800003de:	0685                	addi	a3,a3,1
    800003e0:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800003e4:	40d707bb          	subw	a5,a4,a3
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	010787bb          	addw	a5,a5,a6
    800003ee:	fef048e3          	bgtz	a5,800003de <strncpy+0x24>
  return os;
}
    800003f2:	6422                	ld	s0,8(sp)
    800003f4:	0141                	addi	sp,sp,16
    800003f6:	8082                	ret

00000000800003f8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800003f8:	1141                	addi	sp,sp,-16
    800003fa:	e422                	sd	s0,8(sp)
    800003fc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800003fe:	02c05363          	blez	a2,80000424 <safestrcpy+0x2c>
    80000402:	fff6069b          	addiw	a3,a2,-1
    80000406:	1682                	slli	a3,a3,0x20
    80000408:	9281                	srli	a3,a3,0x20
    8000040a:	96ae                	add	a3,a3,a1
    8000040c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000040e:	00d58963          	beq	a1,a3,80000420 <safestrcpy+0x28>
    80000412:	0585                	addi	a1,a1,1
    80000414:	0785                	addi	a5,a5,1
    80000416:	fff5c703          	lbu	a4,-1(a1)
    8000041a:	fee78fa3          	sb	a4,-1(a5)
    8000041e:	fb65                	bnez	a4,8000040e <safestrcpy+0x16>
    ;
  *s = 0;
    80000420:	00078023          	sb	zero,0(a5)
  return os;
}
    80000424:	6422                	ld	s0,8(sp)
    80000426:	0141                	addi	sp,sp,16
    80000428:	8082                	ret

000000008000042a <strlen>:

int
strlen(const char *s)
{
    8000042a:	1141                	addi	sp,sp,-16
    8000042c:	e422                	sd	s0,8(sp)
    8000042e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000430:	00054783          	lbu	a5,0(a0)
    80000434:	cf91                	beqz	a5,80000450 <strlen+0x26>
    80000436:	0505                	addi	a0,a0,1
    80000438:	87aa                	mv	a5,a0
    8000043a:	4685                	li	a3,1
    8000043c:	9e89                	subw	a3,a3,a0
    8000043e:	00f6853b          	addw	a0,a3,a5
    80000442:	0785                	addi	a5,a5,1
    80000444:	fff7c703          	lbu	a4,-1(a5)
    80000448:	fb7d                	bnez	a4,8000043e <strlen+0x14>
    ;
  return n;
}
    8000044a:	6422                	ld	s0,8(sp)
    8000044c:	0141                	addi	sp,sp,16
    8000044e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000450:	4501                	li	a0,0
    80000452:	bfe5                	j	8000044a <strlen+0x20>

0000000080000454 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000454:	1141                	addi	sp,sp,-16
    80000456:	e406                	sd	ra,8(sp)
    80000458:	e022                	sd	s0,0(sp)
    8000045a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000045c:	3f1000ef          	jal	ra,8000104c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000460:	00007717          	auipc	a4,0x7
    80000464:	61070713          	addi	a4,a4,1552 # 80007a70 <started>
  if(cpuid() == 0){
    80000468:	c51d                	beqz	a0,80000496 <main+0x42>
    while(started == 0)
    8000046a:	431c                	lw	a5,0(a4)
    8000046c:	2781                	sext.w	a5,a5
    8000046e:	dff5                	beqz	a5,8000046a <main+0x16>
      ;
    __sync_synchronize();
    80000470:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000474:	3d9000ef          	jal	ra,8000104c <cpuid>
    80000478:	85aa                	mv	a1,a0
    8000047a:	00007517          	auipc	a0,0x7
    8000047e:	c4650513          	addi	a0,a0,-954 # 800070c0 <etext+0xc0>
    80000482:	6cd040ef          	jal	ra,8000534e <printf>
    kvminithart();    // turn on paging
    80000486:	080000ef          	jal	ra,80000506 <kvminithart>
    trapinithart();   // install kernel trap vector
    8000048a:	6dc010ef          	jal	ra,80001b66 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000048e:	4d6040ef          	jal	ra,80004964 <plicinithart>
  }

  scheduler();
    80000492:	018010ef          	jal	ra,800014aa <scheduler>
    consoleinit();
    80000496:	5e3040ef          	jal	ra,80005278 <consoleinit>
    printfinit();
    8000049a:	1a2050ef          	jal	ra,8000563c <printfinit>
    printf("\n");
    8000049e:	00007517          	auipc	a0,0x7
    800004a2:	c3250513          	addi	a0,a0,-974 # 800070d0 <etext+0xd0>
    800004a6:	6a9040ef          	jal	ra,8000534e <printf>
    printf("xv6 kernel is booting\n");
    800004aa:	00007517          	auipc	a0,0x7
    800004ae:	bfe50513          	addi	a0,a0,-1026 # 800070a8 <etext+0xa8>
    800004b2:	69d040ef          	jal	ra,8000534e <printf>
    printf("\n");
    800004b6:	00007517          	auipc	a0,0x7
    800004ba:	c1a50513          	addi	a0,a0,-998 # 800070d0 <etext+0xd0>
    800004be:	691040ef          	jal	ra,8000534e <printf>
    kinit();         // physical page allocator
    800004c2:	c69ff0ef          	jal	ra,8000012a <kinit>
    kvminit();       // create kernel page table
    800004c6:	350000ef          	jal	ra,80000816 <kvminit>
    kvminithart();   // turn on paging
    800004ca:	03c000ef          	jal	ra,80000506 <kvminithart>
    procinit();      // process table
    800004ce:	2d7000ef          	jal	ra,80000fa4 <procinit>
    trapinit();      // trap vectors
    800004d2:	670010ef          	jal	ra,80001b42 <trapinit>
    trapinithart();  // install kernel trap vector
    800004d6:	690010ef          	jal	ra,80001b66 <trapinithart>
    plicinit();      // set up interrupt controller
    800004da:	474040ef          	jal	ra,8000494e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800004de:	486040ef          	jal	ra,80004964 <plicinithart>
    binit();         // buffer cache
    800004e2:	503010ef          	jal	ra,800021e4 <binit>
    iinit();         // inode table
    800004e6:	2de020ef          	jal	ra,800027c4 <iinit>
    fileinit();      // file table
    800004ea:	080030ef          	jal	ra,8000356a <fileinit>
    virtio_disk_init(); // emulated hard disk
    800004ee:	566040ef          	jal	ra,80004a54 <virtio_disk_init>
    userinit();      // first user process
    800004f2:	5ef000ef          	jal	ra,800012e0 <userinit>
    __sync_synchronize();
    800004f6:	0ff0000f          	fence
    started = 1;
    800004fa:	4785                	li	a5,1
    800004fc:	00007717          	auipc	a4,0x7
    80000500:	56f72a23          	sw	a5,1396(a4) # 80007a70 <started>
    80000504:	b779                	j	80000492 <main+0x3e>

0000000080000506 <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    80000506:	1141                	addi	sp,sp,-16
    80000508:	e422                	sd	s0,8(sp)
    8000050a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000050c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000510:	00007797          	auipc	a5,0x7
    80000514:	5687b783          	ld	a5,1384(a5) # 80007a78 <kernel_pagetable>
    80000518:	83b1                	srli	a5,a5,0xc
    8000051a:	577d                	li	a4,-1
    8000051c:	177e                	slli	a4,a4,0x3f
    8000051e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000520:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000524:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000528:	6422                	ld	s0,8(sp)
    8000052a:	0141                	addi	sp,sp,16
    8000052c:	8082                	ret

000000008000052e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000052e:	7139                	addi	sp,sp,-64
    80000530:	fc06                	sd	ra,56(sp)
    80000532:	f822                	sd	s0,48(sp)
    80000534:	f426                	sd	s1,40(sp)
    80000536:	f04a                	sd	s2,32(sp)
    80000538:	ec4e                	sd	s3,24(sp)
    8000053a:	e852                	sd	s4,16(sp)
    8000053c:	e456                	sd	s5,8(sp)
    8000053e:	e05a                	sd	s6,0(sp)
    80000540:	0080                	addi	s0,sp,64
    80000542:	892a                	mv	s2,a0
    80000544:	89ae                	mv	s3,a1
    80000546:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000548:	57fd                	li	a5,-1
    8000054a:	83e9                	srli	a5,a5,0x1a
    8000054c:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--)
    8000054e:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000550:	02b7fb63          	bgeu	a5,a1,80000586 <walk+0x58>
    panic("walk");
    80000554:	00007517          	auipc	a0,0x7
    80000558:	b8450513          	addi	a0,a0,-1148 # 800070d8 <etext+0xd8>
    8000055c:	0a6050ef          	jal	ra,80005602 <panic>
      }
#endif
    }
    else
    {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000560:	060a8563          	beqz	s5,800005ca <walk+0x9c>
    80000564:	c01ff0ef          	jal	ra,80000164 <kalloc>
    80000568:	892a                	mv	s2,a0
    8000056a:	c135                	beqz	a0,800005ce <walk+0xa0>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000056c:	6605                	lui	a2,0x1
    8000056e:	4581                	li	a1,0
    80000570:	d43ff0ef          	jal	ra,800002b2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000574:	00c95793          	srli	a5,s2,0xc
    80000578:	07aa                	slli	a5,a5,0xa
    8000057a:	0017e793          	ori	a5,a5,1
    8000057e:	e09c                	sd	a5,0(s1)
  for (int level = 2; level > 0; level--)
    80000580:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde027>
    80000582:	036a0263          	beq	s4,s6,800005a6 <walk+0x78>
    pte_t *pte = &pagetable[PX(level, va)];
    80000586:	0149d4b3          	srl	s1,s3,s4
    8000058a:	1ff4f493          	andi	s1,s1,511
    8000058e:	048e                	slli	s1,s1,0x3
    80000590:	94ca                	add	s1,s1,s2
    if (*pte & PTE_V)
    80000592:	609c                	ld	a5,0(s1)
    80000594:	0017f713          	andi	a4,a5,1
    80000598:	d761                	beqz	a4,80000560 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000059a:	00a7d913          	srli	s2,a5,0xa
    8000059e:	0932                	slli	s2,s2,0xc
      if (PTE_LEAF(*pte))
    800005a0:	8bb9                	andi	a5,a5,14
    800005a2:	dff9                	beqz	a5,80000580 <walk+0x52>
    800005a4:	a801                	j	800005b4 <walk+0x86>
    }
  }
  return &pagetable[PX(0, va)];
    800005a6:	00c9d993          	srli	s3,s3,0xc
    800005aa:	1ff9f993          	andi	s3,s3,511
    800005ae:	098e                	slli	s3,s3,0x3
    800005b0:	013904b3          	add	s1,s2,s3
}
    800005b4:	8526                	mv	a0,s1
    800005b6:	70e2                	ld	ra,56(sp)
    800005b8:	7442                	ld	s0,48(sp)
    800005ba:	74a2                	ld	s1,40(sp)
    800005bc:	7902                	ld	s2,32(sp)
    800005be:	69e2                	ld	s3,24(sp)
    800005c0:	6a42                	ld	s4,16(sp)
    800005c2:	6aa2                	ld	s5,8(sp)
    800005c4:	6b02                	ld	s6,0(sp)
    800005c6:	6121                	addi	sp,sp,64
    800005c8:	8082                	ret
        return 0;
    800005ca:	4481                	li	s1,0
    800005cc:	b7e5                	j	800005b4 <walk+0x86>
    800005ce:	84aa                	mv	s1,a0
    800005d0:	b7d5                	j	800005b4 <walk+0x86>

00000000800005d2 <superwalk>:

//derivative of walk that only decends one level in the page table
//key spec for superpages
pte_t *
superwalk(pagetable_t pagetable, uint64 va, int alloc)
{
    800005d2:	7179                	addi	sp,sp,-48
    800005d4:	f406                	sd	ra,40(sp)
    800005d6:	f022                	sd	s0,32(sp)
    800005d8:	ec26                	sd	s1,24(sp)
    800005da:	e84a                	sd	s2,16(sp)
    800005dc:	e44e                	sd	s3,8(sp)
    800005de:	1800                	addi	s0,sp,48
  if(va >= MAXVA) {
    800005e0:	57fd                	li	a5,-1
    800005e2:	83e9                	srli	a5,a5,0x1a
    800005e4:	02b7ed63          	bltu	a5,a1,8000061e <superwalk+0x4c>
    800005e8:	84ae                	mv	s1,a1
    panic("superwalk");
  }

  pte_t *pte = &pagetable[PX(2, va)]; //only descend one level
    800005ea:	01e5d793          	srli	a5,a1,0x1e
    800005ee:	078e                	slli	a5,a5,0x3
    800005f0:	00f509b3          	add	s3,a0,a5
  if(*pte & PTE_V) {
    800005f4:	0009b903          	ld	s2,0(s3) # 1000 <_entry-0x7ffff000>
    800005f8:	00197793          	andi	a5,s2,1
    800005fc:	c79d                	beqz	a5,8000062a <superwalk+0x58>
    pagetable = (pagetable_t)PTE2PA(*pte);
    800005fe:	00a95913          	srli	s2,s2,0xa
    80000602:	0932                	slli	s2,s2,0xc
      return 0;
  }
    memset(pagetable, 0, PGSIZE);
    *pte = PA2PTE(pagetable) | PTE_V;
  }
  return &pagetable[PX(1, va)];
    80000604:	80d5                	srli	s1,s1,0x15
    80000606:	1ff4f493          	andi	s1,s1,511
    8000060a:	048e                	slli	s1,s1,0x3
    8000060c:	9926                	add	s2,s2,s1
}
    8000060e:	854a                	mv	a0,s2
    80000610:	70a2                	ld	ra,40(sp)
    80000612:	7402                	ld	s0,32(sp)
    80000614:	64e2                	ld	s1,24(sp)
    80000616:	6942                	ld	s2,16(sp)
    80000618:	69a2                	ld	s3,8(sp)
    8000061a:	6145                	addi	sp,sp,48
    8000061c:	8082                	ret
    panic("superwalk");
    8000061e:	00007517          	auipc	a0,0x7
    80000622:	ac250513          	addi	a0,a0,-1342 # 800070e0 <etext+0xe0>
    80000626:	7dd040ef          	jal	ra,80005602 <panic>
      return 0;
    8000062a:	4901                	li	s2,0
    if (!alloc || (pagetable = (pde_t *)kalloc()) == 0) {
    8000062c:	d26d                	beqz	a2,8000060e <superwalk+0x3c>
    8000062e:	b37ff0ef          	jal	ra,80000164 <kalloc>
    80000632:	892a                	mv	s2,a0
    80000634:	dd69                	beqz	a0,8000060e <superwalk+0x3c>
    memset(pagetable, 0, PGSIZE);
    80000636:	6605                	lui	a2,0x1
    80000638:	4581                	li	a1,0
    8000063a:	c79ff0ef          	jal	ra,800002b2 <memset>
    *pte = PA2PTE(pagetable) | PTE_V;
    8000063e:	00c95793          	srli	a5,s2,0xc
    80000642:	07aa                	slli	a5,a5,0xa
    80000644:	0017e793          	ori	a5,a5,1
    80000648:	00f9b023          	sd	a5,0(s3)
    8000064c:	bf65                	j	80000604 <superwalk+0x32>

000000008000064e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    8000064e:	57fd                	li	a5,-1
    80000650:	83e9                	srli	a5,a5,0x1a
    80000652:	00b7f463          	bgeu	a5,a1,8000065a <walkaddr+0xc>
    return 0;
    80000656:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000658:	8082                	ret
{
    8000065a:	1141                	addi	sp,sp,-16
    8000065c:	e406                	sd	ra,8(sp)
    8000065e:	e022                	sd	s0,0(sp)
    80000660:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000662:	4601                	li	a2,0
    80000664:	ecbff0ef          	jal	ra,8000052e <walk>
  if (pte == 0)
    80000668:	c105                	beqz	a0,80000688 <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    8000066a:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    8000066c:	0117f693          	andi	a3,a5,17
    80000670:	4745                	li	a4,17
    return 0;
    80000672:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000674:	00e68663          	beq	a3,a4,80000680 <walkaddr+0x32>
}
    80000678:	60a2                	ld	ra,8(sp)
    8000067a:	6402                	ld	s0,0(sp)
    8000067c:	0141                	addi	sp,sp,16
    8000067e:	8082                	ret
  pa = PTE2PA(*pte);
    80000680:	83a9                	srli	a5,a5,0xa
    80000682:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000686:	bfcd                	j	80000678 <walkaddr+0x2a>
    return 0;
    80000688:	4501                	li	a0,0
    8000068a:	b7fd                	j	80000678 <walkaddr+0x2a>

000000008000068c <mappages>:
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000068c:	715d                	addi	sp,sp,-80
    8000068e:	e486                	sd	ra,72(sp)
    80000690:	e0a2                	sd	s0,64(sp)
    80000692:	fc26                	sd	s1,56(sp)
    80000694:	f84a                	sd	s2,48(sp)
    80000696:	f44e                	sd	s3,40(sp)
    80000698:	f052                	sd	s4,32(sp)
    8000069a:	ec56                	sd	s5,24(sp)
    8000069c:	e85a                	sd	s6,16(sp)
    8000069e:	e45e                	sd	s7,8(sp)
    800006a0:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800006a2:	03459793          	slli	a5,a1,0x34
    800006a6:	e7a9                	bnez	a5,800006f0 <mappages+0x64>
    800006a8:	8aaa                	mv	s5,a0
    800006aa:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    800006ac:	03461793          	slli	a5,a2,0x34
    800006b0:	e7b1                	bnez	a5,800006fc <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    800006b2:	ca39                	beqz	a2,80000708 <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    800006b4:	77fd                	lui	a5,0xfffff
    800006b6:	963e                	add	a2,a2,a5
    800006b8:	00b609b3          	add	s3,a2,a1
  a = va;
    800006bc:	892e                	mv	s2,a1
    800006be:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    800006c2:	6b85                	lui	s7,0x1
    800006c4:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    800006c8:	4605                	li	a2,1
    800006ca:	85ca                	mv	a1,s2
    800006cc:	8556                	mv	a0,s5
    800006ce:	e61ff0ef          	jal	ra,8000052e <walk>
    800006d2:	c539                	beqz	a0,80000720 <mappages+0x94>
    if (*pte & PTE_V)
    800006d4:	611c                	ld	a5,0(a0)
    800006d6:	8b85                	andi	a5,a5,1
    800006d8:	ef95                	bnez	a5,80000714 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800006da:	80b1                	srli	s1,s1,0xc
    800006dc:	04aa                	slli	s1,s1,0xa
    800006de:	0164e4b3          	or	s1,s1,s6
    800006e2:	0014e493          	ori	s1,s1,1
    800006e6:	e104                	sd	s1,0(a0)
    if (a == last)
    800006e8:	05390863          	beq	s2,s3,80000738 <mappages+0xac>
    a += PGSIZE;
    800006ec:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800006ee:	bfd9                	j	800006c4 <mappages+0x38>
    panic("mappages: va not aligned");
    800006f0:	00007517          	auipc	a0,0x7
    800006f4:	a0050513          	addi	a0,a0,-1536 # 800070f0 <etext+0xf0>
    800006f8:	70b040ef          	jal	ra,80005602 <panic>
    panic("mappages: size not aligned");
    800006fc:	00007517          	auipc	a0,0x7
    80000700:	a1450513          	addi	a0,a0,-1516 # 80007110 <etext+0x110>
    80000704:	6ff040ef          	jal	ra,80005602 <panic>
    panic("mappages: size");
    80000708:	00007517          	auipc	a0,0x7
    8000070c:	a2850513          	addi	a0,a0,-1496 # 80007130 <etext+0x130>
    80000710:	6f3040ef          	jal	ra,80005602 <panic>
      panic("mappages: remap");
    80000714:	00007517          	auipc	a0,0x7
    80000718:	a2c50513          	addi	a0,a0,-1492 # 80007140 <etext+0x140>
    8000071c:	6e7040ef          	jal	ra,80005602 <panic>
      return -1;
    80000720:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000722:	60a6                	ld	ra,72(sp)
    80000724:	6406                	ld	s0,64(sp)
    80000726:	74e2                	ld	s1,56(sp)
    80000728:	7942                	ld	s2,48(sp)
    8000072a:	79a2                	ld	s3,40(sp)
    8000072c:	7a02                	ld	s4,32(sp)
    8000072e:	6ae2                	ld	s5,24(sp)
    80000730:	6b42                	ld	s6,16(sp)
    80000732:	6ba2                	ld	s7,8(sp)
    80000734:	6161                	addi	sp,sp,80
    80000736:	8082                	ret
  return 0;
    80000738:	4501                	li	a0,0
    8000073a:	b7e5                	j	80000722 <mappages+0x96>

000000008000073c <kvmmap>:
{
    8000073c:	1141                	addi	sp,sp,-16
    8000073e:	e406                	sd	ra,8(sp)
    80000740:	e022                	sd	s0,0(sp)
    80000742:	0800                	addi	s0,sp,16
    80000744:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000746:	86b2                	mv	a3,a2
    80000748:	863e                	mv	a2,a5
    8000074a:	f43ff0ef          	jal	ra,8000068c <mappages>
    8000074e:	e509                	bnez	a0,80000758 <kvmmap+0x1c>
}
    80000750:	60a2                	ld	ra,8(sp)
    80000752:	6402                	ld	s0,0(sp)
    80000754:	0141                	addi	sp,sp,16
    80000756:	8082                	ret
    panic("kvmmap");
    80000758:	00007517          	auipc	a0,0x7
    8000075c:	9f850513          	addi	a0,a0,-1544 # 80007150 <etext+0x150>
    80000760:	6a3040ef          	jal	ra,80005602 <panic>

0000000080000764 <kvmmake>:
{
    80000764:	1101                	addi	sp,sp,-32
    80000766:	ec06                	sd	ra,24(sp)
    80000768:	e822                	sd	s0,16(sp)
    8000076a:	e426                	sd	s1,8(sp)
    8000076c:	e04a                	sd	s2,0(sp)
    8000076e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80000770:	9f5ff0ef          	jal	ra,80000164 <kalloc>
    80000774:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000776:	6605                	lui	a2,0x1
    80000778:	4581                	li	a1,0
    8000077a:	b39ff0ef          	jal	ra,800002b2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000077e:	4719                	li	a4,6
    80000780:	6685                	lui	a3,0x1
    80000782:	10000637          	lui	a2,0x10000
    80000786:	100005b7          	lui	a1,0x10000
    8000078a:	8526                	mv	a0,s1
    8000078c:	fb1ff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000790:	4719                	li	a4,6
    80000792:	6685                	lui	a3,0x1
    80000794:	10001637          	lui	a2,0x10001
    80000798:	100015b7          	lui	a1,0x10001
    8000079c:	8526                	mv	a0,s1
    8000079e:	f9fff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800007a2:	4719                	li	a4,6
    800007a4:	040006b7          	lui	a3,0x4000
    800007a8:	0c000637          	lui	a2,0xc000
    800007ac:	0c0005b7          	lui	a1,0xc000
    800007b0:	8526                	mv	a0,s1
    800007b2:	f8bff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800007b6:	00007917          	auipc	s2,0x7
    800007ba:	84a90913          	addi	s2,s2,-1974 # 80007000 <etext>
    800007be:	4729                	li	a4,10
    800007c0:	80007697          	auipc	a3,0x80007
    800007c4:	84068693          	addi	a3,a3,-1984 # 7000 <_entry-0x7fff9000>
    800007c8:	4605                	li	a2,1
    800007ca:	067e                	slli	a2,a2,0x1f
    800007cc:	85b2                	mv	a1,a2
    800007ce:	8526                	mv	a0,s1
    800007d0:	f6dff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    800007d4:	4719                	li	a4,6
    800007d6:	46c5                	li	a3,17
    800007d8:	06ee                	slli	a3,a3,0x1b
    800007da:	412686b3          	sub	a3,a3,s2
    800007de:	864a                	mv	a2,s2
    800007e0:	85ca                	mv	a1,s2
    800007e2:	8526                	mv	a0,s1
    800007e4:	f59ff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800007e8:	4729                	li	a4,10
    800007ea:	6685                	lui	a3,0x1
    800007ec:	00006617          	auipc	a2,0x6
    800007f0:	81460613          	addi	a2,a2,-2028 # 80006000 <_trampoline>
    800007f4:	040005b7          	lui	a1,0x4000
    800007f8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800007fa:	05b2                	slli	a1,a1,0xc
    800007fc:	8526                	mv	a0,s1
    800007fe:	f3fff0ef          	jal	ra,8000073c <kvmmap>
  proc_mapstacks(kpgtbl);
    80000802:	8526                	mv	a0,s1
    80000804:	716000ef          	jal	ra,80000f1a <proc_mapstacks>
}
    80000808:	8526                	mv	a0,s1
    8000080a:	60e2                	ld	ra,24(sp)
    8000080c:	6442                	ld	s0,16(sp)
    8000080e:	64a2                	ld	s1,8(sp)
    80000810:	6902                	ld	s2,0(sp)
    80000812:	6105                	addi	sp,sp,32
    80000814:	8082                	ret

0000000080000816 <kvminit>:
{
    80000816:	1141                	addi	sp,sp,-16
    80000818:	e406                	sd	ra,8(sp)
    8000081a:	e022                	sd	s0,0(sp)
    8000081c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000081e:	f47ff0ef          	jal	ra,80000764 <kvmmake>
    80000822:	00007797          	auipc	a5,0x7
    80000826:	24a7bb23          	sd	a0,598(a5) # 80007a78 <kernel_pagetable>
}
    8000082a:	60a2                	ld	ra,8(sp)
    8000082c:	6402                	ld	s0,0(sp)
    8000082e:	0141                	addi	sp,sp,16
    80000830:	8082                	ret

0000000080000832 <supermappages>:

int
supermappages(pagetable_t pagetable, uint64 va, uint64 pa, int perm) {
    80000832:	1101                	addi	sp,sp,-32
    80000834:	ec06                	sd	ra,24(sp)
    80000836:	e822                	sd	s0,16(sp)
    80000838:	e426                	sd	s1,8(sp)
    8000083a:	e04a                	sd	s2,0(sp)
    8000083c:	1000                	addi	s0,sp,32
  pte_t *pte;
  if ((va % SUPERPGSIZE) != 0) {
    8000083e:	02b59793          	slli	a5,a1,0x2b
    80000842:	eb8d                	bnez	a5,80000874 <supermappages+0x42>
    80000844:	84b2                	mv	s1,a2
    80000846:	8936                	mv	s2,a3
    panic("supermappages: va not aligned");
  }
  if ((pte = superwalk(pagetable, va, 1)) == 0) { //superwalk failed
    80000848:	4605                	li	a2,1
    8000084a:	d89ff0ef          	jal	ra,800005d2 <superwalk>
    8000084e:	cd1d                	beqz	a0,8000088c <supermappages+0x5a>
    return -1;
  }
  if (*pte & PTE_V) {
    80000850:	611c                	ld	a5,0(a0)
    80000852:	8b85                	andi	a5,a5,1
    80000854:	e795                	bnez	a5,80000880 <supermappages+0x4e>
    panic("supermappages: remap");
  }
  *pte = PA2PTE(pa) | perm | PTE_V;
    80000856:	00c4d613          	srli	a2,s1,0xc
    8000085a:	062a                	slli	a2,a2,0xa
    8000085c:	01266633          	or	a2,a2,s2
    80000860:	00166613          	ori	a2,a2,1
    80000864:	e110                	sd	a2,0(a0)
  return 0;
    80000866:	4501                	li	a0,0
}
    80000868:	60e2                	ld	ra,24(sp)
    8000086a:	6442                	ld	s0,16(sp)
    8000086c:	64a2                	ld	s1,8(sp)
    8000086e:	6902                	ld	s2,0(sp)
    80000870:	6105                	addi	sp,sp,32
    80000872:	8082                	ret
    panic("supermappages: va not aligned");
    80000874:	00007517          	auipc	a0,0x7
    80000878:	8e450513          	addi	a0,a0,-1820 # 80007158 <etext+0x158>
    8000087c:	587040ef          	jal	ra,80005602 <panic>
    panic("supermappages: remap");
    80000880:	00007517          	auipc	a0,0x7
    80000884:	8f850513          	addi	a0,a0,-1800 # 80007178 <etext+0x178>
    80000888:	57b040ef          	jal	ra,80005602 <panic>
    return -1;
    8000088c:	557d                	li	a0,-1
    8000088e:	bfe9                	j	80000868 <supermappages+0x36>

0000000080000890 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000890:	715d                	addi	sp,sp,-80
    80000892:	e486                	sd	ra,72(sp)
    80000894:	e0a2                	sd	s0,64(sp)
    80000896:	fc26                	sd	s1,56(sp)
    80000898:	f84a                	sd	s2,48(sp)
    8000089a:	f44e                	sd	s3,40(sp)
    8000089c:	f052                	sd	s4,32(sp)
    8000089e:	ec56                	sd	s5,24(sp)
    800008a0:	e85a                	sd	s6,16(sp)
    800008a2:	e45e                	sd	s7,8(sp)
    800008a4:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;
  int sz;

  if ((va % PGSIZE) != 0)
    800008a6:	03459793          	slli	a5,a1,0x34
    800008aa:	e795                	bnez	a5,800008d6 <uvmunmap+0x46>
    800008ac:	8a2a                	mv	s4,a0
    800008ae:	892e                	mv	s2,a1
    800008b0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += sz)
    800008b2:	0632                	slli	a2,a2,0xc
    800008b4:	00b609b3          	add	s3,a2,a1
    if ((*pte & PTE_V) == 0)
    {
      printf("va=%ld pte=%ld\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if (PTE_FLAGS(*pte) == PTE_V)
    800008b8:	4b85                	li	s7,1
  for (a = va; a < va + npages * PGSIZE; a += sz)
    800008ba:	6b05                	lui	s6,0x1
    800008bc:	0735e163          	bltu	a1,s3,8000091e <uvmunmap+0x8e>
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
  }
}
    800008c0:	60a6                	ld	ra,72(sp)
    800008c2:	6406                	ld	s0,64(sp)
    800008c4:	74e2                	ld	s1,56(sp)
    800008c6:	7942                	ld	s2,48(sp)
    800008c8:	79a2                	ld	s3,40(sp)
    800008ca:	7a02                	ld	s4,32(sp)
    800008cc:	6ae2                	ld	s5,24(sp)
    800008ce:	6b42                	ld	s6,16(sp)
    800008d0:	6ba2                	ld	s7,8(sp)
    800008d2:	6161                	addi	sp,sp,80
    800008d4:	8082                	ret
    panic("uvmunmap: not aligned");
    800008d6:	00007517          	auipc	a0,0x7
    800008da:	8ba50513          	addi	a0,a0,-1862 # 80007190 <etext+0x190>
    800008de:	525040ef          	jal	ra,80005602 <panic>
      panic("uvmunmap: walk");
    800008e2:	00007517          	auipc	a0,0x7
    800008e6:	8c650513          	addi	a0,a0,-1850 # 800071a8 <etext+0x1a8>
    800008ea:	519040ef          	jal	ra,80005602 <panic>
      printf("va=%ld pte=%ld\n", a, *pte);
    800008ee:	85ca                	mv	a1,s2
    800008f0:	00007517          	auipc	a0,0x7
    800008f4:	8c850513          	addi	a0,a0,-1848 # 800071b8 <etext+0x1b8>
    800008f8:	257040ef          	jal	ra,8000534e <printf>
      panic("uvmunmap: not mapped");
    800008fc:	00007517          	auipc	a0,0x7
    80000900:	8cc50513          	addi	a0,a0,-1844 # 800071c8 <etext+0x1c8>
    80000904:	4ff040ef          	jal	ra,80005602 <panic>
      panic("uvmunmap: not a leaf");
    80000908:	00007517          	auipc	a0,0x7
    8000090c:	8d850513          	addi	a0,a0,-1832 # 800071e0 <etext+0x1e0>
    80000910:	4f3040ef          	jal	ra,80005602 <panic>
    *pte = 0;
    80000914:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += sz)
    80000918:	995a                	add	s2,s2,s6
    8000091a:	fb3973e3          	bgeu	s2,s3,800008c0 <uvmunmap+0x30>
    if ((pte = walk(pagetable, a, 0)) == 0)
    8000091e:	4601                	li	a2,0
    80000920:	85ca                	mv	a1,s2
    80000922:	8552                	mv	a0,s4
    80000924:	c0bff0ef          	jal	ra,8000052e <walk>
    80000928:	84aa                	mv	s1,a0
    8000092a:	dd45                	beqz	a0,800008e2 <uvmunmap+0x52>
    if ((*pte & PTE_V) == 0)
    8000092c:	6110                	ld	a2,0(a0)
    8000092e:	00167793          	andi	a5,a2,1
    80000932:	dfd5                	beqz	a5,800008ee <uvmunmap+0x5e>
    if (PTE_FLAGS(*pte) == PTE_V)
    80000934:	3ff67793          	andi	a5,a2,1023
    80000938:	fd7788e3          	beq	a5,s7,80000908 <uvmunmap+0x78>
    if (do_free)
    8000093c:	fc0a8ce3          	beqz	s5,80000914 <uvmunmap+0x84>
      uint64 pa = PTE2PA(*pte);
    80000940:	8229                	srli	a2,a2,0xa
      kfree((void *)pa);
    80000942:	00c61513          	slli	a0,a2,0xc
    80000946:	f2aff0ef          	jal	ra,80000070 <kfree>
    8000094a:	b7e9                	j	80000914 <uvmunmap+0x84>

000000008000094c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000094c:	1101                	addi	sp,sp,-32
    8000094e:	ec06                	sd	ra,24(sp)
    80000950:	e822                	sd	s0,16(sp)
    80000952:	e426                	sd	s1,8(sp)
    80000954:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80000956:	80fff0ef          	jal	ra,80000164 <kalloc>
    8000095a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000095c:	c509                	beqz	a0,80000966 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000095e:	6605                	lui	a2,0x1
    80000960:	4581                	li	a1,0
    80000962:	951ff0ef          	jal	ra,800002b2 <memset>
  return pagetable;
}
    80000966:	8526                	mv	a0,s1
    80000968:	60e2                	ld	ra,24(sp)
    8000096a:	6442                	ld	s0,16(sp)
    8000096c:	64a2                	ld	s1,8(sp)
    8000096e:	6105                	addi	sp,sp,32
    80000970:	8082                	ret

0000000080000972 <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000972:	7179                	addi	sp,sp,-48
    80000974:	f406                	sd	ra,40(sp)
    80000976:	f022                	sd	s0,32(sp)
    80000978:	ec26                	sd	s1,24(sp)
    8000097a:	e84a                	sd	s2,16(sp)
    8000097c:	e44e                	sd	s3,8(sp)
    8000097e:	e052                	sd	s4,0(sp)
    80000980:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    80000982:	6785                	lui	a5,0x1
    80000984:	04f67063          	bgeu	a2,a5,800009c4 <uvmfirst+0x52>
    80000988:	8a2a                	mv	s4,a0
    8000098a:	89ae                	mv	s3,a1
    8000098c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000098e:	fd6ff0ef          	jal	ra,80000164 <kalloc>
    80000992:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000994:	6605                	lui	a2,0x1
    80000996:	4581                	li	a1,0
    80000998:	91bff0ef          	jal	ra,800002b2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    8000099c:	4779                	li	a4,30
    8000099e:	86ca                	mv	a3,s2
    800009a0:	6605                	lui	a2,0x1
    800009a2:	4581                	li	a1,0
    800009a4:	8552                	mv	a0,s4
    800009a6:	ce7ff0ef          	jal	ra,8000068c <mappages>
  memmove(mem, src, sz);
    800009aa:	8626                	mv	a2,s1
    800009ac:	85ce                	mv	a1,s3
    800009ae:	854a                	mv	a0,s2
    800009b0:	95fff0ef          	jal	ra,8000030e <memmove>
}
    800009b4:	70a2                	ld	ra,40(sp)
    800009b6:	7402                	ld	s0,32(sp)
    800009b8:	64e2                	ld	s1,24(sp)
    800009ba:	6942                	ld	s2,16(sp)
    800009bc:	69a2                	ld	s3,8(sp)
    800009be:	6a02                	ld	s4,0(sp)
    800009c0:	6145                	addi	sp,sp,48
    800009c2:	8082                	ret
    panic("uvmfirst: more than a page");
    800009c4:	00007517          	auipc	a0,0x7
    800009c8:	83450513          	addi	a0,a0,-1996 # 800071f8 <etext+0x1f8>
    800009cc:	437040ef          	jal	ra,80005602 <panic>

00000000800009d0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800009d0:	1101                	addi	sp,sp,-32
    800009d2:	ec06                	sd	ra,24(sp)
    800009d4:	e822                	sd	s0,16(sp)
    800009d6:	e426                	sd	s1,8(sp)
    800009d8:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800009da:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800009dc:	00b67d63          	bgeu	a2,a1,800009f6 <uvmdealloc+0x26>
    800009e0:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800009e2:	6785                	lui	a5,0x1
    800009e4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800009e6:	00f60733          	add	a4,a2,a5
    800009ea:	76fd                	lui	a3,0xfffff
    800009ec:	8f75                	and	a4,a4,a3
    800009ee:	97ae                	add	a5,a5,a1
    800009f0:	8ff5                	and	a5,a5,a3
    800009f2:	00f76863          	bltu	a4,a5,80000a02 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800009f6:	8526                	mv	a0,s1
    800009f8:	60e2                	ld	ra,24(sp)
    800009fa:	6442                	ld	s0,16(sp)
    800009fc:	64a2                	ld	s1,8(sp)
    800009fe:	6105                	addi	sp,sp,32
    80000a00:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000a02:	8f99                	sub	a5,a5,a4
    80000a04:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80000a06:	4685                	li	a3,1
    80000a08:	0007861b          	sext.w	a2,a5
    80000a0c:	85ba                	mv	a1,a4
    80000a0e:	e83ff0ef          	jal	ra,80000890 <uvmunmap>
    80000a12:	b7d5                	j	800009f6 <uvmdealloc+0x26>

0000000080000a14 <uvmalloc>:
  if (newsz < oldsz)
    80000a14:	08b66963          	bltu	a2,a1,80000aa6 <uvmalloc+0x92>
{
    80000a18:	7139                	addi	sp,sp,-64
    80000a1a:	fc06                	sd	ra,56(sp)
    80000a1c:	f822                	sd	s0,48(sp)
    80000a1e:	f426                	sd	s1,40(sp)
    80000a20:	f04a                	sd	s2,32(sp)
    80000a22:	ec4e                	sd	s3,24(sp)
    80000a24:	e852                	sd	s4,16(sp)
    80000a26:	e456                	sd	s5,8(sp)
    80000a28:	e05a                	sd	s6,0(sp)
    80000a2a:	0080                	addi	s0,sp,64
    80000a2c:	8aaa                	mv	s5,a0
    80000a2e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80000a30:	6785                	lui	a5,0x1
    80000a32:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000a34:	95be                	add	a1,a1,a5
    80000a36:	77fd                	lui	a5,0xfffff
    80000a38:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += sz)
    80000a3c:	06c9f763          	bgeu	s3,a2,80000aaa <uvmalloc+0x96>
    80000a40:	894e                	mv	s2,s3
    if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000a42:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80000a46:	f1eff0ef          	jal	ra,80000164 <kalloc>
    80000a4a:	84aa                	mv	s1,a0
    if (mem == 0)
    80000a4c:	c11d                	beqz	a0,80000a72 <uvmalloc+0x5e>
    memset(mem, 0, sz);
    80000a4e:	6605                	lui	a2,0x1
    80000a50:	4581                	li	a1,0
    80000a52:	861ff0ef          	jal	ra,800002b2 <memset>
    if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000a56:	875a                	mv	a4,s6
    80000a58:	86a6                	mv	a3,s1
    80000a5a:	6605                	lui	a2,0x1
    80000a5c:	85ca                	mv	a1,s2
    80000a5e:	8556                	mv	a0,s5
    80000a60:	c2dff0ef          	jal	ra,8000068c <mappages>
    80000a64:	e51d                	bnez	a0,80000a92 <uvmalloc+0x7e>
  for (a = oldsz; a < newsz; a += sz)
    80000a66:	6785                	lui	a5,0x1
    80000a68:	993e                	add	s2,s2,a5
    80000a6a:	fd496ee3          	bltu	s2,s4,80000a46 <uvmalloc+0x32>
  return newsz;
    80000a6e:	8552                	mv	a0,s4
    80000a70:	a039                	j	80000a7e <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    80000a72:	864e                	mv	a2,s3
    80000a74:	85ca                	mv	a1,s2
    80000a76:	8556                	mv	a0,s5
    80000a78:	f59ff0ef          	jal	ra,800009d0 <uvmdealloc>
      return 0;
    80000a7c:	4501                	li	a0,0
}
    80000a7e:	70e2                	ld	ra,56(sp)
    80000a80:	7442                	ld	s0,48(sp)
    80000a82:	74a2                	ld	s1,40(sp)
    80000a84:	7902                	ld	s2,32(sp)
    80000a86:	69e2                	ld	s3,24(sp)
    80000a88:	6a42                	ld	s4,16(sp)
    80000a8a:	6aa2                	ld	s5,8(sp)
    80000a8c:	6b02                	ld	s6,0(sp)
    80000a8e:	6121                	addi	sp,sp,64
    80000a90:	8082                	ret
      kfree(mem);
    80000a92:	8526                	mv	a0,s1
    80000a94:	ddcff0ef          	jal	ra,80000070 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000a98:	864e                	mv	a2,s3
    80000a9a:	85ca                	mv	a1,s2
    80000a9c:	8556                	mv	a0,s5
    80000a9e:	f33ff0ef          	jal	ra,800009d0 <uvmdealloc>
      return 0;
    80000aa2:	4501                	li	a0,0
    80000aa4:	bfe9                	j	80000a7e <uvmalloc+0x6a>
    return oldsz;
    80000aa6:	852e                	mv	a0,a1
}
    80000aa8:	8082                	ret
  return newsz;
    80000aaa:	8532                	mv	a0,a2
    80000aac:	bfc9                	j	80000a7e <uvmalloc+0x6a>

0000000080000aae <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    80000aae:	7179                	addi	sp,sp,-48
    80000ab0:	f406                	sd	ra,40(sp)
    80000ab2:	f022                	sd	s0,32(sp)
    80000ab4:	ec26                	sd	s1,24(sp)
    80000ab6:	e84a                	sd	s2,16(sp)
    80000ab8:	e44e                	sd	s3,8(sp)
    80000aba:	e052                	sd	s4,0(sp)
    80000abc:	1800                	addi	s0,sp,48
    80000abe:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    80000ac0:	84aa                	mv	s1,a0
    80000ac2:	6905                	lui	s2,0x1
    80000ac4:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000ac6:	4985                	li	s3,1
    80000ac8:	a819                	j	80000ade <freewalk+0x30>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000aca:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80000acc:	00c79513          	slli	a0,a5,0xc
    80000ad0:	fdfff0ef          	jal	ra,80000aae <freewalk>
      pagetable[i] = 0;
    80000ad4:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    80000ad8:	04a1                	addi	s1,s1,8
    80000ada:	01248f63          	beq	s1,s2,80000af8 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80000ade:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000ae0:	00f7f713          	andi	a4,a5,15
    80000ae4:	ff3703e3          	beq	a4,s3,80000aca <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    80000ae8:	8b85                	andi	a5,a5,1
    80000aea:	d7fd                	beqz	a5,80000ad8 <freewalk+0x2a>
    {
      panic("freewalk: leaf");
    80000aec:	00006517          	auipc	a0,0x6
    80000af0:	72c50513          	addi	a0,a0,1836 # 80007218 <etext+0x218>
    80000af4:	30f040ef          	jal	ra,80005602 <panic>
    }
  }
  kfree((void *)pagetable);
    80000af8:	8552                	mv	a0,s4
    80000afa:	d76ff0ef          	jal	ra,80000070 <kfree>
}
    80000afe:	70a2                	ld	ra,40(sp)
    80000b00:	7402                	ld	s0,32(sp)
    80000b02:	64e2                	ld	s1,24(sp)
    80000b04:	6942                	ld	s2,16(sp)
    80000b06:	69a2                	ld	s3,8(sp)
    80000b08:	6a02                	ld	s4,0(sp)
    80000b0a:	6145                	addi	sp,sp,48
    80000b0c:	8082                	ret

0000000080000b0e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000b0e:	1101                	addi	sp,sp,-32
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	e822                	sd	s0,16(sp)
    80000b14:	e426                	sd	s1,8(sp)
    80000b16:	1000                	addi	s0,sp,32
    80000b18:	84aa                	mv	s1,a0
  if (sz > 0)
    80000b1a:	e989                	bnez	a1,80000b2c <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80000b1c:	8526                	mv	a0,s1
    80000b1e:	f91ff0ef          	jal	ra,80000aae <freewalk>
}
    80000b22:	60e2                	ld	ra,24(sp)
    80000b24:	6442                	ld	s0,16(sp)
    80000b26:	64a2                	ld	s1,8(sp)
    80000b28:	6105                	addi	sp,sp,32
    80000b2a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80000b2c:	6785                	lui	a5,0x1
    80000b2e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000b30:	95be                	add	a1,a1,a5
    80000b32:	4685                	li	a3,1
    80000b34:	00c5d613          	srli	a2,a1,0xc
    80000b38:	4581                	li	a1,0
    80000b3a:	d57ff0ef          	jal	ra,80000890 <uvmunmap>
    80000b3e:	bff9                	j	80000b1c <uvmfree+0xe>

0000000080000b40 <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;
  int szinc;

  for (i = 0; i < sz; i += szinc)
    80000b40:	c65d                	beqz	a2,80000bee <uvmcopy+0xae>
{
    80000b42:	715d                	addi	sp,sp,-80
    80000b44:	e486                	sd	ra,72(sp)
    80000b46:	e0a2                	sd	s0,64(sp)
    80000b48:	fc26                	sd	s1,56(sp)
    80000b4a:	f84a                	sd	s2,48(sp)
    80000b4c:	f44e                	sd	s3,40(sp)
    80000b4e:	f052                	sd	s4,32(sp)
    80000b50:	ec56                	sd	s5,24(sp)
    80000b52:	e85a                	sd	s6,16(sp)
    80000b54:	e45e                	sd	s7,8(sp)
    80000b56:	0880                	addi	s0,sp,80
    80000b58:	8b2a                	mv	s6,a0
    80000b5a:	8aae                	mv	s5,a1
    80000b5c:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += szinc)
    80000b5e:	4981                	li	s3,0
  {
    szinc = PGSIZE;
    if ((pte = walk(old, i, 0)) == 0)
    80000b60:	4601                	li	a2,0
    80000b62:	85ce                	mv	a1,s3
    80000b64:	855a                	mv	a0,s6
    80000b66:	9c9ff0ef          	jal	ra,8000052e <walk>
    80000b6a:	c121                	beqz	a0,80000baa <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    80000b6c:	6118                	ld	a4,0(a0)
    80000b6e:	00177793          	andi	a5,a4,1
    80000b72:	c3b1                	beqz	a5,80000bb6 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000b74:	00a75593          	srli	a1,a4,0xa
    80000b78:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000b7c:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80000b80:	de4ff0ef          	jal	ra,80000164 <kalloc>
    80000b84:	892a                	mv	s2,a0
    80000b86:	c129                	beqz	a0,80000bc8 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80000b88:	6605                	lui	a2,0x1
    80000b8a:	85de                	mv	a1,s7
    80000b8c:	f82ff0ef          	jal	ra,8000030e <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80000b90:	8726                	mv	a4,s1
    80000b92:	86ca                	mv	a3,s2
    80000b94:	6605                	lui	a2,0x1
    80000b96:	85ce                	mv	a1,s3
    80000b98:	8556                	mv	a0,s5
    80000b9a:	af3ff0ef          	jal	ra,8000068c <mappages>
    80000b9e:	e115                	bnez	a0,80000bc2 <uvmcopy+0x82>
  for (i = 0; i < sz; i += szinc)
    80000ba0:	6785                	lui	a5,0x1
    80000ba2:	99be                	add	s3,s3,a5
    80000ba4:	fb49eee3          	bltu	s3,s4,80000b60 <uvmcopy+0x20>
    80000ba8:	a805                	j	80000bd8 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80000baa:	00006517          	auipc	a0,0x6
    80000bae:	67e50513          	addi	a0,a0,1662 # 80007228 <etext+0x228>
    80000bb2:	251040ef          	jal	ra,80005602 <panic>
      panic("uvmcopy: page not present");
    80000bb6:	00006517          	auipc	a0,0x6
    80000bba:	69250513          	addi	a0,a0,1682 # 80007248 <etext+0x248>
    80000bbe:	245040ef          	jal	ra,80005602 <panic>
    {
      kfree(mem);
    80000bc2:	854a                	mv	a0,s2
    80000bc4:	cacff0ef          	jal	ra,80000070 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000bc8:	4685                	li	a3,1
    80000bca:	00c9d613          	srli	a2,s3,0xc
    80000bce:	4581                	li	a1,0
    80000bd0:	8556                	mv	a0,s5
    80000bd2:	cbfff0ef          	jal	ra,80000890 <uvmunmap>
  return -1;
    80000bd6:	557d                	li	a0,-1
}
    80000bd8:	60a6                	ld	ra,72(sp)
    80000bda:	6406                	ld	s0,64(sp)
    80000bdc:	74e2                	ld	s1,56(sp)
    80000bde:	7942                	ld	s2,48(sp)
    80000be0:	79a2                	ld	s3,40(sp)
    80000be2:	7a02                	ld	s4,32(sp)
    80000be4:	6ae2                	ld	s5,24(sp)
    80000be6:	6b42                	ld	s6,16(sp)
    80000be8:	6ba2                	ld	s7,8(sp)
    80000bea:	6161                	addi	sp,sp,80
    80000bec:	8082                	ret
  return 0;
    80000bee:	4501                	li	a0,0
}
    80000bf0:	8082                	ret

0000000080000bf2 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    80000bf2:	1141                	addi	sp,sp,-16
    80000bf4:	e406                	sd	ra,8(sp)
    80000bf6:	e022                	sd	s0,0(sp)
    80000bf8:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80000bfa:	4601                	li	a2,0
    80000bfc:	933ff0ef          	jal	ra,8000052e <walk>
  if (pte == 0)
    80000c00:	c901                	beqz	a0,80000c10 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000c02:	611c                	ld	a5,0(a0)
    80000c04:	9bbd                	andi	a5,a5,-17
    80000c06:	e11c                	sd	a5,0(a0)
}
    80000c08:	60a2                	ld	ra,8(sp)
    80000c0a:	6402                	ld	s0,0(sp)
    80000c0c:	0141                	addi	sp,sp,16
    80000c0e:	8082                	ret
    panic("uvmclear");
    80000c10:	00006517          	auipc	a0,0x6
    80000c14:	65850513          	addi	a0,a0,1624 # 80007268 <etext+0x268>
    80000c18:	1eb040ef          	jal	ra,80005602 <panic>

0000000080000c1c <copyout>:
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while (len > 0)
    80000c1c:	c6c1                	beqz	a3,80000ca4 <copyout+0x88>
{
    80000c1e:	711d                	addi	sp,sp,-96
    80000c20:	ec86                	sd	ra,88(sp)
    80000c22:	e8a2                	sd	s0,80(sp)
    80000c24:	e4a6                	sd	s1,72(sp)
    80000c26:	e0ca                	sd	s2,64(sp)
    80000c28:	fc4e                	sd	s3,56(sp)
    80000c2a:	f852                	sd	s4,48(sp)
    80000c2c:	f456                	sd	s5,40(sp)
    80000c2e:	f05a                	sd	s6,32(sp)
    80000c30:	ec5e                	sd	s7,24(sp)
    80000c32:	e862                	sd	s8,16(sp)
    80000c34:	e466                	sd	s9,8(sp)
    80000c36:	1080                	addi	s0,sp,96
    80000c38:	8b2a                	mv	s6,a0
    80000c3a:	8a2e                	mv	s4,a1
    80000c3c:	8ab2                	mv	s5,a2
    80000c3e:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80000c40:	74fd                	lui	s1,0xfffff
    80000c42:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000c44:	57fd                	li	a5,-1
    80000c46:	83e9                	srli	a5,a5,0x1a
    80000c48:	0697e063          	bltu	a5,s1,80000ca8 <copyout+0x8c>
    80000c4c:	6c05                	lui	s8,0x1
    80000c4e:	8bbe                	mv	s7,a5
    80000c50:	a015                	j	80000c74 <copyout+0x58>
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000c52:	409a04b3          	sub	s1,s4,s1
    80000c56:	0009061b          	sext.w	a2,s2
    80000c5a:	85d6                	mv	a1,s5
    80000c5c:	9526                	add	a0,a0,s1
    80000c5e:	eb0ff0ef          	jal	ra,8000030e <memmove>

    len -= n;
    80000c62:	412989b3          	sub	s3,s3,s2
    src += n;
    80000c66:	9aca                	add	s5,s5,s2
  while (len > 0)
    80000c68:	02098c63          	beqz	s3,80000ca0 <copyout+0x84>
    if (va0 >= MAXVA)
    80000c6c:	059be063          	bltu	s7,s9,80000cac <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80000c70:	84e6                	mv	s1,s9
    dstva = va0 + PGSIZE;
    80000c72:	8a66                	mv	s4,s9
    if ((pte = walk(pagetable, va0, 0)) == 0)
    80000c74:	4601                	li	a2,0
    80000c76:	85a6                	mv	a1,s1
    80000c78:	855a                	mv	a0,s6
    80000c7a:	8b5ff0ef          	jal	ra,8000052e <walk>
    80000c7e:	c90d                	beqz	a0,80000cb0 <copyout+0x94>
    if ((*pte & PTE_W) == 0)
    80000c80:	611c                	ld	a5,0(a0)
    80000c82:	8b91                	andi	a5,a5,4
    80000c84:	c7a1                	beqz	a5,80000ccc <copyout+0xb0>
    pa0 = walkaddr(pagetable, va0);
    80000c86:	85a6                	mv	a1,s1
    80000c88:	855a                	mv	a0,s6
    80000c8a:	9c5ff0ef          	jal	ra,8000064e <walkaddr>
    if (pa0 == 0)
    80000c8e:	c129                	beqz	a0,80000cd0 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80000c90:	01848cb3          	add	s9,s1,s8
    80000c94:	414c8933          	sub	s2,s9,s4
    80000c98:	fb29fde3          	bgeu	s3,s2,80000c52 <copyout+0x36>
    80000c9c:	894e                	mv	s2,s3
    80000c9e:	bf55                	j	80000c52 <copyout+0x36>
  }
  return 0;
    80000ca0:	4501                	li	a0,0
    80000ca2:	a801                	j	80000cb2 <copyout+0x96>
    80000ca4:	4501                	li	a0,0
}
    80000ca6:	8082                	ret
      return -1;
    80000ca8:	557d                	li	a0,-1
    80000caa:	a021                	j	80000cb2 <copyout+0x96>
    80000cac:	557d                	li	a0,-1
    80000cae:	a011                	j	80000cb2 <copyout+0x96>
      return -1;
    80000cb0:	557d                	li	a0,-1
}
    80000cb2:	60e6                	ld	ra,88(sp)
    80000cb4:	6446                	ld	s0,80(sp)
    80000cb6:	64a6                	ld	s1,72(sp)
    80000cb8:	6906                	ld	s2,64(sp)
    80000cba:	79e2                	ld	s3,56(sp)
    80000cbc:	7a42                	ld	s4,48(sp)
    80000cbe:	7aa2                	ld	s5,40(sp)
    80000cc0:	7b02                	ld	s6,32(sp)
    80000cc2:	6be2                	ld	s7,24(sp)
    80000cc4:	6c42                	ld	s8,16(sp)
    80000cc6:	6ca2                	ld	s9,8(sp)
    80000cc8:	6125                	addi	sp,sp,96
    80000cca:	8082                	ret
      return -1;
    80000ccc:	557d                	li	a0,-1
    80000cce:	b7d5                	j	80000cb2 <copyout+0x96>
      return -1;
    80000cd0:	557d                	li	a0,-1
    80000cd2:	b7c5                	j	80000cb2 <copyout+0x96>

0000000080000cd4 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    80000cd4:	c6a5                	beqz	a3,80000d3c <copyin+0x68>
{
    80000cd6:	715d                	addi	sp,sp,-80
    80000cd8:	e486                	sd	ra,72(sp)
    80000cda:	e0a2                	sd	s0,64(sp)
    80000cdc:	fc26                	sd	s1,56(sp)
    80000cde:	f84a                	sd	s2,48(sp)
    80000ce0:	f44e                	sd	s3,40(sp)
    80000ce2:	f052                	sd	s4,32(sp)
    80000ce4:	ec56                	sd	s5,24(sp)
    80000ce6:	e85a                	sd	s6,16(sp)
    80000ce8:	e45e                	sd	s7,8(sp)
    80000cea:	e062                	sd	s8,0(sp)
    80000cec:	0880                	addi	s0,sp,80
    80000cee:	8b2a                	mv	s6,a0
    80000cf0:	8a2e                	mv	s4,a1
    80000cf2:	8c32                	mv	s8,a2
    80000cf4:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000cf6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000cf8:	6a85                	lui	s5,0x1
    80000cfa:	a00d                	j	80000d1c <copyin+0x48>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000cfc:	018505b3          	add	a1,a0,s8
    80000d00:	0004861b          	sext.w	a2,s1
    80000d04:	412585b3          	sub	a1,a1,s2
    80000d08:	8552                	mv	a0,s4
    80000d0a:	e04ff0ef          	jal	ra,8000030e <memmove>

    len -= n;
    80000d0e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000d12:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000d14:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80000d18:	02098063          	beqz	s3,80000d38 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000d1c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000d20:	85ca                	mv	a1,s2
    80000d22:	855a                	mv	a0,s6
    80000d24:	92bff0ef          	jal	ra,8000064e <walkaddr>
    if (pa0 == 0)
    80000d28:	cd01                	beqz	a0,80000d40 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000d2a:	418904b3          	sub	s1,s2,s8
    80000d2e:	94d6                	add	s1,s1,s5
    80000d30:	fc99f6e3          	bgeu	s3,s1,80000cfc <copyin+0x28>
    80000d34:	84ce                	mv	s1,s3
    80000d36:	b7d9                	j	80000cfc <copyin+0x28>
  }
  return 0;
    80000d38:	4501                	li	a0,0
    80000d3a:	a021                	j	80000d42 <copyin+0x6e>
    80000d3c:	4501                	li	a0,0
}
    80000d3e:	8082                	ret
      return -1;
    80000d40:	557d                	li	a0,-1
}
    80000d42:	60a6                	ld	ra,72(sp)
    80000d44:	6406                	ld	s0,64(sp)
    80000d46:	74e2                	ld	s1,56(sp)
    80000d48:	7942                	ld	s2,48(sp)
    80000d4a:	79a2                	ld	s3,40(sp)
    80000d4c:	7a02                	ld	s4,32(sp)
    80000d4e:	6ae2                	ld	s5,24(sp)
    80000d50:	6b42                	ld	s6,16(sp)
    80000d52:	6ba2                	ld	s7,8(sp)
    80000d54:	6c02                	ld	s8,0(sp)
    80000d56:	6161                	addi	sp,sp,80
    80000d58:	8082                	ret

0000000080000d5a <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80000d5a:	c2cd                	beqz	a3,80000dfc <copyinstr+0xa2>
{
    80000d5c:	715d                	addi	sp,sp,-80
    80000d5e:	e486                	sd	ra,72(sp)
    80000d60:	e0a2                	sd	s0,64(sp)
    80000d62:	fc26                	sd	s1,56(sp)
    80000d64:	f84a                	sd	s2,48(sp)
    80000d66:	f44e                	sd	s3,40(sp)
    80000d68:	f052                	sd	s4,32(sp)
    80000d6a:	ec56                	sd	s5,24(sp)
    80000d6c:	e85a                	sd	s6,16(sp)
    80000d6e:	e45e                	sd	s7,8(sp)
    80000d70:	0880                	addi	s0,sp,80
    80000d72:	8a2a                	mv	s4,a0
    80000d74:	8b2e                	mv	s6,a1
    80000d76:	8bb2                	mv	s7,a2
    80000d78:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000d7a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000d7c:	6985                	lui	s3,0x1
    80000d7e:	a02d                	j	80000da8 <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    80000d80:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000d84:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80000d86:	37fd                	addiw	a5,a5,-1
    80000d88:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    80000d8c:	60a6                	ld	ra,72(sp)
    80000d8e:	6406                	ld	s0,64(sp)
    80000d90:	74e2                	ld	s1,56(sp)
    80000d92:	7942                	ld	s2,48(sp)
    80000d94:	79a2                	ld	s3,40(sp)
    80000d96:	7a02                	ld	s4,32(sp)
    80000d98:	6ae2                	ld	s5,24(sp)
    80000d9a:	6b42                	ld	s6,16(sp)
    80000d9c:	6ba2                	ld	s7,8(sp)
    80000d9e:	6161                	addi	sp,sp,80
    80000da0:	8082                	ret
    srcva = va0 + PGSIZE;
    80000da2:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80000da6:	c4b9                	beqz	s1,80000df4 <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80000da8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000dac:	85ca                	mv	a1,s2
    80000dae:	8552                	mv	a0,s4
    80000db0:	89fff0ef          	jal	ra,8000064e <walkaddr>
    if (pa0 == 0)
    80000db4:	c131                	beqz	a0,80000df8 <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80000db6:	417906b3          	sub	a3,s2,s7
    80000dba:	96ce                	add	a3,a3,s3
    80000dbc:	00d4f363          	bgeu	s1,a3,80000dc2 <copyinstr+0x68>
    80000dc0:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80000dc2:	955e                	add	a0,a0,s7
    80000dc4:	41250533          	sub	a0,a0,s2
    while (n > 0)
    80000dc8:	dee9                	beqz	a3,80000da2 <copyinstr+0x48>
    80000dca:	87da                	mv	a5,s6
      if (*p == '\0')
    80000dcc:	41650633          	sub	a2,a0,s6
    80000dd0:	fff48593          	addi	a1,s1,-1 # ffffffffffffefff <end+0xffffffff7ffde02f>
    80000dd4:	95da                	add	a1,a1,s6
    while (n > 0)
    80000dd6:	96da                	add	a3,a3,s6
      if (*p == '\0')
    80000dd8:	00f60733          	add	a4,a2,a5
    80000ddc:	00074703          	lbu	a4,0(a4)
    80000de0:	d345                	beqz	a4,80000d80 <copyinstr+0x26>
        *dst = *p;
    80000de2:	00e78023          	sb	a4,0(a5)
      --max;
    80000de6:	40f584b3          	sub	s1,a1,a5
      dst++;
    80000dea:	0785                	addi	a5,a5,1
    while (n > 0)
    80000dec:	fed796e3          	bne	a5,a3,80000dd8 <copyinstr+0x7e>
      dst++;
    80000df0:	8b3e                	mv	s6,a5
    80000df2:	bf45                	j	80000da2 <copyinstr+0x48>
    80000df4:	4781                	li	a5,0
    80000df6:	bf41                	j	80000d86 <copyinstr+0x2c>
      return -1;
    80000df8:	557d                	li	a0,-1
    80000dfa:	bf49                	j	80000d8c <copyinstr+0x32>
  int got_null = 0;
    80000dfc:	4781                	li	a5,0
  if (got_null)
    80000dfe:	37fd                	addiw	a5,a5,-1
    80000e00:	0007851b          	sext.w	a0,a5
}
    80000e04:	8082                	ret

0000000080000e06 <vmprint_recurse>:
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
}
#endif

void vmprint_recurse(pagetable_t pagetable, int depth, uint64 va_recursive)
{ // seperate function so we can keep track of depth using a parameter
    80000e06:	7119                	addi	sp,sp,-128
    80000e08:	fc86                	sd	ra,120(sp)
    80000e0a:	f8a2                	sd	s0,112(sp)
    80000e0c:	f4a6                	sd	s1,104(sp)
    80000e0e:	f0ca                	sd	s2,96(sp)
    80000e10:	ecce                	sd	s3,88(sp)
    80000e12:	e8d2                	sd	s4,80(sp)
    80000e14:	e4d6                	sd	s5,72(sp)
    80000e16:	e0da                	sd	s6,64(sp)
    80000e18:	fc5e                	sd	s7,56(sp)
    80000e1a:	f862                	sd	s8,48(sp)
    80000e1c:	f466                	sd	s9,40(sp)
    80000e1e:	f06a                	sd	s10,32(sp)
    80000e20:	ec6e                	sd	s11,24(sp)
    80000e22:	0100                	addi	s0,sp,128
    80000e24:	8aae                	mv	s5,a1
    80000e26:	8d32                	mv	s10,a2
    { // skip the pte if it's not valid per lab spec
      continue;
    }

    // reconstruct va using i, px shift, and the previous va
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000e28:	4789                	li	a5,2
    80000e2a:	9f8d                	subw	a5,a5,a1
    80000e2c:	00379c9b          	slliw	s9,a5,0x3
    80000e30:	00fc8cbb          	addw	s9,s9,a5
    80000e34:	2cb1                	addiw	s9,s9,12
    80000e36:	8a2a                	mv	s4,a0
    80000e38:	4981                	li	s3,0
      printf(".. ");
    }
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));

    // recursive block
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000e3a:	4d85                	li	s11,1
    {
      uint64 child_pa = PTE2PA(pte); // get child pa to convert to a pagetable
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000e3c:	0015879b          	addiw	a5,a1,1
    80000e40:	f8f43423          	sd	a5,-120(s0)
      printf(".. ");
    80000e44:	00006b17          	auipc	s6,0x6
    80000e48:	43cb0b13          	addi	s6,s6,1084 # 80007280 <etext+0x280>
  for (int i = 0; i < 512; i++)
    80000e4c:	20000c13          	li	s8,512
    80000e50:	a029                	j	80000e5a <vmprint_recurse+0x54>
    80000e52:	0985                	addi	s3,s3,1 # 1001 <_entry-0x7fffefff>
    80000e54:	0a21                	addi	s4,s4,8
    80000e56:	07898163          	beq	s3,s8,80000eb8 <vmprint_recurse+0xb2>
    pte_t pte = pagetable[i]; // store pte from page table
    80000e5a:	000a3903          	ld	s2,0(s4)
    if (!(pte & PTE_V))
    80000e5e:	00197793          	andi	a5,s2,1
    80000e62:	dbe5                	beqz	a5,80000e52 <vmprint_recurse+0x4c>
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000e64:	01999bb3          	sll	s7,s3,s9
    80000e68:	01abebb3          	or	s7,s7,s10
    printf(" ");
    80000e6c:	00006517          	auipc	a0,0x6
    80000e70:	40c50513          	addi	a0,a0,1036 # 80007278 <etext+0x278>
    80000e74:	4da040ef          	jal	ra,8000534e <printf>
    for (int j = 0; j < depth; j++)
    80000e78:	01505963          	blez	s5,80000e8a <vmprint_recurse+0x84>
    80000e7c:	4481                	li	s1,0
      printf(".. ");
    80000e7e:	855a                	mv	a0,s6
    80000e80:	4ce040ef          	jal	ra,8000534e <printf>
    for (int j = 0; j < depth; j++)
    80000e84:	2485                	addiw	s1,s1,1
    80000e86:	fe9a9ce3          	bne	s5,s1,80000e7e <vmprint_recurse+0x78>
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));
    80000e8a:	00a95493          	srli	s1,s2,0xa
    80000e8e:	04b2                	slli	s1,s1,0xc
    80000e90:	86a6                	mv	a3,s1
    80000e92:	864a                	mv	a2,s2
    80000e94:	85de                	mv	a1,s7
    80000e96:	00006517          	auipc	a0,0x6
    80000e9a:	3f250513          	addi	a0,a0,1010 # 80007288 <etext+0x288>
    80000e9e:	4b0040ef          	jal	ra,8000534e <printf>
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000ea2:	00f97913          	andi	s2,s2,15
    80000ea6:	fbb916e3          	bne	s2,s11,80000e52 <vmprint_recurse+0x4c>
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000eaa:	865e                	mv	a2,s7
    80000eac:	f8843583          	ld	a1,-120(s0)
    80000eb0:	8526                	mv	a0,s1
    80000eb2:	f55ff0ef          	jal	ra,80000e06 <vmprint_recurse>
    80000eb6:	bf71                	j	80000e52 <vmprint_recurse+0x4c>
    }
  }
}
    80000eb8:	70e6                	ld	ra,120(sp)
    80000eba:	7446                	ld	s0,112(sp)
    80000ebc:	74a6                	ld	s1,104(sp)
    80000ebe:	7906                	ld	s2,96(sp)
    80000ec0:	69e6                	ld	s3,88(sp)
    80000ec2:	6a46                	ld	s4,80(sp)
    80000ec4:	6aa6                	ld	s5,72(sp)
    80000ec6:	6b06                	ld	s6,64(sp)
    80000ec8:	7be2                	ld	s7,56(sp)
    80000eca:	7c42                	ld	s8,48(sp)
    80000ecc:	7ca2                	ld	s9,40(sp)
    80000ece:	7d02                	ld	s10,32(sp)
    80000ed0:	6de2                	ld	s11,24(sp)
    80000ed2:	6109                	addi	sp,sp,128
    80000ed4:	8082                	ret

0000000080000ed6 <vmprint>:
{
    80000ed6:	1101                	addi	sp,sp,-32
    80000ed8:	ec06                	sd	ra,24(sp)
    80000eda:	e822                	sd	s0,16(sp)
    80000edc:	e426                	sd	s1,8(sp)
    80000ede:	1000                	addi	s0,sp,32
    80000ee0:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80000ee2:	85aa                	mv	a1,a0
    80000ee4:	00006517          	auipc	a0,0x6
    80000ee8:	3bc50513          	addi	a0,a0,956 # 800072a0 <etext+0x2a0>
    80000eec:	462040ef          	jal	ra,8000534e <printf>
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
    80000ef0:	4601                	li	a2,0
    80000ef2:	4581                	li	a1,0
    80000ef4:	8526                	mv	a0,s1
    80000ef6:	f11ff0ef          	jal	ra,80000e06 <vmprint_recurse>
}
    80000efa:	60e2                	ld	ra,24(sp)
    80000efc:	6442                	ld	s0,16(sp)
    80000efe:	64a2                	ld	s1,8(sp)
    80000f00:	6105                	addi	sp,sp,32
    80000f02:	8082                	ret

0000000080000f04 <pgpte>:

#ifdef LAB_PGTBL
pte_t *
pgpte(pagetable_t pagetable, uint64 va)
{
    80000f04:	1141                	addi	sp,sp,-16
    80000f06:	e406                	sd	ra,8(sp)
    80000f08:	e022                	sd	s0,0(sp)
    80000f0a:	0800                	addi	s0,sp,16
  return walk(pagetable, va, 0);
    80000f0c:	4601                	li	a2,0
    80000f0e:	e20ff0ef          	jal	ra,8000052e <walk>
}
    80000f12:	60a2                	ld	ra,8(sp)
    80000f14:	6402                	ld	s0,0(sp)
    80000f16:	0141                	addi	sp,sp,16
    80000f18:	8082                	ret

0000000080000f1a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000f1a:	7139                	addi	sp,sp,-64
    80000f1c:	fc06                	sd	ra,56(sp)
    80000f1e:	f822                	sd	s0,48(sp)
    80000f20:	f426                	sd	s1,40(sp)
    80000f22:	f04a                	sd	s2,32(sp)
    80000f24:	ec4e                	sd	s3,24(sp)
    80000f26:	e852                	sd	s4,16(sp)
    80000f28:	e456                	sd	s5,8(sp)
    80000f2a:	e05a                	sd	s6,0(sp)
    80000f2c:	0080                	addi	s0,sp,64
    80000f2e:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80000f30:	00007497          	auipc	s1,0x7
    80000f34:	1c048493          	addi	s1,s1,448 # 800080f0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000f38:	8b26                	mv	s6,s1
    80000f3a:	00006a97          	auipc	s5,0x6
    80000f3e:	0c6a8a93          	addi	s5,s5,198 # 80007000 <etext>
    80000f42:	04000937          	lui	s2,0x4000
    80000f46:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000f48:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f4a:	0000da17          	auipc	s4,0xd
    80000f4e:	ba6a0a13          	addi	s4,s4,-1114 # 8000daf0 <tickslock>
    char *pa = kalloc();
    80000f52:	a12ff0ef          	jal	ra,80000164 <kalloc>
    80000f56:	862a                	mv	a2,a0
    if(pa == 0)
    80000f58:	c121                	beqz	a0,80000f98 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80000f5a:	416485b3          	sub	a1,s1,s6
    80000f5e:	858d                	srai	a1,a1,0x3
    80000f60:	000ab783          	ld	a5,0(s5)
    80000f64:	02f585b3          	mul	a1,a1,a5
    80000f68:	2585                	addiw	a1,a1,1
    80000f6a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000f6e:	4719                	li	a4,6
    80000f70:	6685                	lui	a3,0x1
    80000f72:	40b905b3          	sub	a1,s2,a1
    80000f76:	854e                	mv	a0,s3
    80000f78:	fc4ff0ef          	jal	ra,8000073c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f7c:	16848493          	addi	s1,s1,360
    80000f80:	fd4499e3          	bne	s1,s4,80000f52 <proc_mapstacks+0x38>
  }
}
    80000f84:	70e2                	ld	ra,56(sp)
    80000f86:	7442                	ld	s0,48(sp)
    80000f88:	74a2                	ld	s1,40(sp)
    80000f8a:	7902                	ld	s2,32(sp)
    80000f8c:	69e2                	ld	s3,24(sp)
    80000f8e:	6a42                	ld	s4,16(sp)
    80000f90:	6aa2                	ld	s5,8(sp)
    80000f92:	6b02                	ld	s6,0(sp)
    80000f94:	6121                	addi	sp,sp,64
    80000f96:	8082                	ret
      panic("kalloc");
    80000f98:	00006517          	auipc	a0,0x6
    80000f9c:	31850513          	addi	a0,a0,792 # 800072b0 <etext+0x2b0>
    80000fa0:	662040ef          	jal	ra,80005602 <panic>

0000000080000fa4 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000fa4:	7139                	addi	sp,sp,-64
    80000fa6:	fc06                	sd	ra,56(sp)
    80000fa8:	f822                	sd	s0,48(sp)
    80000faa:	f426                	sd	s1,40(sp)
    80000fac:	f04a                	sd	s2,32(sp)
    80000fae:	ec4e                	sd	s3,24(sp)
    80000fb0:	e852                	sd	s4,16(sp)
    80000fb2:	e456                	sd	s5,8(sp)
    80000fb4:	e05a                	sd	s6,0(sp)
    80000fb6:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80000fb8:	00006597          	auipc	a1,0x6
    80000fbc:	30058593          	addi	a1,a1,768 # 800072b8 <etext+0x2b8>
    80000fc0:	00007517          	auipc	a0,0x7
    80000fc4:	d0050513          	addi	a0,a0,-768 # 80007cc0 <pid_lock>
    80000fc8:	0cb040ef          	jal	ra,80005892 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000fcc:	00006597          	auipc	a1,0x6
    80000fd0:	2f458593          	addi	a1,a1,756 # 800072c0 <etext+0x2c0>
    80000fd4:	00007517          	auipc	a0,0x7
    80000fd8:	d0450513          	addi	a0,a0,-764 # 80007cd8 <wait_lock>
    80000fdc:	0b7040ef          	jal	ra,80005892 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fe0:	00007497          	auipc	s1,0x7
    80000fe4:	11048493          	addi	s1,s1,272 # 800080f0 <proc>
      initlock(&p->lock, "proc");
    80000fe8:	00006b17          	auipc	s6,0x6
    80000fec:	2e8b0b13          	addi	s6,s6,744 # 800072d0 <etext+0x2d0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000ff0:	8aa6                	mv	s5,s1
    80000ff2:	00006a17          	auipc	s4,0x6
    80000ff6:	00ea0a13          	addi	s4,s4,14 # 80007000 <etext>
    80000ffa:	04000937          	lui	s2,0x4000
    80000ffe:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001000:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001002:	0000d997          	auipc	s3,0xd
    80001006:	aee98993          	addi	s3,s3,-1298 # 8000daf0 <tickslock>
      initlock(&p->lock, "proc");
    8000100a:	85da                	mv	a1,s6
    8000100c:	8526                	mv	a0,s1
    8000100e:	085040ef          	jal	ra,80005892 <initlock>
      p->state = UNUSED;
    80001012:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001016:	415487b3          	sub	a5,s1,s5
    8000101a:	878d                	srai	a5,a5,0x3
    8000101c:	000a3703          	ld	a4,0(s4)
    80001020:	02e787b3          	mul	a5,a5,a4
    80001024:	2785                	addiw	a5,a5,1
    80001026:	00d7979b          	slliw	a5,a5,0xd
    8000102a:	40f907b3          	sub	a5,s2,a5
    8000102e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001030:	16848493          	addi	s1,s1,360
    80001034:	fd349be3          	bne	s1,s3,8000100a <procinit+0x66>
  }
}
    80001038:	70e2                	ld	ra,56(sp)
    8000103a:	7442                	ld	s0,48(sp)
    8000103c:	74a2                	ld	s1,40(sp)
    8000103e:	7902                	ld	s2,32(sp)
    80001040:	69e2                	ld	s3,24(sp)
    80001042:	6a42                	ld	s4,16(sp)
    80001044:	6aa2                	ld	s5,8(sp)
    80001046:	6b02                	ld	s6,0(sp)
    80001048:	6121                	addi	sp,sp,64
    8000104a:	8082                	ret

000000008000104c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000104c:	1141                	addi	sp,sp,-16
    8000104e:	e422                	sd	s0,8(sp)
    80001050:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001052:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001054:	2501                	sext.w	a0,a0
    80001056:	6422                	ld	s0,8(sp)
    80001058:	0141                	addi	sp,sp,16
    8000105a:	8082                	ret

000000008000105c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000105c:	1141                	addi	sp,sp,-16
    8000105e:	e422                	sd	s0,8(sp)
    80001060:	0800                	addi	s0,sp,16
    80001062:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001064:	2781                	sext.w	a5,a5
    80001066:	079e                	slli	a5,a5,0x7
  return c;
}
    80001068:	00007517          	auipc	a0,0x7
    8000106c:	c8850513          	addi	a0,a0,-888 # 80007cf0 <cpus>
    80001070:	953e                	add	a0,a0,a5
    80001072:	6422                	ld	s0,8(sp)
    80001074:	0141                	addi	sp,sp,16
    80001076:	8082                	ret

0000000080001078 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001078:	1101                	addi	sp,sp,-32
    8000107a:	ec06                	sd	ra,24(sp)
    8000107c:	e822                	sd	s0,16(sp)
    8000107e:	e426                	sd	s1,8(sp)
    80001080:	1000                	addi	s0,sp,32
  push_off();
    80001082:	051040ef          	jal	ra,800058d2 <push_off>
    80001086:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001088:	2781                	sext.w	a5,a5
    8000108a:	079e                	slli	a5,a5,0x7
    8000108c:	00007717          	auipc	a4,0x7
    80001090:	c3470713          	addi	a4,a4,-972 # 80007cc0 <pid_lock>
    80001094:	97ba                	add	a5,a5,a4
    80001096:	7b84                	ld	s1,48(a5)
  pop_off();
    80001098:	0bf040ef          	jal	ra,80005956 <pop_off>
  return p;
}
    8000109c:	8526                	mv	a0,s1
    8000109e:	60e2                	ld	ra,24(sp)
    800010a0:	6442                	ld	s0,16(sp)
    800010a2:	64a2                	ld	s1,8(sp)
    800010a4:	6105                	addi	sp,sp,32
    800010a6:	8082                	ret

00000000800010a8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800010a8:	1141                	addi	sp,sp,-16
    800010aa:	e406                	sd	ra,8(sp)
    800010ac:	e022                	sd	s0,0(sp)
    800010ae:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800010b0:	fc9ff0ef          	jal	ra,80001078 <myproc>
    800010b4:	0f7040ef          	jal	ra,800059aa <release>

  if (first) {
    800010b8:	00007797          	auipc	a5,0x7
    800010bc:	9487a783          	lw	a5,-1720(a5) # 80007a00 <first.1>
    800010c0:	e799                	bnez	a5,800010ce <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    800010c2:	2bd000ef          	jal	ra,80001b7e <usertrapret>
}
    800010c6:	60a2                	ld	ra,8(sp)
    800010c8:	6402                	ld	s0,0(sp)
    800010ca:	0141                	addi	sp,sp,16
    800010cc:	8082                	ret
    fsinit(ROOTDEV);
    800010ce:	4505                	li	a0,1
    800010d0:	688010ef          	jal	ra,80002758 <fsinit>
    first = 0;
    800010d4:	00007797          	auipc	a5,0x7
    800010d8:	9207a623          	sw	zero,-1748(a5) # 80007a00 <first.1>
    __sync_synchronize();
    800010dc:	0ff0000f          	fence
    800010e0:	b7cd                	j	800010c2 <forkret+0x1a>

00000000800010e2 <allocpid>:
{
    800010e2:	1101                	addi	sp,sp,-32
    800010e4:	ec06                	sd	ra,24(sp)
    800010e6:	e822                	sd	s0,16(sp)
    800010e8:	e426                	sd	s1,8(sp)
    800010ea:	e04a                	sd	s2,0(sp)
    800010ec:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800010ee:	00007917          	auipc	s2,0x7
    800010f2:	bd290913          	addi	s2,s2,-1070 # 80007cc0 <pid_lock>
    800010f6:	854a                	mv	a0,s2
    800010f8:	01b040ef          	jal	ra,80005912 <acquire>
  pid = nextpid;
    800010fc:	00007797          	auipc	a5,0x7
    80001100:	90878793          	addi	a5,a5,-1784 # 80007a04 <nextpid>
    80001104:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001106:	0014871b          	addiw	a4,s1,1
    8000110a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    8000110c:	854a                	mv	a0,s2
    8000110e:	09d040ef          	jal	ra,800059aa <release>
}
    80001112:	8526                	mv	a0,s1
    80001114:	60e2                	ld	ra,24(sp)
    80001116:	6442                	ld	s0,16(sp)
    80001118:	64a2                	ld	s1,8(sp)
    8000111a:	6902                	ld	s2,0(sp)
    8000111c:	6105                	addi	sp,sp,32
    8000111e:	8082                	ret

0000000080001120 <proc_pagetable>:
{
    80001120:	1101                	addi	sp,sp,-32
    80001122:	ec06                	sd	ra,24(sp)
    80001124:	e822                	sd	s0,16(sp)
    80001126:	e426                	sd	s1,8(sp)
    80001128:	e04a                	sd	s2,0(sp)
    8000112a:	1000                	addi	s0,sp,32
    8000112c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000112e:	81fff0ef          	jal	ra,8000094c <uvmcreate>
    80001132:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001134:	cd05                	beqz	a0,8000116c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001136:	4729                	li	a4,10
    80001138:	00005697          	auipc	a3,0x5
    8000113c:	ec868693          	addi	a3,a3,-312 # 80006000 <_trampoline>
    80001140:	6605                	lui	a2,0x1
    80001142:	040005b7          	lui	a1,0x4000
    80001146:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001148:	05b2                	slli	a1,a1,0xc
    8000114a:	d42ff0ef          	jal	ra,8000068c <mappages>
    8000114e:	02054663          	bltz	a0,8000117a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001152:	4719                	li	a4,6
    80001154:	05893683          	ld	a3,88(s2)
    80001158:	6605                	lui	a2,0x1
    8000115a:	020005b7          	lui	a1,0x2000
    8000115e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001160:	05b6                	slli	a1,a1,0xd
    80001162:	8526                	mv	a0,s1
    80001164:	d28ff0ef          	jal	ra,8000068c <mappages>
    80001168:	00054f63          	bltz	a0,80001186 <proc_pagetable+0x66>
}
    8000116c:	8526                	mv	a0,s1
    8000116e:	60e2                	ld	ra,24(sp)
    80001170:	6442                	ld	s0,16(sp)
    80001172:	64a2                	ld	s1,8(sp)
    80001174:	6902                	ld	s2,0(sp)
    80001176:	6105                	addi	sp,sp,32
    80001178:	8082                	ret
    uvmfree(pagetable, 0);
    8000117a:	4581                	li	a1,0
    8000117c:	8526                	mv	a0,s1
    8000117e:	991ff0ef          	jal	ra,80000b0e <uvmfree>
    return 0;
    80001182:	4481                	li	s1,0
    80001184:	b7e5                	j	8000116c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001186:	4681                	li	a3,0
    80001188:	4605                	li	a2,1
    8000118a:	040005b7          	lui	a1,0x4000
    8000118e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001190:	05b2                	slli	a1,a1,0xc
    80001192:	8526                	mv	a0,s1
    80001194:	efcff0ef          	jal	ra,80000890 <uvmunmap>
    uvmfree(pagetable, 0);
    80001198:	4581                	li	a1,0
    8000119a:	8526                	mv	a0,s1
    8000119c:	973ff0ef          	jal	ra,80000b0e <uvmfree>
    return 0;
    800011a0:	4481                	li	s1,0
    800011a2:	b7e9                	j	8000116c <proc_pagetable+0x4c>

00000000800011a4 <proc_freepagetable>:
{
    800011a4:	1101                	addi	sp,sp,-32
    800011a6:	ec06                	sd	ra,24(sp)
    800011a8:	e822                	sd	s0,16(sp)
    800011aa:	e426                	sd	s1,8(sp)
    800011ac:	e04a                	sd	s2,0(sp)
    800011ae:	1000                	addi	s0,sp,32
    800011b0:	84aa                	mv	s1,a0
    800011b2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800011b4:	4681                	li	a3,0
    800011b6:	4605                	li	a2,1
    800011b8:	040005b7          	lui	a1,0x4000
    800011bc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011be:	05b2                	slli	a1,a1,0xc
    800011c0:	ed0ff0ef          	jal	ra,80000890 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800011c4:	4681                	li	a3,0
    800011c6:	4605                	li	a2,1
    800011c8:	020005b7          	lui	a1,0x2000
    800011cc:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800011ce:	05b6                	slli	a1,a1,0xd
    800011d0:	8526                	mv	a0,s1
    800011d2:	ebeff0ef          	jal	ra,80000890 <uvmunmap>
  uvmfree(pagetable, sz);
    800011d6:	85ca                	mv	a1,s2
    800011d8:	8526                	mv	a0,s1
    800011da:	935ff0ef          	jal	ra,80000b0e <uvmfree>
}
    800011de:	60e2                	ld	ra,24(sp)
    800011e0:	6442                	ld	s0,16(sp)
    800011e2:	64a2                	ld	s1,8(sp)
    800011e4:	6902                	ld	s2,0(sp)
    800011e6:	6105                	addi	sp,sp,32
    800011e8:	8082                	ret

00000000800011ea <freeproc>:
{
    800011ea:	1101                	addi	sp,sp,-32
    800011ec:	ec06                	sd	ra,24(sp)
    800011ee:	e822                	sd	s0,16(sp)
    800011f0:	e426                	sd	s1,8(sp)
    800011f2:	1000                	addi	s0,sp,32
    800011f4:	84aa                	mv	s1,a0
  if(p->trapframe)
    800011f6:	6d28                	ld	a0,88(a0)
    800011f8:	c119                	beqz	a0,800011fe <freeproc+0x14>
    kfree((void*)p->trapframe);
    800011fa:	e77fe0ef          	jal	ra,80000070 <kfree>
  p->trapframe = 0;
    800011fe:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001202:	68a8                	ld	a0,80(s1)
    80001204:	c501                	beqz	a0,8000120c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001206:	64ac                	ld	a1,72(s1)
    80001208:	f9dff0ef          	jal	ra,800011a4 <proc_freepagetable>
  p->pagetable = 0;
    8000120c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001210:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001214:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001218:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000121c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001220:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001224:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001228:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    8000122c:	0004ac23          	sw	zero,24(s1)
}
    80001230:	60e2                	ld	ra,24(sp)
    80001232:	6442                	ld	s0,16(sp)
    80001234:	64a2                	ld	s1,8(sp)
    80001236:	6105                	addi	sp,sp,32
    80001238:	8082                	ret

000000008000123a <allocproc>:
{
    8000123a:	1101                	addi	sp,sp,-32
    8000123c:	ec06                	sd	ra,24(sp)
    8000123e:	e822                	sd	s0,16(sp)
    80001240:	e426                	sd	s1,8(sp)
    80001242:	e04a                	sd	s2,0(sp)
    80001244:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001246:	00007497          	auipc	s1,0x7
    8000124a:	eaa48493          	addi	s1,s1,-342 # 800080f0 <proc>
    8000124e:	0000d917          	auipc	s2,0xd
    80001252:	8a290913          	addi	s2,s2,-1886 # 8000daf0 <tickslock>
    acquire(&p->lock);
    80001256:	8526                	mv	a0,s1
    80001258:	6ba040ef          	jal	ra,80005912 <acquire>
    if(p->state == UNUSED) {
    8000125c:	4c9c                	lw	a5,24(s1)
    8000125e:	cb91                	beqz	a5,80001272 <allocproc+0x38>
      release(&p->lock);
    80001260:	8526                	mv	a0,s1
    80001262:	748040ef          	jal	ra,800059aa <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001266:	16848493          	addi	s1,s1,360
    8000126a:	ff2496e3          	bne	s1,s2,80001256 <allocproc+0x1c>
  return 0;
    8000126e:	4481                	li	s1,0
    80001270:	a089                	j	800012b2 <allocproc+0x78>
  p->pid = allocpid();
    80001272:	e71ff0ef          	jal	ra,800010e2 <allocpid>
    80001276:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001278:	4785                	li	a5,1
    8000127a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000127c:	ee9fe0ef          	jal	ra,80000164 <kalloc>
    80001280:	892a                	mv	s2,a0
    80001282:	eca8                	sd	a0,88(s1)
    80001284:	cd15                	beqz	a0,800012c0 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001286:	8526                	mv	a0,s1
    80001288:	e99ff0ef          	jal	ra,80001120 <proc_pagetable>
    8000128c:	892a                	mv	s2,a0
    8000128e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001290:	c121                	beqz	a0,800012d0 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001292:	07000613          	li	a2,112
    80001296:	4581                	li	a1,0
    80001298:	06048513          	addi	a0,s1,96
    8000129c:	816ff0ef          	jal	ra,800002b2 <memset>
  p->context.ra = (uint64)forkret;
    800012a0:	00000797          	auipc	a5,0x0
    800012a4:	e0878793          	addi	a5,a5,-504 # 800010a8 <forkret>
    800012a8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800012aa:	60bc                	ld	a5,64(s1)
    800012ac:	6705                	lui	a4,0x1
    800012ae:	97ba                	add	a5,a5,a4
    800012b0:	f4bc                	sd	a5,104(s1)
}
    800012b2:	8526                	mv	a0,s1
    800012b4:	60e2                	ld	ra,24(sp)
    800012b6:	6442                	ld	s0,16(sp)
    800012b8:	64a2                	ld	s1,8(sp)
    800012ba:	6902                	ld	s2,0(sp)
    800012bc:	6105                	addi	sp,sp,32
    800012be:	8082                	ret
    freeproc(p);
    800012c0:	8526                	mv	a0,s1
    800012c2:	f29ff0ef          	jal	ra,800011ea <freeproc>
    release(&p->lock);
    800012c6:	8526                	mv	a0,s1
    800012c8:	6e2040ef          	jal	ra,800059aa <release>
    return 0;
    800012cc:	84ca                	mv	s1,s2
    800012ce:	b7d5                	j	800012b2 <allocproc+0x78>
    freeproc(p);
    800012d0:	8526                	mv	a0,s1
    800012d2:	f19ff0ef          	jal	ra,800011ea <freeproc>
    release(&p->lock);
    800012d6:	8526                	mv	a0,s1
    800012d8:	6d2040ef          	jal	ra,800059aa <release>
    return 0;
    800012dc:	84ca                	mv	s1,s2
    800012de:	bfd1                	j	800012b2 <allocproc+0x78>

00000000800012e0 <userinit>:
{
    800012e0:	1101                	addi	sp,sp,-32
    800012e2:	ec06                	sd	ra,24(sp)
    800012e4:	e822                	sd	s0,16(sp)
    800012e6:	e426                	sd	s1,8(sp)
    800012e8:	1000                	addi	s0,sp,32
  p = allocproc();
    800012ea:	f51ff0ef          	jal	ra,8000123a <allocproc>
    800012ee:	84aa                	mv	s1,a0
  initproc = p;
    800012f0:	00006797          	auipc	a5,0x6
    800012f4:	78a7b823          	sd	a0,1936(a5) # 80007a80 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800012f8:	03400613          	li	a2,52
    800012fc:	00006597          	auipc	a1,0x6
    80001300:	71458593          	addi	a1,a1,1812 # 80007a10 <initcode>
    80001304:	6928                	ld	a0,80(a0)
    80001306:	e6cff0ef          	jal	ra,80000972 <uvmfirst>
  p->sz = PGSIZE;
    8000130a:	6785                	lui	a5,0x1
    8000130c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000130e:	6cb8                	ld	a4,88(s1)
    80001310:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001314:	6cb8                	ld	a4,88(s1)
    80001316:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001318:	4641                	li	a2,16
    8000131a:	00006597          	auipc	a1,0x6
    8000131e:	fbe58593          	addi	a1,a1,-66 # 800072d8 <etext+0x2d8>
    80001322:	15848513          	addi	a0,s1,344
    80001326:	8d2ff0ef          	jal	ra,800003f8 <safestrcpy>
  p->cwd = namei("/");
    8000132a:	00006517          	auipc	a0,0x6
    8000132e:	fbe50513          	addi	a0,a0,-66 # 800072e8 <etext+0x2e8>
    80001332:	50d010ef          	jal	ra,8000303e <namei>
    80001336:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000133a:	478d                	li	a5,3
    8000133c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000133e:	8526                	mv	a0,s1
    80001340:	66a040ef          	jal	ra,800059aa <release>
}
    80001344:	60e2                	ld	ra,24(sp)
    80001346:	6442                	ld	s0,16(sp)
    80001348:	64a2                	ld	s1,8(sp)
    8000134a:	6105                	addi	sp,sp,32
    8000134c:	8082                	ret

000000008000134e <growproc>:
{
    8000134e:	1101                	addi	sp,sp,-32
    80001350:	ec06                	sd	ra,24(sp)
    80001352:	e822                	sd	s0,16(sp)
    80001354:	e426                	sd	s1,8(sp)
    80001356:	e04a                	sd	s2,0(sp)
    80001358:	1000                	addi	s0,sp,32
    8000135a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000135c:	d1dff0ef          	jal	ra,80001078 <myproc>
    80001360:	84aa                	mv	s1,a0
  sz = p->sz;
    80001362:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001364:	01204c63          	bgtz	s2,8000137c <growproc+0x2e>
  } else if(n < 0){
    80001368:	02094463          	bltz	s2,80001390 <growproc+0x42>
  p->sz = sz;
    8000136c:	e4ac                	sd	a1,72(s1)
  return 0;
    8000136e:	4501                	li	a0,0
}
    80001370:	60e2                	ld	ra,24(sp)
    80001372:	6442                	ld	s0,16(sp)
    80001374:	64a2                	ld	s1,8(sp)
    80001376:	6902                	ld	s2,0(sp)
    80001378:	6105                	addi	sp,sp,32
    8000137a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000137c:	4691                	li	a3,4
    8000137e:	00b90633          	add	a2,s2,a1
    80001382:	6928                	ld	a0,80(a0)
    80001384:	e90ff0ef          	jal	ra,80000a14 <uvmalloc>
    80001388:	85aa                	mv	a1,a0
    8000138a:	f16d                	bnez	a0,8000136c <growproc+0x1e>
      return -1;
    8000138c:	557d                	li	a0,-1
    8000138e:	b7cd                	j	80001370 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001390:	00b90633          	add	a2,s2,a1
    80001394:	6928                	ld	a0,80(a0)
    80001396:	e3aff0ef          	jal	ra,800009d0 <uvmdealloc>
    8000139a:	85aa                	mv	a1,a0
    8000139c:	bfc1                	j	8000136c <growproc+0x1e>

000000008000139e <fork>:
{
    8000139e:	7139                	addi	sp,sp,-64
    800013a0:	fc06                	sd	ra,56(sp)
    800013a2:	f822                	sd	s0,48(sp)
    800013a4:	f426                	sd	s1,40(sp)
    800013a6:	f04a                	sd	s2,32(sp)
    800013a8:	ec4e                	sd	s3,24(sp)
    800013aa:	e852                	sd	s4,16(sp)
    800013ac:	e456                	sd	s5,8(sp)
    800013ae:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800013b0:	cc9ff0ef          	jal	ra,80001078 <myproc>
    800013b4:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800013b6:	e85ff0ef          	jal	ra,8000123a <allocproc>
    800013ba:	0e050663          	beqz	a0,800014a6 <fork+0x108>
    800013be:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800013c0:	048ab603          	ld	a2,72(s5)
    800013c4:	692c                	ld	a1,80(a0)
    800013c6:	050ab503          	ld	a0,80(s5)
    800013ca:	f76ff0ef          	jal	ra,80000b40 <uvmcopy>
    800013ce:	04054863          	bltz	a0,8000141e <fork+0x80>
  np->sz = p->sz;
    800013d2:	048ab783          	ld	a5,72(s5)
    800013d6:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800013da:	058ab683          	ld	a3,88(s5)
    800013de:	87b6                	mv	a5,a3
    800013e0:	058a3703          	ld	a4,88(s4)
    800013e4:	12068693          	addi	a3,a3,288
    800013e8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800013ec:	6788                	ld	a0,8(a5)
    800013ee:	6b8c                	ld	a1,16(a5)
    800013f0:	6f90                	ld	a2,24(a5)
    800013f2:	01073023          	sd	a6,0(a4)
    800013f6:	e708                	sd	a0,8(a4)
    800013f8:	eb0c                	sd	a1,16(a4)
    800013fa:	ef10                	sd	a2,24(a4)
    800013fc:	02078793          	addi	a5,a5,32
    80001400:	02070713          	addi	a4,a4,32
    80001404:	fed792e3          	bne	a5,a3,800013e8 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001408:	058a3783          	ld	a5,88(s4)
    8000140c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001410:	0d0a8493          	addi	s1,s5,208
    80001414:	0d0a0913          	addi	s2,s4,208
    80001418:	150a8993          	addi	s3,s5,336
    8000141c:	a829                	j	80001436 <fork+0x98>
    freeproc(np);
    8000141e:	8552                	mv	a0,s4
    80001420:	dcbff0ef          	jal	ra,800011ea <freeproc>
    release(&np->lock);
    80001424:	8552                	mv	a0,s4
    80001426:	584040ef          	jal	ra,800059aa <release>
    return -1;
    8000142a:	597d                	li	s2,-1
    8000142c:	a09d                	j	80001492 <fork+0xf4>
  for(i = 0; i < NOFILE; i++)
    8000142e:	04a1                	addi	s1,s1,8
    80001430:	0921                	addi	s2,s2,8
    80001432:	01348963          	beq	s1,s3,80001444 <fork+0xa6>
    if(p->ofile[i])
    80001436:	6088                	ld	a0,0(s1)
    80001438:	d97d                	beqz	a0,8000142e <fork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    8000143a:	1b2020ef          	jal	ra,800035ec <filedup>
    8000143e:	00a93023          	sd	a0,0(s2)
    80001442:	b7f5                	j	8000142e <fork+0x90>
  np->cwd = idup(p->cwd);
    80001444:	150ab503          	ld	a0,336(s5)
    80001448:	508010ef          	jal	ra,80002950 <idup>
    8000144c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001450:	4641                	li	a2,16
    80001452:	158a8593          	addi	a1,s5,344
    80001456:	158a0513          	addi	a0,s4,344
    8000145a:	f9ffe0ef          	jal	ra,800003f8 <safestrcpy>
  pid = np->pid;
    8000145e:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001462:	8552                	mv	a0,s4
    80001464:	546040ef          	jal	ra,800059aa <release>
  acquire(&wait_lock);
    80001468:	00007497          	auipc	s1,0x7
    8000146c:	87048493          	addi	s1,s1,-1936 # 80007cd8 <wait_lock>
    80001470:	8526                	mv	a0,s1
    80001472:	4a0040ef          	jal	ra,80005912 <acquire>
  np->parent = p;
    80001476:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    8000147a:	8526                	mv	a0,s1
    8000147c:	52e040ef          	jal	ra,800059aa <release>
  acquire(&np->lock);
    80001480:	8552                	mv	a0,s4
    80001482:	490040ef          	jal	ra,80005912 <acquire>
  np->state = RUNNABLE;
    80001486:	478d                	li	a5,3
    80001488:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000148c:	8552                	mv	a0,s4
    8000148e:	51c040ef          	jal	ra,800059aa <release>
}
    80001492:	854a                	mv	a0,s2
    80001494:	70e2                	ld	ra,56(sp)
    80001496:	7442                	ld	s0,48(sp)
    80001498:	74a2                	ld	s1,40(sp)
    8000149a:	7902                	ld	s2,32(sp)
    8000149c:	69e2                	ld	s3,24(sp)
    8000149e:	6a42                	ld	s4,16(sp)
    800014a0:	6aa2                	ld	s5,8(sp)
    800014a2:	6121                	addi	sp,sp,64
    800014a4:	8082                	ret
    return -1;
    800014a6:	597d                	li	s2,-1
    800014a8:	b7ed                	j	80001492 <fork+0xf4>

00000000800014aa <scheduler>:
{
    800014aa:	715d                	addi	sp,sp,-80
    800014ac:	e486                	sd	ra,72(sp)
    800014ae:	e0a2                	sd	s0,64(sp)
    800014b0:	fc26                	sd	s1,56(sp)
    800014b2:	f84a                	sd	s2,48(sp)
    800014b4:	f44e                	sd	s3,40(sp)
    800014b6:	f052                	sd	s4,32(sp)
    800014b8:	ec56                	sd	s5,24(sp)
    800014ba:	e85a                	sd	s6,16(sp)
    800014bc:	e45e                	sd	s7,8(sp)
    800014be:	e062                	sd	s8,0(sp)
    800014c0:	0880                	addi	s0,sp,80
    800014c2:	8792                	mv	a5,tp
  int id = r_tp();
    800014c4:	2781                	sext.w	a5,a5
  c->proc = 0;
    800014c6:	00779b13          	slli	s6,a5,0x7
    800014ca:	00006717          	auipc	a4,0x6
    800014ce:	7f670713          	addi	a4,a4,2038 # 80007cc0 <pid_lock>
    800014d2:	975a                	add	a4,a4,s6
    800014d4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800014d8:	00007717          	auipc	a4,0x7
    800014dc:	82070713          	addi	a4,a4,-2016 # 80007cf8 <cpus+0x8>
    800014e0:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800014e2:	4c11                	li	s8,4
        c->proc = p;
    800014e4:	079e                	slli	a5,a5,0x7
    800014e6:	00006a17          	auipc	s4,0x6
    800014ea:	7daa0a13          	addi	s4,s4,2010 # 80007cc0 <pid_lock>
    800014ee:	9a3e                	add	s4,s4,a5
        found = 1;
    800014f0:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800014f2:	0000c997          	auipc	s3,0xc
    800014f6:	5fe98993          	addi	s3,s3,1534 # 8000daf0 <tickslock>
    800014fa:	a0a9                	j	80001544 <scheduler+0x9a>
      release(&p->lock);
    800014fc:	8526                	mv	a0,s1
    800014fe:	4ac040ef          	jal	ra,800059aa <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001502:	16848493          	addi	s1,s1,360
    80001506:	03348563          	beq	s1,s3,80001530 <scheduler+0x86>
      acquire(&p->lock);
    8000150a:	8526                	mv	a0,s1
    8000150c:	406040ef          	jal	ra,80005912 <acquire>
      if(p->state == RUNNABLE) {
    80001510:	4c9c                	lw	a5,24(s1)
    80001512:	ff2795e3          	bne	a5,s2,800014fc <scheduler+0x52>
        p->state = RUNNING;
    80001516:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000151a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000151e:	06048593          	addi	a1,s1,96
    80001522:	855a                	mv	a0,s6
    80001524:	5b4000ef          	jal	ra,80001ad8 <swtch>
        c->proc = 0;
    80001528:	020a3823          	sd	zero,48(s4)
        found = 1;
    8000152c:	8ade                	mv	s5,s7
    8000152e:	b7f9                	j	800014fc <scheduler+0x52>
    if(found == 0) {
    80001530:	000a9a63          	bnez	s5,80001544 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001534:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001538:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000153c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001540:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001544:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001548:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000154c:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001550:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001552:	00007497          	auipc	s1,0x7
    80001556:	b9e48493          	addi	s1,s1,-1122 # 800080f0 <proc>
      if(p->state == RUNNABLE) {
    8000155a:	490d                	li	s2,3
    8000155c:	b77d                	j	8000150a <scheduler+0x60>

000000008000155e <sched>:
{
    8000155e:	7179                	addi	sp,sp,-48
    80001560:	f406                	sd	ra,40(sp)
    80001562:	f022                	sd	s0,32(sp)
    80001564:	ec26                	sd	s1,24(sp)
    80001566:	e84a                	sd	s2,16(sp)
    80001568:	e44e                	sd	s3,8(sp)
    8000156a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000156c:	b0dff0ef          	jal	ra,80001078 <myproc>
    80001570:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001572:	336040ef          	jal	ra,800058a8 <holding>
    80001576:	c92d                	beqz	a0,800015e8 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001578:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000157a:	2781                	sext.w	a5,a5
    8000157c:	079e                	slli	a5,a5,0x7
    8000157e:	00006717          	auipc	a4,0x6
    80001582:	74270713          	addi	a4,a4,1858 # 80007cc0 <pid_lock>
    80001586:	97ba                	add	a5,a5,a4
    80001588:	0a87a703          	lw	a4,168(a5)
    8000158c:	4785                	li	a5,1
    8000158e:	06f71363          	bne	a4,a5,800015f4 <sched+0x96>
  if(p->state == RUNNING)
    80001592:	4c98                	lw	a4,24(s1)
    80001594:	4791                	li	a5,4
    80001596:	06f70563          	beq	a4,a5,80001600 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000159a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000159e:	8b89                	andi	a5,a5,2
  if(intr_get())
    800015a0:	e7b5                	bnez	a5,8000160c <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800015a2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800015a4:	00006917          	auipc	s2,0x6
    800015a8:	71c90913          	addi	s2,s2,1820 # 80007cc0 <pid_lock>
    800015ac:	2781                	sext.w	a5,a5
    800015ae:	079e                	slli	a5,a5,0x7
    800015b0:	97ca                	add	a5,a5,s2
    800015b2:	0ac7a983          	lw	s3,172(a5)
    800015b6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800015b8:	2781                	sext.w	a5,a5
    800015ba:	079e                	slli	a5,a5,0x7
    800015bc:	00006597          	auipc	a1,0x6
    800015c0:	73c58593          	addi	a1,a1,1852 # 80007cf8 <cpus+0x8>
    800015c4:	95be                	add	a1,a1,a5
    800015c6:	06048513          	addi	a0,s1,96
    800015ca:	50e000ef          	jal	ra,80001ad8 <swtch>
    800015ce:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800015d0:	2781                	sext.w	a5,a5
    800015d2:	079e                	slli	a5,a5,0x7
    800015d4:	993e                	add	s2,s2,a5
    800015d6:	0b392623          	sw	s3,172(s2)
}
    800015da:	70a2                	ld	ra,40(sp)
    800015dc:	7402                	ld	s0,32(sp)
    800015de:	64e2                	ld	s1,24(sp)
    800015e0:	6942                	ld	s2,16(sp)
    800015e2:	69a2                	ld	s3,8(sp)
    800015e4:	6145                	addi	sp,sp,48
    800015e6:	8082                	ret
    panic("sched p->lock");
    800015e8:	00006517          	auipc	a0,0x6
    800015ec:	d0850513          	addi	a0,a0,-760 # 800072f0 <etext+0x2f0>
    800015f0:	012040ef          	jal	ra,80005602 <panic>
    panic("sched locks");
    800015f4:	00006517          	auipc	a0,0x6
    800015f8:	d0c50513          	addi	a0,a0,-756 # 80007300 <etext+0x300>
    800015fc:	006040ef          	jal	ra,80005602 <panic>
    panic("sched running");
    80001600:	00006517          	auipc	a0,0x6
    80001604:	d1050513          	addi	a0,a0,-752 # 80007310 <etext+0x310>
    80001608:	7fb030ef          	jal	ra,80005602 <panic>
    panic("sched interruptible");
    8000160c:	00006517          	auipc	a0,0x6
    80001610:	d1450513          	addi	a0,a0,-748 # 80007320 <etext+0x320>
    80001614:	7ef030ef          	jal	ra,80005602 <panic>

0000000080001618 <yield>:
{
    80001618:	1101                	addi	sp,sp,-32
    8000161a:	ec06                	sd	ra,24(sp)
    8000161c:	e822                	sd	s0,16(sp)
    8000161e:	e426                	sd	s1,8(sp)
    80001620:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001622:	a57ff0ef          	jal	ra,80001078 <myproc>
    80001626:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001628:	2ea040ef          	jal	ra,80005912 <acquire>
  p->state = RUNNABLE;
    8000162c:	478d                	li	a5,3
    8000162e:	cc9c                	sw	a5,24(s1)
  sched();
    80001630:	f2fff0ef          	jal	ra,8000155e <sched>
  release(&p->lock);
    80001634:	8526                	mv	a0,s1
    80001636:	374040ef          	jal	ra,800059aa <release>
}
    8000163a:	60e2                	ld	ra,24(sp)
    8000163c:	6442                	ld	s0,16(sp)
    8000163e:	64a2                	ld	s1,8(sp)
    80001640:	6105                	addi	sp,sp,32
    80001642:	8082                	ret

0000000080001644 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001644:	7179                	addi	sp,sp,-48
    80001646:	f406                	sd	ra,40(sp)
    80001648:	f022                	sd	s0,32(sp)
    8000164a:	ec26                	sd	s1,24(sp)
    8000164c:	e84a                	sd	s2,16(sp)
    8000164e:	e44e                	sd	s3,8(sp)
    80001650:	1800                	addi	s0,sp,48
    80001652:	89aa                	mv	s3,a0
    80001654:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001656:	a23ff0ef          	jal	ra,80001078 <myproc>
    8000165a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000165c:	2b6040ef          	jal	ra,80005912 <acquire>
  release(lk);
    80001660:	854a                	mv	a0,s2
    80001662:	348040ef          	jal	ra,800059aa <release>

  // Go to sleep.
  p->chan = chan;
    80001666:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000166a:	4789                	li	a5,2
    8000166c:	cc9c                	sw	a5,24(s1)

  sched();
    8000166e:	ef1ff0ef          	jal	ra,8000155e <sched>

  // Tidy up.
  p->chan = 0;
    80001672:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001676:	8526                	mv	a0,s1
    80001678:	332040ef          	jal	ra,800059aa <release>
  acquire(lk);
    8000167c:	854a                	mv	a0,s2
    8000167e:	294040ef          	jal	ra,80005912 <acquire>
}
    80001682:	70a2                	ld	ra,40(sp)
    80001684:	7402                	ld	s0,32(sp)
    80001686:	64e2                	ld	s1,24(sp)
    80001688:	6942                	ld	s2,16(sp)
    8000168a:	69a2                	ld	s3,8(sp)
    8000168c:	6145                	addi	sp,sp,48
    8000168e:	8082                	ret

0000000080001690 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001690:	7139                	addi	sp,sp,-64
    80001692:	fc06                	sd	ra,56(sp)
    80001694:	f822                	sd	s0,48(sp)
    80001696:	f426                	sd	s1,40(sp)
    80001698:	f04a                	sd	s2,32(sp)
    8000169a:	ec4e                	sd	s3,24(sp)
    8000169c:	e852                	sd	s4,16(sp)
    8000169e:	e456                	sd	s5,8(sp)
    800016a0:	0080                	addi	s0,sp,64
    800016a2:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800016a4:	00007497          	auipc	s1,0x7
    800016a8:	a4c48493          	addi	s1,s1,-1460 # 800080f0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800016ac:	4989                	li	s3,2
        p->state = RUNNABLE;
    800016ae:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800016b0:	0000c917          	auipc	s2,0xc
    800016b4:	44090913          	addi	s2,s2,1088 # 8000daf0 <tickslock>
    800016b8:	a801                	j	800016c8 <wakeup+0x38>
      }
      release(&p->lock);
    800016ba:	8526                	mv	a0,s1
    800016bc:	2ee040ef          	jal	ra,800059aa <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800016c0:	16848493          	addi	s1,s1,360
    800016c4:	03248263          	beq	s1,s2,800016e8 <wakeup+0x58>
    if(p != myproc()){
    800016c8:	9b1ff0ef          	jal	ra,80001078 <myproc>
    800016cc:	fea48ae3          	beq	s1,a0,800016c0 <wakeup+0x30>
      acquire(&p->lock);
    800016d0:	8526                	mv	a0,s1
    800016d2:	240040ef          	jal	ra,80005912 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800016d6:	4c9c                	lw	a5,24(s1)
    800016d8:	ff3791e3          	bne	a5,s3,800016ba <wakeup+0x2a>
    800016dc:	709c                	ld	a5,32(s1)
    800016de:	fd479ee3          	bne	a5,s4,800016ba <wakeup+0x2a>
        p->state = RUNNABLE;
    800016e2:	0154ac23          	sw	s5,24(s1)
    800016e6:	bfd1                	j	800016ba <wakeup+0x2a>
    }
  }
}
    800016e8:	70e2                	ld	ra,56(sp)
    800016ea:	7442                	ld	s0,48(sp)
    800016ec:	74a2                	ld	s1,40(sp)
    800016ee:	7902                	ld	s2,32(sp)
    800016f0:	69e2                	ld	s3,24(sp)
    800016f2:	6a42                	ld	s4,16(sp)
    800016f4:	6aa2                	ld	s5,8(sp)
    800016f6:	6121                	addi	sp,sp,64
    800016f8:	8082                	ret

00000000800016fa <reparent>:
{
    800016fa:	7179                	addi	sp,sp,-48
    800016fc:	f406                	sd	ra,40(sp)
    800016fe:	f022                	sd	s0,32(sp)
    80001700:	ec26                	sd	s1,24(sp)
    80001702:	e84a                	sd	s2,16(sp)
    80001704:	e44e                	sd	s3,8(sp)
    80001706:	e052                	sd	s4,0(sp)
    80001708:	1800                	addi	s0,sp,48
    8000170a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000170c:	00007497          	auipc	s1,0x7
    80001710:	9e448493          	addi	s1,s1,-1564 # 800080f0 <proc>
      pp->parent = initproc;
    80001714:	00006a17          	auipc	s4,0x6
    80001718:	36ca0a13          	addi	s4,s4,876 # 80007a80 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000171c:	0000c997          	auipc	s3,0xc
    80001720:	3d498993          	addi	s3,s3,980 # 8000daf0 <tickslock>
    80001724:	a029                	j	8000172e <reparent+0x34>
    80001726:	16848493          	addi	s1,s1,360
    8000172a:	01348b63          	beq	s1,s3,80001740 <reparent+0x46>
    if(pp->parent == p){
    8000172e:	7c9c                	ld	a5,56(s1)
    80001730:	ff279be3          	bne	a5,s2,80001726 <reparent+0x2c>
      pp->parent = initproc;
    80001734:	000a3503          	ld	a0,0(s4)
    80001738:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000173a:	f57ff0ef          	jal	ra,80001690 <wakeup>
    8000173e:	b7e5                	j	80001726 <reparent+0x2c>
}
    80001740:	70a2                	ld	ra,40(sp)
    80001742:	7402                	ld	s0,32(sp)
    80001744:	64e2                	ld	s1,24(sp)
    80001746:	6942                	ld	s2,16(sp)
    80001748:	69a2                	ld	s3,8(sp)
    8000174a:	6a02                	ld	s4,0(sp)
    8000174c:	6145                	addi	sp,sp,48
    8000174e:	8082                	ret

0000000080001750 <exit>:
{
    80001750:	7179                	addi	sp,sp,-48
    80001752:	f406                	sd	ra,40(sp)
    80001754:	f022                	sd	s0,32(sp)
    80001756:	ec26                	sd	s1,24(sp)
    80001758:	e84a                	sd	s2,16(sp)
    8000175a:	e44e                	sd	s3,8(sp)
    8000175c:	e052                	sd	s4,0(sp)
    8000175e:	1800                	addi	s0,sp,48
    80001760:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001762:	917ff0ef          	jal	ra,80001078 <myproc>
    80001766:	89aa                	mv	s3,a0
  if(p == initproc)
    80001768:	00006797          	auipc	a5,0x6
    8000176c:	3187b783          	ld	a5,792(a5) # 80007a80 <initproc>
    80001770:	0d050493          	addi	s1,a0,208
    80001774:	15050913          	addi	s2,a0,336
    80001778:	00a79f63          	bne	a5,a0,80001796 <exit+0x46>
    panic("init exiting");
    8000177c:	00006517          	auipc	a0,0x6
    80001780:	bbc50513          	addi	a0,a0,-1092 # 80007338 <etext+0x338>
    80001784:	67f030ef          	jal	ra,80005602 <panic>
      fileclose(f);
    80001788:	6ab010ef          	jal	ra,80003632 <fileclose>
      p->ofile[fd] = 0;
    8000178c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001790:	04a1                	addi	s1,s1,8
    80001792:	01248563          	beq	s1,s2,8000179c <exit+0x4c>
    if(p->ofile[fd]){
    80001796:	6088                	ld	a0,0(s1)
    80001798:	f965                	bnez	a0,80001788 <exit+0x38>
    8000179a:	bfdd                	j	80001790 <exit+0x40>
  begin_op();
    8000179c:	27f010ef          	jal	ra,8000321a <begin_op>
  iput(p->cwd);
    800017a0:	1509b503          	ld	a0,336(s3)
    800017a4:	360010ef          	jal	ra,80002b04 <iput>
  end_op();
    800017a8:	2e1010ef          	jal	ra,80003288 <end_op>
  p->cwd = 0;
    800017ac:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800017b0:	00006497          	auipc	s1,0x6
    800017b4:	52848493          	addi	s1,s1,1320 # 80007cd8 <wait_lock>
    800017b8:	8526                	mv	a0,s1
    800017ba:	158040ef          	jal	ra,80005912 <acquire>
  reparent(p);
    800017be:	854e                	mv	a0,s3
    800017c0:	f3bff0ef          	jal	ra,800016fa <reparent>
  wakeup(p->parent);
    800017c4:	0389b503          	ld	a0,56(s3)
    800017c8:	ec9ff0ef          	jal	ra,80001690 <wakeup>
  acquire(&p->lock);
    800017cc:	854e                	mv	a0,s3
    800017ce:	144040ef          	jal	ra,80005912 <acquire>
  p->xstate = status;
    800017d2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800017d6:	4795                	li	a5,5
    800017d8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800017dc:	8526                	mv	a0,s1
    800017de:	1cc040ef          	jal	ra,800059aa <release>
  sched();
    800017e2:	d7dff0ef          	jal	ra,8000155e <sched>
  panic("zombie exit");
    800017e6:	00006517          	auipc	a0,0x6
    800017ea:	b6250513          	addi	a0,a0,-1182 # 80007348 <etext+0x348>
    800017ee:	615030ef          	jal	ra,80005602 <panic>

00000000800017f2 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800017f2:	7179                	addi	sp,sp,-48
    800017f4:	f406                	sd	ra,40(sp)
    800017f6:	f022                	sd	s0,32(sp)
    800017f8:	ec26                	sd	s1,24(sp)
    800017fa:	e84a                	sd	s2,16(sp)
    800017fc:	e44e                	sd	s3,8(sp)
    800017fe:	1800                	addi	s0,sp,48
    80001800:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001802:	00007497          	auipc	s1,0x7
    80001806:	8ee48493          	addi	s1,s1,-1810 # 800080f0 <proc>
    8000180a:	0000c997          	auipc	s3,0xc
    8000180e:	2e698993          	addi	s3,s3,742 # 8000daf0 <tickslock>
    acquire(&p->lock);
    80001812:	8526                	mv	a0,s1
    80001814:	0fe040ef          	jal	ra,80005912 <acquire>
    if(p->pid == pid){
    80001818:	589c                	lw	a5,48(s1)
    8000181a:	01278b63          	beq	a5,s2,80001830 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000181e:	8526                	mv	a0,s1
    80001820:	18a040ef          	jal	ra,800059aa <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001824:	16848493          	addi	s1,s1,360
    80001828:	ff3495e3          	bne	s1,s3,80001812 <kill+0x20>
  }
  return -1;
    8000182c:	557d                	li	a0,-1
    8000182e:	a819                	j	80001844 <kill+0x52>
      p->killed = 1;
    80001830:	4785                	li	a5,1
    80001832:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001834:	4c98                	lw	a4,24(s1)
    80001836:	4789                	li	a5,2
    80001838:	00f70d63          	beq	a4,a5,80001852 <kill+0x60>
      release(&p->lock);
    8000183c:	8526                	mv	a0,s1
    8000183e:	16c040ef          	jal	ra,800059aa <release>
      return 0;
    80001842:	4501                	li	a0,0
}
    80001844:	70a2                	ld	ra,40(sp)
    80001846:	7402                	ld	s0,32(sp)
    80001848:	64e2                	ld	s1,24(sp)
    8000184a:	6942                	ld	s2,16(sp)
    8000184c:	69a2                	ld	s3,8(sp)
    8000184e:	6145                	addi	sp,sp,48
    80001850:	8082                	ret
        p->state = RUNNABLE;
    80001852:	478d                	li	a5,3
    80001854:	cc9c                	sw	a5,24(s1)
    80001856:	b7dd                	j	8000183c <kill+0x4a>

0000000080001858 <setkilled>:

void
setkilled(struct proc *p)
{
    80001858:	1101                	addi	sp,sp,-32
    8000185a:	ec06                	sd	ra,24(sp)
    8000185c:	e822                	sd	s0,16(sp)
    8000185e:	e426                	sd	s1,8(sp)
    80001860:	1000                	addi	s0,sp,32
    80001862:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001864:	0ae040ef          	jal	ra,80005912 <acquire>
  p->killed = 1;
    80001868:	4785                	li	a5,1
    8000186a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000186c:	8526                	mv	a0,s1
    8000186e:	13c040ef          	jal	ra,800059aa <release>
}
    80001872:	60e2                	ld	ra,24(sp)
    80001874:	6442                	ld	s0,16(sp)
    80001876:	64a2                	ld	s1,8(sp)
    80001878:	6105                	addi	sp,sp,32
    8000187a:	8082                	ret

000000008000187c <killed>:

int
killed(struct proc *p)
{
    8000187c:	1101                	addi	sp,sp,-32
    8000187e:	ec06                	sd	ra,24(sp)
    80001880:	e822                	sd	s0,16(sp)
    80001882:	e426                	sd	s1,8(sp)
    80001884:	e04a                	sd	s2,0(sp)
    80001886:	1000                	addi	s0,sp,32
    80001888:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000188a:	088040ef          	jal	ra,80005912 <acquire>
  k = p->killed;
    8000188e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001892:	8526                	mv	a0,s1
    80001894:	116040ef          	jal	ra,800059aa <release>
  return k;
}
    80001898:	854a                	mv	a0,s2
    8000189a:	60e2                	ld	ra,24(sp)
    8000189c:	6442                	ld	s0,16(sp)
    8000189e:	64a2                	ld	s1,8(sp)
    800018a0:	6902                	ld	s2,0(sp)
    800018a2:	6105                	addi	sp,sp,32
    800018a4:	8082                	ret

00000000800018a6 <wait>:
{
    800018a6:	715d                	addi	sp,sp,-80
    800018a8:	e486                	sd	ra,72(sp)
    800018aa:	e0a2                	sd	s0,64(sp)
    800018ac:	fc26                	sd	s1,56(sp)
    800018ae:	f84a                	sd	s2,48(sp)
    800018b0:	f44e                	sd	s3,40(sp)
    800018b2:	f052                	sd	s4,32(sp)
    800018b4:	ec56                	sd	s5,24(sp)
    800018b6:	e85a                	sd	s6,16(sp)
    800018b8:	e45e                	sd	s7,8(sp)
    800018ba:	e062                	sd	s8,0(sp)
    800018bc:	0880                	addi	s0,sp,80
    800018be:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800018c0:	fb8ff0ef          	jal	ra,80001078 <myproc>
    800018c4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800018c6:	00006517          	auipc	a0,0x6
    800018ca:	41250513          	addi	a0,a0,1042 # 80007cd8 <wait_lock>
    800018ce:	044040ef          	jal	ra,80005912 <acquire>
    havekids = 0;
    800018d2:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800018d4:	4a15                	li	s4,5
        havekids = 1;
    800018d6:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800018d8:	0000c997          	auipc	s3,0xc
    800018dc:	21898993          	addi	s3,s3,536 # 8000daf0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800018e0:	00006c17          	auipc	s8,0x6
    800018e4:	3f8c0c13          	addi	s8,s8,1016 # 80007cd8 <wait_lock>
    havekids = 0;
    800018e8:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800018ea:	00007497          	auipc	s1,0x7
    800018ee:	80648493          	addi	s1,s1,-2042 # 800080f0 <proc>
    800018f2:	a899                	j	80001948 <wait+0xa2>
          pid = pp->pid;
    800018f4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800018f8:	000b0c63          	beqz	s6,80001910 <wait+0x6a>
    800018fc:	4691                	li	a3,4
    800018fe:	02c48613          	addi	a2,s1,44
    80001902:	85da                	mv	a1,s6
    80001904:	05093503          	ld	a0,80(s2)
    80001908:	b14ff0ef          	jal	ra,80000c1c <copyout>
    8000190c:	00054f63          	bltz	a0,8000192a <wait+0x84>
          freeproc(pp);
    80001910:	8526                	mv	a0,s1
    80001912:	8d9ff0ef          	jal	ra,800011ea <freeproc>
          release(&pp->lock);
    80001916:	8526                	mv	a0,s1
    80001918:	092040ef          	jal	ra,800059aa <release>
          release(&wait_lock);
    8000191c:	00006517          	auipc	a0,0x6
    80001920:	3bc50513          	addi	a0,a0,956 # 80007cd8 <wait_lock>
    80001924:	086040ef          	jal	ra,800059aa <release>
          return pid;
    80001928:	a891                	j	8000197c <wait+0xd6>
            release(&pp->lock);
    8000192a:	8526                	mv	a0,s1
    8000192c:	07e040ef          	jal	ra,800059aa <release>
            release(&wait_lock);
    80001930:	00006517          	auipc	a0,0x6
    80001934:	3a850513          	addi	a0,a0,936 # 80007cd8 <wait_lock>
    80001938:	072040ef          	jal	ra,800059aa <release>
            return -1;
    8000193c:	59fd                	li	s3,-1
    8000193e:	a83d                	j	8000197c <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001940:	16848493          	addi	s1,s1,360
    80001944:	03348063          	beq	s1,s3,80001964 <wait+0xbe>
      if(pp->parent == p){
    80001948:	7c9c                	ld	a5,56(s1)
    8000194a:	ff279be3          	bne	a5,s2,80001940 <wait+0x9a>
        acquire(&pp->lock);
    8000194e:	8526                	mv	a0,s1
    80001950:	7c3030ef          	jal	ra,80005912 <acquire>
        if(pp->state == ZOMBIE){
    80001954:	4c9c                	lw	a5,24(s1)
    80001956:	f9478fe3          	beq	a5,s4,800018f4 <wait+0x4e>
        release(&pp->lock);
    8000195a:	8526                	mv	a0,s1
    8000195c:	04e040ef          	jal	ra,800059aa <release>
        havekids = 1;
    80001960:	8756                	mv	a4,s5
    80001962:	bff9                	j	80001940 <wait+0x9a>
    if(!havekids || killed(p)){
    80001964:	c709                	beqz	a4,8000196e <wait+0xc8>
    80001966:	854a                	mv	a0,s2
    80001968:	f15ff0ef          	jal	ra,8000187c <killed>
    8000196c:	c50d                	beqz	a0,80001996 <wait+0xf0>
      release(&wait_lock);
    8000196e:	00006517          	auipc	a0,0x6
    80001972:	36a50513          	addi	a0,a0,874 # 80007cd8 <wait_lock>
    80001976:	034040ef          	jal	ra,800059aa <release>
      return -1;
    8000197a:	59fd                	li	s3,-1
}
    8000197c:	854e                	mv	a0,s3
    8000197e:	60a6                	ld	ra,72(sp)
    80001980:	6406                	ld	s0,64(sp)
    80001982:	74e2                	ld	s1,56(sp)
    80001984:	7942                	ld	s2,48(sp)
    80001986:	79a2                	ld	s3,40(sp)
    80001988:	7a02                	ld	s4,32(sp)
    8000198a:	6ae2                	ld	s5,24(sp)
    8000198c:	6b42                	ld	s6,16(sp)
    8000198e:	6ba2                	ld	s7,8(sp)
    80001990:	6c02                	ld	s8,0(sp)
    80001992:	6161                	addi	sp,sp,80
    80001994:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001996:	85e2                	mv	a1,s8
    80001998:	854a                	mv	a0,s2
    8000199a:	cabff0ef          	jal	ra,80001644 <sleep>
    havekids = 0;
    8000199e:	b7a9                	j	800018e8 <wait+0x42>

00000000800019a0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800019a0:	7179                	addi	sp,sp,-48
    800019a2:	f406                	sd	ra,40(sp)
    800019a4:	f022                	sd	s0,32(sp)
    800019a6:	ec26                	sd	s1,24(sp)
    800019a8:	e84a                	sd	s2,16(sp)
    800019aa:	e44e                	sd	s3,8(sp)
    800019ac:	e052                	sd	s4,0(sp)
    800019ae:	1800                	addi	s0,sp,48
    800019b0:	84aa                	mv	s1,a0
    800019b2:	892e                	mv	s2,a1
    800019b4:	89b2                	mv	s3,a2
    800019b6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800019b8:	ec0ff0ef          	jal	ra,80001078 <myproc>
  if(user_dst){
    800019bc:	cc99                	beqz	s1,800019da <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800019be:	86d2                	mv	a3,s4
    800019c0:	864e                	mv	a2,s3
    800019c2:	85ca                	mv	a1,s2
    800019c4:	6928                	ld	a0,80(a0)
    800019c6:	a56ff0ef          	jal	ra,80000c1c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800019ca:	70a2                	ld	ra,40(sp)
    800019cc:	7402                	ld	s0,32(sp)
    800019ce:	64e2                	ld	s1,24(sp)
    800019d0:	6942                	ld	s2,16(sp)
    800019d2:	69a2                	ld	s3,8(sp)
    800019d4:	6a02                	ld	s4,0(sp)
    800019d6:	6145                	addi	sp,sp,48
    800019d8:	8082                	ret
    memmove((char *)dst, src, len);
    800019da:	000a061b          	sext.w	a2,s4
    800019de:	85ce                	mv	a1,s3
    800019e0:	854a                	mv	a0,s2
    800019e2:	92dfe0ef          	jal	ra,8000030e <memmove>
    return 0;
    800019e6:	8526                	mv	a0,s1
    800019e8:	b7cd                	j	800019ca <either_copyout+0x2a>

00000000800019ea <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800019ea:	7179                	addi	sp,sp,-48
    800019ec:	f406                	sd	ra,40(sp)
    800019ee:	f022                	sd	s0,32(sp)
    800019f0:	ec26                	sd	s1,24(sp)
    800019f2:	e84a                	sd	s2,16(sp)
    800019f4:	e44e                	sd	s3,8(sp)
    800019f6:	e052                	sd	s4,0(sp)
    800019f8:	1800                	addi	s0,sp,48
    800019fa:	892a                	mv	s2,a0
    800019fc:	84ae                	mv	s1,a1
    800019fe:	89b2                	mv	s3,a2
    80001a00:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001a02:	e76ff0ef          	jal	ra,80001078 <myproc>
  if(user_src){
    80001a06:	cc99                	beqz	s1,80001a24 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001a08:	86d2                	mv	a3,s4
    80001a0a:	864e                	mv	a2,s3
    80001a0c:	85ca                	mv	a1,s2
    80001a0e:	6928                	ld	a0,80(a0)
    80001a10:	ac4ff0ef          	jal	ra,80000cd4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001a14:	70a2                	ld	ra,40(sp)
    80001a16:	7402                	ld	s0,32(sp)
    80001a18:	64e2                	ld	s1,24(sp)
    80001a1a:	6942                	ld	s2,16(sp)
    80001a1c:	69a2                	ld	s3,8(sp)
    80001a1e:	6a02                	ld	s4,0(sp)
    80001a20:	6145                	addi	sp,sp,48
    80001a22:	8082                	ret
    memmove(dst, (char*)src, len);
    80001a24:	000a061b          	sext.w	a2,s4
    80001a28:	85ce                	mv	a1,s3
    80001a2a:	854a                	mv	a0,s2
    80001a2c:	8e3fe0ef          	jal	ra,8000030e <memmove>
    return 0;
    80001a30:	8526                	mv	a0,s1
    80001a32:	b7cd                	j	80001a14 <either_copyin+0x2a>

0000000080001a34 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001a34:	715d                	addi	sp,sp,-80
    80001a36:	e486                	sd	ra,72(sp)
    80001a38:	e0a2                	sd	s0,64(sp)
    80001a3a:	fc26                	sd	s1,56(sp)
    80001a3c:	f84a                	sd	s2,48(sp)
    80001a3e:	f44e                	sd	s3,40(sp)
    80001a40:	f052                	sd	s4,32(sp)
    80001a42:	ec56                	sd	s5,24(sp)
    80001a44:	e85a                	sd	s6,16(sp)
    80001a46:	e45e                	sd	s7,8(sp)
    80001a48:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001a4a:	00005517          	auipc	a0,0x5
    80001a4e:	68650513          	addi	a0,a0,1670 # 800070d0 <etext+0xd0>
    80001a52:	0fd030ef          	jal	ra,8000534e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a56:	00006497          	auipc	s1,0x6
    80001a5a:	7f248493          	addi	s1,s1,2034 # 80008248 <proc+0x158>
    80001a5e:	0000c917          	auipc	s2,0xc
    80001a62:	1ea90913          	addi	s2,s2,490 # 8000dc48 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a66:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001a68:	00006997          	auipc	s3,0x6
    80001a6c:	8f098993          	addi	s3,s3,-1808 # 80007358 <etext+0x358>
    printf("%d %s %s", p->pid, state, p->name);
    80001a70:	00006a97          	auipc	s5,0x6
    80001a74:	8f0a8a93          	addi	s5,s5,-1808 # 80007360 <etext+0x360>
    printf("\n");
    80001a78:	00005a17          	auipc	s4,0x5
    80001a7c:	658a0a13          	addi	s4,s4,1624 # 800070d0 <etext+0xd0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a80:	00006b97          	auipc	s7,0x6
    80001a84:	920b8b93          	addi	s7,s7,-1760 # 800073a0 <states.0>
    80001a88:	a829                	j	80001aa2 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001a8a:	ed86a583          	lw	a1,-296(a3)
    80001a8e:	8556                	mv	a0,s5
    80001a90:	0bf030ef          	jal	ra,8000534e <printf>
    printf("\n");
    80001a94:	8552                	mv	a0,s4
    80001a96:	0b9030ef          	jal	ra,8000534e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a9a:	16848493          	addi	s1,s1,360
    80001a9e:	03248263          	beq	s1,s2,80001ac2 <procdump+0x8e>
    if(p->state == UNUSED)
    80001aa2:	86a6                	mv	a3,s1
    80001aa4:	ec04a783          	lw	a5,-320(s1)
    80001aa8:	dbed                	beqz	a5,80001a9a <procdump+0x66>
      state = "???";
    80001aaa:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001aac:	fcfb6fe3          	bltu	s6,a5,80001a8a <procdump+0x56>
    80001ab0:	02079713          	slli	a4,a5,0x20
    80001ab4:	01d75793          	srli	a5,a4,0x1d
    80001ab8:	97de                	add	a5,a5,s7
    80001aba:	6390                	ld	a2,0(a5)
    80001abc:	f679                	bnez	a2,80001a8a <procdump+0x56>
      state = "???";
    80001abe:	864e                	mv	a2,s3
    80001ac0:	b7e9                	j	80001a8a <procdump+0x56>
  }
}
    80001ac2:	60a6                	ld	ra,72(sp)
    80001ac4:	6406                	ld	s0,64(sp)
    80001ac6:	74e2                	ld	s1,56(sp)
    80001ac8:	7942                	ld	s2,48(sp)
    80001aca:	79a2                	ld	s3,40(sp)
    80001acc:	7a02                	ld	s4,32(sp)
    80001ace:	6ae2                	ld	s5,24(sp)
    80001ad0:	6b42                	ld	s6,16(sp)
    80001ad2:	6ba2                	ld	s7,8(sp)
    80001ad4:	6161                	addi	sp,sp,80
    80001ad6:	8082                	ret

0000000080001ad8 <swtch>:
    80001ad8:	00153023          	sd	ra,0(a0)
    80001adc:	00253423          	sd	sp,8(a0)
    80001ae0:	e900                	sd	s0,16(a0)
    80001ae2:	ed04                	sd	s1,24(a0)
    80001ae4:	03253023          	sd	s2,32(a0)
    80001ae8:	03353423          	sd	s3,40(a0)
    80001aec:	03453823          	sd	s4,48(a0)
    80001af0:	03553c23          	sd	s5,56(a0)
    80001af4:	05653023          	sd	s6,64(a0)
    80001af8:	05753423          	sd	s7,72(a0)
    80001afc:	05853823          	sd	s8,80(a0)
    80001b00:	05953c23          	sd	s9,88(a0)
    80001b04:	07a53023          	sd	s10,96(a0)
    80001b08:	07b53423          	sd	s11,104(a0)
    80001b0c:	0005b083          	ld	ra,0(a1)
    80001b10:	0085b103          	ld	sp,8(a1)
    80001b14:	6980                	ld	s0,16(a1)
    80001b16:	6d84                	ld	s1,24(a1)
    80001b18:	0205b903          	ld	s2,32(a1)
    80001b1c:	0285b983          	ld	s3,40(a1)
    80001b20:	0305ba03          	ld	s4,48(a1)
    80001b24:	0385ba83          	ld	s5,56(a1)
    80001b28:	0405bb03          	ld	s6,64(a1)
    80001b2c:	0485bb83          	ld	s7,72(a1)
    80001b30:	0505bc03          	ld	s8,80(a1)
    80001b34:	0585bc83          	ld	s9,88(a1)
    80001b38:	0605bd03          	ld	s10,96(a1)
    80001b3c:	0685bd83          	ld	s11,104(a1)
    80001b40:	8082                	ret

0000000080001b42 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001b42:	1141                	addi	sp,sp,-16
    80001b44:	e406                	sd	ra,8(sp)
    80001b46:	e022                	sd	s0,0(sp)
    80001b48:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001b4a:	00006597          	auipc	a1,0x6
    80001b4e:	88658593          	addi	a1,a1,-1914 # 800073d0 <states.0+0x30>
    80001b52:	0000c517          	auipc	a0,0xc
    80001b56:	f9e50513          	addi	a0,a0,-98 # 8000daf0 <tickslock>
    80001b5a:	539030ef          	jal	ra,80005892 <initlock>
}
    80001b5e:	60a2                	ld	ra,8(sp)
    80001b60:	6402                	ld	s0,0(sp)
    80001b62:	0141                	addi	sp,sp,16
    80001b64:	8082                	ret

0000000080001b66 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001b66:	1141                	addi	sp,sp,-16
    80001b68:	e422                	sd	s0,8(sp)
    80001b6a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b6c:	00003797          	auipc	a5,0x3
    80001b70:	d8478793          	addi	a5,a5,-636 # 800048f0 <kernelvec>
    80001b74:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001b78:	6422                	ld	s0,8(sp)
    80001b7a:	0141                	addi	sp,sp,16
    80001b7c:	8082                	ret

0000000080001b7e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001b7e:	1141                	addi	sp,sp,-16
    80001b80:	e406                	sd	ra,8(sp)
    80001b82:	e022                	sd	s0,0(sp)
    80001b84:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001b86:	cf2ff0ef          	jal	ra,80001078 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b8a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001b8e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b90:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001b94:	00004697          	auipc	a3,0x4
    80001b98:	46c68693          	addi	a3,a3,1132 # 80006000 <_trampoline>
    80001b9c:	00004717          	auipc	a4,0x4
    80001ba0:	46470713          	addi	a4,a4,1124 # 80006000 <_trampoline>
    80001ba4:	8f15                	sub	a4,a4,a3
    80001ba6:	040007b7          	lui	a5,0x4000
    80001baa:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001bac:	07b2                	slli	a5,a5,0xc
    80001bae:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001bb0:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001bb4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001bb6:	18002673          	csrr	a2,satp
    80001bba:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001bbc:	6d30                	ld	a2,88(a0)
    80001bbe:	6138                	ld	a4,64(a0)
    80001bc0:	6585                	lui	a1,0x1
    80001bc2:	972e                	add	a4,a4,a1
    80001bc4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001bc6:	6d38                	ld	a4,88(a0)
    80001bc8:	00000617          	auipc	a2,0x0
    80001bcc:	10c60613          	addi	a2,a2,268 # 80001cd4 <usertrap>
    80001bd0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001bd2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bd4:	8612                	mv	a2,tp
    80001bd6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001bd8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001bdc:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001be0:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001be4:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001be8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001bea:	6f18                	ld	a4,24(a4)
    80001bec:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001bf0:	6928                	ld	a0,80(a0)
    80001bf2:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001bf4:	00004717          	auipc	a4,0x4
    80001bf8:	4a870713          	addi	a4,a4,1192 # 8000609c <userret>
    80001bfc:	8f15                	sub	a4,a4,a3
    80001bfe:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001c00:	577d                	li	a4,-1
    80001c02:	177e                	slli	a4,a4,0x3f
    80001c04:	8d59                	or	a0,a0,a4
    80001c06:	9782                	jalr	a5
}
    80001c08:	60a2                	ld	ra,8(sp)
    80001c0a:	6402                	ld	s0,0(sp)
    80001c0c:	0141                	addi	sp,sp,16
    80001c0e:	8082                	ret

0000000080001c10 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001c10:	1101                	addi	sp,sp,-32
    80001c12:	ec06                	sd	ra,24(sp)
    80001c14:	e822                	sd	s0,16(sp)
    80001c16:	e426                	sd	s1,8(sp)
    80001c18:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001c1a:	c32ff0ef          	jal	ra,8000104c <cpuid>
    80001c1e:	cd19                	beqz	a0,80001c3c <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001c20:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001c24:	000f4737          	lui	a4,0xf4
    80001c28:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001c2c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001c2e:	14d79073          	csrw	0x14d,a5
}
    80001c32:	60e2                	ld	ra,24(sp)
    80001c34:	6442                	ld	s0,16(sp)
    80001c36:	64a2                	ld	s1,8(sp)
    80001c38:	6105                	addi	sp,sp,32
    80001c3a:	8082                	ret
    acquire(&tickslock);
    80001c3c:	0000c497          	auipc	s1,0xc
    80001c40:	eb448493          	addi	s1,s1,-332 # 8000daf0 <tickslock>
    80001c44:	8526                	mv	a0,s1
    80001c46:	4cd030ef          	jal	ra,80005912 <acquire>
    ticks++;
    80001c4a:	00006517          	auipc	a0,0x6
    80001c4e:	e3e50513          	addi	a0,a0,-450 # 80007a88 <ticks>
    80001c52:	411c                	lw	a5,0(a0)
    80001c54:	2785                	addiw	a5,a5,1
    80001c56:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001c58:	a39ff0ef          	jal	ra,80001690 <wakeup>
    release(&tickslock);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	54d030ef          	jal	ra,800059aa <release>
    80001c62:	bf7d                	j	80001c20 <clockintr+0x10>

0000000080001c64 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001c64:	1101                	addi	sp,sp,-32
    80001c66:	ec06                	sd	ra,24(sp)
    80001c68:	e822                	sd	s0,16(sp)
    80001c6a:	e426                	sd	s1,8(sp)
    80001c6c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c6e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001c72:	57fd                	li	a5,-1
    80001c74:	17fe                	slli	a5,a5,0x3f
    80001c76:	07a5                	addi	a5,a5,9
    80001c78:	00f70d63          	beq	a4,a5,80001c92 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001c7c:	57fd                	li	a5,-1
    80001c7e:	17fe                	slli	a5,a5,0x3f
    80001c80:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001c82:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001c84:	04f70463          	beq	a4,a5,80001ccc <devintr+0x68>
  }
}
    80001c88:	60e2                	ld	ra,24(sp)
    80001c8a:	6442                	ld	s0,16(sp)
    80001c8c:	64a2                	ld	s1,8(sp)
    80001c8e:	6105                	addi	sp,sp,32
    80001c90:	8082                	ret
    int irq = plic_claim();
    80001c92:	507020ef          	jal	ra,80004998 <plic_claim>
    80001c96:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001c98:	47a9                	li	a5,10
    80001c9a:	02f50363          	beq	a0,a5,80001cc0 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001c9e:	4785                	li	a5,1
    80001ca0:	02f50363          	beq	a0,a5,80001cc6 <devintr+0x62>
    return 1;
    80001ca4:	4505                	li	a0,1
    } else if(irq){
    80001ca6:	d0ed                	beqz	s1,80001c88 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001ca8:	85a6                	mv	a1,s1
    80001caa:	00005517          	auipc	a0,0x5
    80001cae:	72e50513          	addi	a0,a0,1838 # 800073d8 <states.0+0x38>
    80001cb2:	69c030ef          	jal	ra,8000534e <printf>
      plic_complete(irq);
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	501020ef          	jal	ra,800049b8 <plic_complete>
    return 1;
    80001cbc:	4505                	li	a0,1
    80001cbe:	b7e9                	j	80001c88 <devintr+0x24>
      uartintr();
    80001cc0:	397030ef          	jal	ra,80005856 <uartintr>
    80001cc4:	bfcd                	j	80001cb6 <devintr+0x52>
      virtio_disk_intr();
    80001cc6:	15e030ef          	jal	ra,80004e24 <virtio_disk_intr>
    80001cca:	b7f5                	j	80001cb6 <devintr+0x52>
    clockintr();
    80001ccc:	f45ff0ef          	jal	ra,80001c10 <clockintr>
    return 2;
    80001cd0:	4509                	li	a0,2
    80001cd2:	bf5d                	j	80001c88 <devintr+0x24>

0000000080001cd4 <usertrap>:
{
    80001cd4:	1101                	addi	sp,sp,-32
    80001cd6:	ec06                	sd	ra,24(sp)
    80001cd8:	e822                	sd	s0,16(sp)
    80001cda:	e426                	sd	s1,8(sp)
    80001cdc:	e04a                	sd	s2,0(sp)
    80001cde:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ce0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001ce4:	1007f793          	andi	a5,a5,256
    80001ce8:	ef85                	bnez	a5,80001d20 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001cea:	00003797          	auipc	a5,0x3
    80001cee:	c0678793          	addi	a5,a5,-1018 # 800048f0 <kernelvec>
    80001cf2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001cf6:	b82ff0ef          	jal	ra,80001078 <myproc>
    80001cfa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001cfc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001cfe:	14102773          	csrr	a4,sepc
    80001d02:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d04:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001d08:	47a1                	li	a5,8
    80001d0a:	02f70163          	beq	a4,a5,80001d2c <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001d0e:	f57ff0ef          	jal	ra,80001c64 <devintr>
    80001d12:	892a                	mv	s2,a0
    80001d14:	c135                	beqz	a0,80001d78 <usertrap+0xa4>
  if(killed(p))
    80001d16:	8526                	mv	a0,s1
    80001d18:	b65ff0ef          	jal	ra,8000187c <killed>
    80001d1c:	cd1d                	beqz	a0,80001d5a <usertrap+0x86>
    80001d1e:	a81d                	j	80001d54 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001d20:	00005517          	auipc	a0,0x5
    80001d24:	6d850513          	addi	a0,a0,1752 # 800073f8 <states.0+0x58>
    80001d28:	0db030ef          	jal	ra,80005602 <panic>
    if(killed(p))
    80001d2c:	b51ff0ef          	jal	ra,8000187c <killed>
    80001d30:	e121                	bnez	a0,80001d70 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001d32:	6cb8                	ld	a4,88(s1)
    80001d34:	6f1c                	ld	a5,24(a4)
    80001d36:	0791                	addi	a5,a5,4
    80001d38:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d42:	10079073          	csrw	sstatus,a5
    syscall();
    80001d46:	248000ef          	jal	ra,80001f8e <syscall>
  if(killed(p))
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	b31ff0ef          	jal	ra,8000187c <killed>
    80001d50:	c901                	beqz	a0,80001d60 <usertrap+0x8c>
    80001d52:	4901                	li	s2,0
    exit(-1);
    80001d54:	557d                	li	a0,-1
    80001d56:	9fbff0ef          	jal	ra,80001750 <exit>
  if(which_dev == 2)
    80001d5a:	4789                	li	a5,2
    80001d5c:	04f90563          	beq	s2,a5,80001da6 <usertrap+0xd2>
  usertrapret();
    80001d60:	e1fff0ef          	jal	ra,80001b7e <usertrapret>
}
    80001d64:	60e2                	ld	ra,24(sp)
    80001d66:	6442                	ld	s0,16(sp)
    80001d68:	64a2                	ld	s1,8(sp)
    80001d6a:	6902                	ld	s2,0(sp)
    80001d6c:	6105                	addi	sp,sp,32
    80001d6e:	8082                	ret
      exit(-1);
    80001d70:	557d                	li	a0,-1
    80001d72:	9dfff0ef          	jal	ra,80001750 <exit>
    80001d76:	bf75                	j	80001d32 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d78:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001d7c:	5890                	lw	a2,48(s1)
    80001d7e:	00005517          	auipc	a0,0x5
    80001d82:	69a50513          	addi	a0,a0,1690 # 80007418 <states.0+0x78>
    80001d86:	5c8030ef          	jal	ra,8000534e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d8a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001d8e:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001d92:	00005517          	auipc	a0,0x5
    80001d96:	6b650513          	addi	a0,a0,1718 # 80007448 <states.0+0xa8>
    80001d9a:	5b4030ef          	jal	ra,8000534e <printf>
    setkilled(p);
    80001d9e:	8526                	mv	a0,s1
    80001da0:	ab9ff0ef          	jal	ra,80001858 <setkilled>
    80001da4:	b75d                	j	80001d4a <usertrap+0x76>
    yield();
    80001da6:	873ff0ef          	jal	ra,80001618 <yield>
    80001daa:	bf5d                	j	80001d60 <usertrap+0x8c>

0000000080001dac <kerneltrap>:
{
    80001dac:	7179                	addi	sp,sp,-48
    80001dae:	f406                	sd	ra,40(sp)
    80001db0:	f022                	sd	s0,32(sp)
    80001db2:	ec26                	sd	s1,24(sp)
    80001db4:	e84a                	sd	s2,16(sp)
    80001db6:	e44e                	sd	s3,8(sp)
    80001db8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001dba:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dbe:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001dc2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001dc6:	1004f793          	andi	a5,s1,256
    80001dca:	c795                	beqz	a5,80001df6 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dcc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001dd0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001dd2:	eb85                	bnez	a5,80001e02 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001dd4:	e91ff0ef          	jal	ra,80001c64 <devintr>
    80001dd8:	c91d                	beqz	a0,80001e0e <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001dda:	4789                	li	a5,2
    80001ddc:	04f50a63          	beq	a0,a5,80001e30 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001de0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001de4:	10049073          	csrw	sstatus,s1
}
    80001de8:	70a2                	ld	ra,40(sp)
    80001dea:	7402                	ld	s0,32(sp)
    80001dec:	64e2                	ld	s1,24(sp)
    80001dee:	6942                	ld	s2,16(sp)
    80001df0:	69a2                	ld	s3,8(sp)
    80001df2:	6145                	addi	sp,sp,48
    80001df4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001df6:	00005517          	auipc	a0,0x5
    80001dfa:	67a50513          	addi	a0,a0,1658 # 80007470 <states.0+0xd0>
    80001dfe:	005030ef          	jal	ra,80005602 <panic>
    panic("kerneltrap: interrupts enabled");
    80001e02:	00005517          	auipc	a0,0x5
    80001e06:	69650513          	addi	a0,a0,1686 # 80007498 <states.0+0xf8>
    80001e0a:	7f8030ef          	jal	ra,80005602 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e0e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e12:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001e16:	85ce                	mv	a1,s3
    80001e18:	00005517          	auipc	a0,0x5
    80001e1c:	6a050513          	addi	a0,a0,1696 # 800074b8 <states.0+0x118>
    80001e20:	52e030ef          	jal	ra,8000534e <printf>
    panic("kerneltrap");
    80001e24:	00005517          	auipc	a0,0x5
    80001e28:	6bc50513          	addi	a0,a0,1724 # 800074e0 <states.0+0x140>
    80001e2c:	7d6030ef          	jal	ra,80005602 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001e30:	a48ff0ef          	jal	ra,80001078 <myproc>
    80001e34:	d555                	beqz	a0,80001de0 <kerneltrap+0x34>
    yield();
    80001e36:	fe2ff0ef          	jal	ra,80001618 <yield>
    80001e3a:	b75d                	j	80001de0 <kerneltrap+0x34>

0000000080001e3c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001e3c:	1101                	addi	sp,sp,-32
    80001e3e:	ec06                	sd	ra,24(sp)
    80001e40:	e822                	sd	s0,16(sp)
    80001e42:	e426                	sd	s1,8(sp)
    80001e44:	1000                	addi	s0,sp,32
    80001e46:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e48:	a30ff0ef          	jal	ra,80001078 <myproc>
  switch (n) {
    80001e4c:	4795                	li	a5,5
    80001e4e:	0497e163          	bltu	a5,s1,80001e90 <argraw+0x54>
    80001e52:	048a                	slli	s1,s1,0x2
    80001e54:	00005717          	auipc	a4,0x5
    80001e58:	6c470713          	addi	a4,a4,1732 # 80007518 <states.0+0x178>
    80001e5c:	94ba                	add	s1,s1,a4
    80001e5e:	409c                	lw	a5,0(s1)
    80001e60:	97ba                	add	a5,a5,a4
    80001e62:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001e64:	6d3c                	ld	a5,88(a0)
    80001e66:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001e68:	60e2                	ld	ra,24(sp)
    80001e6a:	6442                	ld	s0,16(sp)
    80001e6c:	64a2                	ld	s1,8(sp)
    80001e6e:	6105                	addi	sp,sp,32
    80001e70:	8082                	ret
    return p->trapframe->a1;
    80001e72:	6d3c                	ld	a5,88(a0)
    80001e74:	7fa8                	ld	a0,120(a5)
    80001e76:	bfcd                	j	80001e68 <argraw+0x2c>
    return p->trapframe->a2;
    80001e78:	6d3c                	ld	a5,88(a0)
    80001e7a:	63c8                	ld	a0,128(a5)
    80001e7c:	b7f5                	j	80001e68 <argraw+0x2c>
    return p->trapframe->a3;
    80001e7e:	6d3c                	ld	a5,88(a0)
    80001e80:	67c8                	ld	a0,136(a5)
    80001e82:	b7dd                	j	80001e68 <argraw+0x2c>
    return p->trapframe->a4;
    80001e84:	6d3c                	ld	a5,88(a0)
    80001e86:	6bc8                	ld	a0,144(a5)
    80001e88:	b7c5                	j	80001e68 <argraw+0x2c>
    return p->trapframe->a5;
    80001e8a:	6d3c                	ld	a5,88(a0)
    80001e8c:	6fc8                	ld	a0,152(a5)
    80001e8e:	bfe9                	j	80001e68 <argraw+0x2c>
  panic("argraw");
    80001e90:	00005517          	auipc	a0,0x5
    80001e94:	66050513          	addi	a0,a0,1632 # 800074f0 <states.0+0x150>
    80001e98:	76a030ef          	jal	ra,80005602 <panic>

0000000080001e9c <fetchaddr>:
{
    80001e9c:	1101                	addi	sp,sp,-32
    80001e9e:	ec06                	sd	ra,24(sp)
    80001ea0:	e822                	sd	s0,16(sp)
    80001ea2:	e426                	sd	s1,8(sp)
    80001ea4:	e04a                	sd	s2,0(sp)
    80001ea6:	1000                	addi	s0,sp,32
    80001ea8:	84aa                	mv	s1,a0
    80001eaa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001eac:	9ccff0ef          	jal	ra,80001078 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001eb0:	653c                	ld	a5,72(a0)
    80001eb2:	02f4f663          	bgeu	s1,a5,80001ede <fetchaddr+0x42>
    80001eb6:	00848713          	addi	a4,s1,8
    80001eba:	02e7e463          	bltu	a5,a4,80001ee2 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001ebe:	46a1                	li	a3,8
    80001ec0:	8626                	mv	a2,s1
    80001ec2:	85ca                	mv	a1,s2
    80001ec4:	6928                	ld	a0,80(a0)
    80001ec6:	e0ffe0ef          	jal	ra,80000cd4 <copyin>
    80001eca:	00a03533          	snez	a0,a0
    80001ece:	40a00533          	neg	a0,a0
}
    80001ed2:	60e2                	ld	ra,24(sp)
    80001ed4:	6442                	ld	s0,16(sp)
    80001ed6:	64a2                	ld	s1,8(sp)
    80001ed8:	6902                	ld	s2,0(sp)
    80001eda:	6105                	addi	sp,sp,32
    80001edc:	8082                	ret
    return -1;
    80001ede:	557d                	li	a0,-1
    80001ee0:	bfcd                	j	80001ed2 <fetchaddr+0x36>
    80001ee2:	557d                	li	a0,-1
    80001ee4:	b7fd                	j	80001ed2 <fetchaddr+0x36>

0000000080001ee6 <fetchstr>:
{
    80001ee6:	7179                	addi	sp,sp,-48
    80001ee8:	f406                	sd	ra,40(sp)
    80001eea:	f022                	sd	s0,32(sp)
    80001eec:	ec26                	sd	s1,24(sp)
    80001eee:	e84a                	sd	s2,16(sp)
    80001ef0:	e44e                	sd	s3,8(sp)
    80001ef2:	1800                	addi	s0,sp,48
    80001ef4:	892a                	mv	s2,a0
    80001ef6:	84ae                	mv	s1,a1
    80001ef8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001efa:	97eff0ef          	jal	ra,80001078 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001efe:	86ce                	mv	a3,s3
    80001f00:	864a                	mv	a2,s2
    80001f02:	85a6                	mv	a1,s1
    80001f04:	6928                	ld	a0,80(a0)
    80001f06:	e55fe0ef          	jal	ra,80000d5a <copyinstr>
    80001f0a:	00054c63          	bltz	a0,80001f22 <fetchstr+0x3c>
  return strlen(buf);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	d1afe0ef          	jal	ra,8000042a <strlen>
}
    80001f14:	70a2                	ld	ra,40(sp)
    80001f16:	7402                	ld	s0,32(sp)
    80001f18:	64e2                	ld	s1,24(sp)
    80001f1a:	6942                	ld	s2,16(sp)
    80001f1c:	69a2                	ld	s3,8(sp)
    80001f1e:	6145                	addi	sp,sp,48
    80001f20:	8082                	ret
    return -1;
    80001f22:	557d                	li	a0,-1
    80001f24:	bfc5                	j	80001f14 <fetchstr+0x2e>

0000000080001f26 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001f26:	1101                	addi	sp,sp,-32
    80001f28:	ec06                	sd	ra,24(sp)
    80001f2a:	e822                	sd	s0,16(sp)
    80001f2c:	e426                	sd	s1,8(sp)
    80001f2e:	1000                	addi	s0,sp,32
    80001f30:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001f32:	f0bff0ef          	jal	ra,80001e3c <argraw>
    80001f36:	c088                	sw	a0,0(s1)
}
    80001f38:	60e2                	ld	ra,24(sp)
    80001f3a:	6442                	ld	s0,16(sp)
    80001f3c:	64a2                	ld	s1,8(sp)
    80001f3e:	6105                	addi	sp,sp,32
    80001f40:	8082                	ret

0000000080001f42 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001f42:	1101                	addi	sp,sp,-32
    80001f44:	ec06                	sd	ra,24(sp)
    80001f46:	e822                	sd	s0,16(sp)
    80001f48:	e426                	sd	s1,8(sp)
    80001f4a:	1000                	addi	s0,sp,32
    80001f4c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001f4e:	eefff0ef          	jal	ra,80001e3c <argraw>
    80001f52:	e088                	sd	a0,0(s1)
}
    80001f54:	60e2                	ld	ra,24(sp)
    80001f56:	6442                	ld	s0,16(sp)
    80001f58:	64a2                	ld	s1,8(sp)
    80001f5a:	6105                	addi	sp,sp,32
    80001f5c:	8082                	ret

0000000080001f5e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001f5e:	7179                	addi	sp,sp,-48
    80001f60:	f406                	sd	ra,40(sp)
    80001f62:	f022                	sd	s0,32(sp)
    80001f64:	ec26                	sd	s1,24(sp)
    80001f66:	e84a                	sd	s2,16(sp)
    80001f68:	1800                	addi	s0,sp,48
    80001f6a:	84ae                	mv	s1,a1
    80001f6c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001f6e:	fd840593          	addi	a1,s0,-40
    80001f72:	fd1ff0ef          	jal	ra,80001f42 <argaddr>
  return fetchstr(addr, buf, max);
    80001f76:	864a                	mv	a2,s2
    80001f78:	85a6                	mv	a1,s1
    80001f7a:	fd843503          	ld	a0,-40(s0)
    80001f7e:	f69ff0ef          	jal	ra,80001ee6 <fetchstr>
}
    80001f82:	70a2                	ld	ra,40(sp)
    80001f84:	7402                	ld	s0,32(sp)
    80001f86:	64e2                	ld	s1,24(sp)
    80001f88:	6942                	ld	s2,16(sp)
    80001f8a:	6145                	addi	sp,sp,48
    80001f8c:	8082                	ret

0000000080001f8e <syscall>:
#endif
};

void
syscall(void)
{
    80001f8e:	1101                	addi	sp,sp,-32
    80001f90:	ec06                	sd	ra,24(sp)
    80001f92:	e822                	sd	s0,16(sp)
    80001f94:	e426                	sd	s1,8(sp)
    80001f96:	e04a                	sd	s2,0(sp)
    80001f98:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001f9a:	8deff0ef          	jal	ra,80001078 <myproc>
    80001f9e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001fa0:	05853903          	ld	s2,88(a0)
    80001fa4:	0a893783          	ld	a5,168(s2)
    80001fa8:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001fac:	37fd                	addiw	a5,a5,-1
    80001fae:	02100713          	li	a4,33
    80001fb2:	00f76f63          	bltu	a4,a5,80001fd0 <syscall+0x42>
    80001fb6:	00369713          	slli	a4,a3,0x3
    80001fba:	00005797          	auipc	a5,0x5
    80001fbe:	57678793          	addi	a5,a5,1398 # 80007530 <syscalls>
    80001fc2:	97ba                	add	a5,a5,a4
    80001fc4:	639c                	ld	a5,0(a5)
    80001fc6:	c789                	beqz	a5,80001fd0 <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001fc8:	9782                	jalr	a5
    80001fca:	06a93823          	sd	a0,112(s2)
    80001fce:	a829                	j	80001fe8 <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001fd0:	15848613          	addi	a2,s1,344
    80001fd4:	588c                	lw	a1,48(s1)
    80001fd6:	00005517          	auipc	a0,0x5
    80001fda:	52250513          	addi	a0,a0,1314 # 800074f8 <states.0+0x158>
    80001fde:	370030ef          	jal	ra,8000534e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001fe2:	6cbc                	ld	a5,88(s1)
    80001fe4:	577d                	li	a4,-1
    80001fe6:	fbb8                	sd	a4,112(a5)
  }
}
    80001fe8:	60e2                	ld	ra,24(sp)
    80001fea:	6442                	ld	s0,16(sp)
    80001fec:	64a2                	ld	s1,8(sp)
    80001fee:	6902                	ld	s2,0(sp)
    80001ff0:	6105                	addi	sp,sp,32
    80001ff2:	8082                	ret

0000000080001ff4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001ff4:	1101                	addi	sp,sp,-32
    80001ff6:	ec06                	sd	ra,24(sp)
    80001ff8:	e822                	sd	s0,16(sp)
    80001ffa:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001ffc:	fec40593          	addi	a1,s0,-20
    80002000:	4501                	li	a0,0
    80002002:	f25ff0ef          	jal	ra,80001f26 <argint>
  exit(n);
    80002006:	fec42503          	lw	a0,-20(s0)
    8000200a:	f46ff0ef          	jal	ra,80001750 <exit>
  return 0;  // not reached
}
    8000200e:	4501                	li	a0,0
    80002010:	60e2                	ld	ra,24(sp)
    80002012:	6442                	ld	s0,16(sp)
    80002014:	6105                	addi	sp,sp,32
    80002016:	8082                	ret

0000000080002018 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002018:	1141                	addi	sp,sp,-16
    8000201a:	e406                	sd	ra,8(sp)
    8000201c:	e022                	sd	s0,0(sp)
    8000201e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002020:	858ff0ef          	jal	ra,80001078 <myproc>
}
    80002024:	5908                	lw	a0,48(a0)
    80002026:	60a2                	ld	ra,8(sp)
    80002028:	6402                	ld	s0,0(sp)
    8000202a:	0141                	addi	sp,sp,16
    8000202c:	8082                	ret

000000008000202e <sys_fork>:

uint64
sys_fork(void)
{
    8000202e:	1141                	addi	sp,sp,-16
    80002030:	e406                	sd	ra,8(sp)
    80002032:	e022                	sd	s0,0(sp)
    80002034:	0800                	addi	s0,sp,16
  return fork();
    80002036:	b68ff0ef          	jal	ra,8000139e <fork>
}
    8000203a:	60a2                	ld	ra,8(sp)
    8000203c:	6402                	ld	s0,0(sp)
    8000203e:	0141                	addi	sp,sp,16
    80002040:	8082                	ret

0000000080002042 <sys_wait>:

uint64
sys_wait(void)
{
    80002042:	1101                	addi	sp,sp,-32
    80002044:	ec06                	sd	ra,24(sp)
    80002046:	e822                	sd	s0,16(sp)
    80002048:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000204a:	fe840593          	addi	a1,s0,-24
    8000204e:	4501                	li	a0,0
    80002050:	ef3ff0ef          	jal	ra,80001f42 <argaddr>
  return wait(p);
    80002054:	fe843503          	ld	a0,-24(s0)
    80002058:	84fff0ef          	jal	ra,800018a6 <wait>
}
    8000205c:	60e2                	ld	ra,24(sp)
    8000205e:	6442                	ld	s0,16(sp)
    80002060:	6105                	addi	sp,sp,32
    80002062:	8082                	ret

0000000080002064 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002064:	7179                	addi	sp,sp,-48
    80002066:	f406                	sd	ra,40(sp)
    80002068:	f022                	sd	s0,32(sp)
    8000206a:	ec26                	sd	s1,24(sp)
    8000206c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000206e:	fdc40593          	addi	a1,s0,-36
    80002072:	4501                	li	a0,0
    80002074:	eb3ff0ef          	jal	ra,80001f26 <argint>
  addr = myproc()->sz;
    80002078:	800ff0ef          	jal	ra,80001078 <myproc>
    8000207c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000207e:	fdc42503          	lw	a0,-36(s0)
    80002082:	accff0ef          	jal	ra,8000134e <growproc>
    80002086:	00054863          	bltz	a0,80002096 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    8000208a:	8526                	mv	a0,s1
    8000208c:	70a2                	ld	ra,40(sp)
    8000208e:	7402                	ld	s0,32(sp)
    80002090:	64e2                	ld	s1,24(sp)
    80002092:	6145                	addi	sp,sp,48
    80002094:	8082                	ret
    return -1;
    80002096:	54fd                	li	s1,-1
    80002098:	bfcd                	j	8000208a <sys_sbrk+0x26>

000000008000209a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000209a:	7139                	addi	sp,sp,-64
    8000209c:	fc06                	sd	ra,56(sp)
    8000209e:	f822                	sd	s0,48(sp)
    800020a0:	f426                	sd	s1,40(sp)
    800020a2:	f04a                	sd	s2,32(sp)
    800020a4:	ec4e                	sd	s3,24(sp)
    800020a6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800020a8:	fcc40593          	addi	a1,s0,-52
    800020ac:	4501                	li	a0,0
    800020ae:	e79ff0ef          	jal	ra,80001f26 <argint>
  if(n < 0)
    800020b2:	fcc42783          	lw	a5,-52(s0)
    800020b6:	0607c563          	bltz	a5,80002120 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    800020ba:	0000c517          	auipc	a0,0xc
    800020be:	a3650513          	addi	a0,a0,-1482 # 8000daf0 <tickslock>
    800020c2:	051030ef          	jal	ra,80005912 <acquire>
  ticks0 = ticks;
    800020c6:	00006917          	auipc	s2,0x6
    800020ca:	9c292903          	lw	s2,-1598(s2) # 80007a88 <ticks>
  while(ticks - ticks0 < n){
    800020ce:	fcc42783          	lw	a5,-52(s0)
    800020d2:	cb8d                	beqz	a5,80002104 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800020d4:	0000c997          	auipc	s3,0xc
    800020d8:	a1c98993          	addi	s3,s3,-1508 # 8000daf0 <tickslock>
    800020dc:	00006497          	auipc	s1,0x6
    800020e0:	9ac48493          	addi	s1,s1,-1620 # 80007a88 <ticks>
    if(killed(myproc())){
    800020e4:	f95fe0ef          	jal	ra,80001078 <myproc>
    800020e8:	f94ff0ef          	jal	ra,8000187c <killed>
    800020ec:	ed0d                	bnez	a0,80002126 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800020ee:	85ce                	mv	a1,s3
    800020f0:	8526                	mv	a0,s1
    800020f2:	d52ff0ef          	jal	ra,80001644 <sleep>
  while(ticks - ticks0 < n){
    800020f6:	409c                	lw	a5,0(s1)
    800020f8:	412787bb          	subw	a5,a5,s2
    800020fc:	fcc42703          	lw	a4,-52(s0)
    80002100:	fee7e2e3          	bltu	a5,a4,800020e4 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002104:	0000c517          	auipc	a0,0xc
    80002108:	9ec50513          	addi	a0,a0,-1556 # 8000daf0 <tickslock>
    8000210c:	09f030ef          	jal	ra,800059aa <release>
  return 0;
    80002110:	4501                	li	a0,0
}
    80002112:	70e2                	ld	ra,56(sp)
    80002114:	7442                	ld	s0,48(sp)
    80002116:	74a2                	ld	s1,40(sp)
    80002118:	7902                	ld	s2,32(sp)
    8000211a:	69e2                	ld	s3,24(sp)
    8000211c:	6121                	addi	sp,sp,64
    8000211e:	8082                	ret
    n = 0;
    80002120:	fc042623          	sw	zero,-52(s0)
    80002124:	bf59                	j	800020ba <sys_sleep+0x20>
      release(&tickslock);
    80002126:	0000c517          	auipc	a0,0xc
    8000212a:	9ca50513          	addi	a0,a0,-1590 # 8000daf0 <tickslock>
    8000212e:	07d030ef          	jal	ra,800059aa <release>
      return -1;
    80002132:	557d                	li	a0,-1
    80002134:	bff9                	j	80002112 <sys_sleep+0x78>

0000000080002136 <sys_pgpte>:


#ifdef LAB_PGTBL
int
sys_pgpte(void)
{
    80002136:	7179                	addi	sp,sp,-48
    80002138:	f406                	sd	ra,40(sp)
    8000213a:	f022                	sd	s0,32(sp)
    8000213c:	ec26                	sd	s1,24(sp)
    8000213e:	1800                	addi	s0,sp,48
  uint64 va;
  struct proc *p;

  p = myproc();
    80002140:	f39fe0ef          	jal	ra,80001078 <myproc>
    80002144:	84aa                	mv	s1,a0
  argaddr(0, &va);
    80002146:	fd840593          	addi	a1,s0,-40
    8000214a:	4501                	li	a0,0
    8000214c:	df7ff0ef          	jal	ra,80001f42 <argaddr>
  pte_t *pte = pgpte(p->pagetable, va);
    80002150:	fd843583          	ld	a1,-40(s0)
    80002154:	68a8                	ld	a0,80(s1)
    80002156:	daffe0ef          	jal	ra,80000f04 <pgpte>
    8000215a:	87aa                	mv	a5,a0
  if(pte != 0) {
      return (uint64) *pte;
  }
  return 0;
    8000215c:	4501                	li	a0,0
  if(pte != 0) {
    8000215e:	c391                	beqz	a5,80002162 <sys_pgpte+0x2c>
      return (uint64) *pte;
    80002160:	4388                	lw	a0,0(a5)
}
    80002162:	70a2                	ld	ra,40(sp)
    80002164:	7402                	ld	s0,32(sp)
    80002166:	64e2                	ld	s1,24(sp)
    80002168:	6145                	addi	sp,sp,48
    8000216a:	8082                	ret

000000008000216c <sys_kpgtbl>:
#endif

#ifdef LAB_PGTBL
int
sys_kpgtbl(void)
{
    8000216c:	1141                	addi	sp,sp,-16
    8000216e:	e406                	sd	ra,8(sp)
    80002170:	e022                	sd	s0,0(sp)
    80002172:	0800                	addi	s0,sp,16
  struct proc *p;

  p = myproc();
    80002174:	f05fe0ef          	jal	ra,80001078 <myproc>
  vmprint(p->pagetable);
    80002178:	6928                	ld	a0,80(a0)
    8000217a:	d5dfe0ef          	jal	ra,80000ed6 <vmprint>
  return 0;
}
    8000217e:	4501                	li	a0,0
    80002180:	60a2                	ld	ra,8(sp)
    80002182:	6402                	ld	s0,0(sp)
    80002184:	0141                	addi	sp,sp,16
    80002186:	8082                	ret

0000000080002188 <sys_kill>:
#endif


uint64
sys_kill(void)
{
    80002188:	1101                	addi	sp,sp,-32
    8000218a:	ec06                	sd	ra,24(sp)
    8000218c:	e822                	sd	s0,16(sp)
    8000218e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002190:	fec40593          	addi	a1,s0,-20
    80002194:	4501                	li	a0,0
    80002196:	d91ff0ef          	jal	ra,80001f26 <argint>
  return kill(pid);
    8000219a:	fec42503          	lw	a0,-20(s0)
    8000219e:	e54ff0ef          	jal	ra,800017f2 <kill>
}
    800021a2:	60e2                	ld	ra,24(sp)
    800021a4:	6442                	ld	s0,16(sp)
    800021a6:	6105                	addi	sp,sp,32
    800021a8:	8082                	ret

00000000800021aa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800021aa:	1101                	addi	sp,sp,-32
    800021ac:	ec06                	sd	ra,24(sp)
    800021ae:	e822                	sd	s0,16(sp)
    800021b0:	e426                	sd	s1,8(sp)
    800021b2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800021b4:	0000c517          	auipc	a0,0xc
    800021b8:	93c50513          	addi	a0,a0,-1732 # 8000daf0 <tickslock>
    800021bc:	756030ef          	jal	ra,80005912 <acquire>
  xticks = ticks;
    800021c0:	00006497          	auipc	s1,0x6
    800021c4:	8c84a483          	lw	s1,-1848(s1) # 80007a88 <ticks>
  release(&tickslock);
    800021c8:	0000c517          	auipc	a0,0xc
    800021cc:	92850513          	addi	a0,a0,-1752 # 8000daf0 <tickslock>
    800021d0:	7da030ef          	jal	ra,800059aa <release>
  return xticks;
}
    800021d4:	02049513          	slli	a0,s1,0x20
    800021d8:	9101                	srli	a0,a0,0x20
    800021da:	60e2                	ld	ra,24(sp)
    800021dc:	6442                	ld	s0,16(sp)
    800021de:	64a2                	ld	s1,8(sp)
    800021e0:	6105                	addi	sp,sp,32
    800021e2:	8082                	ret

00000000800021e4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800021e4:	7179                	addi	sp,sp,-48
    800021e6:	f406                	sd	ra,40(sp)
    800021e8:	f022                	sd	s0,32(sp)
    800021ea:	ec26                	sd	s1,24(sp)
    800021ec:	e84a                	sd	s2,16(sp)
    800021ee:	e44e                	sd	s3,8(sp)
    800021f0:	e052                	sd	s4,0(sp)
    800021f2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800021f4:	00005597          	auipc	a1,0x5
    800021f8:	45458593          	addi	a1,a1,1108 # 80007648 <syscalls+0x118>
    800021fc:	0000c517          	auipc	a0,0xc
    80002200:	90c50513          	addi	a0,a0,-1780 # 8000db08 <bcache>
    80002204:	68e030ef          	jal	ra,80005892 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002208:	00014797          	auipc	a5,0x14
    8000220c:	90078793          	addi	a5,a5,-1792 # 80015b08 <bcache+0x8000>
    80002210:	00014717          	auipc	a4,0x14
    80002214:	b6070713          	addi	a4,a4,-1184 # 80015d70 <bcache+0x8268>
    80002218:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000221c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002220:	0000c497          	auipc	s1,0xc
    80002224:	90048493          	addi	s1,s1,-1792 # 8000db20 <bcache+0x18>
    b->next = bcache.head.next;
    80002228:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000222a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000222c:	00005a17          	auipc	s4,0x5
    80002230:	424a0a13          	addi	s4,s4,1060 # 80007650 <syscalls+0x120>
    b->next = bcache.head.next;
    80002234:	2b893783          	ld	a5,696(s2)
    80002238:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000223a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000223e:	85d2                	mv	a1,s4
    80002240:	01048513          	addi	a0,s1,16
    80002244:	228010ef          	jal	ra,8000346c <initsleeplock>
    bcache.head.next->prev = b;
    80002248:	2b893783          	ld	a5,696(s2)
    8000224c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000224e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002252:	45848493          	addi	s1,s1,1112
    80002256:	fd349fe3          	bne	s1,s3,80002234 <binit+0x50>
  }
}
    8000225a:	70a2                	ld	ra,40(sp)
    8000225c:	7402                	ld	s0,32(sp)
    8000225e:	64e2                	ld	s1,24(sp)
    80002260:	6942                	ld	s2,16(sp)
    80002262:	69a2                	ld	s3,8(sp)
    80002264:	6a02                	ld	s4,0(sp)
    80002266:	6145                	addi	sp,sp,48
    80002268:	8082                	ret

000000008000226a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000226a:	7179                	addi	sp,sp,-48
    8000226c:	f406                	sd	ra,40(sp)
    8000226e:	f022                	sd	s0,32(sp)
    80002270:	ec26                	sd	s1,24(sp)
    80002272:	e84a                	sd	s2,16(sp)
    80002274:	e44e                	sd	s3,8(sp)
    80002276:	1800                	addi	s0,sp,48
    80002278:	892a                	mv	s2,a0
    8000227a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000227c:	0000c517          	auipc	a0,0xc
    80002280:	88c50513          	addi	a0,a0,-1908 # 8000db08 <bcache>
    80002284:	68e030ef          	jal	ra,80005912 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002288:	00014497          	auipc	s1,0x14
    8000228c:	b384b483          	ld	s1,-1224(s1) # 80015dc0 <bcache+0x82b8>
    80002290:	00014797          	auipc	a5,0x14
    80002294:	ae078793          	addi	a5,a5,-1312 # 80015d70 <bcache+0x8268>
    80002298:	02f48b63          	beq	s1,a5,800022ce <bread+0x64>
    8000229c:	873e                	mv	a4,a5
    8000229e:	a021                	j	800022a6 <bread+0x3c>
    800022a0:	68a4                	ld	s1,80(s1)
    800022a2:	02e48663          	beq	s1,a4,800022ce <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800022a6:	449c                	lw	a5,8(s1)
    800022a8:	ff279ce3          	bne	a5,s2,800022a0 <bread+0x36>
    800022ac:	44dc                	lw	a5,12(s1)
    800022ae:	ff3799e3          	bne	a5,s3,800022a0 <bread+0x36>
      b->refcnt++;
    800022b2:	40bc                	lw	a5,64(s1)
    800022b4:	2785                	addiw	a5,a5,1
    800022b6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800022b8:	0000c517          	auipc	a0,0xc
    800022bc:	85050513          	addi	a0,a0,-1968 # 8000db08 <bcache>
    800022c0:	6ea030ef          	jal	ra,800059aa <release>
      acquiresleep(&b->lock);
    800022c4:	01048513          	addi	a0,s1,16
    800022c8:	1da010ef          	jal	ra,800034a2 <acquiresleep>
      return b;
    800022cc:	a889                	j	8000231e <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800022ce:	00014497          	auipc	s1,0x14
    800022d2:	aea4b483          	ld	s1,-1302(s1) # 80015db8 <bcache+0x82b0>
    800022d6:	00014797          	auipc	a5,0x14
    800022da:	a9a78793          	addi	a5,a5,-1382 # 80015d70 <bcache+0x8268>
    800022de:	00f48863          	beq	s1,a5,800022ee <bread+0x84>
    800022e2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800022e4:	40bc                	lw	a5,64(s1)
    800022e6:	cb91                	beqz	a5,800022fa <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800022e8:	64a4                	ld	s1,72(s1)
    800022ea:	fee49de3          	bne	s1,a4,800022e4 <bread+0x7a>
  panic("bget: no buffers");
    800022ee:	00005517          	auipc	a0,0x5
    800022f2:	36a50513          	addi	a0,a0,874 # 80007658 <syscalls+0x128>
    800022f6:	30c030ef          	jal	ra,80005602 <panic>
      b->dev = dev;
    800022fa:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800022fe:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002302:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002306:	4785                	li	a5,1
    80002308:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000230a:	0000b517          	auipc	a0,0xb
    8000230e:	7fe50513          	addi	a0,a0,2046 # 8000db08 <bcache>
    80002312:	698030ef          	jal	ra,800059aa <release>
      acquiresleep(&b->lock);
    80002316:	01048513          	addi	a0,s1,16
    8000231a:	188010ef          	jal	ra,800034a2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000231e:	409c                	lw	a5,0(s1)
    80002320:	cb89                	beqz	a5,80002332 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002322:	8526                	mv	a0,s1
    80002324:	70a2                	ld	ra,40(sp)
    80002326:	7402                	ld	s0,32(sp)
    80002328:	64e2                	ld	s1,24(sp)
    8000232a:	6942                	ld	s2,16(sp)
    8000232c:	69a2                	ld	s3,8(sp)
    8000232e:	6145                	addi	sp,sp,48
    80002330:	8082                	ret
    virtio_disk_rw(b, 0);
    80002332:	4581                	li	a1,0
    80002334:	8526                	mv	a0,s1
    80002336:	0d5020ef          	jal	ra,80004c0a <virtio_disk_rw>
    b->valid = 1;
    8000233a:	4785                	li	a5,1
    8000233c:	c09c                	sw	a5,0(s1)
  return b;
    8000233e:	b7d5                	j	80002322 <bread+0xb8>

0000000080002340 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002340:	1101                	addi	sp,sp,-32
    80002342:	ec06                	sd	ra,24(sp)
    80002344:	e822                	sd	s0,16(sp)
    80002346:	e426                	sd	s1,8(sp)
    80002348:	1000                	addi	s0,sp,32
    8000234a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000234c:	0541                	addi	a0,a0,16
    8000234e:	1d2010ef          	jal	ra,80003520 <holdingsleep>
    80002352:	c911                	beqz	a0,80002366 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002354:	4585                	li	a1,1
    80002356:	8526                	mv	a0,s1
    80002358:	0b3020ef          	jal	ra,80004c0a <virtio_disk_rw>
}
    8000235c:	60e2                	ld	ra,24(sp)
    8000235e:	6442                	ld	s0,16(sp)
    80002360:	64a2                	ld	s1,8(sp)
    80002362:	6105                	addi	sp,sp,32
    80002364:	8082                	ret
    panic("bwrite");
    80002366:	00005517          	auipc	a0,0x5
    8000236a:	30a50513          	addi	a0,a0,778 # 80007670 <syscalls+0x140>
    8000236e:	294030ef          	jal	ra,80005602 <panic>

0000000080002372 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002372:	1101                	addi	sp,sp,-32
    80002374:	ec06                	sd	ra,24(sp)
    80002376:	e822                	sd	s0,16(sp)
    80002378:	e426                	sd	s1,8(sp)
    8000237a:	e04a                	sd	s2,0(sp)
    8000237c:	1000                	addi	s0,sp,32
    8000237e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002380:	01050913          	addi	s2,a0,16
    80002384:	854a                	mv	a0,s2
    80002386:	19a010ef          	jal	ra,80003520 <holdingsleep>
    8000238a:	c13d                	beqz	a0,800023f0 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    8000238c:	854a                	mv	a0,s2
    8000238e:	15a010ef          	jal	ra,800034e8 <releasesleep>

  acquire(&bcache.lock);
    80002392:	0000b517          	auipc	a0,0xb
    80002396:	77650513          	addi	a0,a0,1910 # 8000db08 <bcache>
    8000239a:	578030ef          	jal	ra,80005912 <acquire>
  b->refcnt--;
    8000239e:	40bc                	lw	a5,64(s1)
    800023a0:	37fd                	addiw	a5,a5,-1
    800023a2:	0007871b          	sext.w	a4,a5
    800023a6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800023a8:	eb05                	bnez	a4,800023d8 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800023aa:	68bc                	ld	a5,80(s1)
    800023ac:	64b8                	ld	a4,72(s1)
    800023ae:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800023b0:	64bc                	ld	a5,72(s1)
    800023b2:	68b8                	ld	a4,80(s1)
    800023b4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800023b6:	00013797          	auipc	a5,0x13
    800023ba:	75278793          	addi	a5,a5,1874 # 80015b08 <bcache+0x8000>
    800023be:	2b87b703          	ld	a4,696(a5)
    800023c2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800023c4:	00014717          	auipc	a4,0x14
    800023c8:	9ac70713          	addi	a4,a4,-1620 # 80015d70 <bcache+0x8268>
    800023cc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800023ce:	2b87b703          	ld	a4,696(a5)
    800023d2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800023d4:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    800023d8:	0000b517          	auipc	a0,0xb
    800023dc:	73050513          	addi	a0,a0,1840 # 8000db08 <bcache>
    800023e0:	5ca030ef          	jal	ra,800059aa <release>
}
    800023e4:	60e2                	ld	ra,24(sp)
    800023e6:	6442                	ld	s0,16(sp)
    800023e8:	64a2                	ld	s1,8(sp)
    800023ea:	6902                	ld	s2,0(sp)
    800023ec:	6105                	addi	sp,sp,32
    800023ee:	8082                	ret
    panic("brelse");
    800023f0:	00005517          	auipc	a0,0x5
    800023f4:	28850513          	addi	a0,a0,648 # 80007678 <syscalls+0x148>
    800023f8:	20a030ef          	jal	ra,80005602 <panic>

00000000800023fc <bpin>:

void
bpin(struct buf *b) {
    800023fc:	1101                	addi	sp,sp,-32
    800023fe:	ec06                	sd	ra,24(sp)
    80002400:	e822                	sd	s0,16(sp)
    80002402:	e426                	sd	s1,8(sp)
    80002404:	1000                	addi	s0,sp,32
    80002406:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002408:	0000b517          	auipc	a0,0xb
    8000240c:	70050513          	addi	a0,a0,1792 # 8000db08 <bcache>
    80002410:	502030ef          	jal	ra,80005912 <acquire>
  b->refcnt++;
    80002414:	40bc                	lw	a5,64(s1)
    80002416:	2785                	addiw	a5,a5,1
    80002418:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000241a:	0000b517          	auipc	a0,0xb
    8000241e:	6ee50513          	addi	a0,a0,1774 # 8000db08 <bcache>
    80002422:	588030ef          	jal	ra,800059aa <release>
}
    80002426:	60e2                	ld	ra,24(sp)
    80002428:	6442                	ld	s0,16(sp)
    8000242a:	64a2                	ld	s1,8(sp)
    8000242c:	6105                	addi	sp,sp,32
    8000242e:	8082                	ret

0000000080002430 <bunpin>:

void
bunpin(struct buf *b) {
    80002430:	1101                	addi	sp,sp,-32
    80002432:	ec06                	sd	ra,24(sp)
    80002434:	e822                	sd	s0,16(sp)
    80002436:	e426                	sd	s1,8(sp)
    80002438:	1000                	addi	s0,sp,32
    8000243a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000243c:	0000b517          	auipc	a0,0xb
    80002440:	6cc50513          	addi	a0,a0,1740 # 8000db08 <bcache>
    80002444:	4ce030ef          	jal	ra,80005912 <acquire>
  b->refcnt--;
    80002448:	40bc                	lw	a5,64(s1)
    8000244a:	37fd                	addiw	a5,a5,-1
    8000244c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000244e:	0000b517          	auipc	a0,0xb
    80002452:	6ba50513          	addi	a0,a0,1722 # 8000db08 <bcache>
    80002456:	554030ef          	jal	ra,800059aa <release>
}
    8000245a:	60e2                	ld	ra,24(sp)
    8000245c:	6442                	ld	s0,16(sp)
    8000245e:	64a2                	ld	s1,8(sp)
    80002460:	6105                	addi	sp,sp,32
    80002462:	8082                	ret

0000000080002464 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002464:	1101                	addi	sp,sp,-32
    80002466:	ec06                	sd	ra,24(sp)
    80002468:	e822                	sd	s0,16(sp)
    8000246a:	e426                	sd	s1,8(sp)
    8000246c:	e04a                	sd	s2,0(sp)
    8000246e:	1000                	addi	s0,sp,32
    80002470:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002472:	00d5d59b          	srliw	a1,a1,0xd
    80002476:	00014797          	auipc	a5,0x14
    8000247a:	d6e7a783          	lw	a5,-658(a5) # 800161e4 <sb+0x1c>
    8000247e:	9dbd                	addw	a1,a1,a5
    80002480:	debff0ef          	jal	ra,8000226a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002484:	0074f713          	andi	a4,s1,7
    80002488:	4785                	li	a5,1
    8000248a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000248e:	14ce                	slli	s1,s1,0x33
    80002490:	90d9                	srli	s1,s1,0x36
    80002492:	00950733          	add	a4,a0,s1
    80002496:	05874703          	lbu	a4,88(a4)
    8000249a:	00e7f6b3          	and	a3,a5,a4
    8000249e:	c29d                	beqz	a3,800024c4 <bfree+0x60>
    800024a0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800024a2:	94aa                	add	s1,s1,a0
    800024a4:	fff7c793          	not	a5,a5
    800024a8:	8f7d                	and	a4,a4,a5
    800024aa:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800024ae:	6ef000ef          	jal	ra,8000339c <log_write>
  brelse(bp);
    800024b2:	854a                	mv	a0,s2
    800024b4:	ebfff0ef          	jal	ra,80002372 <brelse>
}
    800024b8:	60e2                	ld	ra,24(sp)
    800024ba:	6442                	ld	s0,16(sp)
    800024bc:	64a2                	ld	s1,8(sp)
    800024be:	6902                	ld	s2,0(sp)
    800024c0:	6105                	addi	sp,sp,32
    800024c2:	8082                	ret
    panic("freeing free block");
    800024c4:	00005517          	auipc	a0,0x5
    800024c8:	1bc50513          	addi	a0,a0,444 # 80007680 <syscalls+0x150>
    800024cc:	136030ef          	jal	ra,80005602 <panic>

00000000800024d0 <balloc>:
{
    800024d0:	711d                	addi	sp,sp,-96
    800024d2:	ec86                	sd	ra,88(sp)
    800024d4:	e8a2                	sd	s0,80(sp)
    800024d6:	e4a6                	sd	s1,72(sp)
    800024d8:	e0ca                	sd	s2,64(sp)
    800024da:	fc4e                	sd	s3,56(sp)
    800024dc:	f852                	sd	s4,48(sp)
    800024de:	f456                	sd	s5,40(sp)
    800024e0:	f05a                	sd	s6,32(sp)
    800024e2:	ec5e                	sd	s7,24(sp)
    800024e4:	e862                	sd	s8,16(sp)
    800024e6:	e466                	sd	s9,8(sp)
    800024e8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800024ea:	00014797          	auipc	a5,0x14
    800024ee:	ce27a783          	lw	a5,-798(a5) # 800161cc <sb+0x4>
    800024f2:	cff1                	beqz	a5,800025ce <balloc+0xfe>
    800024f4:	8baa                	mv	s7,a0
    800024f6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800024f8:	00014b17          	auipc	s6,0x14
    800024fc:	cd0b0b13          	addi	s6,s6,-816 # 800161c8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002500:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002502:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002504:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002506:	6c89                	lui	s9,0x2
    80002508:	a0b5                	j	80002574 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000250a:	97ca                	add	a5,a5,s2
    8000250c:	8e55                	or	a2,a2,a3
    8000250e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002512:	854a                	mv	a0,s2
    80002514:	689000ef          	jal	ra,8000339c <log_write>
        brelse(bp);
    80002518:	854a                	mv	a0,s2
    8000251a:	e59ff0ef          	jal	ra,80002372 <brelse>
  bp = bread(dev, bno);
    8000251e:	85a6                	mv	a1,s1
    80002520:	855e                	mv	a0,s7
    80002522:	d49ff0ef          	jal	ra,8000226a <bread>
    80002526:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002528:	40000613          	li	a2,1024
    8000252c:	4581                	li	a1,0
    8000252e:	05850513          	addi	a0,a0,88
    80002532:	d81fd0ef          	jal	ra,800002b2 <memset>
  log_write(bp);
    80002536:	854a                	mv	a0,s2
    80002538:	665000ef          	jal	ra,8000339c <log_write>
  brelse(bp);
    8000253c:	854a                	mv	a0,s2
    8000253e:	e35ff0ef          	jal	ra,80002372 <brelse>
}
    80002542:	8526                	mv	a0,s1
    80002544:	60e6                	ld	ra,88(sp)
    80002546:	6446                	ld	s0,80(sp)
    80002548:	64a6                	ld	s1,72(sp)
    8000254a:	6906                	ld	s2,64(sp)
    8000254c:	79e2                	ld	s3,56(sp)
    8000254e:	7a42                	ld	s4,48(sp)
    80002550:	7aa2                	ld	s5,40(sp)
    80002552:	7b02                	ld	s6,32(sp)
    80002554:	6be2                	ld	s7,24(sp)
    80002556:	6c42                	ld	s8,16(sp)
    80002558:	6ca2                	ld	s9,8(sp)
    8000255a:	6125                	addi	sp,sp,96
    8000255c:	8082                	ret
    brelse(bp);
    8000255e:	854a                	mv	a0,s2
    80002560:	e13ff0ef          	jal	ra,80002372 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002564:	015c87bb          	addw	a5,s9,s5
    80002568:	00078a9b          	sext.w	s5,a5
    8000256c:	004b2703          	lw	a4,4(s6)
    80002570:	04eaff63          	bgeu	s5,a4,800025ce <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80002574:	41fad79b          	sraiw	a5,s5,0x1f
    80002578:	0137d79b          	srliw	a5,a5,0x13
    8000257c:	015787bb          	addw	a5,a5,s5
    80002580:	40d7d79b          	sraiw	a5,a5,0xd
    80002584:	01cb2583          	lw	a1,28(s6)
    80002588:	9dbd                	addw	a1,a1,a5
    8000258a:	855e                	mv	a0,s7
    8000258c:	cdfff0ef          	jal	ra,8000226a <bread>
    80002590:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002592:	004b2503          	lw	a0,4(s6)
    80002596:	000a849b          	sext.w	s1,s5
    8000259a:	8762                	mv	a4,s8
    8000259c:	fca4f1e3          	bgeu	s1,a0,8000255e <balloc+0x8e>
      m = 1 << (bi % 8);
    800025a0:	00777693          	andi	a3,a4,7
    800025a4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800025a8:	41f7579b          	sraiw	a5,a4,0x1f
    800025ac:	01d7d79b          	srliw	a5,a5,0x1d
    800025b0:	9fb9                	addw	a5,a5,a4
    800025b2:	4037d79b          	sraiw	a5,a5,0x3
    800025b6:	00f90633          	add	a2,s2,a5
    800025ba:	05864603          	lbu	a2,88(a2)
    800025be:	00c6f5b3          	and	a1,a3,a2
    800025c2:	d5a1                	beqz	a1,8000250a <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800025c4:	2705                	addiw	a4,a4,1
    800025c6:	2485                	addiw	s1,s1,1
    800025c8:	fd471ae3          	bne	a4,s4,8000259c <balloc+0xcc>
    800025cc:	bf49                	j	8000255e <balloc+0x8e>
  printf("balloc: out of blocks\n");
    800025ce:	00005517          	auipc	a0,0x5
    800025d2:	0ca50513          	addi	a0,a0,202 # 80007698 <syscalls+0x168>
    800025d6:	579020ef          	jal	ra,8000534e <printf>
  return 0;
    800025da:	4481                	li	s1,0
    800025dc:	b79d                	j	80002542 <balloc+0x72>

00000000800025de <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800025de:	7179                	addi	sp,sp,-48
    800025e0:	f406                	sd	ra,40(sp)
    800025e2:	f022                	sd	s0,32(sp)
    800025e4:	ec26                	sd	s1,24(sp)
    800025e6:	e84a                	sd	s2,16(sp)
    800025e8:	e44e                	sd	s3,8(sp)
    800025ea:	e052                	sd	s4,0(sp)
    800025ec:	1800                	addi	s0,sp,48
    800025ee:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800025f0:	47ad                	li	a5,11
    800025f2:	02b7e663          	bltu	a5,a1,8000261e <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    800025f6:	02059793          	slli	a5,a1,0x20
    800025fa:	01e7d593          	srli	a1,a5,0x1e
    800025fe:	00b504b3          	add	s1,a0,a1
    80002602:	0504a903          	lw	s2,80(s1)
    80002606:	06091663          	bnez	s2,80002672 <bmap+0x94>
      addr = balloc(ip->dev);
    8000260a:	4108                	lw	a0,0(a0)
    8000260c:	ec5ff0ef          	jal	ra,800024d0 <balloc>
    80002610:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002614:	04090f63          	beqz	s2,80002672 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80002618:	0524a823          	sw	s2,80(s1)
    8000261c:	a899                	j	80002672 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000261e:	ff45849b          	addiw	s1,a1,-12
    80002622:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002626:	0ff00793          	li	a5,255
    8000262a:	06e7eb63          	bltu	a5,a4,800026a0 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000262e:	08052903          	lw	s2,128(a0)
    80002632:	00091b63          	bnez	s2,80002648 <bmap+0x6a>
      addr = balloc(ip->dev);
    80002636:	4108                	lw	a0,0(a0)
    80002638:	e99ff0ef          	jal	ra,800024d0 <balloc>
    8000263c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002640:	02090963          	beqz	s2,80002672 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002644:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002648:	85ca                	mv	a1,s2
    8000264a:	0009a503          	lw	a0,0(s3)
    8000264e:	c1dff0ef          	jal	ra,8000226a <bread>
    80002652:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002654:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002658:	02049713          	slli	a4,s1,0x20
    8000265c:	01e75593          	srli	a1,a4,0x1e
    80002660:	00b784b3          	add	s1,a5,a1
    80002664:	0004a903          	lw	s2,0(s1)
    80002668:	00090e63          	beqz	s2,80002684 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000266c:	8552                	mv	a0,s4
    8000266e:	d05ff0ef          	jal	ra,80002372 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002672:	854a                	mv	a0,s2
    80002674:	70a2                	ld	ra,40(sp)
    80002676:	7402                	ld	s0,32(sp)
    80002678:	64e2                	ld	s1,24(sp)
    8000267a:	6942                	ld	s2,16(sp)
    8000267c:	69a2                	ld	s3,8(sp)
    8000267e:	6a02                	ld	s4,0(sp)
    80002680:	6145                	addi	sp,sp,48
    80002682:	8082                	ret
      addr = balloc(ip->dev);
    80002684:	0009a503          	lw	a0,0(s3)
    80002688:	e49ff0ef          	jal	ra,800024d0 <balloc>
    8000268c:	0005091b          	sext.w	s2,a0
      if(addr){
    80002690:	fc090ee3          	beqz	s2,8000266c <bmap+0x8e>
        a[bn] = addr;
    80002694:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002698:	8552                	mv	a0,s4
    8000269a:	503000ef          	jal	ra,8000339c <log_write>
    8000269e:	b7f9                	j	8000266c <bmap+0x8e>
  panic("bmap: out of range");
    800026a0:	00005517          	auipc	a0,0x5
    800026a4:	01050513          	addi	a0,a0,16 # 800076b0 <syscalls+0x180>
    800026a8:	75b020ef          	jal	ra,80005602 <panic>

00000000800026ac <iget>:
{
    800026ac:	7179                	addi	sp,sp,-48
    800026ae:	f406                	sd	ra,40(sp)
    800026b0:	f022                	sd	s0,32(sp)
    800026b2:	ec26                	sd	s1,24(sp)
    800026b4:	e84a                	sd	s2,16(sp)
    800026b6:	e44e                	sd	s3,8(sp)
    800026b8:	e052                	sd	s4,0(sp)
    800026ba:	1800                	addi	s0,sp,48
    800026bc:	89aa                	mv	s3,a0
    800026be:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800026c0:	00014517          	auipc	a0,0x14
    800026c4:	b2850513          	addi	a0,a0,-1240 # 800161e8 <itable>
    800026c8:	24a030ef          	jal	ra,80005912 <acquire>
  empty = 0;
    800026cc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800026ce:	00014497          	auipc	s1,0x14
    800026d2:	b3248493          	addi	s1,s1,-1230 # 80016200 <itable+0x18>
    800026d6:	00015697          	auipc	a3,0x15
    800026da:	5ba68693          	addi	a3,a3,1466 # 80017c90 <log>
    800026de:	a039                	j	800026ec <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800026e0:	02090963          	beqz	s2,80002712 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800026e4:	08848493          	addi	s1,s1,136
    800026e8:	02d48863          	beq	s1,a3,80002718 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800026ec:	449c                	lw	a5,8(s1)
    800026ee:	fef059e3          	blez	a5,800026e0 <iget+0x34>
    800026f2:	4098                	lw	a4,0(s1)
    800026f4:	ff3716e3          	bne	a4,s3,800026e0 <iget+0x34>
    800026f8:	40d8                	lw	a4,4(s1)
    800026fa:	ff4713e3          	bne	a4,s4,800026e0 <iget+0x34>
      ip->ref++;
    800026fe:	2785                	addiw	a5,a5,1
    80002700:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002702:	00014517          	auipc	a0,0x14
    80002706:	ae650513          	addi	a0,a0,-1306 # 800161e8 <itable>
    8000270a:	2a0030ef          	jal	ra,800059aa <release>
      return ip;
    8000270e:	8926                	mv	s2,s1
    80002710:	a02d                	j	8000273a <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002712:	fbe9                	bnez	a5,800026e4 <iget+0x38>
    80002714:	8926                	mv	s2,s1
    80002716:	b7f9                	j	800026e4 <iget+0x38>
  if(empty == 0)
    80002718:	02090a63          	beqz	s2,8000274c <iget+0xa0>
  ip->dev = dev;
    8000271c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002720:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002724:	4785                	li	a5,1
    80002726:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000272a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000272e:	00014517          	auipc	a0,0x14
    80002732:	aba50513          	addi	a0,a0,-1350 # 800161e8 <itable>
    80002736:	274030ef          	jal	ra,800059aa <release>
}
    8000273a:	854a                	mv	a0,s2
    8000273c:	70a2                	ld	ra,40(sp)
    8000273e:	7402                	ld	s0,32(sp)
    80002740:	64e2                	ld	s1,24(sp)
    80002742:	6942                	ld	s2,16(sp)
    80002744:	69a2                	ld	s3,8(sp)
    80002746:	6a02                	ld	s4,0(sp)
    80002748:	6145                	addi	sp,sp,48
    8000274a:	8082                	ret
    panic("iget: no inodes");
    8000274c:	00005517          	auipc	a0,0x5
    80002750:	f7c50513          	addi	a0,a0,-132 # 800076c8 <syscalls+0x198>
    80002754:	6af020ef          	jal	ra,80005602 <panic>

0000000080002758 <fsinit>:
fsinit(int dev) {
    80002758:	7179                	addi	sp,sp,-48
    8000275a:	f406                	sd	ra,40(sp)
    8000275c:	f022                	sd	s0,32(sp)
    8000275e:	ec26                	sd	s1,24(sp)
    80002760:	e84a                	sd	s2,16(sp)
    80002762:	e44e                	sd	s3,8(sp)
    80002764:	1800                	addi	s0,sp,48
    80002766:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002768:	4585                	li	a1,1
    8000276a:	b01ff0ef          	jal	ra,8000226a <bread>
    8000276e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002770:	00014997          	auipc	s3,0x14
    80002774:	a5898993          	addi	s3,s3,-1448 # 800161c8 <sb>
    80002778:	02000613          	li	a2,32
    8000277c:	05850593          	addi	a1,a0,88
    80002780:	854e                	mv	a0,s3
    80002782:	b8dfd0ef          	jal	ra,8000030e <memmove>
  brelse(bp);
    80002786:	8526                	mv	a0,s1
    80002788:	bebff0ef          	jal	ra,80002372 <brelse>
  if(sb.magic != FSMAGIC)
    8000278c:	0009a703          	lw	a4,0(s3)
    80002790:	102037b7          	lui	a5,0x10203
    80002794:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002798:	02f71063          	bne	a4,a5,800027b8 <fsinit+0x60>
  initlog(dev, &sb);
    8000279c:	00014597          	auipc	a1,0x14
    800027a0:	a2c58593          	addi	a1,a1,-1492 # 800161c8 <sb>
    800027a4:	854a                	mv	a0,s2
    800027a6:	1e3000ef          	jal	ra,80003188 <initlog>
}
    800027aa:	70a2                	ld	ra,40(sp)
    800027ac:	7402                	ld	s0,32(sp)
    800027ae:	64e2                	ld	s1,24(sp)
    800027b0:	6942                	ld	s2,16(sp)
    800027b2:	69a2                	ld	s3,8(sp)
    800027b4:	6145                	addi	sp,sp,48
    800027b6:	8082                	ret
    panic("invalid file system");
    800027b8:	00005517          	auipc	a0,0x5
    800027bc:	f2050513          	addi	a0,a0,-224 # 800076d8 <syscalls+0x1a8>
    800027c0:	643020ef          	jal	ra,80005602 <panic>

00000000800027c4 <iinit>:
{
    800027c4:	7179                	addi	sp,sp,-48
    800027c6:	f406                	sd	ra,40(sp)
    800027c8:	f022                	sd	s0,32(sp)
    800027ca:	ec26                	sd	s1,24(sp)
    800027cc:	e84a                	sd	s2,16(sp)
    800027ce:	e44e                	sd	s3,8(sp)
    800027d0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800027d2:	00005597          	auipc	a1,0x5
    800027d6:	f1e58593          	addi	a1,a1,-226 # 800076f0 <syscalls+0x1c0>
    800027da:	00014517          	auipc	a0,0x14
    800027de:	a0e50513          	addi	a0,a0,-1522 # 800161e8 <itable>
    800027e2:	0b0030ef          	jal	ra,80005892 <initlock>
  for(i = 0; i < NINODE; i++) {
    800027e6:	00014497          	auipc	s1,0x14
    800027ea:	a2a48493          	addi	s1,s1,-1494 # 80016210 <itable+0x28>
    800027ee:	00015997          	auipc	s3,0x15
    800027f2:	4b298993          	addi	s3,s3,1202 # 80017ca0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800027f6:	00005917          	auipc	s2,0x5
    800027fa:	f0290913          	addi	s2,s2,-254 # 800076f8 <syscalls+0x1c8>
    800027fe:	85ca                	mv	a1,s2
    80002800:	8526                	mv	a0,s1
    80002802:	46b000ef          	jal	ra,8000346c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002806:	08848493          	addi	s1,s1,136
    8000280a:	ff349ae3          	bne	s1,s3,800027fe <iinit+0x3a>
}
    8000280e:	70a2                	ld	ra,40(sp)
    80002810:	7402                	ld	s0,32(sp)
    80002812:	64e2                	ld	s1,24(sp)
    80002814:	6942                	ld	s2,16(sp)
    80002816:	69a2                	ld	s3,8(sp)
    80002818:	6145                	addi	sp,sp,48
    8000281a:	8082                	ret

000000008000281c <ialloc>:
{
    8000281c:	715d                	addi	sp,sp,-80
    8000281e:	e486                	sd	ra,72(sp)
    80002820:	e0a2                	sd	s0,64(sp)
    80002822:	fc26                	sd	s1,56(sp)
    80002824:	f84a                	sd	s2,48(sp)
    80002826:	f44e                	sd	s3,40(sp)
    80002828:	f052                	sd	s4,32(sp)
    8000282a:	ec56                	sd	s5,24(sp)
    8000282c:	e85a                	sd	s6,16(sp)
    8000282e:	e45e                	sd	s7,8(sp)
    80002830:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002832:	00014717          	auipc	a4,0x14
    80002836:	9a272703          	lw	a4,-1630(a4) # 800161d4 <sb+0xc>
    8000283a:	4785                	li	a5,1
    8000283c:	04e7f663          	bgeu	a5,a4,80002888 <ialloc+0x6c>
    80002840:	8aaa                	mv	s5,a0
    80002842:	8bae                	mv	s7,a1
    80002844:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002846:	00014a17          	auipc	s4,0x14
    8000284a:	982a0a13          	addi	s4,s4,-1662 # 800161c8 <sb>
    8000284e:	00048b1b          	sext.w	s6,s1
    80002852:	0044d593          	srli	a1,s1,0x4
    80002856:	018a2783          	lw	a5,24(s4)
    8000285a:	9dbd                	addw	a1,a1,a5
    8000285c:	8556                	mv	a0,s5
    8000285e:	a0dff0ef          	jal	ra,8000226a <bread>
    80002862:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002864:	05850993          	addi	s3,a0,88
    80002868:	00f4f793          	andi	a5,s1,15
    8000286c:	079a                	slli	a5,a5,0x6
    8000286e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002870:	00099783          	lh	a5,0(s3)
    80002874:	cf85                	beqz	a5,800028ac <ialloc+0x90>
    brelse(bp);
    80002876:	afdff0ef          	jal	ra,80002372 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000287a:	0485                	addi	s1,s1,1
    8000287c:	00ca2703          	lw	a4,12(s4)
    80002880:	0004879b          	sext.w	a5,s1
    80002884:	fce7e5e3          	bltu	a5,a4,8000284e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002888:	00005517          	auipc	a0,0x5
    8000288c:	e7850513          	addi	a0,a0,-392 # 80007700 <syscalls+0x1d0>
    80002890:	2bf020ef          	jal	ra,8000534e <printf>
  return 0;
    80002894:	4501                	li	a0,0
}
    80002896:	60a6                	ld	ra,72(sp)
    80002898:	6406                	ld	s0,64(sp)
    8000289a:	74e2                	ld	s1,56(sp)
    8000289c:	7942                	ld	s2,48(sp)
    8000289e:	79a2                	ld	s3,40(sp)
    800028a0:	7a02                	ld	s4,32(sp)
    800028a2:	6ae2                	ld	s5,24(sp)
    800028a4:	6b42                	ld	s6,16(sp)
    800028a6:	6ba2                	ld	s7,8(sp)
    800028a8:	6161                	addi	sp,sp,80
    800028aa:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800028ac:	04000613          	li	a2,64
    800028b0:	4581                	li	a1,0
    800028b2:	854e                	mv	a0,s3
    800028b4:	9fffd0ef          	jal	ra,800002b2 <memset>
      dip->type = type;
    800028b8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800028bc:	854a                	mv	a0,s2
    800028be:	2df000ef          	jal	ra,8000339c <log_write>
      brelse(bp);
    800028c2:	854a                	mv	a0,s2
    800028c4:	aafff0ef          	jal	ra,80002372 <brelse>
      return iget(dev, inum);
    800028c8:	85da                	mv	a1,s6
    800028ca:	8556                	mv	a0,s5
    800028cc:	de1ff0ef          	jal	ra,800026ac <iget>
    800028d0:	b7d9                	j	80002896 <ialloc+0x7a>

00000000800028d2 <iupdate>:
{
    800028d2:	1101                	addi	sp,sp,-32
    800028d4:	ec06                	sd	ra,24(sp)
    800028d6:	e822                	sd	s0,16(sp)
    800028d8:	e426                	sd	s1,8(sp)
    800028da:	e04a                	sd	s2,0(sp)
    800028dc:	1000                	addi	s0,sp,32
    800028de:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800028e0:	415c                	lw	a5,4(a0)
    800028e2:	0047d79b          	srliw	a5,a5,0x4
    800028e6:	00014597          	auipc	a1,0x14
    800028ea:	8fa5a583          	lw	a1,-1798(a1) # 800161e0 <sb+0x18>
    800028ee:	9dbd                	addw	a1,a1,a5
    800028f0:	4108                	lw	a0,0(a0)
    800028f2:	979ff0ef          	jal	ra,8000226a <bread>
    800028f6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800028f8:	05850793          	addi	a5,a0,88
    800028fc:	40d8                	lw	a4,4(s1)
    800028fe:	8b3d                	andi	a4,a4,15
    80002900:	071a                	slli	a4,a4,0x6
    80002902:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002904:	04449703          	lh	a4,68(s1)
    80002908:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000290c:	04649703          	lh	a4,70(s1)
    80002910:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002914:	04849703          	lh	a4,72(s1)
    80002918:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000291c:	04a49703          	lh	a4,74(s1)
    80002920:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002924:	44f8                	lw	a4,76(s1)
    80002926:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002928:	03400613          	li	a2,52
    8000292c:	05048593          	addi	a1,s1,80
    80002930:	00c78513          	addi	a0,a5,12
    80002934:	9dbfd0ef          	jal	ra,8000030e <memmove>
  log_write(bp);
    80002938:	854a                	mv	a0,s2
    8000293a:	263000ef          	jal	ra,8000339c <log_write>
  brelse(bp);
    8000293e:	854a                	mv	a0,s2
    80002940:	a33ff0ef          	jal	ra,80002372 <brelse>
}
    80002944:	60e2                	ld	ra,24(sp)
    80002946:	6442                	ld	s0,16(sp)
    80002948:	64a2                	ld	s1,8(sp)
    8000294a:	6902                	ld	s2,0(sp)
    8000294c:	6105                	addi	sp,sp,32
    8000294e:	8082                	ret

0000000080002950 <idup>:
{
    80002950:	1101                	addi	sp,sp,-32
    80002952:	ec06                	sd	ra,24(sp)
    80002954:	e822                	sd	s0,16(sp)
    80002956:	e426                	sd	s1,8(sp)
    80002958:	1000                	addi	s0,sp,32
    8000295a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000295c:	00014517          	auipc	a0,0x14
    80002960:	88c50513          	addi	a0,a0,-1908 # 800161e8 <itable>
    80002964:	7af020ef          	jal	ra,80005912 <acquire>
  ip->ref++;
    80002968:	449c                	lw	a5,8(s1)
    8000296a:	2785                	addiw	a5,a5,1
    8000296c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000296e:	00014517          	auipc	a0,0x14
    80002972:	87a50513          	addi	a0,a0,-1926 # 800161e8 <itable>
    80002976:	034030ef          	jal	ra,800059aa <release>
}
    8000297a:	8526                	mv	a0,s1
    8000297c:	60e2                	ld	ra,24(sp)
    8000297e:	6442                	ld	s0,16(sp)
    80002980:	64a2                	ld	s1,8(sp)
    80002982:	6105                	addi	sp,sp,32
    80002984:	8082                	ret

0000000080002986 <ilock>:
{
    80002986:	1101                	addi	sp,sp,-32
    80002988:	ec06                	sd	ra,24(sp)
    8000298a:	e822                	sd	s0,16(sp)
    8000298c:	e426                	sd	s1,8(sp)
    8000298e:	e04a                	sd	s2,0(sp)
    80002990:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002992:	c105                	beqz	a0,800029b2 <ilock+0x2c>
    80002994:	84aa                	mv	s1,a0
    80002996:	451c                	lw	a5,8(a0)
    80002998:	00f05d63          	blez	a5,800029b2 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000299c:	0541                	addi	a0,a0,16
    8000299e:	305000ef          	jal	ra,800034a2 <acquiresleep>
  if(ip->valid == 0){
    800029a2:	40bc                	lw	a5,64(s1)
    800029a4:	cf89                	beqz	a5,800029be <ilock+0x38>
}
    800029a6:	60e2                	ld	ra,24(sp)
    800029a8:	6442                	ld	s0,16(sp)
    800029aa:	64a2                	ld	s1,8(sp)
    800029ac:	6902                	ld	s2,0(sp)
    800029ae:	6105                	addi	sp,sp,32
    800029b0:	8082                	ret
    panic("ilock");
    800029b2:	00005517          	auipc	a0,0x5
    800029b6:	d6650513          	addi	a0,a0,-666 # 80007718 <syscalls+0x1e8>
    800029ba:	449020ef          	jal	ra,80005602 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800029be:	40dc                	lw	a5,4(s1)
    800029c0:	0047d79b          	srliw	a5,a5,0x4
    800029c4:	00014597          	auipc	a1,0x14
    800029c8:	81c5a583          	lw	a1,-2020(a1) # 800161e0 <sb+0x18>
    800029cc:	9dbd                	addw	a1,a1,a5
    800029ce:	4088                	lw	a0,0(s1)
    800029d0:	89bff0ef          	jal	ra,8000226a <bread>
    800029d4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800029d6:	05850593          	addi	a1,a0,88
    800029da:	40dc                	lw	a5,4(s1)
    800029dc:	8bbd                	andi	a5,a5,15
    800029de:	079a                	slli	a5,a5,0x6
    800029e0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800029e2:	00059783          	lh	a5,0(a1)
    800029e6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800029ea:	00259783          	lh	a5,2(a1)
    800029ee:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800029f2:	00459783          	lh	a5,4(a1)
    800029f6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800029fa:	00659783          	lh	a5,6(a1)
    800029fe:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002a02:	459c                	lw	a5,8(a1)
    80002a04:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002a06:	03400613          	li	a2,52
    80002a0a:	05b1                	addi	a1,a1,12
    80002a0c:	05048513          	addi	a0,s1,80
    80002a10:	8fffd0ef          	jal	ra,8000030e <memmove>
    brelse(bp);
    80002a14:	854a                	mv	a0,s2
    80002a16:	95dff0ef          	jal	ra,80002372 <brelse>
    ip->valid = 1;
    80002a1a:	4785                	li	a5,1
    80002a1c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002a1e:	04449783          	lh	a5,68(s1)
    80002a22:	f3d1                	bnez	a5,800029a6 <ilock+0x20>
      panic("ilock: no type");
    80002a24:	00005517          	auipc	a0,0x5
    80002a28:	cfc50513          	addi	a0,a0,-772 # 80007720 <syscalls+0x1f0>
    80002a2c:	3d7020ef          	jal	ra,80005602 <panic>

0000000080002a30 <iunlock>:
{
    80002a30:	1101                	addi	sp,sp,-32
    80002a32:	ec06                	sd	ra,24(sp)
    80002a34:	e822                	sd	s0,16(sp)
    80002a36:	e426                	sd	s1,8(sp)
    80002a38:	e04a                	sd	s2,0(sp)
    80002a3a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002a3c:	c505                	beqz	a0,80002a64 <iunlock+0x34>
    80002a3e:	84aa                	mv	s1,a0
    80002a40:	01050913          	addi	s2,a0,16
    80002a44:	854a                	mv	a0,s2
    80002a46:	2db000ef          	jal	ra,80003520 <holdingsleep>
    80002a4a:	cd09                	beqz	a0,80002a64 <iunlock+0x34>
    80002a4c:	449c                	lw	a5,8(s1)
    80002a4e:	00f05b63          	blez	a5,80002a64 <iunlock+0x34>
  releasesleep(&ip->lock);
    80002a52:	854a                	mv	a0,s2
    80002a54:	295000ef          	jal	ra,800034e8 <releasesleep>
}
    80002a58:	60e2                	ld	ra,24(sp)
    80002a5a:	6442                	ld	s0,16(sp)
    80002a5c:	64a2                	ld	s1,8(sp)
    80002a5e:	6902                	ld	s2,0(sp)
    80002a60:	6105                	addi	sp,sp,32
    80002a62:	8082                	ret
    panic("iunlock");
    80002a64:	00005517          	auipc	a0,0x5
    80002a68:	ccc50513          	addi	a0,a0,-820 # 80007730 <syscalls+0x200>
    80002a6c:	397020ef          	jal	ra,80005602 <panic>

0000000080002a70 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002a70:	7179                	addi	sp,sp,-48
    80002a72:	f406                	sd	ra,40(sp)
    80002a74:	f022                	sd	s0,32(sp)
    80002a76:	ec26                	sd	s1,24(sp)
    80002a78:	e84a                	sd	s2,16(sp)
    80002a7a:	e44e                	sd	s3,8(sp)
    80002a7c:	e052                	sd	s4,0(sp)
    80002a7e:	1800                	addi	s0,sp,48
    80002a80:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002a82:	05050493          	addi	s1,a0,80
    80002a86:	08050913          	addi	s2,a0,128
    80002a8a:	a021                	j	80002a92 <itrunc+0x22>
    80002a8c:	0491                	addi	s1,s1,4
    80002a8e:	01248b63          	beq	s1,s2,80002aa4 <itrunc+0x34>
    if(ip->addrs[i]){
    80002a92:	408c                	lw	a1,0(s1)
    80002a94:	dde5                	beqz	a1,80002a8c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002a96:	0009a503          	lw	a0,0(s3)
    80002a9a:	9cbff0ef          	jal	ra,80002464 <bfree>
      ip->addrs[i] = 0;
    80002a9e:	0004a023          	sw	zero,0(s1)
    80002aa2:	b7ed                	j	80002a8c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002aa4:	0809a583          	lw	a1,128(s3)
    80002aa8:	ed91                	bnez	a1,80002ac4 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002aaa:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002aae:	854e                	mv	a0,s3
    80002ab0:	e23ff0ef          	jal	ra,800028d2 <iupdate>
}
    80002ab4:	70a2                	ld	ra,40(sp)
    80002ab6:	7402                	ld	s0,32(sp)
    80002ab8:	64e2                	ld	s1,24(sp)
    80002aba:	6942                	ld	s2,16(sp)
    80002abc:	69a2                	ld	s3,8(sp)
    80002abe:	6a02                	ld	s4,0(sp)
    80002ac0:	6145                	addi	sp,sp,48
    80002ac2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002ac4:	0009a503          	lw	a0,0(s3)
    80002ac8:	fa2ff0ef          	jal	ra,8000226a <bread>
    80002acc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002ace:	05850493          	addi	s1,a0,88
    80002ad2:	45850913          	addi	s2,a0,1112
    80002ad6:	a021                	j	80002ade <itrunc+0x6e>
    80002ad8:	0491                	addi	s1,s1,4
    80002ada:	01248963          	beq	s1,s2,80002aec <itrunc+0x7c>
      if(a[j])
    80002ade:	408c                	lw	a1,0(s1)
    80002ae0:	dde5                	beqz	a1,80002ad8 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80002ae2:	0009a503          	lw	a0,0(s3)
    80002ae6:	97fff0ef          	jal	ra,80002464 <bfree>
    80002aea:	b7fd                	j	80002ad8 <itrunc+0x68>
    brelse(bp);
    80002aec:	8552                	mv	a0,s4
    80002aee:	885ff0ef          	jal	ra,80002372 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002af2:	0809a583          	lw	a1,128(s3)
    80002af6:	0009a503          	lw	a0,0(s3)
    80002afa:	96bff0ef          	jal	ra,80002464 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002afe:	0809a023          	sw	zero,128(s3)
    80002b02:	b765                	j	80002aaa <itrunc+0x3a>

0000000080002b04 <iput>:
{
    80002b04:	1101                	addi	sp,sp,-32
    80002b06:	ec06                	sd	ra,24(sp)
    80002b08:	e822                	sd	s0,16(sp)
    80002b0a:	e426                	sd	s1,8(sp)
    80002b0c:	e04a                	sd	s2,0(sp)
    80002b0e:	1000                	addi	s0,sp,32
    80002b10:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002b12:	00013517          	auipc	a0,0x13
    80002b16:	6d650513          	addi	a0,a0,1750 # 800161e8 <itable>
    80002b1a:	5f9020ef          	jal	ra,80005912 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002b1e:	4498                	lw	a4,8(s1)
    80002b20:	4785                	li	a5,1
    80002b22:	02f70163          	beq	a4,a5,80002b44 <iput+0x40>
  ip->ref--;
    80002b26:	449c                	lw	a5,8(s1)
    80002b28:	37fd                	addiw	a5,a5,-1
    80002b2a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002b2c:	00013517          	auipc	a0,0x13
    80002b30:	6bc50513          	addi	a0,a0,1724 # 800161e8 <itable>
    80002b34:	677020ef          	jal	ra,800059aa <release>
}
    80002b38:	60e2                	ld	ra,24(sp)
    80002b3a:	6442                	ld	s0,16(sp)
    80002b3c:	64a2                	ld	s1,8(sp)
    80002b3e:	6902                	ld	s2,0(sp)
    80002b40:	6105                	addi	sp,sp,32
    80002b42:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002b44:	40bc                	lw	a5,64(s1)
    80002b46:	d3e5                	beqz	a5,80002b26 <iput+0x22>
    80002b48:	04a49783          	lh	a5,74(s1)
    80002b4c:	ffe9                	bnez	a5,80002b26 <iput+0x22>
    acquiresleep(&ip->lock);
    80002b4e:	01048913          	addi	s2,s1,16
    80002b52:	854a                	mv	a0,s2
    80002b54:	14f000ef          	jal	ra,800034a2 <acquiresleep>
    release(&itable.lock);
    80002b58:	00013517          	auipc	a0,0x13
    80002b5c:	69050513          	addi	a0,a0,1680 # 800161e8 <itable>
    80002b60:	64b020ef          	jal	ra,800059aa <release>
    itrunc(ip);
    80002b64:	8526                	mv	a0,s1
    80002b66:	f0bff0ef          	jal	ra,80002a70 <itrunc>
    ip->type = 0;
    80002b6a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002b6e:	8526                	mv	a0,s1
    80002b70:	d63ff0ef          	jal	ra,800028d2 <iupdate>
    ip->valid = 0;
    80002b74:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002b78:	854a                	mv	a0,s2
    80002b7a:	16f000ef          	jal	ra,800034e8 <releasesleep>
    acquire(&itable.lock);
    80002b7e:	00013517          	auipc	a0,0x13
    80002b82:	66a50513          	addi	a0,a0,1642 # 800161e8 <itable>
    80002b86:	58d020ef          	jal	ra,80005912 <acquire>
    80002b8a:	bf71                	j	80002b26 <iput+0x22>

0000000080002b8c <iunlockput>:
{
    80002b8c:	1101                	addi	sp,sp,-32
    80002b8e:	ec06                	sd	ra,24(sp)
    80002b90:	e822                	sd	s0,16(sp)
    80002b92:	e426                	sd	s1,8(sp)
    80002b94:	1000                	addi	s0,sp,32
    80002b96:	84aa                	mv	s1,a0
  iunlock(ip);
    80002b98:	e99ff0ef          	jal	ra,80002a30 <iunlock>
  iput(ip);
    80002b9c:	8526                	mv	a0,s1
    80002b9e:	f67ff0ef          	jal	ra,80002b04 <iput>
}
    80002ba2:	60e2                	ld	ra,24(sp)
    80002ba4:	6442                	ld	s0,16(sp)
    80002ba6:	64a2                	ld	s1,8(sp)
    80002ba8:	6105                	addi	sp,sp,32
    80002baa:	8082                	ret

0000000080002bac <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002bac:	1141                	addi	sp,sp,-16
    80002bae:	e422                	sd	s0,8(sp)
    80002bb0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002bb2:	411c                	lw	a5,0(a0)
    80002bb4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002bb6:	415c                	lw	a5,4(a0)
    80002bb8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002bba:	04451783          	lh	a5,68(a0)
    80002bbe:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002bc2:	04a51783          	lh	a5,74(a0)
    80002bc6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002bca:	04c56783          	lwu	a5,76(a0)
    80002bce:	e99c                	sd	a5,16(a1)
}
    80002bd0:	6422                	ld	s0,8(sp)
    80002bd2:	0141                	addi	sp,sp,16
    80002bd4:	8082                	ret

0000000080002bd6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002bd6:	457c                	lw	a5,76(a0)
    80002bd8:	0cd7ef63          	bltu	a5,a3,80002cb6 <readi+0xe0>
{
    80002bdc:	7159                	addi	sp,sp,-112
    80002bde:	f486                	sd	ra,104(sp)
    80002be0:	f0a2                	sd	s0,96(sp)
    80002be2:	eca6                	sd	s1,88(sp)
    80002be4:	e8ca                	sd	s2,80(sp)
    80002be6:	e4ce                	sd	s3,72(sp)
    80002be8:	e0d2                	sd	s4,64(sp)
    80002bea:	fc56                	sd	s5,56(sp)
    80002bec:	f85a                	sd	s6,48(sp)
    80002bee:	f45e                	sd	s7,40(sp)
    80002bf0:	f062                	sd	s8,32(sp)
    80002bf2:	ec66                	sd	s9,24(sp)
    80002bf4:	e86a                	sd	s10,16(sp)
    80002bf6:	e46e                	sd	s11,8(sp)
    80002bf8:	1880                	addi	s0,sp,112
    80002bfa:	8b2a                	mv	s6,a0
    80002bfc:	8bae                	mv	s7,a1
    80002bfe:	8a32                	mv	s4,a2
    80002c00:	84b6                	mv	s1,a3
    80002c02:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002c04:	9f35                	addw	a4,a4,a3
    return 0;
    80002c06:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002c08:	08d76663          	bltu	a4,a3,80002c94 <readi+0xbe>
  if(off + n > ip->size)
    80002c0c:	00e7f463          	bgeu	a5,a4,80002c14 <readi+0x3e>
    n = ip->size - off;
    80002c10:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002c14:	080a8f63          	beqz	s5,80002cb2 <readi+0xdc>
    80002c18:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c1a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002c1e:	5c7d                	li	s8,-1
    80002c20:	a80d                	j	80002c52 <readi+0x7c>
    80002c22:	020d1d93          	slli	s11,s10,0x20
    80002c26:	020ddd93          	srli	s11,s11,0x20
    80002c2a:	05890613          	addi	a2,s2,88
    80002c2e:	86ee                	mv	a3,s11
    80002c30:	963a                	add	a2,a2,a4
    80002c32:	85d2                	mv	a1,s4
    80002c34:	855e                	mv	a0,s7
    80002c36:	d6bfe0ef          	jal	ra,800019a0 <either_copyout>
    80002c3a:	05850763          	beq	a0,s8,80002c88 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002c3e:	854a                	mv	a0,s2
    80002c40:	f32ff0ef          	jal	ra,80002372 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002c44:	013d09bb          	addw	s3,s10,s3
    80002c48:	009d04bb          	addw	s1,s10,s1
    80002c4c:	9a6e                	add	s4,s4,s11
    80002c4e:	0559f163          	bgeu	s3,s5,80002c90 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80002c52:	00a4d59b          	srliw	a1,s1,0xa
    80002c56:	855a                	mv	a0,s6
    80002c58:	987ff0ef          	jal	ra,800025de <bmap>
    80002c5c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002c60:	c985                	beqz	a1,80002c90 <readi+0xba>
    bp = bread(ip->dev, addr);
    80002c62:	000b2503          	lw	a0,0(s6)
    80002c66:	e04ff0ef          	jal	ra,8000226a <bread>
    80002c6a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c6c:	3ff4f713          	andi	a4,s1,1023
    80002c70:	40ec87bb          	subw	a5,s9,a4
    80002c74:	413a86bb          	subw	a3,s5,s3
    80002c78:	8d3e                	mv	s10,a5
    80002c7a:	2781                	sext.w	a5,a5
    80002c7c:	0006861b          	sext.w	a2,a3
    80002c80:	faf671e3          	bgeu	a2,a5,80002c22 <readi+0x4c>
    80002c84:	8d36                	mv	s10,a3
    80002c86:	bf71                	j	80002c22 <readi+0x4c>
      brelse(bp);
    80002c88:	854a                	mv	a0,s2
    80002c8a:	ee8ff0ef          	jal	ra,80002372 <brelse>
      tot = -1;
    80002c8e:	59fd                	li	s3,-1
  }
  return tot;
    80002c90:	0009851b          	sext.w	a0,s3
}
    80002c94:	70a6                	ld	ra,104(sp)
    80002c96:	7406                	ld	s0,96(sp)
    80002c98:	64e6                	ld	s1,88(sp)
    80002c9a:	6946                	ld	s2,80(sp)
    80002c9c:	69a6                	ld	s3,72(sp)
    80002c9e:	6a06                	ld	s4,64(sp)
    80002ca0:	7ae2                	ld	s5,56(sp)
    80002ca2:	7b42                	ld	s6,48(sp)
    80002ca4:	7ba2                	ld	s7,40(sp)
    80002ca6:	7c02                	ld	s8,32(sp)
    80002ca8:	6ce2                	ld	s9,24(sp)
    80002caa:	6d42                	ld	s10,16(sp)
    80002cac:	6da2                	ld	s11,8(sp)
    80002cae:	6165                	addi	sp,sp,112
    80002cb0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002cb2:	89d6                	mv	s3,s5
    80002cb4:	bff1                	j	80002c90 <readi+0xba>
    return 0;
    80002cb6:	4501                	li	a0,0
}
    80002cb8:	8082                	ret

0000000080002cba <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002cba:	457c                	lw	a5,76(a0)
    80002cbc:	0ed7ea63          	bltu	a5,a3,80002db0 <writei+0xf6>
{
    80002cc0:	7159                	addi	sp,sp,-112
    80002cc2:	f486                	sd	ra,104(sp)
    80002cc4:	f0a2                	sd	s0,96(sp)
    80002cc6:	eca6                	sd	s1,88(sp)
    80002cc8:	e8ca                	sd	s2,80(sp)
    80002cca:	e4ce                	sd	s3,72(sp)
    80002ccc:	e0d2                	sd	s4,64(sp)
    80002cce:	fc56                	sd	s5,56(sp)
    80002cd0:	f85a                	sd	s6,48(sp)
    80002cd2:	f45e                	sd	s7,40(sp)
    80002cd4:	f062                	sd	s8,32(sp)
    80002cd6:	ec66                	sd	s9,24(sp)
    80002cd8:	e86a                	sd	s10,16(sp)
    80002cda:	e46e                	sd	s11,8(sp)
    80002cdc:	1880                	addi	s0,sp,112
    80002cde:	8aaa                	mv	s5,a0
    80002ce0:	8bae                	mv	s7,a1
    80002ce2:	8a32                	mv	s4,a2
    80002ce4:	8936                	mv	s2,a3
    80002ce6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002ce8:	00e687bb          	addw	a5,a3,a4
    80002cec:	0cd7e463          	bltu	a5,a3,80002db4 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002cf0:	00043737          	lui	a4,0x43
    80002cf4:	0cf76263          	bltu	a4,a5,80002db8 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002cf8:	0a0b0a63          	beqz	s6,80002dac <writei+0xf2>
    80002cfc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002cfe:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002d02:	5c7d                	li	s8,-1
    80002d04:	a825                	j	80002d3c <writei+0x82>
    80002d06:	020d1d93          	slli	s11,s10,0x20
    80002d0a:	020ddd93          	srli	s11,s11,0x20
    80002d0e:	05848513          	addi	a0,s1,88
    80002d12:	86ee                	mv	a3,s11
    80002d14:	8652                	mv	a2,s4
    80002d16:	85de                	mv	a1,s7
    80002d18:	953a                	add	a0,a0,a4
    80002d1a:	cd1fe0ef          	jal	ra,800019ea <either_copyin>
    80002d1e:	05850a63          	beq	a0,s8,80002d72 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002d22:	8526                	mv	a0,s1
    80002d24:	678000ef          	jal	ra,8000339c <log_write>
    brelse(bp);
    80002d28:	8526                	mv	a0,s1
    80002d2a:	e48ff0ef          	jal	ra,80002372 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002d2e:	013d09bb          	addw	s3,s10,s3
    80002d32:	012d093b          	addw	s2,s10,s2
    80002d36:	9a6e                	add	s4,s4,s11
    80002d38:	0569f063          	bgeu	s3,s6,80002d78 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002d3c:	00a9559b          	srliw	a1,s2,0xa
    80002d40:	8556                	mv	a0,s5
    80002d42:	89dff0ef          	jal	ra,800025de <bmap>
    80002d46:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002d4a:	c59d                	beqz	a1,80002d78 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002d4c:	000aa503          	lw	a0,0(s5)
    80002d50:	d1aff0ef          	jal	ra,8000226a <bread>
    80002d54:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002d56:	3ff97713          	andi	a4,s2,1023
    80002d5a:	40ec87bb          	subw	a5,s9,a4
    80002d5e:	413b06bb          	subw	a3,s6,s3
    80002d62:	8d3e                	mv	s10,a5
    80002d64:	2781                	sext.w	a5,a5
    80002d66:	0006861b          	sext.w	a2,a3
    80002d6a:	f8f67ee3          	bgeu	a2,a5,80002d06 <writei+0x4c>
    80002d6e:	8d36                	mv	s10,a3
    80002d70:	bf59                	j	80002d06 <writei+0x4c>
      brelse(bp);
    80002d72:	8526                	mv	a0,s1
    80002d74:	dfeff0ef          	jal	ra,80002372 <brelse>
  }

  if(off > ip->size)
    80002d78:	04caa783          	lw	a5,76(s5)
    80002d7c:	0127f463          	bgeu	a5,s2,80002d84 <writei+0xca>
    ip->size = off;
    80002d80:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002d84:	8556                	mv	a0,s5
    80002d86:	b4dff0ef          	jal	ra,800028d2 <iupdate>

  return tot;
    80002d8a:	0009851b          	sext.w	a0,s3
}
    80002d8e:	70a6                	ld	ra,104(sp)
    80002d90:	7406                	ld	s0,96(sp)
    80002d92:	64e6                	ld	s1,88(sp)
    80002d94:	6946                	ld	s2,80(sp)
    80002d96:	69a6                	ld	s3,72(sp)
    80002d98:	6a06                	ld	s4,64(sp)
    80002d9a:	7ae2                	ld	s5,56(sp)
    80002d9c:	7b42                	ld	s6,48(sp)
    80002d9e:	7ba2                	ld	s7,40(sp)
    80002da0:	7c02                	ld	s8,32(sp)
    80002da2:	6ce2                	ld	s9,24(sp)
    80002da4:	6d42                	ld	s10,16(sp)
    80002da6:	6da2                	ld	s11,8(sp)
    80002da8:	6165                	addi	sp,sp,112
    80002daa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002dac:	89da                	mv	s3,s6
    80002dae:	bfd9                	j	80002d84 <writei+0xca>
    return -1;
    80002db0:	557d                	li	a0,-1
}
    80002db2:	8082                	ret
    return -1;
    80002db4:	557d                	li	a0,-1
    80002db6:	bfe1                	j	80002d8e <writei+0xd4>
    return -1;
    80002db8:	557d                	li	a0,-1
    80002dba:	bfd1                	j	80002d8e <writei+0xd4>

0000000080002dbc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002dbc:	1141                	addi	sp,sp,-16
    80002dbe:	e406                	sd	ra,8(sp)
    80002dc0:	e022                	sd	s0,0(sp)
    80002dc2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002dc4:	4639                	li	a2,14
    80002dc6:	db8fd0ef          	jal	ra,8000037e <strncmp>
}
    80002dca:	60a2                	ld	ra,8(sp)
    80002dcc:	6402                	ld	s0,0(sp)
    80002dce:	0141                	addi	sp,sp,16
    80002dd0:	8082                	ret

0000000080002dd2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002dd2:	7139                	addi	sp,sp,-64
    80002dd4:	fc06                	sd	ra,56(sp)
    80002dd6:	f822                	sd	s0,48(sp)
    80002dd8:	f426                	sd	s1,40(sp)
    80002dda:	f04a                	sd	s2,32(sp)
    80002ddc:	ec4e                	sd	s3,24(sp)
    80002dde:	e852                	sd	s4,16(sp)
    80002de0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002de2:	04451703          	lh	a4,68(a0)
    80002de6:	4785                	li	a5,1
    80002de8:	00f71a63          	bne	a4,a5,80002dfc <dirlookup+0x2a>
    80002dec:	892a                	mv	s2,a0
    80002dee:	89ae                	mv	s3,a1
    80002df0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002df2:	457c                	lw	a5,76(a0)
    80002df4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002df6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002df8:	e39d                	bnez	a5,80002e1e <dirlookup+0x4c>
    80002dfa:	a095                	j	80002e5e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002dfc:	00005517          	auipc	a0,0x5
    80002e00:	93c50513          	addi	a0,a0,-1732 # 80007738 <syscalls+0x208>
    80002e04:	7fe020ef          	jal	ra,80005602 <panic>
      panic("dirlookup read");
    80002e08:	00005517          	auipc	a0,0x5
    80002e0c:	94850513          	addi	a0,a0,-1720 # 80007750 <syscalls+0x220>
    80002e10:	7f2020ef          	jal	ra,80005602 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e14:	24c1                	addiw	s1,s1,16
    80002e16:	04c92783          	lw	a5,76(s2)
    80002e1a:	04f4f163          	bgeu	s1,a5,80002e5c <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e1e:	4741                	li	a4,16
    80002e20:	86a6                	mv	a3,s1
    80002e22:	fc040613          	addi	a2,s0,-64
    80002e26:	4581                	li	a1,0
    80002e28:	854a                	mv	a0,s2
    80002e2a:	dadff0ef          	jal	ra,80002bd6 <readi>
    80002e2e:	47c1                	li	a5,16
    80002e30:	fcf51ce3          	bne	a0,a5,80002e08 <dirlookup+0x36>
    if(de.inum == 0)
    80002e34:	fc045783          	lhu	a5,-64(s0)
    80002e38:	dff1                	beqz	a5,80002e14 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002e3a:	fc240593          	addi	a1,s0,-62
    80002e3e:	854e                	mv	a0,s3
    80002e40:	f7dff0ef          	jal	ra,80002dbc <namecmp>
    80002e44:	f961                	bnez	a0,80002e14 <dirlookup+0x42>
      if(poff)
    80002e46:	000a0463          	beqz	s4,80002e4e <dirlookup+0x7c>
        *poff = off;
    80002e4a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002e4e:	fc045583          	lhu	a1,-64(s0)
    80002e52:	00092503          	lw	a0,0(s2)
    80002e56:	857ff0ef          	jal	ra,800026ac <iget>
    80002e5a:	a011                	j	80002e5e <dirlookup+0x8c>
  return 0;
    80002e5c:	4501                	li	a0,0
}
    80002e5e:	70e2                	ld	ra,56(sp)
    80002e60:	7442                	ld	s0,48(sp)
    80002e62:	74a2                	ld	s1,40(sp)
    80002e64:	7902                	ld	s2,32(sp)
    80002e66:	69e2                	ld	s3,24(sp)
    80002e68:	6a42                	ld	s4,16(sp)
    80002e6a:	6121                	addi	sp,sp,64
    80002e6c:	8082                	ret

0000000080002e6e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002e6e:	711d                	addi	sp,sp,-96
    80002e70:	ec86                	sd	ra,88(sp)
    80002e72:	e8a2                	sd	s0,80(sp)
    80002e74:	e4a6                	sd	s1,72(sp)
    80002e76:	e0ca                	sd	s2,64(sp)
    80002e78:	fc4e                	sd	s3,56(sp)
    80002e7a:	f852                	sd	s4,48(sp)
    80002e7c:	f456                	sd	s5,40(sp)
    80002e7e:	f05a                	sd	s6,32(sp)
    80002e80:	ec5e                	sd	s7,24(sp)
    80002e82:	e862                	sd	s8,16(sp)
    80002e84:	e466                	sd	s9,8(sp)
    80002e86:	e06a                	sd	s10,0(sp)
    80002e88:	1080                	addi	s0,sp,96
    80002e8a:	84aa                	mv	s1,a0
    80002e8c:	8b2e                	mv	s6,a1
    80002e8e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002e90:	00054703          	lbu	a4,0(a0)
    80002e94:	02f00793          	li	a5,47
    80002e98:	00f70f63          	beq	a4,a5,80002eb6 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002e9c:	9dcfe0ef          	jal	ra,80001078 <myproc>
    80002ea0:	15053503          	ld	a0,336(a0)
    80002ea4:	aadff0ef          	jal	ra,80002950 <idup>
    80002ea8:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002eaa:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002eae:	4cb5                	li	s9,13
  len = path - s;
    80002eb0:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002eb2:	4c05                	li	s8,1
    80002eb4:	a879                	j	80002f52 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80002eb6:	4585                	li	a1,1
    80002eb8:	4505                	li	a0,1
    80002eba:	ff2ff0ef          	jal	ra,800026ac <iget>
    80002ebe:	8a2a                	mv	s4,a0
    80002ec0:	b7ed                	j	80002eaa <namex+0x3c>
      iunlockput(ip);
    80002ec2:	8552                	mv	a0,s4
    80002ec4:	cc9ff0ef          	jal	ra,80002b8c <iunlockput>
      return 0;
    80002ec8:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002eca:	8552                	mv	a0,s4
    80002ecc:	60e6                	ld	ra,88(sp)
    80002ece:	6446                	ld	s0,80(sp)
    80002ed0:	64a6                	ld	s1,72(sp)
    80002ed2:	6906                	ld	s2,64(sp)
    80002ed4:	79e2                	ld	s3,56(sp)
    80002ed6:	7a42                	ld	s4,48(sp)
    80002ed8:	7aa2                	ld	s5,40(sp)
    80002eda:	7b02                	ld	s6,32(sp)
    80002edc:	6be2                	ld	s7,24(sp)
    80002ede:	6c42                	ld	s8,16(sp)
    80002ee0:	6ca2                	ld	s9,8(sp)
    80002ee2:	6d02                	ld	s10,0(sp)
    80002ee4:	6125                	addi	sp,sp,96
    80002ee6:	8082                	ret
      iunlock(ip);
    80002ee8:	8552                	mv	a0,s4
    80002eea:	b47ff0ef          	jal	ra,80002a30 <iunlock>
      return ip;
    80002eee:	bff1                	j	80002eca <namex+0x5c>
      iunlockput(ip);
    80002ef0:	8552                	mv	a0,s4
    80002ef2:	c9bff0ef          	jal	ra,80002b8c <iunlockput>
      return 0;
    80002ef6:	8a4e                	mv	s4,s3
    80002ef8:	bfc9                	j	80002eca <namex+0x5c>
  len = path - s;
    80002efa:	40998633          	sub	a2,s3,s1
    80002efe:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80002f02:	09acd063          	bge	s9,s10,80002f82 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80002f06:	4639                	li	a2,14
    80002f08:	85a6                	mv	a1,s1
    80002f0a:	8556                	mv	a0,s5
    80002f0c:	c02fd0ef          	jal	ra,8000030e <memmove>
    80002f10:	84ce                	mv	s1,s3
  while(*path == '/')
    80002f12:	0004c783          	lbu	a5,0(s1)
    80002f16:	01279763          	bne	a5,s2,80002f24 <namex+0xb6>
    path++;
    80002f1a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002f1c:	0004c783          	lbu	a5,0(s1)
    80002f20:	ff278de3          	beq	a5,s2,80002f1a <namex+0xac>
    ilock(ip);
    80002f24:	8552                	mv	a0,s4
    80002f26:	a61ff0ef          	jal	ra,80002986 <ilock>
    if(ip->type != T_DIR){
    80002f2a:	044a1783          	lh	a5,68(s4)
    80002f2e:	f9879ae3          	bne	a5,s8,80002ec2 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80002f32:	000b0563          	beqz	s6,80002f3c <namex+0xce>
    80002f36:	0004c783          	lbu	a5,0(s1)
    80002f3a:	d7dd                	beqz	a5,80002ee8 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002f3c:	865e                	mv	a2,s7
    80002f3e:	85d6                	mv	a1,s5
    80002f40:	8552                	mv	a0,s4
    80002f42:	e91ff0ef          	jal	ra,80002dd2 <dirlookup>
    80002f46:	89aa                	mv	s3,a0
    80002f48:	d545                	beqz	a0,80002ef0 <namex+0x82>
    iunlockput(ip);
    80002f4a:	8552                	mv	a0,s4
    80002f4c:	c41ff0ef          	jal	ra,80002b8c <iunlockput>
    ip = next;
    80002f50:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002f52:	0004c783          	lbu	a5,0(s1)
    80002f56:	01279763          	bne	a5,s2,80002f64 <namex+0xf6>
    path++;
    80002f5a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002f5c:	0004c783          	lbu	a5,0(s1)
    80002f60:	ff278de3          	beq	a5,s2,80002f5a <namex+0xec>
  if(*path == 0)
    80002f64:	cb8d                	beqz	a5,80002f96 <namex+0x128>
  while(*path != '/' && *path != 0)
    80002f66:	0004c783          	lbu	a5,0(s1)
    80002f6a:	89a6                	mv	s3,s1
  len = path - s;
    80002f6c:	8d5e                	mv	s10,s7
    80002f6e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80002f70:	01278963          	beq	a5,s2,80002f82 <namex+0x114>
    80002f74:	d3d9                	beqz	a5,80002efa <namex+0x8c>
    path++;
    80002f76:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002f78:	0009c783          	lbu	a5,0(s3)
    80002f7c:	ff279ce3          	bne	a5,s2,80002f74 <namex+0x106>
    80002f80:	bfad                	j	80002efa <namex+0x8c>
    memmove(name, s, len);
    80002f82:	2601                	sext.w	a2,a2
    80002f84:	85a6                	mv	a1,s1
    80002f86:	8556                	mv	a0,s5
    80002f88:	b86fd0ef          	jal	ra,8000030e <memmove>
    name[len] = 0;
    80002f8c:	9d56                	add	s10,s10,s5
    80002f8e:	000d0023          	sb	zero,0(s10)
    80002f92:	84ce                	mv	s1,s3
    80002f94:	bfbd                	j	80002f12 <namex+0xa4>
  if(nameiparent){
    80002f96:	f20b0ae3          	beqz	s6,80002eca <namex+0x5c>
    iput(ip);
    80002f9a:	8552                	mv	a0,s4
    80002f9c:	b69ff0ef          	jal	ra,80002b04 <iput>
    return 0;
    80002fa0:	4a01                	li	s4,0
    80002fa2:	b725                	j	80002eca <namex+0x5c>

0000000080002fa4 <dirlink>:
{
    80002fa4:	7139                	addi	sp,sp,-64
    80002fa6:	fc06                	sd	ra,56(sp)
    80002fa8:	f822                	sd	s0,48(sp)
    80002faa:	f426                	sd	s1,40(sp)
    80002fac:	f04a                	sd	s2,32(sp)
    80002fae:	ec4e                	sd	s3,24(sp)
    80002fb0:	e852                	sd	s4,16(sp)
    80002fb2:	0080                	addi	s0,sp,64
    80002fb4:	892a                	mv	s2,a0
    80002fb6:	8a2e                	mv	s4,a1
    80002fb8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002fba:	4601                	li	a2,0
    80002fbc:	e17ff0ef          	jal	ra,80002dd2 <dirlookup>
    80002fc0:	e52d                	bnez	a0,8000302a <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002fc2:	04c92483          	lw	s1,76(s2)
    80002fc6:	c48d                	beqz	s1,80002ff0 <dirlink+0x4c>
    80002fc8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002fca:	4741                	li	a4,16
    80002fcc:	86a6                	mv	a3,s1
    80002fce:	fc040613          	addi	a2,s0,-64
    80002fd2:	4581                	li	a1,0
    80002fd4:	854a                	mv	a0,s2
    80002fd6:	c01ff0ef          	jal	ra,80002bd6 <readi>
    80002fda:	47c1                	li	a5,16
    80002fdc:	04f51b63          	bne	a0,a5,80003032 <dirlink+0x8e>
    if(de.inum == 0)
    80002fe0:	fc045783          	lhu	a5,-64(s0)
    80002fe4:	c791                	beqz	a5,80002ff0 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002fe6:	24c1                	addiw	s1,s1,16
    80002fe8:	04c92783          	lw	a5,76(s2)
    80002fec:	fcf4efe3          	bltu	s1,a5,80002fca <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002ff0:	4639                	li	a2,14
    80002ff2:	85d2                	mv	a1,s4
    80002ff4:	fc240513          	addi	a0,s0,-62
    80002ff8:	bc2fd0ef          	jal	ra,800003ba <strncpy>
  de.inum = inum;
    80002ffc:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003000:	4741                	li	a4,16
    80003002:	86a6                	mv	a3,s1
    80003004:	fc040613          	addi	a2,s0,-64
    80003008:	4581                	li	a1,0
    8000300a:	854a                	mv	a0,s2
    8000300c:	cafff0ef          	jal	ra,80002cba <writei>
    80003010:	1541                	addi	a0,a0,-16
    80003012:	00a03533          	snez	a0,a0
    80003016:	40a00533          	neg	a0,a0
}
    8000301a:	70e2                	ld	ra,56(sp)
    8000301c:	7442                	ld	s0,48(sp)
    8000301e:	74a2                	ld	s1,40(sp)
    80003020:	7902                	ld	s2,32(sp)
    80003022:	69e2                	ld	s3,24(sp)
    80003024:	6a42                	ld	s4,16(sp)
    80003026:	6121                	addi	sp,sp,64
    80003028:	8082                	ret
    iput(ip);
    8000302a:	adbff0ef          	jal	ra,80002b04 <iput>
    return -1;
    8000302e:	557d                	li	a0,-1
    80003030:	b7ed                	j	8000301a <dirlink+0x76>
      panic("dirlink read");
    80003032:	00004517          	auipc	a0,0x4
    80003036:	72e50513          	addi	a0,a0,1838 # 80007760 <syscalls+0x230>
    8000303a:	5c8020ef          	jal	ra,80005602 <panic>

000000008000303e <namei>:

struct inode*
namei(char *path)
{
    8000303e:	1101                	addi	sp,sp,-32
    80003040:	ec06                	sd	ra,24(sp)
    80003042:	e822                	sd	s0,16(sp)
    80003044:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003046:	fe040613          	addi	a2,s0,-32
    8000304a:	4581                	li	a1,0
    8000304c:	e23ff0ef          	jal	ra,80002e6e <namex>
}
    80003050:	60e2                	ld	ra,24(sp)
    80003052:	6442                	ld	s0,16(sp)
    80003054:	6105                	addi	sp,sp,32
    80003056:	8082                	ret

0000000080003058 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003058:	1141                	addi	sp,sp,-16
    8000305a:	e406                	sd	ra,8(sp)
    8000305c:	e022                	sd	s0,0(sp)
    8000305e:	0800                	addi	s0,sp,16
    80003060:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003062:	4585                	li	a1,1
    80003064:	e0bff0ef          	jal	ra,80002e6e <namex>
}
    80003068:	60a2                	ld	ra,8(sp)
    8000306a:	6402                	ld	s0,0(sp)
    8000306c:	0141                	addi	sp,sp,16
    8000306e:	8082                	ret

0000000080003070 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003070:	1101                	addi	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	e426                	sd	s1,8(sp)
    80003078:	e04a                	sd	s2,0(sp)
    8000307a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000307c:	00015917          	auipc	s2,0x15
    80003080:	c1490913          	addi	s2,s2,-1004 # 80017c90 <log>
    80003084:	01892583          	lw	a1,24(s2)
    80003088:	02892503          	lw	a0,40(s2)
    8000308c:	9deff0ef          	jal	ra,8000226a <bread>
    80003090:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003092:	02c92683          	lw	a3,44(s2)
    80003096:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003098:	02d05863          	blez	a3,800030c8 <write_head+0x58>
    8000309c:	00015797          	auipc	a5,0x15
    800030a0:	c2478793          	addi	a5,a5,-988 # 80017cc0 <log+0x30>
    800030a4:	05c50713          	addi	a4,a0,92
    800030a8:	36fd                	addiw	a3,a3,-1
    800030aa:	02069613          	slli	a2,a3,0x20
    800030ae:	01e65693          	srli	a3,a2,0x1e
    800030b2:	00015617          	auipc	a2,0x15
    800030b6:	c1260613          	addi	a2,a2,-1006 # 80017cc4 <log+0x34>
    800030ba:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800030bc:	4390                	lw	a2,0(a5)
    800030be:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800030c0:	0791                	addi	a5,a5,4
    800030c2:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800030c4:	fed79ce3          	bne	a5,a3,800030bc <write_head+0x4c>
  }
  bwrite(buf);
    800030c8:	8526                	mv	a0,s1
    800030ca:	a76ff0ef          	jal	ra,80002340 <bwrite>
  brelse(buf);
    800030ce:	8526                	mv	a0,s1
    800030d0:	aa2ff0ef          	jal	ra,80002372 <brelse>
}
    800030d4:	60e2                	ld	ra,24(sp)
    800030d6:	6442                	ld	s0,16(sp)
    800030d8:	64a2                	ld	s1,8(sp)
    800030da:	6902                	ld	s2,0(sp)
    800030dc:	6105                	addi	sp,sp,32
    800030de:	8082                	ret

00000000800030e0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800030e0:	00015797          	auipc	a5,0x15
    800030e4:	bdc7a783          	lw	a5,-1060(a5) # 80017cbc <log+0x2c>
    800030e8:	08f05f63          	blez	a5,80003186 <install_trans+0xa6>
{
    800030ec:	7139                	addi	sp,sp,-64
    800030ee:	fc06                	sd	ra,56(sp)
    800030f0:	f822                	sd	s0,48(sp)
    800030f2:	f426                	sd	s1,40(sp)
    800030f4:	f04a                	sd	s2,32(sp)
    800030f6:	ec4e                	sd	s3,24(sp)
    800030f8:	e852                	sd	s4,16(sp)
    800030fa:	e456                	sd	s5,8(sp)
    800030fc:	e05a                	sd	s6,0(sp)
    800030fe:	0080                	addi	s0,sp,64
    80003100:	8b2a                	mv	s6,a0
    80003102:	00015a97          	auipc	s5,0x15
    80003106:	bbea8a93          	addi	s5,s5,-1090 # 80017cc0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000310a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000310c:	00015997          	auipc	s3,0x15
    80003110:	b8498993          	addi	s3,s3,-1148 # 80017c90 <log>
    80003114:	a829                	j	8000312e <install_trans+0x4e>
    brelse(lbuf);
    80003116:	854a                	mv	a0,s2
    80003118:	a5aff0ef          	jal	ra,80002372 <brelse>
    brelse(dbuf);
    8000311c:	8526                	mv	a0,s1
    8000311e:	a54ff0ef          	jal	ra,80002372 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003122:	2a05                	addiw	s4,s4,1
    80003124:	0a91                	addi	s5,s5,4
    80003126:	02c9a783          	lw	a5,44(s3)
    8000312a:	04fa5463          	bge	s4,a5,80003172 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000312e:	0189a583          	lw	a1,24(s3)
    80003132:	014585bb          	addw	a1,a1,s4
    80003136:	2585                	addiw	a1,a1,1
    80003138:	0289a503          	lw	a0,40(s3)
    8000313c:	92eff0ef          	jal	ra,8000226a <bread>
    80003140:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003142:	000aa583          	lw	a1,0(s5)
    80003146:	0289a503          	lw	a0,40(s3)
    8000314a:	920ff0ef          	jal	ra,8000226a <bread>
    8000314e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003150:	40000613          	li	a2,1024
    80003154:	05890593          	addi	a1,s2,88
    80003158:	05850513          	addi	a0,a0,88
    8000315c:	9b2fd0ef          	jal	ra,8000030e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003160:	8526                	mv	a0,s1
    80003162:	9deff0ef          	jal	ra,80002340 <bwrite>
    if(recovering == 0)
    80003166:	fa0b18e3          	bnez	s6,80003116 <install_trans+0x36>
      bunpin(dbuf);
    8000316a:	8526                	mv	a0,s1
    8000316c:	ac4ff0ef          	jal	ra,80002430 <bunpin>
    80003170:	b75d                	j	80003116 <install_trans+0x36>
}
    80003172:	70e2                	ld	ra,56(sp)
    80003174:	7442                	ld	s0,48(sp)
    80003176:	74a2                	ld	s1,40(sp)
    80003178:	7902                	ld	s2,32(sp)
    8000317a:	69e2                	ld	s3,24(sp)
    8000317c:	6a42                	ld	s4,16(sp)
    8000317e:	6aa2                	ld	s5,8(sp)
    80003180:	6b02                	ld	s6,0(sp)
    80003182:	6121                	addi	sp,sp,64
    80003184:	8082                	ret
    80003186:	8082                	ret

0000000080003188 <initlog>:
{
    80003188:	7179                	addi	sp,sp,-48
    8000318a:	f406                	sd	ra,40(sp)
    8000318c:	f022                	sd	s0,32(sp)
    8000318e:	ec26                	sd	s1,24(sp)
    80003190:	e84a                	sd	s2,16(sp)
    80003192:	e44e                	sd	s3,8(sp)
    80003194:	1800                	addi	s0,sp,48
    80003196:	892a                	mv	s2,a0
    80003198:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000319a:	00015497          	auipc	s1,0x15
    8000319e:	af648493          	addi	s1,s1,-1290 # 80017c90 <log>
    800031a2:	00004597          	auipc	a1,0x4
    800031a6:	5ce58593          	addi	a1,a1,1486 # 80007770 <syscalls+0x240>
    800031aa:	8526                	mv	a0,s1
    800031ac:	6e6020ef          	jal	ra,80005892 <initlock>
  log.start = sb->logstart;
    800031b0:	0149a583          	lw	a1,20(s3)
    800031b4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800031b6:	0109a783          	lw	a5,16(s3)
    800031ba:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800031bc:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800031c0:	854a                	mv	a0,s2
    800031c2:	8a8ff0ef          	jal	ra,8000226a <bread>
  log.lh.n = lh->n;
    800031c6:	4d34                	lw	a3,88(a0)
    800031c8:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800031ca:	02d05663          	blez	a3,800031f6 <initlog+0x6e>
    800031ce:	05c50793          	addi	a5,a0,92
    800031d2:	00015717          	auipc	a4,0x15
    800031d6:	aee70713          	addi	a4,a4,-1298 # 80017cc0 <log+0x30>
    800031da:	36fd                	addiw	a3,a3,-1
    800031dc:	02069613          	slli	a2,a3,0x20
    800031e0:	01e65693          	srli	a3,a2,0x1e
    800031e4:	06050613          	addi	a2,a0,96
    800031e8:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800031ea:	4390                	lw	a2,0(a5)
    800031ec:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800031ee:	0791                	addi	a5,a5,4
    800031f0:	0711                	addi	a4,a4,4
    800031f2:	fed79ce3          	bne	a5,a3,800031ea <initlog+0x62>
  brelse(buf);
    800031f6:	97cff0ef          	jal	ra,80002372 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800031fa:	4505                	li	a0,1
    800031fc:	ee5ff0ef          	jal	ra,800030e0 <install_trans>
  log.lh.n = 0;
    80003200:	00015797          	auipc	a5,0x15
    80003204:	aa07ae23          	sw	zero,-1348(a5) # 80017cbc <log+0x2c>
  write_head(); // clear the log
    80003208:	e69ff0ef          	jal	ra,80003070 <write_head>
}
    8000320c:	70a2                	ld	ra,40(sp)
    8000320e:	7402                	ld	s0,32(sp)
    80003210:	64e2                	ld	s1,24(sp)
    80003212:	6942                	ld	s2,16(sp)
    80003214:	69a2                	ld	s3,8(sp)
    80003216:	6145                	addi	sp,sp,48
    80003218:	8082                	ret

000000008000321a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000321a:	1101                	addi	sp,sp,-32
    8000321c:	ec06                	sd	ra,24(sp)
    8000321e:	e822                	sd	s0,16(sp)
    80003220:	e426                	sd	s1,8(sp)
    80003222:	e04a                	sd	s2,0(sp)
    80003224:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003226:	00015517          	auipc	a0,0x15
    8000322a:	a6a50513          	addi	a0,a0,-1430 # 80017c90 <log>
    8000322e:	6e4020ef          	jal	ra,80005912 <acquire>
  while(1){
    if(log.committing){
    80003232:	00015497          	auipc	s1,0x15
    80003236:	a5e48493          	addi	s1,s1,-1442 # 80017c90 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000323a:	4979                	li	s2,30
    8000323c:	a029                	j	80003246 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000323e:	85a6                	mv	a1,s1
    80003240:	8526                	mv	a0,s1
    80003242:	c02fe0ef          	jal	ra,80001644 <sleep>
    if(log.committing){
    80003246:	50dc                	lw	a5,36(s1)
    80003248:	fbfd                	bnez	a5,8000323e <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000324a:	5098                	lw	a4,32(s1)
    8000324c:	2705                	addiw	a4,a4,1
    8000324e:	0007069b          	sext.w	a3,a4
    80003252:	0027179b          	slliw	a5,a4,0x2
    80003256:	9fb9                	addw	a5,a5,a4
    80003258:	0017979b          	slliw	a5,a5,0x1
    8000325c:	54d8                	lw	a4,44(s1)
    8000325e:	9fb9                	addw	a5,a5,a4
    80003260:	00f95763          	bge	s2,a5,8000326e <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003264:	85a6                	mv	a1,s1
    80003266:	8526                	mv	a0,s1
    80003268:	bdcfe0ef          	jal	ra,80001644 <sleep>
    8000326c:	bfe9                	j	80003246 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000326e:	00015517          	auipc	a0,0x15
    80003272:	a2250513          	addi	a0,a0,-1502 # 80017c90 <log>
    80003276:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80003278:	732020ef          	jal	ra,800059aa <release>
      break;
    }
  }
}
    8000327c:	60e2                	ld	ra,24(sp)
    8000327e:	6442                	ld	s0,16(sp)
    80003280:	64a2                	ld	s1,8(sp)
    80003282:	6902                	ld	s2,0(sp)
    80003284:	6105                	addi	sp,sp,32
    80003286:	8082                	ret

0000000080003288 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003288:	7139                	addi	sp,sp,-64
    8000328a:	fc06                	sd	ra,56(sp)
    8000328c:	f822                	sd	s0,48(sp)
    8000328e:	f426                	sd	s1,40(sp)
    80003290:	f04a                	sd	s2,32(sp)
    80003292:	ec4e                	sd	s3,24(sp)
    80003294:	e852                	sd	s4,16(sp)
    80003296:	e456                	sd	s5,8(sp)
    80003298:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000329a:	00015497          	auipc	s1,0x15
    8000329e:	9f648493          	addi	s1,s1,-1546 # 80017c90 <log>
    800032a2:	8526                	mv	a0,s1
    800032a4:	66e020ef          	jal	ra,80005912 <acquire>
  log.outstanding -= 1;
    800032a8:	509c                	lw	a5,32(s1)
    800032aa:	37fd                	addiw	a5,a5,-1
    800032ac:	0007891b          	sext.w	s2,a5
    800032b0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800032b2:	50dc                	lw	a5,36(s1)
    800032b4:	ef9d                	bnez	a5,800032f2 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    800032b6:	04091463          	bnez	s2,800032fe <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800032ba:	00015497          	auipc	s1,0x15
    800032be:	9d648493          	addi	s1,s1,-1578 # 80017c90 <log>
    800032c2:	4785                	li	a5,1
    800032c4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800032c6:	8526                	mv	a0,s1
    800032c8:	6e2020ef          	jal	ra,800059aa <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800032cc:	54dc                	lw	a5,44(s1)
    800032ce:	04f04b63          	bgtz	a5,80003324 <end_op+0x9c>
    acquire(&log.lock);
    800032d2:	00015497          	auipc	s1,0x15
    800032d6:	9be48493          	addi	s1,s1,-1602 # 80017c90 <log>
    800032da:	8526                	mv	a0,s1
    800032dc:	636020ef          	jal	ra,80005912 <acquire>
    log.committing = 0;
    800032e0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800032e4:	8526                	mv	a0,s1
    800032e6:	baafe0ef          	jal	ra,80001690 <wakeup>
    release(&log.lock);
    800032ea:	8526                	mv	a0,s1
    800032ec:	6be020ef          	jal	ra,800059aa <release>
}
    800032f0:	a00d                	j	80003312 <end_op+0x8a>
    panic("log.committing");
    800032f2:	00004517          	auipc	a0,0x4
    800032f6:	48650513          	addi	a0,a0,1158 # 80007778 <syscalls+0x248>
    800032fa:	308020ef          	jal	ra,80005602 <panic>
    wakeup(&log);
    800032fe:	00015497          	auipc	s1,0x15
    80003302:	99248493          	addi	s1,s1,-1646 # 80017c90 <log>
    80003306:	8526                	mv	a0,s1
    80003308:	b88fe0ef          	jal	ra,80001690 <wakeup>
  release(&log.lock);
    8000330c:	8526                	mv	a0,s1
    8000330e:	69c020ef          	jal	ra,800059aa <release>
}
    80003312:	70e2                	ld	ra,56(sp)
    80003314:	7442                	ld	s0,48(sp)
    80003316:	74a2                	ld	s1,40(sp)
    80003318:	7902                	ld	s2,32(sp)
    8000331a:	69e2                	ld	s3,24(sp)
    8000331c:	6a42                	ld	s4,16(sp)
    8000331e:	6aa2                	ld	s5,8(sp)
    80003320:	6121                	addi	sp,sp,64
    80003322:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003324:	00015a97          	auipc	s5,0x15
    80003328:	99ca8a93          	addi	s5,s5,-1636 # 80017cc0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000332c:	00015a17          	auipc	s4,0x15
    80003330:	964a0a13          	addi	s4,s4,-1692 # 80017c90 <log>
    80003334:	018a2583          	lw	a1,24(s4)
    80003338:	012585bb          	addw	a1,a1,s2
    8000333c:	2585                	addiw	a1,a1,1
    8000333e:	028a2503          	lw	a0,40(s4)
    80003342:	f29fe0ef          	jal	ra,8000226a <bread>
    80003346:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003348:	000aa583          	lw	a1,0(s5)
    8000334c:	028a2503          	lw	a0,40(s4)
    80003350:	f1bfe0ef          	jal	ra,8000226a <bread>
    80003354:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003356:	40000613          	li	a2,1024
    8000335a:	05850593          	addi	a1,a0,88
    8000335e:	05848513          	addi	a0,s1,88
    80003362:	fadfc0ef          	jal	ra,8000030e <memmove>
    bwrite(to);  // write the log
    80003366:	8526                	mv	a0,s1
    80003368:	fd9fe0ef          	jal	ra,80002340 <bwrite>
    brelse(from);
    8000336c:	854e                	mv	a0,s3
    8000336e:	804ff0ef          	jal	ra,80002372 <brelse>
    brelse(to);
    80003372:	8526                	mv	a0,s1
    80003374:	ffffe0ef          	jal	ra,80002372 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003378:	2905                	addiw	s2,s2,1
    8000337a:	0a91                	addi	s5,s5,4
    8000337c:	02ca2783          	lw	a5,44(s4)
    80003380:	faf94ae3          	blt	s2,a5,80003334 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003384:	cedff0ef          	jal	ra,80003070 <write_head>
    install_trans(0); // Now install writes to home locations
    80003388:	4501                	li	a0,0
    8000338a:	d57ff0ef          	jal	ra,800030e0 <install_trans>
    log.lh.n = 0;
    8000338e:	00015797          	auipc	a5,0x15
    80003392:	9207a723          	sw	zero,-1746(a5) # 80017cbc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003396:	cdbff0ef          	jal	ra,80003070 <write_head>
    8000339a:	bf25                	j	800032d2 <end_op+0x4a>

000000008000339c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000339c:	1101                	addi	sp,sp,-32
    8000339e:	ec06                	sd	ra,24(sp)
    800033a0:	e822                	sd	s0,16(sp)
    800033a2:	e426                	sd	s1,8(sp)
    800033a4:	e04a                	sd	s2,0(sp)
    800033a6:	1000                	addi	s0,sp,32
    800033a8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800033aa:	00015917          	auipc	s2,0x15
    800033ae:	8e690913          	addi	s2,s2,-1818 # 80017c90 <log>
    800033b2:	854a                	mv	a0,s2
    800033b4:	55e020ef          	jal	ra,80005912 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800033b8:	02c92603          	lw	a2,44(s2)
    800033bc:	47f5                	li	a5,29
    800033be:	06c7c363          	blt	a5,a2,80003424 <log_write+0x88>
    800033c2:	00015797          	auipc	a5,0x15
    800033c6:	8ea7a783          	lw	a5,-1814(a5) # 80017cac <log+0x1c>
    800033ca:	37fd                	addiw	a5,a5,-1
    800033cc:	04f65c63          	bge	a2,a5,80003424 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800033d0:	00015797          	auipc	a5,0x15
    800033d4:	8e07a783          	lw	a5,-1824(a5) # 80017cb0 <log+0x20>
    800033d8:	04f05c63          	blez	a5,80003430 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800033dc:	4781                	li	a5,0
    800033de:	04c05f63          	blez	a2,8000343c <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800033e2:	44cc                	lw	a1,12(s1)
    800033e4:	00015717          	auipc	a4,0x15
    800033e8:	8dc70713          	addi	a4,a4,-1828 # 80017cc0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800033ec:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800033ee:	4314                	lw	a3,0(a4)
    800033f0:	04b68663          	beq	a3,a1,8000343c <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800033f4:	2785                	addiw	a5,a5,1
    800033f6:	0711                	addi	a4,a4,4
    800033f8:	fef61be3          	bne	a2,a5,800033ee <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    800033fc:	0621                	addi	a2,a2,8
    800033fe:	060a                	slli	a2,a2,0x2
    80003400:	00015797          	auipc	a5,0x15
    80003404:	89078793          	addi	a5,a5,-1904 # 80017c90 <log>
    80003408:	97b2                	add	a5,a5,a2
    8000340a:	44d8                	lw	a4,12(s1)
    8000340c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000340e:	8526                	mv	a0,s1
    80003410:	fedfe0ef          	jal	ra,800023fc <bpin>
    log.lh.n++;
    80003414:	00015717          	auipc	a4,0x15
    80003418:	87c70713          	addi	a4,a4,-1924 # 80017c90 <log>
    8000341c:	575c                	lw	a5,44(a4)
    8000341e:	2785                	addiw	a5,a5,1
    80003420:	d75c                	sw	a5,44(a4)
    80003422:	a80d                	j	80003454 <log_write+0xb8>
    panic("too big a transaction");
    80003424:	00004517          	auipc	a0,0x4
    80003428:	36450513          	addi	a0,a0,868 # 80007788 <syscalls+0x258>
    8000342c:	1d6020ef          	jal	ra,80005602 <panic>
    panic("log_write outside of trans");
    80003430:	00004517          	auipc	a0,0x4
    80003434:	37050513          	addi	a0,a0,880 # 800077a0 <syscalls+0x270>
    80003438:	1ca020ef          	jal	ra,80005602 <panic>
  log.lh.block[i] = b->blockno;
    8000343c:	00878693          	addi	a3,a5,8
    80003440:	068a                	slli	a3,a3,0x2
    80003442:	00015717          	auipc	a4,0x15
    80003446:	84e70713          	addi	a4,a4,-1970 # 80017c90 <log>
    8000344a:	9736                	add	a4,a4,a3
    8000344c:	44d4                	lw	a3,12(s1)
    8000344e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003450:	faf60fe3          	beq	a2,a5,8000340e <log_write+0x72>
  }
  release(&log.lock);
    80003454:	00015517          	auipc	a0,0x15
    80003458:	83c50513          	addi	a0,a0,-1988 # 80017c90 <log>
    8000345c:	54e020ef          	jal	ra,800059aa <release>
}
    80003460:	60e2                	ld	ra,24(sp)
    80003462:	6442                	ld	s0,16(sp)
    80003464:	64a2                	ld	s1,8(sp)
    80003466:	6902                	ld	s2,0(sp)
    80003468:	6105                	addi	sp,sp,32
    8000346a:	8082                	ret

000000008000346c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000346c:	1101                	addi	sp,sp,-32
    8000346e:	ec06                	sd	ra,24(sp)
    80003470:	e822                	sd	s0,16(sp)
    80003472:	e426                	sd	s1,8(sp)
    80003474:	e04a                	sd	s2,0(sp)
    80003476:	1000                	addi	s0,sp,32
    80003478:	84aa                	mv	s1,a0
    8000347a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000347c:	00004597          	auipc	a1,0x4
    80003480:	34458593          	addi	a1,a1,836 # 800077c0 <syscalls+0x290>
    80003484:	0521                	addi	a0,a0,8
    80003486:	40c020ef          	jal	ra,80005892 <initlock>
  lk->name = name;
    8000348a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000348e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003492:	0204a423          	sw	zero,40(s1)
}
    80003496:	60e2                	ld	ra,24(sp)
    80003498:	6442                	ld	s0,16(sp)
    8000349a:	64a2                	ld	s1,8(sp)
    8000349c:	6902                	ld	s2,0(sp)
    8000349e:	6105                	addi	sp,sp,32
    800034a0:	8082                	ret

00000000800034a2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800034a2:	1101                	addi	sp,sp,-32
    800034a4:	ec06                	sd	ra,24(sp)
    800034a6:	e822                	sd	s0,16(sp)
    800034a8:	e426                	sd	s1,8(sp)
    800034aa:	e04a                	sd	s2,0(sp)
    800034ac:	1000                	addi	s0,sp,32
    800034ae:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800034b0:	00850913          	addi	s2,a0,8
    800034b4:	854a                	mv	a0,s2
    800034b6:	45c020ef          	jal	ra,80005912 <acquire>
  while (lk->locked) {
    800034ba:	409c                	lw	a5,0(s1)
    800034bc:	c799                	beqz	a5,800034ca <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800034be:	85ca                	mv	a1,s2
    800034c0:	8526                	mv	a0,s1
    800034c2:	982fe0ef          	jal	ra,80001644 <sleep>
  while (lk->locked) {
    800034c6:	409c                	lw	a5,0(s1)
    800034c8:	fbfd                	bnez	a5,800034be <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800034ca:	4785                	li	a5,1
    800034cc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800034ce:	babfd0ef          	jal	ra,80001078 <myproc>
    800034d2:	591c                	lw	a5,48(a0)
    800034d4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800034d6:	854a                	mv	a0,s2
    800034d8:	4d2020ef          	jal	ra,800059aa <release>
}
    800034dc:	60e2                	ld	ra,24(sp)
    800034de:	6442                	ld	s0,16(sp)
    800034e0:	64a2                	ld	s1,8(sp)
    800034e2:	6902                	ld	s2,0(sp)
    800034e4:	6105                	addi	sp,sp,32
    800034e6:	8082                	ret

00000000800034e8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800034e8:	1101                	addi	sp,sp,-32
    800034ea:	ec06                	sd	ra,24(sp)
    800034ec:	e822                	sd	s0,16(sp)
    800034ee:	e426                	sd	s1,8(sp)
    800034f0:	e04a                	sd	s2,0(sp)
    800034f2:	1000                	addi	s0,sp,32
    800034f4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800034f6:	00850913          	addi	s2,a0,8
    800034fa:	854a                	mv	a0,s2
    800034fc:	416020ef          	jal	ra,80005912 <acquire>
  lk->locked = 0;
    80003500:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003504:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003508:	8526                	mv	a0,s1
    8000350a:	986fe0ef          	jal	ra,80001690 <wakeup>
  release(&lk->lk);
    8000350e:	854a                	mv	a0,s2
    80003510:	49a020ef          	jal	ra,800059aa <release>
}
    80003514:	60e2                	ld	ra,24(sp)
    80003516:	6442                	ld	s0,16(sp)
    80003518:	64a2                	ld	s1,8(sp)
    8000351a:	6902                	ld	s2,0(sp)
    8000351c:	6105                	addi	sp,sp,32
    8000351e:	8082                	ret

0000000080003520 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003520:	7179                	addi	sp,sp,-48
    80003522:	f406                	sd	ra,40(sp)
    80003524:	f022                	sd	s0,32(sp)
    80003526:	ec26                	sd	s1,24(sp)
    80003528:	e84a                	sd	s2,16(sp)
    8000352a:	e44e                	sd	s3,8(sp)
    8000352c:	1800                	addi	s0,sp,48
    8000352e:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80003530:	00850913          	addi	s2,a0,8
    80003534:	854a                	mv	a0,s2
    80003536:	3dc020ef          	jal	ra,80005912 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000353a:	409c                	lw	a5,0(s1)
    8000353c:	ef89                	bnez	a5,80003556 <holdingsleep+0x36>
    8000353e:	4481                	li	s1,0
  release(&lk->lk);
    80003540:	854a                	mv	a0,s2
    80003542:	468020ef          	jal	ra,800059aa <release>
  return r;
}
    80003546:	8526                	mv	a0,s1
    80003548:	70a2                	ld	ra,40(sp)
    8000354a:	7402                	ld	s0,32(sp)
    8000354c:	64e2                	ld	s1,24(sp)
    8000354e:	6942                	ld	s2,16(sp)
    80003550:	69a2                	ld	s3,8(sp)
    80003552:	6145                	addi	sp,sp,48
    80003554:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003556:	0284a983          	lw	s3,40(s1)
    8000355a:	b1ffd0ef          	jal	ra,80001078 <myproc>
    8000355e:	5904                	lw	s1,48(a0)
    80003560:	413484b3          	sub	s1,s1,s3
    80003564:	0014b493          	seqz	s1,s1
    80003568:	bfe1                	j	80003540 <holdingsleep+0x20>

000000008000356a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000356a:	1141                	addi	sp,sp,-16
    8000356c:	e406                	sd	ra,8(sp)
    8000356e:	e022                	sd	s0,0(sp)
    80003570:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003572:	00004597          	auipc	a1,0x4
    80003576:	25e58593          	addi	a1,a1,606 # 800077d0 <syscalls+0x2a0>
    8000357a:	00015517          	auipc	a0,0x15
    8000357e:	85e50513          	addi	a0,a0,-1954 # 80017dd8 <ftable>
    80003582:	310020ef          	jal	ra,80005892 <initlock>
}
    80003586:	60a2                	ld	ra,8(sp)
    80003588:	6402                	ld	s0,0(sp)
    8000358a:	0141                	addi	sp,sp,16
    8000358c:	8082                	ret

000000008000358e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000358e:	1101                	addi	sp,sp,-32
    80003590:	ec06                	sd	ra,24(sp)
    80003592:	e822                	sd	s0,16(sp)
    80003594:	e426                	sd	s1,8(sp)
    80003596:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003598:	00015517          	auipc	a0,0x15
    8000359c:	84050513          	addi	a0,a0,-1984 # 80017dd8 <ftable>
    800035a0:	372020ef          	jal	ra,80005912 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800035a4:	00015497          	auipc	s1,0x15
    800035a8:	84c48493          	addi	s1,s1,-1972 # 80017df0 <ftable+0x18>
    800035ac:	00015717          	auipc	a4,0x15
    800035b0:	7e470713          	addi	a4,a4,2020 # 80018d90 <disk>
    if(f->ref == 0){
    800035b4:	40dc                	lw	a5,4(s1)
    800035b6:	cf89                	beqz	a5,800035d0 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800035b8:	02848493          	addi	s1,s1,40
    800035bc:	fee49ce3          	bne	s1,a4,800035b4 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800035c0:	00015517          	auipc	a0,0x15
    800035c4:	81850513          	addi	a0,a0,-2024 # 80017dd8 <ftable>
    800035c8:	3e2020ef          	jal	ra,800059aa <release>
  return 0;
    800035cc:	4481                	li	s1,0
    800035ce:	a809                	j	800035e0 <filealloc+0x52>
      f->ref = 1;
    800035d0:	4785                	li	a5,1
    800035d2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800035d4:	00015517          	auipc	a0,0x15
    800035d8:	80450513          	addi	a0,a0,-2044 # 80017dd8 <ftable>
    800035dc:	3ce020ef          	jal	ra,800059aa <release>
}
    800035e0:	8526                	mv	a0,s1
    800035e2:	60e2                	ld	ra,24(sp)
    800035e4:	6442                	ld	s0,16(sp)
    800035e6:	64a2                	ld	s1,8(sp)
    800035e8:	6105                	addi	sp,sp,32
    800035ea:	8082                	ret

00000000800035ec <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800035ec:	1101                	addi	sp,sp,-32
    800035ee:	ec06                	sd	ra,24(sp)
    800035f0:	e822                	sd	s0,16(sp)
    800035f2:	e426                	sd	s1,8(sp)
    800035f4:	1000                	addi	s0,sp,32
    800035f6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800035f8:	00014517          	auipc	a0,0x14
    800035fc:	7e050513          	addi	a0,a0,2016 # 80017dd8 <ftable>
    80003600:	312020ef          	jal	ra,80005912 <acquire>
  if(f->ref < 1)
    80003604:	40dc                	lw	a5,4(s1)
    80003606:	02f05063          	blez	a5,80003626 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000360a:	2785                	addiw	a5,a5,1
    8000360c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000360e:	00014517          	auipc	a0,0x14
    80003612:	7ca50513          	addi	a0,a0,1994 # 80017dd8 <ftable>
    80003616:	394020ef          	jal	ra,800059aa <release>
  return f;
}
    8000361a:	8526                	mv	a0,s1
    8000361c:	60e2                	ld	ra,24(sp)
    8000361e:	6442                	ld	s0,16(sp)
    80003620:	64a2                	ld	s1,8(sp)
    80003622:	6105                	addi	sp,sp,32
    80003624:	8082                	ret
    panic("filedup");
    80003626:	00004517          	auipc	a0,0x4
    8000362a:	1b250513          	addi	a0,a0,434 # 800077d8 <syscalls+0x2a8>
    8000362e:	7d5010ef          	jal	ra,80005602 <panic>

0000000080003632 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003632:	7139                	addi	sp,sp,-64
    80003634:	fc06                	sd	ra,56(sp)
    80003636:	f822                	sd	s0,48(sp)
    80003638:	f426                	sd	s1,40(sp)
    8000363a:	f04a                	sd	s2,32(sp)
    8000363c:	ec4e                	sd	s3,24(sp)
    8000363e:	e852                	sd	s4,16(sp)
    80003640:	e456                	sd	s5,8(sp)
    80003642:	0080                	addi	s0,sp,64
    80003644:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003646:	00014517          	auipc	a0,0x14
    8000364a:	79250513          	addi	a0,a0,1938 # 80017dd8 <ftable>
    8000364e:	2c4020ef          	jal	ra,80005912 <acquire>
  if(f->ref < 1)
    80003652:	40dc                	lw	a5,4(s1)
    80003654:	04f05963          	blez	a5,800036a6 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80003658:	37fd                	addiw	a5,a5,-1
    8000365a:	0007871b          	sext.w	a4,a5
    8000365e:	c0dc                	sw	a5,4(s1)
    80003660:	04e04963          	bgtz	a4,800036b2 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003664:	0004a903          	lw	s2,0(s1)
    80003668:	0094ca83          	lbu	s5,9(s1)
    8000366c:	0104ba03          	ld	s4,16(s1)
    80003670:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003674:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003678:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000367c:	00014517          	auipc	a0,0x14
    80003680:	75c50513          	addi	a0,a0,1884 # 80017dd8 <ftable>
    80003684:	326020ef          	jal	ra,800059aa <release>

  if(ff.type == FD_PIPE){
    80003688:	4785                	li	a5,1
    8000368a:	04f90363          	beq	s2,a5,800036d0 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000368e:	3979                	addiw	s2,s2,-2
    80003690:	4785                	li	a5,1
    80003692:	0327e663          	bltu	a5,s2,800036be <fileclose+0x8c>
    begin_op();
    80003696:	b85ff0ef          	jal	ra,8000321a <begin_op>
    iput(ff.ip);
    8000369a:	854e                	mv	a0,s3
    8000369c:	c68ff0ef          	jal	ra,80002b04 <iput>
    end_op();
    800036a0:	be9ff0ef          	jal	ra,80003288 <end_op>
    800036a4:	a829                	j	800036be <fileclose+0x8c>
    panic("fileclose");
    800036a6:	00004517          	auipc	a0,0x4
    800036aa:	13a50513          	addi	a0,a0,314 # 800077e0 <syscalls+0x2b0>
    800036ae:	755010ef          	jal	ra,80005602 <panic>
    release(&ftable.lock);
    800036b2:	00014517          	auipc	a0,0x14
    800036b6:	72650513          	addi	a0,a0,1830 # 80017dd8 <ftable>
    800036ba:	2f0020ef          	jal	ra,800059aa <release>
  }
}
    800036be:	70e2                	ld	ra,56(sp)
    800036c0:	7442                	ld	s0,48(sp)
    800036c2:	74a2                	ld	s1,40(sp)
    800036c4:	7902                	ld	s2,32(sp)
    800036c6:	69e2                	ld	s3,24(sp)
    800036c8:	6a42                	ld	s4,16(sp)
    800036ca:	6aa2                	ld	s5,8(sp)
    800036cc:	6121                	addi	sp,sp,64
    800036ce:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800036d0:	85d6                	mv	a1,s5
    800036d2:	8552                	mv	a0,s4
    800036d4:	2ec000ef          	jal	ra,800039c0 <pipeclose>
    800036d8:	b7dd                	j	800036be <fileclose+0x8c>

00000000800036da <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800036da:	715d                	addi	sp,sp,-80
    800036dc:	e486                	sd	ra,72(sp)
    800036de:	e0a2                	sd	s0,64(sp)
    800036e0:	fc26                	sd	s1,56(sp)
    800036e2:	f84a                	sd	s2,48(sp)
    800036e4:	f44e                	sd	s3,40(sp)
    800036e6:	0880                	addi	s0,sp,80
    800036e8:	84aa                	mv	s1,a0
    800036ea:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800036ec:	98dfd0ef          	jal	ra,80001078 <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800036f0:	409c                	lw	a5,0(s1)
    800036f2:	37f9                	addiw	a5,a5,-2
    800036f4:	4705                	li	a4,1
    800036f6:	02f76f63          	bltu	a4,a5,80003734 <filestat+0x5a>
    800036fa:	892a                	mv	s2,a0
    ilock(f->ip);
    800036fc:	6c88                	ld	a0,24(s1)
    800036fe:	a88ff0ef          	jal	ra,80002986 <ilock>
    stati(f->ip, &st);
    80003702:	fb840593          	addi	a1,s0,-72
    80003706:	6c88                	ld	a0,24(s1)
    80003708:	ca4ff0ef          	jal	ra,80002bac <stati>
    iunlock(f->ip);
    8000370c:	6c88                	ld	a0,24(s1)
    8000370e:	b22ff0ef          	jal	ra,80002a30 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003712:	46e1                	li	a3,24
    80003714:	fb840613          	addi	a2,s0,-72
    80003718:	85ce                	mv	a1,s3
    8000371a:	05093503          	ld	a0,80(s2)
    8000371e:	cfefd0ef          	jal	ra,80000c1c <copyout>
    80003722:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003726:	60a6                	ld	ra,72(sp)
    80003728:	6406                	ld	s0,64(sp)
    8000372a:	74e2                	ld	s1,56(sp)
    8000372c:	7942                	ld	s2,48(sp)
    8000372e:	79a2                	ld	s3,40(sp)
    80003730:	6161                	addi	sp,sp,80
    80003732:	8082                	ret
  return -1;
    80003734:	557d                	li	a0,-1
    80003736:	bfc5                	j	80003726 <filestat+0x4c>

0000000080003738 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003738:	7179                	addi	sp,sp,-48
    8000373a:	f406                	sd	ra,40(sp)
    8000373c:	f022                	sd	s0,32(sp)
    8000373e:	ec26                	sd	s1,24(sp)
    80003740:	e84a                	sd	s2,16(sp)
    80003742:	e44e                	sd	s3,8(sp)
    80003744:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003746:	00854783          	lbu	a5,8(a0)
    8000374a:	cbc1                	beqz	a5,800037da <fileread+0xa2>
    8000374c:	84aa                	mv	s1,a0
    8000374e:	89ae                	mv	s3,a1
    80003750:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003752:	411c                	lw	a5,0(a0)
    80003754:	4705                	li	a4,1
    80003756:	04e78363          	beq	a5,a4,8000379c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000375a:	470d                	li	a4,3
    8000375c:	04e78563          	beq	a5,a4,800037a6 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003760:	4709                	li	a4,2
    80003762:	06e79663          	bne	a5,a4,800037ce <fileread+0x96>
    ilock(f->ip);
    80003766:	6d08                	ld	a0,24(a0)
    80003768:	a1eff0ef          	jal	ra,80002986 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000376c:	874a                	mv	a4,s2
    8000376e:	5094                	lw	a3,32(s1)
    80003770:	864e                	mv	a2,s3
    80003772:	4585                	li	a1,1
    80003774:	6c88                	ld	a0,24(s1)
    80003776:	c60ff0ef          	jal	ra,80002bd6 <readi>
    8000377a:	892a                	mv	s2,a0
    8000377c:	00a05563          	blez	a0,80003786 <fileread+0x4e>
      f->off += r;
    80003780:	509c                	lw	a5,32(s1)
    80003782:	9fa9                	addw	a5,a5,a0
    80003784:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003786:	6c88                	ld	a0,24(s1)
    80003788:	aa8ff0ef          	jal	ra,80002a30 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000378c:	854a                	mv	a0,s2
    8000378e:	70a2                	ld	ra,40(sp)
    80003790:	7402                	ld	s0,32(sp)
    80003792:	64e2                	ld	s1,24(sp)
    80003794:	6942                	ld	s2,16(sp)
    80003796:	69a2                	ld	s3,8(sp)
    80003798:	6145                	addi	sp,sp,48
    8000379a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000379c:	6908                	ld	a0,16(a0)
    8000379e:	34e000ef          	jal	ra,80003aec <piperead>
    800037a2:	892a                	mv	s2,a0
    800037a4:	b7e5                	j	8000378c <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800037a6:	02451783          	lh	a5,36(a0)
    800037aa:	03079693          	slli	a3,a5,0x30
    800037ae:	92c1                	srli	a3,a3,0x30
    800037b0:	4725                	li	a4,9
    800037b2:	02d76663          	bltu	a4,a3,800037de <fileread+0xa6>
    800037b6:	0792                	slli	a5,a5,0x4
    800037b8:	00014717          	auipc	a4,0x14
    800037bc:	58070713          	addi	a4,a4,1408 # 80017d38 <devsw>
    800037c0:	97ba                	add	a5,a5,a4
    800037c2:	639c                	ld	a5,0(a5)
    800037c4:	cf99                	beqz	a5,800037e2 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800037c6:	4505                	li	a0,1
    800037c8:	9782                	jalr	a5
    800037ca:	892a                	mv	s2,a0
    800037cc:	b7c1                	j	8000378c <fileread+0x54>
    panic("fileread");
    800037ce:	00004517          	auipc	a0,0x4
    800037d2:	02250513          	addi	a0,a0,34 # 800077f0 <syscalls+0x2c0>
    800037d6:	62d010ef          	jal	ra,80005602 <panic>
    return -1;
    800037da:	597d                	li	s2,-1
    800037dc:	bf45                	j	8000378c <fileread+0x54>
      return -1;
    800037de:	597d                	li	s2,-1
    800037e0:	b775                	j	8000378c <fileread+0x54>
    800037e2:	597d                	li	s2,-1
    800037e4:	b765                	j	8000378c <fileread+0x54>

00000000800037e6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800037e6:	715d                	addi	sp,sp,-80
    800037e8:	e486                	sd	ra,72(sp)
    800037ea:	e0a2                	sd	s0,64(sp)
    800037ec:	fc26                	sd	s1,56(sp)
    800037ee:	f84a                	sd	s2,48(sp)
    800037f0:	f44e                	sd	s3,40(sp)
    800037f2:	f052                	sd	s4,32(sp)
    800037f4:	ec56                	sd	s5,24(sp)
    800037f6:	e85a                	sd	s6,16(sp)
    800037f8:	e45e                	sd	s7,8(sp)
    800037fa:	e062                	sd	s8,0(sp)
    800037fc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800037fe:	00954783          	lbu	a5,9(a0)
    80003802:	0e078863          	beqz	a5,800038f2 <filewrite+0x10c>
    80003806:	892a                	mv	s2,a0
    80003808:	8b2e                	mv	s6,a1
    8000380a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000380c:	411c                	lw	a5,0(a0)
    8000380e:	4705                	li	a4,1
    80003810:	02e78263          	beq	a5,a4,80003834 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003814:	470d                	li	a4,3
    80003816:	02e78463          	beq	a5,a4,8000383e <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000381a:	4709                	li	a4,2
    8000381c:	0ce79563          	bne	a5,a4,800038e6 <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003820:	0ac05163          	blez	a2,800038c2 <filewrite+0xdc>
    int i = 0;
    80003824:	4981                	li	s3,0
    80003826:	6b85                	lui	s7,0x1
    80003828:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000382c:	6c05                	lui	s8,0x1
    8000382e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003832:	a041                	j	800038b2 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80003834:	6908                	ld	a0,16(a0)
    80003836:	1e2000ef          	jal	ra,80003a18 <pipewrite>
    8000383a:	8a2a                	mv	s4,a0
    8000383c:	a071                	j	800038c8 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000383e:	02451783          	lh	a5,36(a0)
    80003842:	03079693          	slli	a3,a5,0x30
    80003846:	92c1                	srli	a3,a3,0x30
    80003848:	4725                	li	a4,9
    8000384a:	0ad76663          	bltu	a4,a3,800038f6 <filewrite+0x110>
    8000384e:	0792                	slli	a5,a5,0x4
    80003850:	00014717          	auipc	a4,0x14
    80003854:	4e870713          	addi	a4,a4,1256 # 80017d38 <devsw>
    80003858:	97ba                	add	a5,a5,a4
    8000385a:	679c                	ld	a5,8(a5)
    8000385c:	cfd9                	beqz	a5,800038fa <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    8000385e:	4505                	li	a0,1
    80003860:	9782                	jalr	a5
    80003862:	8a2a                	mv	s4,a0
    80003864:	a095                	j	800038c8 <filewrite+0xe2>
    80003866:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000386a:	9b1ff0ef          	jal	ra,8000321a <begin_op>
      ilock(f->ip);
    8000386e:	01893503          	ld	a0,24(s2)
    80003872:	914ff0ef          	jal	ra,80002986 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003876:	8756                	mv	a4,s5
    80003878:	02092683          	lw	a3,32(s2)
    8000387c:	01698633          	add	a2,s3,s6
    80003880:	4585                	li	a1,1
    80003882:	01893503          	ld	a0,24(s2)
    80003886:	c34ff0ef          	jal	ra,80002cba <writei>
    8000388a:	84aa                	mv	s1,a0
    8000388c:	00a05763          	blez	a0,8000389a <filewrite+0xb4>
        f->off += r;
    80003890:	02092783          	lw	a5,32(s2)
    80003894:	9fa9                	addw	a5,a5,a0
    80003896:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000389a:	01893503          	ld	a0,24(s2)
    8000389e:	992ff0ef          	jal	ra,80002a30 <iunlock>
      end_op();
    800038a2:	9e7ff0ef          	jal	ra,80003288 <end_op>

      if(r != n1){
    800038a6:	009a9f63          	bne	s5,s1,800038c4 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800038aa:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800038ae:	0149db63          	bge	s3,s4,800038c4 <filewrite+0xde>
      int n1 = n - i;
    800038b2:	413a04bb          	subw	s1,s4,s3
    800038b6:	0004879b          	sext.w	a5,s1
    800038ba:	fafbd6e3          	bge	s7,a5,80003866 <filewrite+0x80>
    800038be:	84e2                	mv	s1,s8
    800038c0:	b75d                	j	80003866 <filewrite+0x80>
    int i = 0;
    800038c2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800038c4:	013a1f63          	bne	s4,s3,800038e2 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800038c8:	8552                	mv	a0,s4
    800038ca:	60a6                	ld	ra,72(sp)
    800038cc:	6406                	ld	s0,64(sp)
    800038ce:	74e2                	ld	s1,56(sp)
    800038d0:	7942                	ld	s2,48(sp)
    800038d2:	79a2                	ld	s3,40(sp)
    800038d4:	7a02                	ld	s4,32(sp)
    800038d6:	6ae2                	ld	s5,24(sp)
    800038d8:	6b42                	ld	s6,16(sp)
    800038da:	6ba2                	ld	s7,8(sp)
    800038dc:	6c02                	ld	s8,0(sp)
    800038de:	6161                	addi	sp,sp,80
    800038e0:	8082                	ret
    ret = (i == n ? n : -1);
    800038e2:	5a7d                	li	s4,-1
    800038e4:	b7d5                	j	800038c8 <filewrite+0xe2>
    panic("filewrite");
    800038e6:	00004517          	auipc	a0,0x4
    800038ea:	f1a50513          	addi	a0,a0,-230 # 80007800 <syscalls+0x2d0>
    800038ee:	515010ef          	jal	ra,80005602 <panic>
    return -1;
    800038f2:	5a7d                	li	s4,-1
    800038f4:	bfd1                	j	800038c8 <filewrite+0xe2>
      return -1;
    800038f6:	5a7d                	li	s4,-1
    800038f8:	bfc1                	j	800038c8 <filewrite+0xe2>
    800038fa:	5a7d                	li	s4,-1
    800038fc:	b7f1                	j	800038c8 <filewrite+0xe2>

00000000800038fe <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800038fe:	7179                	addi	sp,sp,-48
    80003900:	f406                	sd	ra,40(sp)
    80003902:	f022                	sd	s0,32(sp)
    80003904:	ec26                	sd	s1,24(sp)
    80003906:	e84a                	sd	s2,16(sp)
    80003908:	e44e                	sd	s3,8(sp)
    8000390a:	e052                	sd	s4,0(sp)
    8000390c:	1800                	addi	s0,sp,48
    8000390e:	84aa                	mv	s1,a0
    80003910:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003912:	0005b023          	sd	zero,0(a1)
    80003916:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000391a:	c75ff0ef          	jal	ra,8000358e <filealloc>
    8000391e:	e088                	sd	a0,0(s1)
    80003920:	cd35                	beqz	a0,8000399c <pipealloc+0x9e>
    80003922:	c6dff0ef          	jal	ra,8000358e <filealloc>
    80003926:	00aa3023          	sd	a0,0(s4)
    8000392a:	c52d                	beqz	a0,80003994 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000392c:	839fc0ef          	jal	ra,80000164 <kalloc>
    80003930:	892a                	mv	s2,a0
    80003932:	cd31                	beqz	a0,8000398e <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80003934:	4985                	li	s3,1
    80003936:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000393a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000393e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003942:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003946:	00004597          	auipc	a1,0x4
    8000394a:	eca58593          	addi	a1,a1,-310 # 80007810 <syscalls+0x2e0>
    8000394e:	745010ef          	jal	ra,80005892 <initlock>
  (*f0)->type = FD_PIPE;
    80003952:	609c                	ld	a5,0(s1)
    80003954:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003958:	609c                	ld	a5,0(s1)
    8000395a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000395e:	609c                	ld	a5,0(s1)
    80003960:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003964:	609c                	ld	a5,0(s1)
    80003966:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000396a:	000a3783          	ld	a5,0(s4)
    8000396e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003972:	000a3783          	ld	a5,0(s4)
    80003976:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000397a:	000a3783          	ld	a5,0(s4)
    8000397e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003982:	000a3783          	ld	a5,0(s4)
    80003986:	0127b823          	sd	s2,16(a5)
  return 0;
    8000398a:	4501                	li	a0,0
    8000398c:	a005                	j	800039ac <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000398e:	6088                	ld	a0,0(s1)
    80003990:	e501                	bnez	a0,80003998 <pipealloc+0x9a>
    80003992:	a029                	j	8000399c <pipealloc+0x9e>
    80003994:	6088                	ld	a0,0(s1)
    80003996:	c11d                	beqz	a0,800039bc <pipealloc+0xbe>
    fileclose(*f0);
    80003998:	c9bff0ef          	jal	ra,80003632 <fileclose>
  if(*f1)
    8000399c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800039a0:	557d                	li	a0,-1
  if(*f1)
    800039a2:	c789                	beqz	a5,800039ac <pipealloc+0xae>
    fileclose(*f1);
    800039a4:	853e                	mv	a0,a5
    800039a6:	c8dff0ef          	jal	ra,80003632 <fileclose>
  return -1;
    800039aa:	557d                	li	a0,-1
}
    800039ac:	70a2                	ld	ra,40(sp)
    800039ae:	7402                	ld	s0,32(sp)
    800039b0:	64e2                	ld	s1,24(sp)
    800039b2:	6942                	ld	s2,16(sp)
    800039b4:	69a2                	ld	s3,8(sp)
    800039b6:	6a02                	ld	s4,0(sp)
    800039b8:	6145                	addi	sp,sp,48
    800039ba:	8082                	ret
  return -1;
    800039bc:	557d                	li	a0,-1
    800039be:	b7fd                	j	800039ac <pipealloc+0xae>

00000000800039c0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800039c0:	1101                	addi	sp,sp,-32
    800039c2:	ec06                	sd	ra,24(sp)
    800039c4:	e822                	sd	s0,16(sp)
    800039c6:	e426                	sd	s1,8(sp)
    800039c8:	e04a                	sd	s2,0(sp)
    800039ca:	1000                	addi	s0,sp,32
    800039cc:	84aa                	mv	s1,a0
    800039ce:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800039d0:	743010ef          	jal	ra,80005912 <acquire>
  if(writable){
    800039d4:	02090763          	beqz	s2,80003a02 <pipeclose+0x42>
    pi->writeopen = 0;
    800039d8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800039dc:	21848513          	addi	a0,s1,536
    800039e0:	cb1fd0ef          	jal	ra,80001690 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800039e4:	2204b783          	ld	a5,544(s1)
    800039e8:	e785                	bnez	a5,80003a10 <pipeclose+0x50>
    release(&pi->lock);
    800039ea:	8526                	mv	a0,s1
    800039ec:	7bf010ef          	jal	ra,800059aa <release>
    kfree((char*)pi);
    800039f0:	8526                	mv	a0,s1
    800039f2:	e7efc0ef          	jal	ra,80000070 <kfree>
  } else
    release(&pi->lock);
}
    800039f6:	60e2                	ld	ra,24(sp)
    800039f8:	6442                	ld	s0,16(sp)
    800039fa:	64a2                	ld	s1,8(sp)
    800039fc:	6902                	ld	s2,0(sp)
    800039fe:	6105                	addi	sp,sp,32
    80003a00:	8082                	ret
    pi->readopen = 0;
    80003a02:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003a06:	21c48513          	addi	a0,s1,540
    80003a0a:	c87fd0ef          	jal	ra,80001690 <wakeup>
    80003a0e:	bfd9                	j	800039e4 <pipeclose+0x24>
    release(&pi->lock);
    80003a10:	8526                	mv	a0,s1
    80003a12:	799010ef          	jal	ra,800059aa <release>
}
    80003a16:	b7c5                	j	800039f6 <pipeclose+0x36>

0000000080003a18 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003a18:	711d                	addi	sp,sp,-96
    80003a1a:	ec86                	sd	ra,88(sp)
    80003a1c:	e8a2                	sd	s0,80(sp)
    80003a1e:	e4a6                	sd	s1,72(sp)
    80003a20:	e0ca                	sd	s2,64(sp)
    80003a22:	fc4e                	sd	s3,56(sp)
    80003a24:	f852                	sd	s4,48(sp)
    80003a26:	f456                	sd	s5,40(sp)
    80003a28:	f05a                	sd	s6,32(sp)
    80003a2a:	ec5e                	sd	s7,24(sp)
    80003a2c:	e862                	sd	s8,16(sp)
    80003a2e:	1080                	addi	s0,sp,96
    80003a30:	84aa                	mv	s1,a0
    80003a32:	8aae                	mv	s5,a1
    80003a34:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003a36:	e42fd0ef          	jal	ra,80001078 <myproc>
    80003a3a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003a3c:	8526                	mv	a0,s1
    80003a3e:	6d5010ef          	jal	ra,80005912 <acquire>
  while(i < n){
    80003a42:	09405c63          	blez	s4,80003ada <pipewrite+0xc2>
  int i = 0;
    80003a46:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003a48:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003a4a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003a4e:	21c48b93          	addi	s7,s1,540
    80003a52:	a81d                	j	80003a88 <pipewrite+0x70>
      release(&pi->lock);
    80003a54:	8526                	mv	a0,s1
    80003a56:	755010ef          	jal	ra,800059aa <release>
      return -1;
    80003a5a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003a5c:	854a                	mv	a0,s2
    80003a5e:	60e6                	ld	ra,88(sp)
    80003a60:	6446                	ld	s0,80(sp)
    80003a62:	64a6                	ld	s1,72(sp)
    80003a64:	6906                	ld	s2,64(sp)
    80003a66:	79e2                	ld	s3,56(sp)
    80003a68:	7a42                	ld	s4,48(sp)
    80003a6a:	7aa2                	ld	s5,40(sp)
    80003a6c:	7b02                	ld	s6,32(sp)
    80003a6e:	6be2                	ld	s7,24(sp)
    80003a70:	6c42                	ld	s8,16(sp)
    80003a72:	6125                	addi	sp,sp,96
    80003a74:	8082                	ret
      wakeup(&pi->nread);
    80003a76:	8562                	mv	a0,s8
    80003a78:	c19fd0ef          	jal	ra,80001690 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003a7c:	85a6                	mv	a1,s1
    80003a7e:	855e                	mv	a0,s7
    80003a80:	bc5fd0ef          	jal	ra,80001644 <sleep>
  while(i < n){
    80003a84:	05495c63          	bge	s2,s4,80003adc <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80003a88:	2204a783          	lw	a5,544(s1)
    80003a8c:	d7e1                	beqz	a5,80003a54 <pipewrite+0x3c>
    80003a8e:	854e                	mv	a0,s3
    80003a90:	dedfd0ef          	jal	ra,8000187c <killed>
    80003a94:	f161                	bnez	a0,80003a54 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003a96:	2184a783          	lw	a5,536(s1)
    80003a9a:	21c4a703          	lw	a4,540(s1)
    80003a9e:	2007879b          	addiw	a5,a5,512
    80003aa2:	fcf70ae3          	beq	a4,a5,80003a76 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003aa6:	4685                	li	a3,1
    80003aa8:	01590633          	add	a2,s2,s5
    80003aac:	faf40593          	addi	a1,s0,-81
    80003ab0:	0509b503          	ld	a0,80(s3)
    80003ab4:	a20fd0ef          	jal	ra,80000cd4 <copyin>
    80003ab8:	03650263          	beq	a0,s6,80003adc <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003abc:	21c4a783          	lw	a5,540(s1)
    80003ac0:	0017871b          	addiw	a4,a5,1
    80003ac4:	20e4ae23          	sw	a4,540(s1)
    80003ac8:	1ff7f793          	andi	a5,a5,511
    80003acc:	97a6                	add	a5,a5,s1
    80003ace:	faf44703          	lbu	a4,-81(s0)
    80003ad2:	00e78c23          	sb	a4,24(a5)
      i++;
    80003ad6:	2905                	addiw	s2,s2,1
    80003ad8:	b775                	j	80003a84 <pipewrite+0x6c>
  int i = 0;
    80003ada:	4901                	li	s2,0
  wakeup(&pi->nread);
    80003adc:	21848513          	addi	a0,s1,536
    80003ae0:	bb1fd0ef          	jal	ra,80001690 <wakeup>
  release(&pi->lock);
    80003ae4:	8526                	mv	a0,s1
    80003ae6:	6c5010ef          	jal	ra,800059aa <release>
  return i;
    80003aea:	bf8d                	j	80003a5c <pipewrite+0x44>

0000000080003aec <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003aec:	715d                	addi	sp,sp,-80
    80003aee:	e486                	sd	ra,72(sp)
    80003af0:	e0a2                	sd	s0,64(sp)
    80003af2:	fc26                	sd	s1,56(sp)
    80003af4:	f84a                	sd	s2,48(sp)
    80003af6:	f44e                	sd	s3,40(sp)
    80003af8:	f052                	sd	s4,32(sp)
    80003afa:	ec56                	sd	s5,24(sp)
    80003afc:	e85a                	sd	s6,16(sp)
    80003afe:	0880                	addi	s0,sp,80
    80003b00:	84aa                	mv	s1,a0
    80003b02:	892e                	mv	s2,a1
    80003b04:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003b06:	d72fd0ef          	jal	ra,80001078 <myproc>
    80003b0a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003b0c:	8526                	mv	a0,s1
    80003b0e:	605010ef          	jal	ra,80005912 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003b12:	2184a703          	lw	a4,536(s1)
    80003b16:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003b1a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003b1e:	02f71363          	bne	a4,a5,80003b44 <piperead+0x58>
    80003b22:	2244a783          	lw	a5,548(s1)
    80003b26:	cf99                	beqz	a5,80003b44 <piperead+0x58>
    if(killed(pr)){
    80003b28:	8552                	mv	a0,s4
    80003b2a:	d53fd0ef          	jal	ra,8000187c <killed>
    80003b2e:	e149                	bnez	a0,80003bb0 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003b30:	85a6                	mv	a1,s1
    80003b32:	854e                	mv	a0,s3
    80003b34:	b11fd0ef          	jal	ra,80001644 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003b38:	2184a703          	lw	a4,536(s1)
    80003b3c:	21c4a783          	lw	a5,540(s1)
    80003b40:	fef701e3          	beq	a4,a5,80003b22 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b44:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003b46:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b48:	05505263          	blez	s5,80003b8c <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    80003b4c:	2184a783          	lw	a5,536(s1)
    80003b50:	21c4a703          	lw	a4,540(s1)
    80003b54:	02f70c63          	beq	a4,a5,80003b8c <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003b58:	0017871b          	addiw	a4,a5,1
    80003b5c:	20e4ac23          	sw	a4,536(s1)
    80003b60:	1ff7f793          	andi	a5,a5,511
    80003b64:	97a6                	add	a5,a5,s1
    80003b66:	0187c783          	lbu	a5,24(a5)
    80003b6a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003b6e:	4685                	li	a3,1
    80003b70:	fbf40613          	addi	a2,s0,-65
    80003b74:	85ca                	mv	a1,s2
    80003b76:	050a3503          	ld	a0,80(s4)
    80003b7a:	8a2fd0ef          	jal	ra,80000c1c <copyout>
    80003b7e:	01650763          	beq	a0,s6,80003b8c <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b82:	2985                	addiw	s3,s3,1
    80003b84:	0905                	addi	s2,s2,1
    80003b86:	fd3a93e3          	bne	s5,s3,80003b4c <piperead+0x60>
    80003b8a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003b8c:	21c48513          	addi	a0,s1,540
    80003b90:	b01fd0ef          	jal	ra,80001690 <wakeup>
  release(&pi->lock);
    80003b94:	8526                	mv	a0,s1
    80003b96:	615010ef          	jal	ra,800059aa <release>
  return i;
}
    80003b9a:	854e                	mv	a0,s3
    80003b9c:	60a6                	ld	ra,72(sp)
    80003b9e:	6406                	ld	s0,64(sp)
    80003ba0:	74e2                	ld	s1,56(sp)
    80003ba2:	7942                	ld	s2,48(sp)
    80003ba4:	79a2                	ld	s3,40(sp)
    80003ba6:	7a02                	ld	s4,32(sp)
    80003ba8:	6ae2                	ld	s5,24(sp)
    80003baa:	6b42                	ld	s6,16(sp)
    80003bac:	6161                	addi	sp,sp,80
    80003bae:	8082                	ret
      release(&pi->lock);
    80003bb0:	8526                	mv	a0,s1
    80003bb2:	5f9010ef          	jal	ra,800059aa <release>
      return -1;
    80003bb6:	59fd                	li	s3,-1
    80003bb8:	b7cd                	j	80003b9a <piperead+0xae>

0000000080003bba <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003bba:	1141                	addi	sp,sp,-16
    80003bbc:	e422                	sd	s0,8(sp)
    80003bbe:	0800                	addi	s0,sp,16
    80003bc0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003bc2:	8905                	andi	a0,a0,1
    80003bc4:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003bc6:	8b89                	andi	a5,a5,2
    80003bc8:	c399                	beqz	a5,80003bce <flags2perm+0x14>
      perm |= PTE_W;
    80003bca:	00456513          	ori	a0,a0,4
    return perm;
}
    80003bce:	6422                	ld	s0,8(sp)
    80003bd0:	0141                	addi	sp,sp,16
    80003bd2:	8082                	ret

0000000080003bd4 <exec>:

int
exec(char *path, char **argv)
{
    80003bd4:	de010113          	addi	sp,sp,-544
    80003bd8:	20113c23          	sd	ra,536(sp)
    80003bdc:	20813823          	sd	s0,528(sp)
    80003be0:	20913423          	sd	s1,520(sp)
    80003be4:	21213023          	sd	s2,512(sp)
    80003be8:	ffce                	sd	s3,504(sp)
    80003bea:	fbd2                	sd	s4,496(sp)
    80003bec:	f7d6                	sd	s5,488(sp)
    80003bee:	f3da                	sd	s6,480(sp)
    80003bf0:	efde                	sd	s7,472(sp)
    80003bf2:	ebe2                	sd	s8,464(sp)
    80003bf4:	e7e6                	sd	s9,456(sp)
    80003bf6:	e3ea                	sd	s10,448(sp)
    80003bf8:	ff6e                	sd	s11,440(sp)
    80003bfa:	1400                	addi	s0,sp,544
    80003bfc:	892a                	mv	s2,a0
    80003bfe:	dea43423          	sd	a0,-536(s0)
    80003c02:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003c06:	c72fd0ef          	jal	ra,80001078 <myproc>
    80003c0a:	84aa                	mv	s1,a0

  begin_op();
    80003c0c:	e0eff0ef          	jal	ra,8000321a <begin_op>

  if((ip = namei(path)) == 0){
    80003c10:	854a                	mv	a0,s2
    80003c12:	c2cff0ef          	jal	ra,8000303e <namei>
    80003c16:	c13d                	beqz	a0,80003c7c <exec+0xa8>
    80003c18:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003c1a:	d6dfe0ef          	jal	ra,80002986 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003c1e:	04000713          	li	a4,64
    80003c22:	4681                	li	a3,0
    80003c24:	e5040613          	addi	a2,s0,-432
    80003c28:	4581                	li	a1,0
    80003c2a:	8556                	mv	a0,s5
    80003c2c:	fabfe0ef          	jal	ra,80002bd6 <readi>
    80003c30:	04000793          	li	a5,64
    80003c34:	00f51a63          	bne	a0,a5,80003c48 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003c38:	e5042703          	lw	a4,-432(s0)
    80003c3c:	464c47b7          	lui	a5,0x464c4
    80003c40:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003c44:	04f70063          	beq	a4,a5,80003c84 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003c48:	8556                	mv	a0,s5
    80003c4a:	f43fe0ef          	jal	ra,80002b8c <iunlockput>
    end_op();
    80003c4e:	e3aff0ef          	jal	ra,80003288 <end_op>
  }
  return -1;
    80003c52:	557d                	li	a0,-1
}
    80003c54:	21813083          	ld	ra,536(sp)
    80003c58:	21013403          	ld	s0,528(sp)
    80003c5c:	20813483          	ld	s1,520(sp)
    80003c60:	20013903          	ld	s2,512(sp)
    80003c64:	79fe                	ld	s3,504(sp)
    80003c66:	7a5e                	ld	s4,496(sp)
    80003c68:	7abe                	ld	s5,488(sp)
    80003c6a:	7b1e                	ld	s6,480(sp)
    80003c6c:	6bfe                	ld	s7,472(sp)
    80003c6e:	6c5e                	ld	s8,464(sp)
    80003c70:	6cbe                	ld	s9,456(sp)
    80003c72:	6d1e                	ld	s10,448(sp)
    80003c74:	7dfa                	ld	s11,440(sp)
    80003c76:	22010113          	addi	sp,sp,544
    80003c7a:	8082                	ret
    end_op();
    80003c7c:	e0cff0ef          	jal	ra,80003288 <end_op>
    return -1;
    80003c80:	557d                	li	a0,-1
    80003c82:	bfc9                	j	80003c54 <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    80003c84:	8526                	mv	a0,s1
    80003c86:	c9afd0ef          	jal	ra,80001120 <proc_pagetable>
    80003c8a:	8b2a                	mv	s6,a0
    80003c8c:	dd55                	beqz	a0,80003c48 <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c8e:	e7042783          	lw	a5,-400(s0)
    80003c92:	e8845703          	lhu	a4,-376(s0)
    80003c96:	c325                	beqz	a4,80003cf6 <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003c98:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c9a:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80003c9e:	6a05                	lui	s4,0x1
    80003ca0:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80003ca4:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80003ca8:	6d85                	lui	s11,0x1
    80003caa:	7d7d                	lui	s10,0xfffff
    80003cac:	a409                	j	80003eae <exec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80003cae:	00004517          	auipc	a0,0x4
    80003cb2:	b6a50513          	addi	a0,a0,-1174 # 80007818 <syscalls+0x2e8>
    80003cb6:	14d010ef          	jal	ra,80005602 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003cba:	874a                	mv	a4,s2
    80003cbc:	009c86bb          	addw	a3,s9,s1
    80003cc0:	4581                	li	a1,0
    80003cc2:	8556                	mv	a0,s5
    80003cc4:	f13fe0ef          	jal	ra,80002bd6 <readi>
    80003cc8:	2501                	sext.w	a0,a0
    80003cca:	18a91163          	bne	s2,a0,80003e4c <exec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80003cce:	009d84bb          	addw	s1,s11,s1
    80003cd2:	013d09bb          	addw	s3,s10,s3
    80003cd6:	1b74fc63          	bgeu	s1,s7,80003e8e <exec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80003cda:	02049593          	slli	a1,s1,0x20
    80003cde:	9181                	srli	a1,a1,0x20
    80003ce0:	95e2                	add	a1,a1,s8
    80003ce2:	855a                	mv	a0,s6
    80003ce4:	96bfc0ef          	jal	ra,8000064e <walkaddr>
    80003ce8:	862a                	mv	a2,a0
    if(pa == 0)
    80003cea:	d171                	beqz	a0,80003cae <exec+0xda>
      n = PGSIZE;
    80003cec:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80003cee:	fd49f6e3          	bgeu	s3,s4,80003cba <exec+0xe6>
      n = sz - i;
    80003cf2:	894e                	mv	s2,s3
    80003cf4:	b7d9                	j	80003cba <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003cf6:	4901                	li	s2,0
  iunlockput(ip);
    80003cf8:	8556                	mv	a0,s5
    80003cfa:	e93fe0ef          	jal	ra,80002b8c <iunlockput>
  end_op();
    80003cfe:	d8aff0ef          	jal	ra,80003288 <end_op>
  p = myproc();
    80003d02:	b76fd0ef          	jal	ra,80001078 <myproc>
    80003d06:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80003d08:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003d0c:	6785                	lui	a5,0x1
    80003d0e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80003d10:	97ca                	add	a5,a5,s2
    80003d12:	777d                	lui	a4,0xfffff
    80003d14:	8ff9                	and	a5,a5,a4
    80003d16:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003d1a:	4691                	li	a3,4
    80003d1c:	6609                	lui	a2,0x2
    80003d1e:	963e                	add	a2,a2,a5
    80003d20:	85be                	mv	a1,a5
    80003d22:	855a                	mv	a0,s6
    80003d24:	cf1fc0ef          	jal	ra,80000a14 <uvmalloc>
    80003d28:	8c2a                	mv	s8,a0
  ip = 0;
    80003d2a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003d2c:	12050063          	beqz	a0,80003e4c <exec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003d30:	75f9                	lui	a1,0xffffe
    80003d32:	95aa                	add	a1,a1,a0
    80003d34:	855a                	mv	a0,s6
    80003d36:	ebdfc0ef          	jal	ra,80000bf2 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003d3a:	7afd                	lui	s5,0xfffff
    80003d3c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80003d3e:	df043783          	ld	a5,-528(s0)
    80003d42:	6388                	ld	a0,0(a5)
    80003d44:	c135                	beqz	a0,80003da8 <exec+0x1d4>
    80003d46:	e9040993          	addi	s3,s0,-368
    80003d4a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80003d4e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003d50:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003d52:	ed8fc0ef          	jal	ra,8000042a <strlen>
    80003d56:	0015079b          	addiw	a5,a0,1
    80003d5a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003d5e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003d62:	11596a63          	bltu	s2,s5,80003e76 <exec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003d66:	df043d83          	ld	s11,-528(s0)
    80003d6a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80003d6e:	8552                	mv	a0,s4
    80003d70:	ebafc0ef          	jal	ra,8000042a <strlen>
    80003d74:	0015069b          	addiw	a3,a0,1
    80003d78:	8652                	mv	a2,s4
    80003d7a:	85ca                	mv	a1,s2
    80003d7c:	855a                	mv	a0,s6
    80003d7e:	e9ffc0ef          	jal	ra,80000c1c <copyout>
    80003d82:	0e054e63          	bltz	a0,80003e7e <exec+0x2aa>
    ustack[argc] = sp;
    80003d86:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003d8a:	0485                	addi	s1,s1,1
    80003d8c:	008d8793          	addi	a5,s11,8
    80003d90:	def43823          	sd	a5,-528(s0)
    80003d94:	008db503          	ld	a0,8(s11)
    80003d98:	c911                	beqz	a0,80003dac <exec+0x1d8>
    if(argc >= MAXARG)
    80003d9a:	09a1                	addi	s3,s3,8
    80003d9c:	fb3c9be3          	bne	s9,s3,80003d52 <exec+0x17e>
  sz = sz1;
    80003da0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003da4:	4a81                	li	s5,0
    80003da6:	a05d                	j	80003e4c <exec+0x278>
  sp = sz;
    80003da8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003daa:	4481                	li	s1,0
  ustack[argc] = 0;
    80003dac:	00349793          	slli	a5,s1,0x3
    80003db0:	f9078793          	addi	a5,a5,-112
    80003db4:	97a2                	add	a5,a5,s0
    80003db6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003dba:	00148693          	addi	a3,s1,1
    80003dbe:	068e                	slli	a3,a3,0x3
    80003dc0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003dc4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80003dc8:	01597663          	bgeu	s2,s5,80003dd4 <exec+0x200>
  sz = sz1;
    80003dcc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003dd0:	4a81                	li	s5,0
    80003dd2:	a8ad                	j	80003e4c <exec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003dd4:	e9040613          	addi	a2,s0,-368
    80003dd8:	85ca                	mv	a1,s2
    80003dda:	855a                	mv	a0,s6
    80003ddc:	e41fc0ef          	jal	ra,80000c1c <copyout>
    80003de0:	0a054363          	bltz	a0,80003e86 <exec+0x2b2>
  p->trapframe->a1 = sp;
    80003de4:	058bb783          	ld	a5,88(s7)
    80003de8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003dec:	de843783          	ld	a5,-536(s0)
    80003df0:	0007c703          	lbu	a4,0(a5)
    80003df4:	cf11                	beqz	a4,80003e10 <exec+0x23c>
    80003df6:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003df8:	02f00693          	li	a3,47
    80003dfc:	a039                	j	80003e0a <exec+0x236>
      last = s+1;
    80003dfe:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80003e02:	0785                	addi	a5,a5,1
    80003e04:	fff7c703          	lbu	a4,-1(a5)
    80003e08:	c701                	beqz	a4,80003e10 <exec+0x23c>
    if(*s == '/')
    80003e0a:	fed71ce3          	bne	a4,a3,80003e02 <exec+0x22e>
    80003e0e:	bfc5                	j	80003dfe <exec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80003e10:	4641                	li	a2,16
    80003e12:	de843583          	ld	a1,-536(s0)
    80003e16:	158b8513          	addi	a0,s7,344
    80003e1a:	ddefc0ef          	jal	ra,800003f8 <safestrcpy>
  oldpagetable = p->pagetable;
    80003e1e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80003e22:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80003e26:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003e2a:	058bb783          	ld	a5,88(s7)
    80003e2e:	e6843703          	ld	a4,-408(s0)
    80003e32:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003e34:	058bb783          	ld	a5,88(s7)
    80003e38:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003e3c:	85ea                	mv	a1,s10
    80003e3e:	b66fd0ef          	jal	ra,800011a4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003e42:	0004851b          	sext.w	a0,s1
    80003e46:	b539                	j	80003c54 <exec+0x80>
    80003e48:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80003e4c:	df843583          	ld	a1,-520(s0)
    80003e50:	855a                	mv	a0,s6
    80003e52:	b52fd0ef          	jal	ra,800011a4 <proc_freepagetable>
  if(ip){
    80003e56:	de0a99e3          	bnez	s5,80003c48 <exec+0x74>
  return -1;
    80003e5a:	557d                	li	a0,-1
    80003e5c:	bbe5                	j	80003c54 <exec+0x80>
    80003e5e:	df243c23          	sd	s2,-520(s0)
    80003e62:	b7ed                	j	80003e4c <exec+0x278>
    80003e64:	df243c23          	sd	s2,-520(s0)
    80003e68:	b7d5                	j	80003e4c <exec+0x278>
    80003e6a:	df243c23          	sd	s2,-520(s0)
    80003e6e:	bff9                	j	80003e4c <exec+0x278>
    80003e70:	df243c23          	sd	s2,-520(s0)
    80003e74:	bfe1                	j	80003e4c <exec+0x278>
  sz = sz1;
    80003e76:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003e7a:	4a81                	li	s5,0
    80003e7c:	bfc1                	j	80003e4c <exec+0x278>
  sz = sz1;
    80003e7e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003e82:	4a81                	li	s5,0
    80003e84:	b7e1                	j	80003e4c <exec+0x278>
  sz = sz1;
    80003e86:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003e8a:	4a81                	li	s5,0
    80003e8c:	b7c1                	j	80003e4c <exec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003e8e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003e92:	e0843783          	ld	a5,-504(s0)
    80003e96:	0017869b          	addiw	a3,a5,1
    80003e9a:	e0d43423          	sd	a3,-504(s0)
    80003e9e:	e0043783          	ld	a5,-512(s0)
    80003ea2:	0387879b          	addiw	a5,a5,56
    80003ea6:	e8845703          	lhu	a4,-376(s0)
    80003eaa:	e4e6d7e3          	bge	a3,a4,80003cf8 <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003eae:	2781                	sext.w	a5,a5
    80003eb0:	e0f43023          	sd	a5,-512(s0)
    80003eb4:	03800713          	li	a4,56
    80003eb8:	86be                	mv	a3,a5
    80003eba:	e1840613          	addi	a2,s0,-488
    80003ebe:	4581                	li	a1,0
    80003ec0:	8556                	mv	a0,s5
    80003ec2:	d15fe0ef          	jal	ra,80002bd6 <readi>
    80003ec6:	03800793          	li	a5,56
    80003eca:	f6f51fe3          	bne	a0,a5,80003e48 <exec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80003ece:	e1842783          	lw	a5,-488(s0)
    80003ed2:	4705                	li	a4,1
    80003ed4:	fae79fe3          	bne	a5,a4,80003e92 <exec+0x2be>
    if(ph.memsz < ph.filesz)
    80003ed8:	e4043483          	ld	s1,-448(s0)
    80003edc:	e3843783          	ld	a5,-456(s0)
    80003ee0:	f6f4efe3          	bltu	s1,a5,80003e5e <exec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003ee4:	e2843783          	ld	a5,-472(s0)
    80003ee8:	94be                	add	s1,s1,a5
    80003eea:	f6f4ede3          	bltu	s1,a5,80003e64 <exec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80003eee:	de043703          	ld	a4,-544(s0)
    80003ef2:	8ff9                	and	a5,a5,a4
    80003ef4:	fbbd                	bnez	a5,80003e6a <exec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003ef6:	e1c42503          	lw	a0,-484(s0)
    80003efa:	cc1ff0ef          	jal	ra,80003bba <flags2perm>
    80003efe:	86aa                	mv	a3,a0
    80003f00:	8626                	mv	a2,s1
    80003f02:	85ca                	mv	a1,s2
    80003f04:	855a                	mv	a0,s6
    80003f06:	b0ffc0ef          	jal	ra,80000a14 <uvmalloc>
    80003f0a:	dea43c23          	sd	a0,-520(s0)
    80003f0e:	d12d                	beqz	a0,80003e70 <exec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003f10:	e2843c03          	ld	s8,-472(s0)
    80003f14:	e2042c83          	lw	s9,-480(s0)
    80003f18:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003f1c:	f60b89e3          	beqz	s7,80003e8e <exec+0x2ba>
    80003f20:	89de                	mv	s3,s7
    80003f22:	4481                	li	s1,0
    80003f24:	bb5d                	j	80003cda <exec+0x106>

0000000080003f26 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003f26:	7179                	addi	sp,sp,-48
    80003f28:	f406                	sd	ra,40(sp)
    80003f2a:	f022                	sd	s0,32(sp)
    80003f2c:	ec26                	sd	s1,24(sp)
    80003f2e:	e84a                	sd	s2,16(sp)
    80003f30:	1800                	addi	s0,sp,48
    80003f32:	892e                	mv	s2,a1
    80003f34:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003f36:	fdc40593          	addi	a1,s0,-36
    80003f3a:	fedfd0ef          	jal	ra,80001f26 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003f3e:	fdc42703          	lw	a4,-36(s0)
    80003f42:	47bd                	li	a5,15
    80003f44:	02e7e963          	bltu	a5,a4,80003f76 <argfd+0x50>
    80003f48:	930fd0ef          	jal	ra,80001078 <myproc>
    80003f4c:	fdc42703          	lw	a4,-36(s0)
    80003f50:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffde04a>
    80003f54:	078e                	slli	a5,a5,0x3
    80003f56:	953e                	add	a0,a0,a5
    80003f58:	611c                	ld	a5,0(a0)
    80003f5a:	c385                	beqz	a5,80003f7a <argfd+0x54>
    return -1;
  if(pfd)
    80003f5c:	00090463          	beqz	s2,80003f64 <argfd+0x3e>
    *pfd = fd;
    80003f60:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003f64:	4501                	li	a0,0
  if(pf)
    80003f66:	c091                	beqz	s1,80003f6a <argfd+0x44>
    *pf = f;
    80003f68:	e09c                	sd	a5,0(s1)
}
    80003f6a:	70a2                	ld	ra,40(sp)
    80003f6c:	7402                	ld	s0,32(sp)
    80003f6e:	64e2                	ld	s1,24(sp)
    80003f70:	6942                	ld	s2,16(sp)
    80003f72:	6145                	addi	sp,sp,48
    80003f74:	8082                	ret
    return -1;
    80003f76:	557d                	li	a0,-1
    80003f78:	bfcd                	j	80003f6a <argfd+0x44>
    80003f7a:	557d                	li	a0,-1
    80003f7c:	b7fd                	j	80003f6a <argfd+0x44>

0000000080003f7e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003f7e:	1101                	addi	sp,sp,-32
    80003f80:	ec06                	sd	ra,24(sp)
    80003f82:	e822                	sd	s0,16(sp)
    80003f84:	e426                	sd	s1,8(sp)
    80003f86:	1000                	addi	s0,sp,32
    80003f88:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003f8a:	8eefd0ef          	jal	ra,80001078 <myproc>
    80003f8e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003f90:	0d050793          	addi	a5,a0,208
    80003f94:	4501                	li	a0,0
    80003f96:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003f98:	6398                	ld	a4,0(a5)
    80003f9a:	cb19                	beqz	a4,80003fb0 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003f9c:	2505                	addiw	a0,a0,1
    80003f9e:	07a1                	addi	a5,a5,8
    80003fa0:	fed51ce3          	bne	a0,a3,80003f98 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003fa4:	557d                	li	a0,-1
}
    80003fa6:	60e2                	ld	ra,24(sp)
    80003fa8:	6442                	ld	s0,16(sp)
    80003faa:	64a2                	ld	s1,8(sp)
    80003fac:	6105                	addi	sp,sp,32
    80003fae:	8082                	ret
      p->ofile[fd] = f;
    80003fb0:	01a50793          	addi	a5,a0,26
    80003fb4:	078e                	slli	a5,a5,0x3
    80003fb6:	963e                	add	a2,a2,a5
    80003fb8:	e204                	sd	s1,0(a2)
      return fd;
    80003fba:	b7f5                	j	80003fa6 <fdalloc+0x28>

0000000080003fbc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003fbc:	715d                	addi	sp,sp,-80
    80003fbe:	e486                	sd	ra,72(sp)
    80003fc0:	e0a2                	sd	s0,64(sp)
    80003fc2:	fc26                	sd	s1,56(sp)
    80003fc4:	f84a                	sd	s2,48(sp)
    80003fc6:	f44e                	sd	s3,40(sp)
    80003fc8:	f052                	sd	s4,32(sp)
    80003fca:	ec56                	sd	s5,24(sp)
    80003fcc:	e85a                	sd	s6,16(sp)
    80003fce:	0880                	addi	s0,sp,80
    80003fd0:	8b2e                	mv	s6,a1
    80003fd2:	89b2                	mv	s3,a2
    80003fd4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003fd6:	fb040593          	addi	a1,s0,-80
    80003fda:	87eff0ef          	jal	ra,80003058 <nameiparent>
    80003fde:	84aa                	mv	s1,a0
    80003fe0:	10050b63          	beqz	a0,800040f6 <create+0x13a>
    return 0;

  ilock(dp);
    80003fe4:	9a3fe0ef          	jal	ra,80002986 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fe8:	4601                	li	a2,0
    80003fea:	fb040593          	addi	a1,s0,-80
    80003fee:	8526                	mv	a0,s1
    80003ff0:	de3fe0ef          	jal	ra,80002dd2 <dirlookup>
    80003ff4:	8aaa                	mv	s5,a0
    80003ff6:	c521                	beqz	a0,8000403e <create+0x82>
    iunlockput(dp);
    80003ff8:	8526                	mv	a0,s1
    80003ffa:	b93fe0ef          	jal	ra,80002b8c <iunlockput>
    ilock(ip);
    80003ffe:	8556                	mv	a0,s5
    80004000:	987fe0ef          	jal	ra,80002986 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004004:	000b059b          	sext.w	a1,s6
    80004008:	4789                	li	a5,2
    8000400a:	02f59563          	bne	a1,a5,80004034 <create+0x78>
    8000400e:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde074>
    80004012:	37f9                	addiw	a5,a5,-2
    80004014:	17c2                	slli	a5,a5,0x30
    80004016:	93c1                	srli	a5,a5,0x30
    80004018:	4705                	li	a4,1
    8000401a:	00f76d63          	bltu	a4,a5,80004034 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000401e:	8556                	mv	a0,s5
    80004020:	60a6                	ld	ra,72(sp)
    80004022:	6406                	ld	s0,64(sp)
    80004024:	74e2                	ld	s1,56(sp)
    80004026:	7942                	ld	s2,48(sp)
    80004028:	79a2                	ld	s3,40(sp)
    8000402a:	7a02                	ld	s4,32(sp)
    8000402c:	6ae2                	ld	s5,24(sp)
    8000402e:	6b42                	ld	s6,16(sp)
    80004030:	6161                	addi	sp,sp,80
    80004032:	8082                	ret
    iunlockput(ip);
    80004034:	8556                	mv	a0,s5
    80004036:	b57fe0ef          	jal	ra,80002b8c <iunlockput>
    return 0;
    8000403a:	4a81                	li	s5,0
    8000403c:	b7cd                	j	8000401e <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000403e:	85da                	mv	a1,s6
    80004040:	4088                	lw	a0,0(s1)
    80004042:	fdafe0ef          	jal	ra,8000281c <ialloc>
    80004046:	8a2a                	mv	s4,a0
    80004048:	cd1d                	beqz	a0,80004086 <create+0xca>
  ilock(ip);
    8000404a:	93dfe0ef          	jal	ra,80002986 <ilock>
  ip->major = major;
    8000404e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004052:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004056:	4905                	li	s2,1
    80004058:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000405c:	8552                	mv	a0,s4
    8000405e:	875fe0ef          	jal	ra,800028d2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004062:	000b059b          	sext.w	a1,s6
    80004066:	03258563          	beq	a1,s2,80004090 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    8000406a:	004a2603          	lw	a2,4(s4)
    8000406e:	fb040593          	addi	a1,s0,-80
    80004072:	8526                	mv	a0,s1
    80004074:	f31fe0ef          	jal	ra,80002fa4 <dirlink>
    80004078:	06054363          	bltz	a0,800040de <create+0x122>
  iunlockput(dp);
    8000407c:	8526                	mv	a0,s1
    8000407e:	b0ffe0ef          	jal	ra,80002b8c <iunlockput>
  return ip;
    80004082:	8ad2                	mv	s5,s4
    80004084:	bf69                	j	8000401e <create+0x62>
    iunlockput(dp);
    80004086:	8526                	mv	a0,s1
    80004088:	b05fe0ef          	jal	ra,80002b8c <iunlockput>
    return 0;
    8000408c:	8ad2                	mv	s5,s4
    8000408e:	bf41                	j	8000401e <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004090:	004a2603          	lw	a2,4(s4)
    80004094:	00003597          	auipc	a1,0x3
    80004098:	7a458593          	addi	a1,a1,1956 # 80007838 <syscalls+0x308>
    8000409c:	8552                	mv	a0,s4
    8000409e:	f07fe0ef          	jal	ra,80002fa4 <dirlink>
    800040a2:	02054e63          	bltz	a0,800040de <create+0x122>
    800040a6:	40d0                	lw	a2,4(s1)
    800040a8:	00003597          	auipc	a1,0x3
    800040ac:	79858593          	addi	a1,a1,1944 # 80007840 <syscalls+0x310>
    800040b0:	8552                	mv	a0,s4
    800040b2:	ef3fe0ef          	jal	ra,80002fa4 <dirlink>
    800040b6:	02054463          	bltz	a0,800040de <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    800040ba:	004a2603          	lw	a2,4(s4)
    800040be:	fb040593          	addi	a1,s0,-80
    800040c2:	8526                	mv	a0,s1
    800040c4:	ee1fe0ef          	jal	ra,80002fa4 <dirlink>
    800040c8:	00054b63          	bltz	a0,800040de <create+0x122>
    dp->nlink++;  // for ".."
    800040cc:	04a4d783          	lhu	a5,74(s1)
    800040d0:	2785                	addiw	a5,a5,1
    800040d2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800040d6:	8526                	mv	a0,s1
    800040d8:	ffafe0ef          	jal	ra,800028d2 <iupdate>
    800040dc:	b745                	j	8000407c <create+0xc0>
  ip->nlink = 0;
    800040de:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800040e2:	8552                	mv	a0,s4
    800040e4:	feefe0ef          	jal	ra,800028d2 <iupdate>
  iunlockput(ip);
    800040e8:	8552                	mv	a0,s4
    800040ea:	aa3fe0ef          	jal	ra,80002b8c <iunlockput>
  iunlockput(dp);
    800040ee:	8526                	mv	a0,s1
    800040f0:	a9dfe0ef          	jal	ra,80002b8c <iunlockput>
  return 0;
    800040f4:	b72d                	j	8000401e <create+0x62>
    return 0;
    800040f6:	8aaa                	mv	s5,a0
    800040f8:	b71d                	j	8000401e <create+0x62>

00000000800040fa <sys_dup>:
{
    800040fa:	7179                	addi	sp,sp,-48
    800040fc:	f406                	sd	ra,40(sp)
    800040fe:	f022                	sd	s0,32(sp)
    80004100:	ec26                	sd	s1,24(sp)
    80004102:	e84a                	sd	s2,16(sp)
    80004104:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004106:	fd840613          	addi	a2,s0,-40
    8000410a:	4581                	li	a1,0
    8000410c:	4501                	li	a0,0
    8000410e:	e19ff0ef          	jal	ra,80003f26 <argfd>
    return -1;
    80004112:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004114:	00054f63          	bltz	a0,80004132 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80004118:	fd843903          	ld	s2,-40(s0)
    8000411c:	854a                	mv	a0,s2
    8000411e:	e61ff0ef          	jal	ra,80003f7e <fdalloc>
    80004122:	84aa                	mv	s1,a0
    return -1;
    80004124:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004126:	00054663          	bltz	a0,80004132 <sys_dup+0x38>
  filedup(f);
    8000412a:	854a                	mv	a0,s2
    8000412c:	cc0ff0ef          	jal	ra,800035ec <filedup>
  return fd;
    80004130:	87a6                	mv	a5,s1
}
    80004132:	853e                	mv	a0,a5
    80004134:	70a2                	ld	ra,40(sp)
    80004136:	7402                	ld	s0,32(sp)
    80004138:	64e2                	ld	s1,24(sp)
    8000413a:	6942                	ld	s2,16(sp)
    8000413c:	6145                	addi	sp,sp,48
    8000413e:	8082                	ret

0000000080004140 <sys_read>:
{
    80004140:	7179                	addi	sp,sp,-48
    80004142:	f406                	sd	ra,40(sp)
    80004144:	f022                	sd	s0,32(sp)
    80004146:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004148:	fd840593          	addi	a1,s0,-40
    8000414c:	4505                	li	a0,1
    8000414e:	df5fd0ef          	jal	ra,80001f42 <argaddr>
  argint(2, &n);
    80004152:	fe440593          	addi	a1,s0,-28
    80004156:	4509                	li	a0,2
    80004158:	dcffd0ef          	jal	ra,80001f26 <argint>
  if(argfd(0, 0, &f) < 0)
    8000415c:	fe840613          	addi	a2,s0,-24
    80004160:	4581                	li	a1,0
    80004162:	4501                	li	a0,0
    80004164:	dc3ff0ef          	jal	ra,80003f26 <argfd>
    80004168:	87aa                	mv	a5,a0
    return -1;
    8000416a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000416c:	0007ca63          	bltz	a5,80004180 <sys_read+0x40>
  return fileread(f, p, n);
    80004170:	fe442603          	lw	a2,-28(s0)
    80004174:	fd843583          	ld	a1,-40(s0)
    80004178:	fe843503          	ld	a0,-24(s0)
    8000417c:	dbcff0ef          	jal	ra,80003738 <fileread>
}
    80004180:	70a2                	ld	ra,40(sp)
    80004182:	7402                	ld	s0,32(sp)
    80004184:	6145                	addi	sp,sp,48
    80004186:	8082                	ret

0000000080004188 <sys_write>:
{
    80004188:	7179                	addi	sp,sp,-48
    8000418a:	f406                	sd	ra,40(sp)
    8000418c:	f022                	sd	s0,32(sp)
    8000418e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004190:	fd840593          	addi	a1,s0,-40
    80004194:	4505                	li	a0,1
    80004196:	dadfd0ef          	jal	ra,80001f42 <argaddr>
  argint(2, &n);
    8000419a:	fe440593          	addi	a1,s0,-28
    8000419e:	4509                	li	a0,2
    800041a0:	d87fd0ef          	jal	ra,80001f26 <argint>
  if(argfd(0, 0, &f) < 0)
    800041a4:	fe840613          	addi	a2,s0,-24
    800041a8:	4581                	li	a1,0
    800041aa:	4501                	li	a0,0
    800041ac:	d7bff0ef          	jal	ra,80003f26 <argfd>
    800041b0:	87aa                	mv	a5,a0
    return -1;
    800041b2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800041b4:	0007ca63          	bltz	a5,800041c8 <sys_write+0x40>
  return filewrite(f, p, n);
    800041b8:	fe442603          	lw	a2,-28(s0)
    800041bc:	fd843583          	ld	a1,-40(s0)
    800041c0:	fe843503          	ld	a0,-24(s0)
    800041c4:	e22ff0ef          	jal	ra,800037e6 <filewrite>
}
    800041c8:	70a2                	ld	ra,40(sp)
    800041ca:	7402                	ld	s0,32(sp)
    800041cc:	6145                	addi	sp,sp,48
    800041ce:	8082                	ret

00000000800041d0 <sys_close>:
{
    800041d0:	1101                	addi	sp,sp,-32
    800041d2:	ec06                	sd	ra,24(sp)
    800041d4:	e822                	sd	s0,16(sp)
    800041d6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800041d8:	fe040613          	addi	a2,s0,-32
    800041dc:	fec40593          	addi	a1,s0,-20
    800041e0:	4501                	li	a0,0
    800041e2:	d45ff0ef          	jal	ra,80003f26 <argfd>
    return -1;
    800041e6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800041e8:	02054063          	bltz	a0,80004208 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800041ec:	e8dfc0ef          	jal	ra,80001078 <myproc>
    800041f0:	fec42783          	lw	a5,-20(s0)
    800041f4:	07e9                	addi	a5,a5,26
    800041f6:	078e                	slli	a5,a5,0x3
    800041f8:	953e                	add	a0,a0,a5
    800041fa:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800041fe:	fe043503          	ld	a0,-32(s0)
    80004202:	c30ff0ef          	jal	ra,80003632 <fileclose>
  return 0;
    80004206:	4781                	li	a5,0
}
    80004208:	853e                	mv	a0,a5
    8000420a:	60e2                	ld	ra,24(sp)
    8000420c:	6442                	ld	s0,16(sp)
    8000420e:	6105                	addi	sp,sp,32
    80004210:	8082                	ret

0000000080004212 <sys_fstat>:
{
    80004212:	1101                	addi	sp,sp,-32
    80004214:	ec06                	sd	ra,24(sp)
    80004216:	e822                	sd	s0,16(sp)
    80004218:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000421a:	fe040593          	addi	a1,s0,-32
    8000421e:	4505                	li	a0,1
    80004220:	d23fd0ef          	jal	ra,80001f42 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004224:	fe840613          	addi	a2,s0,-24
    80004228:	4581                	li	a1,0
    8000422a:	4501                	li	a0,0
    8000422c:	cfbff0ef          	jal	ra,80003f26 <argfd>
    80004230:	87aa                	mv	a5,a0
    return -1;
    80004232:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004234:	0007c863          	bltz	a5,80004244 <sys_fstat+0x32>
  return filestat(f, st);
    80004238:	fe043583          	ld	a1,-32(s0)
    8000423c:	fe843503          	ld	a0,-24(s0)
    80004240:	c9aff0ef          	jal	ra,800036da <filestat>
}
    80004244:	60e2                	ld	ra,24(sp)
    80004246:	6442                	ld	s0,16(sp)
    80004248:	6105                	addi	sp,sp,32
    8000424a:	8082                	ret

000000008000424c <sys_link>:
{
    8000424c:	7169                	addi	sp,sp,-304
    8000424e:	f606                	sd	ra,296(sp)
    80004250:	f222                	sd	s0,288(sp)
    80004252:	ee26                	sd	s1,280(sp)
    80004254:	ea4a                	sd	s2,272(sp)
    80004256:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004258:	08000613          	li	a2,128
    8000425c:	ed040593          	addi	a1,s0,-304
    80004260:	4501                	li	a0,0
    80004262:	cfdfd0ef          	jal	ra,80001f5e <argstr>
    return -1;
    80004266:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004268:	0c054663          	bltz	a0,80004334 <sys_link+0xe8>
    8000426c:	08000613          	li	a2,128
    80004270:	f5040593          	addi	a1,s0,-176
    80004274:	4505                	li	a0,1
    80004276:	ce9fd0ef          	jal	ra,80001f5e <argstr>
    return -1;
    8000427a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000427c:	0a054c63          	bltz	a0,80004334 <sys_link+0xe8>
  begin_op();
    80004280:	f9bfe0ef          	jal	ra,8000321a <begin_op>
  if((ip = namei(old)) == 0){
    80004284:	ed040513          	addi	a0,s0,-304
    80004288:	db7fe0ef          	jal	ra,8000303e <namei>
    8000428c:	84aa                	mv	s1,a0
    8000428e:	c525                	beqz	a0,800042f6 <sys_link+0xaa>
  ilock(ip);
    80004290:	ef6fe0ef          	jal	ra,80002986 <ilock>
  if(ip->type == T_DIR){
    80004294:	04449703          	lh	a4,68(s1)
    80004298:	4785                	li	a5,1
    8000429a:	06f70263          	beq	a4,a5,800042fe <sys_link+0xb2>
  ip->nlink++;
    8000429e:	04a4d783          	lhu	a5,74(s1)
    800042a2:	2785                	addiw	a5,a5,1
    800042a4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800042a8:	8526                	mv	a0,s1
    800042aa:	e28fe0ef          	jal	ra,800028d2 <iupdate>
  iunlock(ip);
    800042ae:	8526                	mv	a0,s1
    800042b0:	f80fe0ef          	jal	ra,80002a30 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800042b4:	fd040593          	addi	a1,s0,-48
    800042b8:	f5040513          	addi	a0,s0,-176
    800042bc:	d9dfe0ef          	jal	ra,80003058 <nameiparent>
    800042c0:	892a                	mv	s2,a0
    800042c2:	c921                	beqz	a0,80004312 <sys_link+0xc6>
  ilock(dp);
    800042c4:	ec2fe0ef          	jal	ra,80002986 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800042c8:	00092703          	lw	a4,0(s2)
    800042cc:	409c                	lw	a5,0(s1)
    800042ce:	02f71f63          	bne	a4,a5,8000430c <sys_link+0xc0>
    800042d2:	40d0                	lw	a2,4(s1)
    800042d4:	fd040593          	addi	a1,s0,-48
    800042d8:	854a                	mv	a0,s2
    800042da:	ccbfe0ef          	jal	ra,80002fa4 <dirlink>
    800042de:	02054763          	bltz	a0,8000430c <sys_link+0xc0>
  iunlockput(dp);
    800042e2:	854a                	mv	a0,s2
    800042e4:	8a9fe0ef          	jal	ra,80002b8c <iunlockput>
  iput(ip);
    800042e8:	8526                	mv	a0,s1
    800042ea:	81bfe0ef          	jal	ra,80002b04 <iput>
  end_op();
    800042ee:	f9bfe0ef          	jal	ra,80003288 <end_op>
  return 0;
    800042f2:	4781                	li	a5,0
    800042f4:	a081                	j	80004334 <sys_link+0xe8>
    end_op();
    800042f6:	f93fe0ef          	jal	ra,80003288 <end_op>
    return -1;
    800042fa:	57fd                	li	a5,-1
    800042fc:	a825                	j	80004334 <sys_link+0xe8>
    iunlockput(ip);
    800042fe:	8526                	mv	a0,s1
    80004300:	88dfe0ef          	jal	ra,80002b8c <iunlockput>
    end_op();
    80004304:	f85fe0ef          	jal	ra,80003288 <end_op>
    return -1;
    80004308:	57fd                	li	a5,-1
    8000430a:	a02d                	j	80004334 <sys_link+0xe8>
    iunlockput(dp);
    8000430c:	854a                	mv	a0,s2
    8000430e:	87ffe0ef          	jal	ra,80002b8c <iunlockput>
  ilock(ip);
    80004312:	8526                	mv	a0,s1
    80004314:	e72fe0ef          	jal	ra,80002986 <ilock>
  ip->nlink--;
    80004318:	04a4d783          	lhu	a5,74(s1)
    8000431c:	37fd                	addiw	a5,a5,-1
    8000431e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004322:	8526                	mv	a0,s1
    80004324:	daefe0ef          	jal	ra,800028d2 <iupdate>
  iunlockput(ip);
    80004328:	8526                	mv	a0,s1
    8000432a:	863fe0ef          	jal	ra,80002b8c <iunlockput>
  end_op();
    8000432e:	f5bfe0ef          	jal	ra,80003288 <end_op>
  return -1;
    80004332:	57fd                	li	a5,-1
}
    80004334:	853e                	mv	a0,a5
    80004336:	70b2                	ld	ra,296(sp)
    80004338:	7412                	ld	s0,288(sp)
    8000433a:	64f2                	ld	s1,280(sp)
    8000433c:	6952                	ld	s2,272(sp)
    8000433e:	6155                	addi	sp,sp,304
    80004340:	8082                	ret

0000000080004342 <sys_unlink>:
{
    80004342:	7151                	addi	sp,sp,-240
    80004344:	f586                	sd	ra,232(sp)
    80004346:	f1a2                	sd	s0,224(sp)
    80004348:	eda6                	sd	s1,216(sp)
    8000434a:	e9ca                	sd	s2,208(sp)
    8000434c:	e5ce                	sd	s3,200(sp)
    8000434e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004350:	08000613          	li	a2,128
    80004354:	f3040593          	addi	a1,s0,-208
    80004358:	4501                	li	a0,0
    8000435a:	c05fd0ef          	jal	ra,80001f5e <argstr>
    8000435e:	12054b63          	bltz	a0,80004494 <sys_unlink+0x152>
  begin_op();
    80004362:	eb9fe0ef          	jal	ra,8000321a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004366:	fb040593          	addi	a1,s0,-80
    8000436a:	f3040513          	addi	a0,s0,-208
    8000436e:	cebfe0ef          	jal	ra,80003058 <nameiparent>
    80004372:	84aa                	mv	s1,a0
    80004374:	c54d                	beqz	a0,8000441e <sys_unlink+0xdc>
  ilock(dp);
    80004376:	e10fe0ef          	jal	ra,80002986 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000437a:	00003597          	auipc	a1,0x3
    8000437e:	4be58593          	addi	a1,a1,1214 # 80007838 <syscalls+0x308>
    80004382:	fb040513          	addi	a0,s0,-80
    80004386:	a37fe0ef          	jal	ra,80002dbc <namecmp>
    8000438a:	10050a63          	beqz	a0,8000449e <sys_unlink+0x15c>
    8000438e:	00003597          	auipc	a1,0x3
    80004392:	4b258593          	addi	a1,a1,1202 # 80007840 <syscalls+0x310>
    80004396:	fb040513          	addi	a0,s0,-80
    8000439a:	a23fe0ef          	jal	ra,80002dbc <namecmp>
    8000439e:	10050063          	beqz	a0,8000449e <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800043a2:	f2c40613          	addi	a2,s0,-212
    800043a6:	fb040593          	addi	a1,s0,-80
    800043aa:	8526                	mv	a0,s1
    800043ac:	a27fe0ef          	jal	ra,80002dd2 <dirlookup>
    800043b0:	892a                	mv	s2,a0
    800043b2:	0e050663          	beqz	a0,8000449e <sys_unlink+0x15c>
  ilock(ip);
    800043b6:	dd0fe0ef          	jal	ra,80002986 <ilock>
  if(ip->nlink < 1)
    800043ba:	04a91783          	lh	a5,74(s2)
    800043be:	06f05463          	blez	a5,80004426 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800043c2:	04491703          	lh	a4,68(s2)
    800043c6:	4785                	li	a5,1
    800043c8:	06f70563          	beq	a4,a5,80004432 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    800043cc:	4641                	li	a2,16
    800043ce:	4581                	li	a1,0
    800043d0:	fc040513          	addi	a0,s0,-64
    800043d4:	edffb0ef          	jal	ra,800002b2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043d8:	4741                	li	a4,16
    800043da:	f2c42683          	lw	a3,-212(s0)
    800043de:	fc040613          	addi	a2,s0,-64
    800043e2:	4581                	li	a1,0
    800043e4:	8526                	mv	a0,s1
    800043e6:	8d5fe0ef          	jal	ra,80002cba <writei>
    800043ea:	47c1                	li	a5,16
    800043ec:	08f51563          	bne	a0,a5,80004476 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800043f0:	04491703          	lh	a4,68(s2)
    800043f4:	4785                	li	a5,1
    800043f6:	08f70663          	beq	a4,a5,80004482 <sys_unlink+0x140>
  iunlockput(dp);
    800043fa:	8526                	mv	a0,s1
    800043fc:	f90fe0ef          	jal	ra,80002b8c <iunlockput>
  ip->nlink--;
    80004400:	04a95783          	lhu	a5,74(s2)
    80004404:	37fd                	addiw	a5,a5,-1
    80004406:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000440a:	854a                	mv	a0,s2
    8000440c:	cc6fe0ef          	jal	ra,800028d2 <iupdate>
  iunlockput(ip);
    80004410:	854a                	mv	a0,s2
    80004412:	f7afe0ef          	jal	ra,80002b8c <iunlockput>
  end_op();
    80004416:	e73fe0ef          	jal	ra,80003288 <end_op>
  return 0;
    8000441a:	4501                	li	a0,0
    8000441c:	a079                	j	800044aa <sys_unlink+0x168>
    end_op();
    8000441e:	e6bfe0ef          	jal	ra,80003288 <end_op>
    return -1;
    80004422:	557d                	li	a0,-1
    80004424:	a059                	j	800044aa <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004426:	00003517          	auipc	a0,0x3
    8000442a:	42250513          	addi	a0,a0,1058 # 80007848 <syscalls+0x318>
    8000442e:	1d4010ef          	jal	ra,80005602 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004432:	04c92703          	lw	a4,76(s2)
    80004436:	02000793          	li	a5,32
    8000443a:	f8e7f9e3          	bgeu	a5,a4,800043cc <sys_unlink+0x8a>
    8000443e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004442:	4741                	li	a4,16
    80004444:	86ce                	mv	a3,s3
    80004446:	f1840613          	addi	a2,s0,-232
    8000444a:	4581                	li	a1,0
    8000444c:	854a                	mv	a0,s2
    8000444e:	f88fe0ef          	jal	ra,80002bd6 <readi>
    80004452:	47c1                	li	a5,16
    80004454:	00f51b63          	bne	a0,a5,8000446a <sys_unlink+0x128>
    if(de.inum != 0)
    80004458:	f1845783          	lhu	a5,-232(s0)
    8000445c:	ef95                	bnez	a5,80004498 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000445e:	29c1                	addiw	s3,s3,16
    80004460:	04c92783          	lw	a5,76(s2)
    80004464:	fcf9efe3          	bltu	s3,a5,80004442 <sys_unlink+0x100>
    80004468:	b795                	j	800043cc <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000446a:	00003517          	auipc	a0,0x3
    8000446e:	3f650513          	addi	a0,a0,1014 # 80007860 <syscalls+0x330>
    80004472:	190010ef          	jal	ra,80005602 <panic>
    panic("unlink: writei");
    80004476:	00003517          	auipc	a0,0x3
    8000447a:	40250513          	addi	a0,a0,1026 # 80007878 <syscalls+0x348>
    8000447e:	184010ef          	jal	ra,80005602 <panic>
    dp->nlink--;
    80004482:	04a4d783          	lhu	a5,74(s1)
    80004486:	37fd                	addiw	a5,a5,-1
    80004488:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000448c:	8526                	mv	a0,s1
    8000448e:	c44fe0ef          	jal	ra,800028d2 <iupdate>
    80004492:	b7a5                	j	800043fa <sys_unlink+0xb8>
    return -1;
    80004494:	557d                	li	a0,-1
    80004496:	a811                	j	800044aa <sys_unlink+0x168>
    iunlockput(ip);
    80004498:	854a                	mv	a0,s2
    8000449a:	ef2fe0ef          	jal	ra,80002b8c <iunlockput>
  iunlockput(dp);
    8000449e:	8526                	mv	a0,s1
    800044a0:	eecfe0ef          	jal	ra,80002b8c <iunlockput>
  end_op();
    800044a4:	de5fe0ef          	jal	ra,80003288 <end_op>
  return -1;
    800044a8:	557d                	li	a0,-1
}
    800044aa:	70ae                	ld	ra,232(sp)
    800044ac:	740e                	ld	s0,224(sp)
    800044ae:	64ee                	ld	s1,216(sp)
    800044b0:	694e                	ld	s2,208(sp)
    800044b2:	69ae                	ld	s3,200(sp)
    800044b4:	616d                	addi	sp,sp,240
    800044b6:	8082                	ret

00000000800044b8 <sys_open>:

uint64
sys_open(void)
{
    800044b8:	7131                	addi	sp,sp,-192
    800044ba:	fd06                	sd	ra,184(sp)
    800044bc:	f922                	sd	s0,176(sp)
    800044be:	f526                	sd	s1,168(sp)
    800044c0:	f14a                	sd	s2,160(sp)
    800044c2:	ed4e                	sd	s3,152(sp)
    800044c4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800044c6:	f4c40593          	addi	a1,s0,-180
    800044ca:	4505                	li	a0,1
    800044cc:	a5bfd0ef          	jal	ra,80001f26 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044d0:	08000613          	li	a2,128
    800044d4:	f5040593          	addi	a1,s0,-176
    800044d8:	4501                	li	a0,0
    800044da:	a85fd0ef          	jal	ra,80001f5e <argstr>
    800044de:	87aa                	mv	a5,a0
    return -1;
    800044e0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044e2:	0807cd63          	bltz	a5,8000457c <sys_open+0xc4>

  begin_op();
    800044e6:	d35fe0ef          	jal	ra,8000321a <begin_op>

  if(omode & O_CREATE){
    800044ea:	f4c42783          	lw	a5,-180(s0)
    800044ee:	2007f793          	andi	a5,a5,512
    800044f2:	c3c5                	beqz	a5,80004592 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800044f4:	4681                	li	a3,0
    800044f6:	4601                	li	a2,0
    800044f8:	4589                	li	a1,2
    800044fa:	f5040513          	addi	a0,s0,-176
    800044fe:	abfff0ef          	jal	ra,80003fbc <create>
    80004502:	84aa                	mv	s1,a0
    if(ip == 0){
    80004504:	c159                	beqz	a0,8000458a <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004506:	04449703          	lh	a4,68(s1)
    8000450a:	478d                	li	a5,3
    8000450c:	00f71763          	bne	a4,a5,8000451a <sys_open+0x62>
    80004510:	0464d703          	lhu	a4,70(s1)
    80004514:	47a5                	li	a5,9
    80004516:	0ae7e963          	bltu	a5,a4,800045c8 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000451a:	874ff0ef          	jal	ra,8000358e <filealloc>
    8000451e:	89aa                	mv	s3,a0
    80004520:	0c050963          	beqz	a0,800045f2 <sys_open+0x13a>
    80004524:	a5bff0ef          	jal	ra,80003f7e <fdalloc>
    80004528:	892a                	mv	s2,a0
    8000452a:	0c054163          	bltz	a0,800045ec <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000452e:	04449703          	lh	a4,68(s1)
    80004532:	478d                	li	a5,3
    80004534:	0af70163          	beq	a4,a5,800045d6 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004538:	4789                	li	a5,2
    8000453a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000453e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004542:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004546:	f4c42783          	lw	a5,-180(s0)
    8000454a:	0017c713          	xori	a4,a5,1
    8000454e:	8b05                	andi	a4,a4,1
    80004550:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004554:	0037f713          	andi	a4,a5,3
    80004558:	00e03733          	snez	a4,a4
    8000455c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004560:	4007f793          	andi	a5,a5,1024
    80004564:	c791                	beqz	a5,80004570 <sys_open+0xb8>
    80004566:	04449703          	lh	a4,68(s1)
    8000456a:	4789                	li	a5,2
    8000456c:	06f70c63          	beq	a4,a5,800045e4 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004570:	8526                	mv	a0,s1
    80004572:	cbefe0ef          	jal	ra,80002a30 <iunlock>
  end_op();
    80004576:	d13fe0ef          	jal	ra,80003288 <end_op>

  return fd;
    8000457a:	854a                	mv	a0,s2
}
    8000457c:	70ea                	ld	ra,184(sp)
    8000457e:	744a                	ld	s0,176(sp)
    80004580:	74aa                	ld	s1,168(sp)
    80004582:	790a                	ld	s2,160(sp)
    80004584:	69ea                	ld	s3,152(sp)
    80004586:	6129                	addi	sp,sp,192
    80004588:	8082                	ret
      end_op();
    8000458a:	cfffe0ef          	jal	ra,80003288 <end_op>
      return -1;
    8000458e:	557d                	li	a0,-1
    80004590:	b7f5                	j	8000457c <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80004592:	f5040513          	addi	a0,s0,-176
    80004596:	aa9fe0ef          	jal	ra,8000303e <namei>
    8000459a:	84aa                	mv	s1,a0
    8000459c:	c115                	beqz	a0,800045c0 <sys_open+0x108>
    ilock(ip);
    8000459e:	be8fe0ef          	jal	ra,80002986 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800045a2:	04449703          	lh	a4,68(s1)
    800045a6:	4785                	li	a5,1
    800045a8:	f4f71fe3          	bne	a4,a5,80004506 <sys_open+0x4e>
    800045ac:	f4c42783          	lw	a5,-180(s0)
    800045b0:	d7ad                	beqz	a5,8000451a <sys_open+0x62>
      iunlockput(ip);
    800045b2:	8526                	mv	a0,s1
    800045b4:	dd8fe0ef          	jal	ra,80002b8c <iunlockput>
      end_op();
    800045b8:	cd1fe0ef          	jal	ra,80003288 <end_op>
      return -1;
    800045bc:	557d                	li	a0,-1
    800045be:	bf7d                	j	8000457c <sys_open+0xc4>
      end_op();
    800045c0:	cc9fe0ef          	jal	ra,80003288 <end_op>
      return -1;
    800045c4:	557d                	li	a0,-1
    800045c6:	bf5d                	j	8000457c <sys_open+0xc4>
    iunlockput(ip);
    800045c8:	8526                	mv	a0,s1
    800045ca:	dc2fe0ef          	jal	ra,80002b8c <iunlockput>
    end_op();
    800045ce:	cbbfe0ef          	jal	ra,80003288 <end_op>
    return -1;
    800045d2:	557d                	li	a0,-1
    800045d4:	b765                	j	8000457c <sys_open+0xc4>
    f->type = FD_DEVICE;
    800045d6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800045da:	04649783          	lh	a5,70(s1)
    800045de:	02f99223          	sh	a5,36(s3)
    800045e2:	b785                	j	80004542 <sys_open+0x8a>
    itrunc(ip);
    800045e4:	8526                	mv	a0,s1
    800045e6:	c8afe0ef          	jal	ra,80002a70 <itrunc>
    800045ea:	b759                	j	80004570 <sys_open+0xb8>
      fileclose(f);
    800045ec:	854e                	mv	a0,s3
    800045ee:	844ff0ef          	jal	ra,80003632 <fileclose>
    iunlockput(ip);
    800045f2:	8526                	mv	a0,s1
    800045f4:	d98fe0ef          	jal	ra,80002b8c <iunlockput>
    end_op();
    800045f8:	c91fe0ef          	jal	ra,80003288 <end_op>
    return -1;
    800045fc:	557d                	li	a0,-1
    800045fe:	bfbd                	j	8000457c <sys_open+0xc4>

0000000080004600 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004600:	7175                	addi	sp,sp,-144
    80004602:	e506                	sd	ra,136(sp)
    80004604:	e122                	sd	s0,128(sp)
    80004606:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004608:	c13fe0ef          	jal	ra,8000321a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000460c:	08000613          	li	a2,128
    80004610:	f7040593          	addi	a1,s0,-144
    80004614:	4501                	li	a0,0
    80004616:	949fd0ef          	jal	ra,80001f5e <argstr>
    8000461a:	02054363          	bltz	a0,80004640 <sys_mkdir+0x40>
    8000461e:	4681                	li	a3,0
    80004620:	4601                	li	a2,0
    80004622:	4585                	li	a1,1
    80004624:	f7040513          	addi	a0,s0,-144
    80004628:	995ff0ef          	jal	ra,80003fbc <create>
    8000462c:	c911                	beqz	a0,80004640 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000462e:	d5efe0ef          	jal	ra,80002b8c <iunlockput>
  end_op();
    80004632:	c57fe0ef          	jal	ra,80003288 <end_op>
  return 0;
    80004636:	4501                	li	a0,0
}
    80004638:	60aa                	ld	ra,136(sp)
    8000463a:	640a                	ld	s0,128(sp)
    8000463c:	6149                	addi	sp,sp,144
    8000463e:	8082                	ret
    end_op();
    80004640:	c49fe0ef          	jal	ra,80003288 <end_op>
    return -1;
    80004644:	557d                	li	a0,-1
    80004646:	bfcd                	j	80004638 <sys_mkdir+0x38>

0000000080004648 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004648:	7135                	addi	sp,sp,-160
    8000464a:	ed06                	sd	ra,152(sp)
    8000464c:	e922                	sd	s0,144(sp)
    8000464e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004650:	bcbfe0ef          	jal	ra,8000321a <begin_op>
  argint(1, &major);
    80004654:	f6c40593          	addi	a1,s0,-148
    80004658:	4505                	li	a0,1
    8000465a:	8cdfd0ef          	jal	ra,80001f26 <argint>
  argint(2, &minor);
    8000465e:	f6840593          	addi	a1,s0,-152
    80004662:	4509                	li	a0,2
    80004664:	8c3fd0ef          	jal	ra,80001f26 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004668:	08000613          	li	a2,128
    8000466c:	f7040593          	addi	a1,s0,-144
    80004670:	4501                	li	a0,0
    80004672:	8edfd0ef          	jal	ra,80001f5e <argstr>
    80004676:	02054563          	bltz	a0,800046a0 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000467a:	f6841683          	lh	a3,-152(s0)
    8000467e:	f6c41603          	lh	a2,-148(s0)
    80004682:	458d                	li	a1,3
    80004684:	f7040513          	addi	a0,s0,-144
    80004688:	935ff0ef          	jal	ra,80003fbc <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000468c:	c911                	beqz	a0,800046a0 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000468e:	cfefe0ef          	jal	ra,80002b8c <iunlockput>
  end_op();
    80004692:	bf7fe0ef          	jal	ra,80003288 <end_op>
  return 0;
    80004696:	4501                	li	a0,0
}
    80004698:	60ea                	ld	ra,152(sp)
    8000469a:	644a                	ld	s0,144(sp)
    8000469c:	610d                	addi	sp,sp,160
    8000469e:	8082                	ret
    end_op();
    800046a0:	be9fe0ef          	jal	ra,80003288 <end_op>
    return -1;
    800046a4:	557d                	li	a0,-1
    800046a6:	bfcd                	j	80004698 <sys_mknod+0x50>

00000000800046a8 <sys_chdir>:

uint64
sys_chdir(void)
{
    800046a8:	7135                	addi	sp,sp,-160
    800046aa:	ed06                	sd	ra,152(sp)
    800046ac:	e922                	sd	s0,144(sp)
    800046ae:	e526                	sd	s1,136(sp)
    800046b0:	e14a                	sd	s2,128(sp)
    800046b2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800046b4:	9c5fc0ef          	jal	ra,80001078 <myproc>
    800046b8:	892a                	mv	s2,a0

  begin_op();
    800046ba:	b61fe0ef          	jal	ra,8000321a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800046be:	08000613          	li	a2,128
    800046c2:	f6040593          	addi	a1,s0,-160
    800046c6:	4501                	li	a0,0
    800046c8:	897fd0ef          	jal	ra,80001f5e <argstr>
    800046cc:	04054163          	bltz	a0,8000470e <sys_chdir+0x66>
    800046d0:	f6040513          	addi	a0,s0,-160
    800046d4:	96bfe0ef          	jal	ra,8000303e <namei>
    800046d8:	84aa                	mv	s1,a0
    800046da:	c915                	beqz	a0,8000470e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800046dc:	aaafe0ef          	jal	ra,80002986 <ilock>
  if(ip->type != T_DIR){
    800046e0:	04449703          	lh	a4,68(s1)
    800046e4:	4785                	li	a5,1
    800046e6:	02f71863          	bne	a4,a5,80004716 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800046ea:	8526                	mv	a0,s1
    800046ec:	b44fe0ef          	jal	ra,80002a30 <iunlock>
  iput(p->cwd);
    800046f0:	15093503          	ld	a0,336(s2)
    800046f4:	c10fe0ef          	jal	ra,80002b04 <iput>
  end_op();
    800046f8:	b91fe0ef          	jal	ra,80003288 <end_op>
  p->cwd = ip;
    800046fc:	14993823          	sd	s1,336(s2)
  return 0;
    80004700:	4501                	li	a0,0
}
    80004702:	60ea                	ld	ra,152(sp)
    80004704:	644a                	ld	s0,144(sp)
    80004706:	64aa                	ld	s1,136(sp)
    80004708:	690a                	ld	s2,128(sp)
    8000470a:	610d                	addi	sp,sp,160
    8000470c:	8082                	ret
    end_op();
    8000470e:	b7bfe0ef          	jal	ra,80003288 <end_op>
    return -1;
    80004712:	557d                	li	a0,-1
    80004714:	b7fd                	j	80004702 <sys_chdir+0x5a>
    iunlockput(ip);
    80004716:	8526                	mv	a0,s1
    80004718:	c74fe0ef          	jal	ra,80002b8c <iunlockput>
    end_op();
    8000471c:	b6dfe0ef          	jal	ra,80003288 <end_op>
    return -1;
    80004720:	557d                	li	a0,-1
    80004722:	b7c5                	j	80004702 <sys_chdir+0x5a>

0000000080004724 <sys_exec>:

uint64
sys_exec(void)
{
    80004724:	7145                	addi	sp,sp,-464
    80004726:	e786                	sd	ra,456(sp)
    80004728:	e3a2                	sd	s0,448(sp)
    8000472a:	ff26                	sd	s1,440(sp)
    8000472c:	fb4a                	sd	s2,432(sp)
    8000472e:	f74e                	sd	s3,424(sp)
    80004730:	f352                	sd	s4,416(sp)
    80004732:	ef56                	sd	s5,408(sp)
    80004734:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004736:	e3840593          	addi	a1,s0,-456
    8000473a:	4505                	li	a0,1
    8000473c:	807fd0ef          	jal	ra,80001f42 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004740:	08000613          	li	a2,128
    80004744:	f4040593          	addi	a1,s0,-192
    80004748:	4501                	li	a0,0
    8000474a:	815fd0ef          	jal	ra,80001f5e <argstr>
    8000474e:	87aa                	mv	a5,a0
    return -1;
    80004750:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004752:	0a07c563          	bltz	a5,800047fc <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80004756:	10000613          	li	a2,256
    8000475a:	4581                	li	a1,0
    8000475c:	e4040513          	addi	a0,s0,-448
    80004760:	b53fb0ef          	jal	ra,800002b2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004764:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004768:	89a6                	mv	s3,s1
    8000476a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000476c:	02000a13          	li	s4,32
    80004770:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004774:	00391513          	slli	a0,s2,0x3
    80004778:	e3040593          	addi	a1,s0,-464
    8000477c:	e3843783          	ld	a5,-456(s0)
    80004780:	953e                	add	a0,a0,a5
    80004782:	f1afd0ef          	jal	ra,80001e9c <fetchaddr>
    80004786:	02054663          	bltz	a0,800047b2 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    8000478a:	e3043783          	ld	a5,-464(s0)
    8000478e:	cf8d                	beqz	a5,800047c8 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004790:	9d5fb0ef          	jal	ra,80000164 <kalloc>
    80004794:	85aa                	mv	a1,a0
    80004796:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000479a:	cd01                	beqz	a0,800047b2 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000479c:	6605                	lui	a2,0x1
    8000479e:	e3043503          	ld	a0,-464(s0)
    800047a2:	f44fd0ef          	jal	ra,80001ee6 <fetchstr>
    800047a6:	00054663          	bltz	a0,800047b2 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800047aa:	0905                	addi	s2,s2,1
    800047ac:	09a1                	addi	s3,s3,8
    800047ae:	fd4911e3          	bne	s2,s4,80004770 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047b2:	f4040913          	addi	s2,s0,-192
    800047b6:	6088                	ld	a0,0(s1)
    800047b8:	c129                	beqz	a0,800047fa <sys_exec+0xd6>
    kfree(argv[i]);
    800047ba:	8b7fb0ef          	jal	ra,80000070 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047be:	04a1                	addi	s1,s1,8
    800047c0:	ff249be3          	bne	s1,s2,800047b6 <sys_exec+0x92>
  return -1;
    800047c4:	557d                	li	a0,-1
    800047c6:	a81d                	j	800047fc <sys_exec+0xd8>
      argv[i] = 0;
    800047c8:	0a8e                	slli	s5,s5,0x3
    800047ca:	fc0a8793          	addi	a5,s5,-64
    800047ce:	00878ab3          	add	s5,a5,s0
    800047d2:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800047d6:	e4040593          	addi	a1,s0,-448
    800047da:	f4040513          	addi	a0,s0,-192
    800047de:	bf6ff0ef          	jal	ra,80003bd4 <exec>
    800047e2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047e4:	f4040993          	addi	s3,s0,-192
    800047e8:	6088                	ld	a0,0(s1)
    800047ea:	c511                	beqz	a0,800047f6 <sys_exec+0xd2>
    kfree(argv[i]);
    800047ec:	885fb0ef          	jal	ra,80000070 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047f0:	04a1                	addi	s1,s1,8
    800047f2:	ff349be3          	bne	s1,s3,800047e8 <sys_exec+0xc4>
  return ret;
    800047f6:	854a                	mv	a0,s2
    800047f8:	a011                	j	800047fc <sys_exec+0xd8>
  return -1;
    800047fa:	557d                	li	a0,-1
}
    800047fc:	60be                	ld	ra,456(sp)
    800047fe:	641e                	ld	s0,448(sp)
    80004800:	74fa                	ld	s1,440(sp)
    80004802:	795a                	ld	s2,432(sp)
    80004804:	79ba                	ld	s3,424(sp)
    80004806:	7a1a                	ld	s4,416(sp)
    80004808:	6afa                	ld	s5,408(sp)
    8000480a:	6179                	addi	sp,sp,464
    8000480c:	8082                	ret

000000008000480e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000480e:	7139                	addi	sp,sp,-64
    80004810:	fc06                	sd	ra,56(sp)
    80004812:	f822                	sd	s0,48(sp)
    80004814:	f426                	sd	s1,40(sp)
    80004816:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004818:	861fc0ef          	jal	ra,80001078 <myproc>
    8000481c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000481e:	fd840593          	addi	a1,s0,-40
    80004822:	4501                	li	a0,0
    80004824:	f1efd0ef          	jal	ra,80001f42 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004828:	fc840593          	addi	a1,s0,-56
    8000482c:	fd040513          	addi	a0,s0,-48
    80004830:	8ceff0ef          	jal	ra,800038fe <pipealloc>
    return -1;
    80004834:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004836:	0a054463          	bltz	a0,800048de <sys_pipe+0xd0>
  fd0 = -1;
    8000483a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000483e:	fd043503          	ld	a0,-48(s0)
    80004842:	f3cff0ef          	jal	ra,80003f7e <fdalloc>
    80004846:	fca42223          	sw	a0,-60(s0)
    8000484a:	08054163          	bltz	a0,800048cc <sys_pipe+0xbe>
    8000484e:	fc843503          	ld	a0,-56(s0)
    80004852:	f2cff0ef          	jal	ra,80003f7e <fdalloc>
    80004856:	fca42023          	sw	a0,-64(s0)
    8000485a:	06054063          	bltz	a0,800048ba <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000485e:	4691                	li	a3,4
    80004860:	fc440613          	addi	a2,s0,-60
    80004864:	fd843583          	ld	a1,-40(s0)
    80004868:	68a8                	ld	a0,80(s1)
    8000486a:	bb2fc0ef          	jal	ra,80000c1c <copyout>
    8000486e:	00054e63          	bltz	a0,8000488a <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004872:	4691                	li	a3,4
    80004874:	fc040613          	addi	a2,s0,-64
    80004878:	fd843583          	ld	a1,-40(s0)
    8000487c:	0591                	addi	a1,a1,4
    8000487e:	68a8                	ld	a0,80(s1)
    80004880:	b9cfc0ef          	jal	ra,80000c1c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004884:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004886:	04055c63          	bgez	a0,800048de <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000488a:	fc442783          	lw	a5,-60(s0)
    8000488e:	07e9                	addi	a5,a5,26
    80004890:	078e                	slli	a5,a5,0x3
    80004892:	97a6                	add	a5,a5,s1
    80004894:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004898:	fc042783          	lw	a5,-64(s0)
    8000489c:	07e9                	addi	a5,a5,26
    8000489e:	078e                	slli	a5,a5,0x3
    800048a0:	94be                	add	s1,s1,a5
    800048a2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800048a6:	fd043503          	ld	a0,-48(s0)
    800048aa:	d89fe0ef          	jal	ra,80003632 <fileclose>
    fileclose(wf);
    800048ae:	fc843503          	ld	a0,-56(s0)
    800048b2:	d81fe0ef          	jal	ra,80003632 <fileclose>
    return -1;
    800048b6:	57fd                	li	a5,-1
    800048b8:	a01d                	j	800048de <sys_pipe+0xd0>
    if(fd0 >= 0)
    800048ba:	fc442783          	lw	a5,-60(s0)
    800048be:	0007c763          	bltz	a5,800048cc <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800048c2:	07e9                	addi	a5,a5,26
    800048c4:	078e                	slli	a5,a5,0x3
    800048c6:	97a6                	add	a5,a5,s1
    800048c8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800048cc:	fd043503          	ld	a0,-48(s0)
    800048d0:	d63fe0ef          	jal	ra,80003632 <fileclose>
    fileclose(wf);
    800048d4:	fc843503          	ld	a0,-56(s0)
    800048d8:	d5bfe0ef          	jal	ra,80003632 <fileclose>
    return -1;
    800048dc:	57fd                	li	a5,-1
}
    800048de:	853e                	mv	a0,a5
    800048e0:	70e2                	ld	ra,56(sp)
    800048e2:	7442                	ld	s0,48(sp)
    800048e4:	74a2                	ld	s1,40(sp)
    800048e6:	6121                	addi	sp,sp,64
    800048e8:	8082                	ret
    800048ea:	0000                	unimp
    800048ec:	0000                	unimp
	...

00000000800048f0 <kernelvec>:
    800048f0:	7111                	addi	sp,sp,-256
    800048f2:	e006                	sd	ra,0(sp)
    800048f4:	e40a                	sd	sp,8(sp)
    800048f6:	e80e                	sd	gp,16(sp)
    800048f8:	ec12                	sd	tp,24(sp)
    800048fa:	f016                	sd	t0,32(sp)
    800048fc:	f41a                	sd	t1,40(sp)
    800048fe:	f81e                	sd	t2,48(sp)
    80004900:	e4aa                	sd	a0,72(sp)
    80004902:	e8ae                	sd	a1,80(sp)
    80004904:	ecb2                	sd	a2,88(sp)
    80004906:	f0b6                	sd	a3,96(sp)
    80004908:	f4ba                	sd	a4,104(sp)
    8000490a:	f8be                	sd	a5,112(sp)
    8000490c:	fcc2                	sd	a6,120(sp)
    8000490e:	e146                	sd	a7,128(sp)
    80004910:	edf2                	sd	t3,216(sp)
    80004912:	f1f6                	sd	t4,224(sp)
    80004914:	f5fa                	sd	t5,232(sp)
    80004916:	f9fe                	sd	t6,240(sp)
    80004918:	c94fd0ef          	jal	ra,80001dac <kerneltrap>
    8000491c:	6082                	ld	ra,0(sp)
    8000491e:	6122                	ld	sp,8(sp)
    80004920:	61c2                	ld	gp,16(sp)
    80004922:	7282                	ld	t0,32(sp)
    80004924:	7322                	ld	t1,40(sp)
    80004926:	73c2                	ld	t2,48(sp)
    80004928:	6526                	ld	a0,72(sp)
    8000492a:	65c6                	ld	a1,80(sp)
    8000492c:	6666                	ld	a2,88(sp)
    8000492e:	7686                	ld	a3,96(sp)
    80004930:	7726                	ld	a4,104(sp)
    80004932:	77c6                	ld	a5,112(sp)
    80004934:	7866                	ld	a6,120(sp)
    80004936:	688a                	ld	a7,128(sp)
    80004938:	6e6e                	ld	t3,216(sp)
    8000493a:	7e8e                	ld	t4,224(sp)
    8000493c:	7f2e                	ld	t5,232(sp)
    8000493e:	7fce                	ld	t6,240(sp)
    80004940:	6111                	addi	sp,sp,256
    80004942:	10200073          	sret
	...

000000008000494e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000494e:	1141                	addi	sp,sp,-16
    80004950:	e422                	sd	s0,8(sp)
    80004952:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004954:	0c0007b7          	lui	a5,0xc000
    80004958:	4705                	li	a4,1
    8000495a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000495c:	c3d8                	sw	a4,4(a5)
}
    8000495e:	6422                	ld	s0,8(sp)
    80004960:	0141                	addi	sp,sp,16
    80004962:	8082                	ret

0000000080004964 <plicinithart>:

void
plicinithart(void)
{
    80004964:	1141                	addi	sp,sp,-16
    80004966:	e406                	sd	ra,8(sp)
    80004968:	e022                	sd	s0,0(sp)
    8000496a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000496c:	ee0fc0ef          	jal	ra,8000104c <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004970:	0085171b          	slliw	a4,a0,0x8
    80004974:	0c0027b7          	lui	a5,0xc002
    80004978:	97ba                	add	a5,a5,a4
    8000497a:	40200713          	li	a4,1026
    8000497e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004982:	00d5151b          	slliw	a0,a0,0xd
    80004986:	0c2017b7          	lui	a5,0xc201
    8000498a:	97aa                	add	a5,a5,a0
    8000498c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004990:	60a2                	ld	ra,8(sp)
    80004992:	6402                	ld	s0,0(sp)
    80004994:	0141                	addi	sp,sp,16
    80004996:	8082                	ret

0000000080004998 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004998:	1141                	addi	sp,sp,-16
    8000499a:	e406                	sd	ra,8(sp)
    8000499c:	e022                	sd	s0,0(sp)
    8000499e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800049a0:	eacfc0ef          	jal	ra,8000104c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800049a4:	00d5151b          	slliw	a0,a0,0xd
    800049a8:	0c2017b7          	lui	a5,0xc201
    800049ac:	97aa                	add	a5,a5,a0
  return irq;
}
    800049ae:	43c8                	lw	a0,4(a5)
    800049b0:	60a2                	ld	ra,8(sp)
    800049b2:	6402                	ld	s0,0(sp)
    800049b4:	0141                	addi	sp,sp,16
    800049b6:	8082                	ret

00000000800049b8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800049b8:	1101                	addi	sp,sp,-32
    800049ba:	ec06                	sd	ra,24(sp)
    800049bc:	e822                	sd	s0,16(sp)
    800049be:	e426                	sd	s1,8(sp)
    800049c0:	1000                	addi	s0,sp,32
    800049c2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800049c4:	e88fc0ef          	jal	ra,8000104c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800049c8:	00d5151b          	slliw	a0,a0,0xd
    800049cc:	0c2017b7          	lui	a5,0xc201
    800049d0:	97aa                	add	a5,a5,a0
    800049d2:	c3c4                	sw	s1,4(a5)
}
    800049d4:	60e2                	ld	ra,24(sp)
    800049d6:	6442                	ld	s0,16(sp)
    800049d8:	64a2                	ld	s1,8(sp)
    800049da:	6105                	addi	sp,sp,32
    800049dc:	8082                	ret

00000000800049de <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800049de:	1141                	addi	sp,sp,-16
    800049e0:	e406                	sd	ra,8(sp)
    800049e2:	e022                	sd	s0,0(sp)
    800049e4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800049e6:	479d                	li	a5,7
    800049e8:	04a7ca63          	blt	a5,a0,80004a3c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800049ec:	00014797          	auipc	a5,0x14
    800049f0:	3a478793          	addi	a5,a5,932 # 80018d90 <disk>
    800049f4:	97aa                	add	a5,a5,a0
    800049f6:	0187c783          	lbu	a5,24(a5)
    800049fa:	e7b9                	bnez	a5,80004a48 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800049fc:	00451693          	slli	a3,a0,0x4
    80004a00:	00014797          	auipc	a5,0x14
    80004a04:	39078793          	addi	a5,a5,912 # 80018d90 <disk>
    80004a08:	6398                	ld	a4,0(a5)
    80004a0a:	9736                	add	a4,a4,a3
    80004a0c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004a10:	6398                	ld	a4,0(a5)
    80004a12:	9736                	add	a4,a4,a3
    80004a14:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004a18:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004a1c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004a20:	97aa                	add	a5,a5,a0
    80004a22:	4705                	li	a4,1
    80004a24:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004a28:	00014517          	auipc	a0,0x14
    80004a2c:	38050513          	addi	a0,a0,896 # 80018da8 <disk+0x18>
    80004a30:	c61fc0ef          	jal	ra,80001690 <wakeup>
}
    80004a34:	60a2                	ld	ra,8(sp)
    80004a36:	6402                	ld	s0,0(sp)
    80004a38:	0141                	addi	sp,sp,16
    80004a3a:	8082                	ret
    panic("free_desc 1");
    80004a3c:	00003517          	auipc	a0,0x3
    80004a40:	e4c50513          	addi	a0,a0,-436 # 80007888 <syscalls+0x358>
    80004a44:	3bf000ef          	jal	ra,80005602 <panic>
    panic("free_desc 2");
    80004a48:	00003517          	auipc	a0,0x3
    80004a4c:	e5050513          	addi	a0,a0,-432 # 80007898 <syscalls+0x368>
    80004a50:	3b3000ef          	jal	ra,80005602 <panic>

0000000080004a54 <virtio_disk_init>:
{
    80004a54:	1101                	addi	sp,sp,-32
    80004a56:	ec06                	sd	ra,24(sp)
    80004a58:	e822                	sd	s0,16(sp)
    80004a5a:	e426                	sd	s1,8(sp)
    80004a5c:	e04a                	sd	s2,0(sp)
    80004a5e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004a60:	00003597          	auipc	a1,0x3
    80004a64:	e4858593          	addi	a1,a1,-440 # 800078a8 <syscalls+0x378>
    80004a68:	00014517          	auipc	a0,0x14
    80004a6c:	45050513          	addi	a0,a0,1104 # 80018eb8 <disk+0x128>
    80004a70:	623000ef          	jal	ra,80005892 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004a74:	100017b7          	lui	a5,0x10001
    80004a78:	4398                	lw	a4,0(a5)
    80004a7a:	2701                	sext.w	a4,a4
    80004a7c:	747277b7          	lui	a5,0x74727
    80004a80:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004a84:	12f71f63          	bne	a4,a5,80004bc2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004a88:	100017b7          	lui	a5,0x10001
    80004a8c:	43dc                	lw	a5,4(a5)
    80004a8e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004a90:	4709                	li	a4,2
    80004a92:	12e79863          	bne	a5,a4,80004bc2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004a96:	100017b7          	lui	a5,0x10001
    80004a9a:	479c                	lw	a5,8(a5)
    80004a9c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004a9e:	12e79263          	bne	a5,a4,80004bc2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004aa2:	100017b7          	lui	a5,0x10001
    80004aa6:	47d8                	lw	a4,12(a5)
    80004aa8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004aaa:	554d47b7          	lui	a5,0x554d4
    80004aae:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004ab2:	10f71863          	bne	a4,a5,80004bc2 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ab6:	100017b7          	lui	a5,0x10001
    80004aba:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004abe:	4705                	li	a4,1
    80004ac0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ac2:	470d                	li	a4,3
    80004ac4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004ac6:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004ac8:	c7ffe6b7          	lui	a3,0xc7ffe
    80004acc:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd78f>
    80004ad0:	8f75                	and	a4,a4,a3
    80004ad2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ad4:	472d                	li	a4,11
    80004ad6:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80004ad8:	5bbc                	lw	a5,112(a5)
    80004ada:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004ade:	8ba1                	andi	a5,a5,8
    80004ae0:	0e078763          	beqz	a5,80004bce <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004ae4:	100017b7          	lui	a5,0x10001
    80004ae8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004aec:	43fc                	lw	a5,68(a5)
    80004aee:	2781                	sext.w	a5,a5
    80004af0:	0e079563          	bnez	a5,80004bda <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004af4:	100017b7          	lui	a5,0x10001
    80004af8:	5bdc                	lw	a5,52(a5)
    80004afa:	2781                	sext.w	a5,a5
  if(max == 0)
    80004afc:	0e078563          	beqz	a5,80004be6 <virtio_disk_init+0x192>
  if(max < NUM)
    80004b00:	471d                	li	a4,7
    80004b02:	0ef77863          	bgeu	a4,a5,80004bf2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80004b06:	e5efb0ef          	jal	ra,80000164 <kalloc>
    80004b0a:	00014497          	auipc	s1,0x14
    80004b0e:	28648493          	addi	s1,s1,646 # 80018d90 <disk>
    80004b12:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004b14:	e50fb0ef          	jal	ra,80000164 <kalloc>
    80004b18:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004b1a:	e4afb0ef          	jal	ra,80000164 <kalloc>
    80004b1e:	87aa                	mv	a5,a0
    80004b20:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004b22:	6088                	ld	a0,0(s1)
    80004b24:	cd69                	beqz	a0,80004bfe <virtio_disk_init+0x1aa>
    80004b26:	00014717          	auipc	a4,0x14
    80004b2a:	27273703          	ld	a4,626(a4) # 80018d98 <disk+0x8>
    80004b2e:	cb61                	beqz	a4,80004bfe <virtio_disk_init+0x1aa>
    80004b30:	c7f9                	beqz	a5,80004bfe <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80004b32:	6605                	lui	a2,0x1
    80004b34:	4581                	li	a1,0
    80004b36:	f7cfb0ef          	jal	ra,800002b2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004b3a:	00014497          	auipc	s1,0x14
    80004b3e:	25648493          	addi	s1,s1,598 # 80018d90 <disk>
    80004b42:	6605                	lui	a2,0x1
    80004b44:	4581                	li	a1,0
    80004b46:	6488                	ld	a0,8(s1)
    80004b48:	f6afb0ef          	jal	ra,800002b2 <memset>
  memset(disk.used, 0, PGSIZE);
    80004b4c:	6605                	lui	a2,0x1
    80004b4e:	4581                	li	a1,0
    80004b50:	6888                	ld	a0,16(s1)
    80004b52:	f60fb0ef          	jal	ra,800002b2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004b56:	100017b7          	lui	a5,0x10001
    80004b5a:	4721                	li	a4,8
    80004b5c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004b5e:	4098                	lw	a4,0(s1)
    80004b60:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004b64:	40d8                	lw	a4,4(s1)
    80004b66:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004b6a:	6498                	ld	a4,8(s1)
    80004b6c:	0007069b          	sext.w	a3,a4
    80004b70:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004b74:	9701                	srai	a4,a4,0x20
    80004b76:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004b7a:	6898                	ld	a4,16(s1)
    80004b7c:	0007069b          	sext.w	a3,a4
    80004b80:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004b84:	9701                	srai	a4,a4,0x20
    80004b86:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004b8a:	4705                	li	a4,1
    80004b8c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80004b8e:	00e48c23          	sb	a4,24(s1)
    80004b92:	00e48ca3          	sb	a4,25(s1)
    80004b96:	00e48d23          	sb	a4,26(s1)
    80004b9a:	00e48da3          	sb	a4,27(s1)
    80004b9e:	00e48e23          	sb	a4,28(s1)
    80004ba2:	00e48ea3          	sb	a4,29(s1)
    80004ba6:	00e48f23          	sb	a4,30(s1)
    80004baa:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004bae:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004bb2:	0727a823          	sw	s2,112(a5)
}
    80004bb6:	60e2                	ld	ra,24(sp)
    80004bb8:	6442                	ld	s0,16(sp)
    80004bba:	64a2                	ld	s1,8(sp)
    80004bbc:	6902                	ld	s2,0(sp)
    80004bbe:	6105                	addi	sp,sp,32
    80004bc0:	8082                	ret
    panic("could not find virtio disk");
    80004bc2:	00003517          	auipc	a0,0x3
    80004bc6:	cf650513          	addi	a0,a0,-778 # 800078b8 <syscalls+0x388>
    80004bca:	239000ef          	jal	ra,80005602 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004bce:	00003517          	auipc	a0,0x3
    80004bd2:	d0a50513          	addi	a0,a0,-758 # 800078d8 <syscalls+0x3a8>
    80004bd6:	22d000ef          	jal	ra,80005602 <panic>
    panic("virtio disk should not be ready");
    80004bda:	00003517          	auipc	a0,0x3
    80004bde:	d1e50513          	addi	a0,a0,-738 # 800078f8 <syscalls+0x3c8>
    80004be2:	221000ef          	jal	ra,80005602 <panic>
    panic("virtio disk has no queue 0");
    80004be6:	00003517          	auipc	a0,0x3
    80004bea:	d3250513          	addi	a0,a0,-718 # 80007918 <syscalls+0x3e8>
    80004bee:	215000ef          	jal	ra,80005602 <panic>
    panic("virtio disk max queue too short");
    80004bf2:	00003517          	auipc	a0,0x3
    80004bf6:	d4650513          	addi	a0,a0,-698 # 80007938 <syscalls+0x408>
    80004bfa:	209000ef          	jal	ra,80005602 <panic>
    panic("virtio disk kalloc");
    80004bfe:	00003517          	auipc	a0,0x3
    80004c02:	d5a50513          	addi	a0,a0,-678 # 80007958 <syscalls+0x428>
    80004c06:	1fd000ef          	jal	ra,80005602 <panic>

0000000080004c0a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004c0a:	7119                	addi	sp,sp,-128
    80004c0c:	fc86                	sd	ra,120(sp)
    80004c0e:	f8a2                	sd	s0,112(sp)
    80004c10:	f4a6                	sd	s1,104(sp)
    80004c12:	f0ca                	sd	s2,96(sp)
    80004c14:	ecce                	sd	s3,88(sp)
    80004c16:	e8d2                	sd	s4,80(sp)
    80004c18:	e4d6                	sd	s5,72(sp)
    80004c1a:	e0da                	sd	s6,64(sp)
    80004c1c:	fc5e                	sd	s7,56(sp)
    80004c1e:	f862                	sd	s8,48(sp)
    80004c20:	f466                	sd	s9,40(sp)
    80004c22:	f06a                	sd	s10,32(sp)
    80004c24:	ec6e                	sd	s11,24(sp)
    80004c26:	0100                	addi	s0,sp,128
    80004c28:	8aaa                	mv	s5,a0
    80004c2a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004c2c:	00c52d03          	lw	s10,12(a0)
    80004c30:	001d1d1b          	slliw	s10,s10,0x1
    80004c34:	1d02                	slli	s10,s10,0x20
    80004c36:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80004c3a:	00014517          	auipc	a0,0x14
    80004c3e:	27e50513          	addi	a0,a0,638 # 80018eb8 <disk+0x128>
    80004c42:	4d1000ef          	jal	ra,80005912 <acquire>
  for(int i = 0; i < 3; i++){
    80004c46:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004c48:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004c4a:	00014b97          	auipc	s7,0x14
    80004c4e:	146b8b93          	addi	s7,s7,326 # 80018d90 <disk>
  for(int i = 0; i < 3; i++){
    80004c52:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004c54:	00014c97          	auipc	s9,0x14
    80004c58:	264c8c93          	addi	s9,s9,612 # 80018eb8 <disk+0x128>
    80004c5c:	a8a9                	j	80004cb6 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004c5e:	00fb8733          	add	a4,s7,a5
    80004c62:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80004c66:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004c68:	0207c563          	bltz	a5,80004c92 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80004c6c:	2905                	addiw	s2,s2,1
    80004c6e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004c70:	05690863          	beq	s2,s6,80004cc0 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80004c74:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004c76:	00014717          	auipc	a4,0x14
    80004c7a:	11a70713          	addi	a4,a4,282 # 80018d90 <disk>
    80004c7e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004c80:	01874683          	lbu	a3,24(a4)
    80004c84:	fee9                	bnez	a3,80004c5e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80004c86:	2785                	addiw	a5,a5,1
    80004c88:	0705                	addi	a4,a4,1
    80004c8a:	fe979be3          	bne	a5,s1,80004c80 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80004c8e:	57fd                	li	a5,-1
    80004c90:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004c92:	01205b63          	blez	s2,80004ca8 <virtio_disk_rw+0x9e>
    80004c96:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80004c98:	000a2503          	lw	a0,0(s4)
    80004c9c:	d43ff0ef          	jal	ra,800049de <free_desc>
      for(int j = 0; j < i; j++)
    80004ca0:	2d85                	addiw	s11,s11,1
    80004ca2:	0a11                	addi	s4,s4,4
    80004ca4:	ff2d9ae3          	bne	s11,s2,80004c98 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004ca8:	85e6                	mv	a1,s9
    80004caa:	00014517          	auipc	a0,0x14
    80004cae:	0fe50513          	addi	a0,a0,254 # 80018da8 <disk+0x18>
    80004cb2:	993fc0ef          	jal	ra,80001644 <sleep>
  for(int i = 0; i < 3; i++){
    80004cb6:	f8040a13          	addi	s4,s0,-128
{
    80004cba:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80004cbc:	894e                	mv	s2,s3
    80004cbe:	bf5d                	j	80004c74 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004cc0:	f8042503          	lw	a0,-128(s0)
    80004cc4:	00a50713          	addi	a4,a0,10
    80004cc8:	0712                	slli	a4,a4,0x4

  if(write)
    80004cca:	00014797          	auipc	a5,0x14
    80004cce:	0c678793          	addi	a5,a5,198 # 80018d90 <disk>
    80004cd2:	00e786b3          	add	a3,a5,a4
    80004cd6:	01803633          	snez	a2,s8
    80004cda:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004cdc:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80004ce0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004ce4:	f6070613          	addi	a2,a4,-160
    80004ce8:	6394                	ld	a3,0(a5)
    80004cea:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004cec:	00870593          	addi	a1,a4,8
    80004cf0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004cf2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004cf4:	0007b803          	ld	a6,0(a5)
    80004cf8:	9642                	add	a2,a2,a6
    80004cfa:	46c1                	li	a3,16
    80004cfc:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004cfe:	4585                	li	a1,1
    80004d00:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80004d04:	f8442683          	lw	a3,-124(s0)
    80004d08:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004d0c:	0692                	slli	a3,a3,0x4
    80004d0e:	9836                	add	a6,a6,a3
    80004d10:	058a8613          	addi	a2,s5,88
    80004d14:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80004d18:	0007b803          	ld	a6,0(a5)
    80004d1c:	96c2                	add	a3,a3,a6
    80004d1e:	40000613          	li	a2,1024
    80004d22:	c690                	sw	a2,8(a3)
  if(write)
    80004d24:	001c3613          	seqz	a2,s8
    80004d28:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004d2c:	00166613          	ori	a2,a2,1
    80004d30:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80004d34:	f8842603          	lw	a2,-120(s0)
    80004d38:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004d3c:	00250693          	addi	a3,a0,2
    80004d40:	0692                	slli	a3,a3,0x4
    80004d42:	96be                	add	a3,a3,a5
    80004d44:	58fd                	li	a7,-1
    80004d46:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004d4a:	0612                	slli	a2,a2,0x4
    80004d4c:	9832                	add	a6,a6,a2
    80004d4e:	f9070713          	addi	a4,a4,-112
    80004d52:	973e                	add	a4,a4,a5
    80004d54:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80004d58:	6398                	ld	a4,0(a5)
    80004d5a:	9732                	add	a4,a4,a2
    80004d5c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004d5e:	4609                	li	a2,2
    80004d60:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80004d64:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004d68:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80004d6c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004d70:	6794                	ld	a3,8(a5)
    80004d72:	0026d703          	lhu	a4,2(a3)
    80004d76:	8b1d                	andi	a4,a4,7
    80004d78:	0706                	slli	a4,a4,0x1
    80004d7a:	96ba                	add	a3,a3,a4
    80004d7c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004d80:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004d84:	6798                	ld	a4,8(a5)
    80004d86:	00275783          	lhu	a5,2(a4)
    80004d8a:	2785                	addiw	a5,a5,1
    80004d8c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004d90:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004d94:	100017b7          	lui	a5,0x10001
    80004d98:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004d9c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80004da0:	00014917          	auipc	s2,0x14
    80004da4:	11890913          	addi	s2,s2,280 # 80018eb8 <disk+0x128>
  while(b->disk == 1) {
    80004da8:	4485                	li	s1,1
    80004daa:	00b79a63          	bne	a5,a1,80004dbe <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80004dae:	85ca                	mv	a1,s2
    80004db0:	8556                	mv	a0,s5
    80004db2:	893fc0ef          	jal	ra,80001644 <sleep>
  while(b->disk == 1) {
    80004db6:	004aa783          	lw	a5,4(s5)
    80004dba:	fe978ae3          	beq	a5,s1,80004dae <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80004dbe:	f8042903          	lw	s2,-128(s0)
    80004dc2:	00290713          	addi	a4,s2,2
    80004dc6:	0712                	slli	a4,a4,0x4
    80004dc8:	00014797          	auipc	a5,0x14
    80004dcc:	fc878793          	addi	a5,a5,-56 # 80018d90 <disk>
    80004dd0:	97ba                	add	a5,a5,a4
    80004dd2:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004dd6:	00014997          	auipc	s3,0x14
    80004dda:	fba98993          	addi	s3,s3,-70 # 80018d90 <disk>
    80004dde:	00491713          	slli	a4,s2,0x4
    80004de2:	0009b783          	ld	a5,0(s3)
    80004de6:	97ba                	add	a5,a5,a4
    80004de8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004dec:	854a                	mv	a0,s2
    80004dee:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004df2:	bedff0ef          	jal	ra,800049de <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004df6:	8885                	andi	s1,s1,1
    80004df8:	f0fd                	bnez	s1,80004dde <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004dfa:	00014517          	auipc	a0,0x14
    80004dfe:	0be50513          	addi	a0,a0,190 # 80018eb8 <disk+0x128>
    80004e02:	3a9000ef          	jal	ra,800059aa <release>
}
    80004e06:	70e6                	ld	ra,120(sp)
    80004e08:	7446                	ld	s0,112(sp)
    80004e0a:	74a6                	ld	s1,104(sp)
    80004e0c:	7906                	ld	s2,96(sp)
    80004e0e:	69e6                	ld	s3,88(sp)
    80004e10:	6a46                	ld	s4,80(sp)
    80004e12:	6aa6                	ld	s5,72(sp)
    80004e14:	6b06                	ld	s6,64(sp)
    80004e16:	7be2                	ld	s7,56(sp)
    80004e18:	7c42                	ld	s8,48(sp)
    80004e1a:	7ca2                	ld	s9,40(sp)
    80004e1c:	7d02                	ld	s10,32(sp)
    80004e1e:	6de2                	ld	s11,24(sp)
    80004e20:	6109                	addi	sp,sp,128
    80004e22:	8082                	ret

0000000080004e24 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004e24:	1101                	addi	sp,sp,-32
    80004e26:	ec06                	sd	ra,24(sp)
    80004e28:	e822                	sd	s0,16(sp)
    80004e2a:	e426                	sd	s1,8(sp)
    80004e2c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004e2e:	00014497          	auipc	s1,0x14
    80004e32:	f6248493          	addi	s1,s1,-158 # 80018d90 <disk>
    80004e36:	00014517          	auipc	a0,0x14
    80004e3a:	08250513          	addi	a0,a0,130 # 80018eb8 <disk+0x128>
    80004e3e:	2d5000ef          	jal	ra,80005912 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004e42:	10001737          	lui	a4,0x10001
    80004e46:	533c                	lw	a5,96(a4)
    80004e48:	8b8d                	andi	a5,a5,3
    80004e4a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80004e4c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004e50:	689c                	ld	a5,16(s1)
    80004e52:	0204d703          	lhu	a4,32(s1)
    80004e56:	0027d783          	lhu	a5,2(a5)
    80004e5a:	04f70663          	beq	a4,a5,80004ea6 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80004e5e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004e62:	6898                	ld	a4,16(s1)
    80004e64:	0204d783          	lhu	a5,32(s1)
    80004e68:	8b9d                	andi	a5,a5,7
    80004e6a:	078e                	slli	a5,a5,0x3
    80004e6c:	97ba                	add	a5,a5,a4
    80004e6e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004e70:	00278713          	addi	a4,a5,2
    80004e74:	0712                	slli	a4,a4,0x4
    80004e76:	9726                	add	a4,a4,s1
    80004e78:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80004e7c:	e321                	bnez	a4,80004ebc <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004e7e:	0789                	addi	a5,a5,2
    80004e80:	0792                	slli	a5,a5,0x4
    80004e82:	97a6                	add	a5,a5,s1
    80004e84:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004e86:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004e8a:	807fc0ef          	jal	ra,80001690 <wakeup>

    disk.used_idx += 1;
    80004e8e:	0204d783          	lhu	a5,32(s1)
    80004e92:	2785                	addiw	a5,a5,1
    80004e94:	17c2                	slli	a5,a5,0x30
    80004e96:	93c1                	srli	a5,a5,0x30
    80004e98:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004e9c:	6898                	ld	a4,16(s1)
    80004e9e:	00275703          	lhu	a4,2(a4)
    80004ea2:	faf71ee3          	bne	a4,a5,80004e5e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80004ea6:	00014517          	auipc	a0,0x14
    80004eaa:	01250513          	addi	a0,a0,18 # 80018eb8 <disk+0x128>
    80004eae:	2fd000ef          	jal	ra,800059aa <release>
}
    80004eb2:	60e2                	ld	ra,24(sp)
    80004eb4:	6442                	ld	s0,16(sp)
    80004eb6:	64a2                	ld	s1,8(sp)
    80004eb8:	6105                	addi	sp,sp,32
    80004eba:	8082                	ret
      panic("virtio_disk_intr status");
    80004ebc:	00003517          	auipc	a0,0x3
    80004ec0:	ab450513          	addi	a0,a0,-1356 # 80007970 <syscalls+0x440>
    80004ec4:	73e000ef          	jal	ra,80005602 <panic>

0000000080004ec8 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004ec8:	1141                	addi	sp,sp,-16
    80004eca:	e422                	sd	s0,8(sp)
    80004ecc:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004ece:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004ed2:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004ed6:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004eda:	30a027f3          	csrr	a5,0x30a

  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63));
    80004ede:	577d                	li	a4,-1
    80004ee0:	177e                	slli	a4,a4,0x3f
    80004ee2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004ee4:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004ee8:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004eec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004ef0:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004ef4:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004ef8:	000f4737          	lui	a4,0xf4
    80004efc:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004f00:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004f02:	14d79073          	csrw	0x14d,a5
}
    80004f06:	6422                	ld	s0,8(sp)
    80004f08:	0141                	addi	sp,sp,16
    80004f0a:	8082                	ret

0000000080004f0c <start>:
{
    80004f0c:	1141                	addi	sp,sp,-16
    80004f0e:	e406                	sd	ra,8(sp)
    80004f10:	e022                	sd	s0,0(sp)
    80004f12:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004f14:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004f18:	7779                	lui	a4,0xffffe
    80004f1a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd82f>
    80004f1e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004f20:	6705                	lui	a4,0x1
    80004f22:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004f26:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004f28:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004f2c:	ffffb797          	auipc	a5,0xffffb
    80004f30:	52878793          	addi	a5,a5,1320 # 80000454 <main>
    80004f34:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004f38:	4781                	li	a5,0
    80004f3a:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004f3e:	67c1                	lui	a5,0x10
    80004f40:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004f42:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004f46:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004f4a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004f4e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004f52:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004f56:	57fd                	li	a5,-1
    80004f58:	83a9                	srli	a5,a5,0xa
    80004f5a:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004f5e:	47bd                	li	a5,15
    80004f60:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004f64:	f65ff0ef          	jal	ra,80004ec8 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004f68:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004f6c:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004f6e:	823e                	mv	tp,a5
  asm volatile("mret");
    80004f70:	30200073          	mret
}
    80004f74:	60a2                	ld	ra,8(sp)
    80004f76:	6402                	ld	s0,0(sp)
    80004f78:	0141                	addi	sp,sp,16
    80004f7a:	8082                	ret

0000000080004f7c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004f7c:	715d                	addi	sp,sp,-80
    80004f7e:	e486                	sd	ra,72(sp)
    80004f80:	e0a2                	sd	s0,64(sp)
    80004f82:	fc26                	sd	s1,56(sp)
    80004f84:	f84a                	sd	s2,48(sp)
    80004f86:	f44e                	sd	s3,40(sp)
    80004f88:	f052                	sd	s4,32(sp)
    80004f8a:	ec56                	sd	s5,24(sp)
    80004f8c:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004f8e:	04c05363          	blez	a2,80004fd4 <consolewrite+0x58>
    80004f92:	8a2a                	mv	s4,a0
    80004f94:	84ae                	mv	s1,a1
    80004f96:	89b2                	mv	s3,a2
    80004f98:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004f9a:	5afd                	li	s5,-1
    80004f9c:	4685                	li	a3,1
    80004f9e:	8626                	mv	a2,s1
    80004fa0:	85d2                	mv	a1,s4
    80004fa2:	fbf40513          	addi	a0,s0,-65
    80004fa6:	a45fc0ef          	jal	ra,800019ea <either_copyin>
    80004faa:	01550b63          	beq	a0,s5,80004fc0 <consolewrite+0x44>
      break;
    uartputc(c);
    80004fae:	fbf44503          	lbu	a0,-65(s0)
    80004fb2:	7da000ef          	jal	ra,8000578c <uartputc>
  for(i = 0; i < n; i++){
    80004fb6:	2905                	addiw	s2,s2,1
    80004fb8:	0485                	addi	s1,s1,1
    80004fba:	ff2991e3          	bne	s3,s2,80004f9c <consolewrite+0x20>
    80004fbe:	894e                	mv	s2,s3
  }

  return i;
}
    80004fc0:	854a                	mv	a0,s2
    80004fc2:	60a6                	ld	ra,72(sp)
    80004fc4:	6406                	ld	s0,64(sp)
    80004fc6:	74e2                	ld	s1,56(sp)
    80004fc8:	7942                	ld	s2,48(sp)
    80004fca:	79a2                	ld	s3,40(sp)
    80004fcc:	7a02                	ld	s4,32(sp)
    80004fce:	6ae2                	ld	s5,24(sp)
    80004fd0:	6161                	addi	sp,sp,80
    80004fd2:	8082                	ret
  for(i = 0; i < n; i++){
    80004fd4:	4901                	li	s2,0
    80004fd6:	b7ed                	j	80004fc0 <consolewrite+0x44>

0000000080004fd8 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004fd8:	7159                	addi	sp,sp,-112
    80004fda:	f486                	sd	ra,104(sp)
    80004fdc:	f0a2                	sd	s0,96(sp)
    80004fde:	eca6                	sd	s1,88(sp)
    80004fe0:	e8ca                	sd	s2,80(sp)
    80004fe2:	e4ce                	sd	s3,72(sp)
    80004fe4:	e0d2                	sd	s4,64(sp)
    80004fe6:	fc56                	sd	s5,56(sp)
    80004fe8:	f85a                	sd	s6,48(sp)
    80004fea:	f45e                	sd	s7,40(sp)
    80004fec:	f062                	sd	s8,32(sp)
    80004fee:	ec66                	sd	s9,24(sp)
    80004ff0:	e86a                	sd	s10,16(sp)
    80004ff2:	1880                	addi	s0,sp,112
    80004ff4:	8aaa                	mv	s5,a0
    80004ff6:	8a2e                	mv	s4,a1
    80004ff8:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004ffa:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004ffe:	0001c517          	auipc	a0,0x1c
    80005002:	ed250513          	addi	a0,a0,-302 # 80020ed0 <cons>
    80005006:	10d000ef          	jal	ra,80005912 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000500a:	0001c497          	auipc	s1,0x1c
    8000500e:	ec648493          	addi	s1,s1,-314 # 80020ed0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005012:	0001c917          	auipc	s2,0x1c
    80005016:	f5690913          	addi	s2,s2,-170 # 80020f68 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000501a:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000501c:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000501e:	4ca9                	li	s9,10
  while(n > 0){
    80005020:	07305363          	blez	s3,80005086 <consoleread+0xae>
    while(cons.r == cons.w){
    80005024:	0984a783          	lw	a5,152(s1)
    80005028:	09c4a703          	lw	a4,156(s1)
    8000502c:	02f71163          	bne	a4,a5,8000504e <consoleread+0x76>
      if(killed(myproc())){
    80005030:	848fc0ef          	jal	ra,80001078 <myproc>
    80005034:	849fc0ef          	jal	ra,8000187c <killed>
    80005038:	e125                	bnez	a0,80005098 <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    8000503a:	85a6                	mv	a1,s1
    8000503c:	854a                	mv	a0,s2
    8000503e:	e06fc0ef          	jal	ra,80001644 <sleep>
    while(cons.r == cons.w){
    80005042:	0984a783          	lw	a5,152(s1)
    80005046:	09c4a703          	lw	a4,156(s1)
    8000504a:	fef703e3          	beq	a4,a5,80005030 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    8000504e:	0017871b          	addiw	a4,a5,1
    80005052:	08e4ac23          	sw	a4,152(s1)
    80005056:	07f7f713          	andi	a4,a5,127
    8000505a:	9726                	add	a4,a4,s1
    8000505c:	01874703          	lbu	a4,24(a4)
    80005060:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80005064:	057d0f63          	beq	s10,s7,800050c2 <consoleread+0xea>
    cbuf = c;
    80005068:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000506c:	4685                	li	a3,1
    8000506e:	f9f40613          	addi	a2,s0,-97
    80005072:	85d2                	mv	a1,s4
    80005074:	8556                	mv	a0,s5
    80005076:	92bfc0ef          	jal	ra,800019a0 <either_copyout>
    8000507a:	01850663          	beq	a0,s8,80005086 <consoleread+0xae>
    dst++;
    8000507e:	0a05                	addi	s4,s4,1
    --n;
    80005080:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80005082:	f99d1fe3          	bne	s10,s9,80005020 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80005086:	0001c517          	auipc	a0,0x1c
    8000508a:	e4a50513          	addi	a0,a0,-438 # 80020ed0 <cons>
    8000508e:	11d000ef          	jal	ra,800059aa <release>

  return target - n;
    80005092:	413b053b          	subw	a0,s6,s3
    80005096:	a801                	j	800050a6 <consoleread+0xce>
        release(&cons.lock);
    80005098:	0001c517          	auipc	a0,0x1c
    8000509c:	e3850513          	addi	a0,a0,-456 # 80020ed0 <cons>
    800050a0:	10b000ef          	jal	ra,800059aa <release>
        return -1;
    800050a4:	557d                	li	a0,-1
}
    800050a6:	70a6                	ld	ra,104(sp)
    800050a8:	7406                	ld	s0,96(sp)
    800050aa:	64e6                	ld	s1,88(sp)
    800050ac:	6946                	ld	s2,80(sp)
    800050ae:	69a6                	ld	s3,72(sp)
    800050b0:	6a06                	ld	s4,64(sp)
    800050b2:	7ae2                	ld	s5,56(sp)
    800050b4:	7b42                	ld	s6,48(sp)
    800050b6:	7ba2                	ld	s7,40(sp)
    800050b8:	7c02                	ld	s8,32(sp)
    800050ba:	6ce2                	ld	s9,24(sp)
    800050bc:	6d42                	ld	s10,16(sp)
    800050be:	6165                	addi	sp,sp,112
    800050c0:	8082                	ret
      if(n < target){
    800050c2:	0009871b          	sext.w	a4,s3
    800050c6:	fd6770e3          	bgeu	a4,s6,80005086 <consoleread+0xae>
        cons.r--;
    800050ca:	0001c717          	auipc	a4,0x1c
    800050ce:	e8f72f23          	sw	a5,-354(a4) # 80020f68 <cons+0x98>
    800050d2:	bf55                	j	80005086 <consoleread+0xae>

00000000800050d4 <consputc>:
{
    800050d4:	1141                	addi	sp,sp,-16
    800050d6:	e406                	sd	ra,8(sp)
    800050d8:	e022                	sd	s0,0(sp)
    800050da:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800050dc:	10000793          	li	a5,256
    800050e0:	00f50863          	beq	a0,a5,800050f0 <consputc+0x1c>
    uartputc_sync(c);
    800050e4:	5d2000ef          	jal	ra,800056b6 <uartputc_sync>
}
    800050e8:	60a2                	ld	ra,8(sp)
    800050ea:	6402                	ld	s0,0(sp)
    800050ec:	0141                	addi	sp,sp,16
    800050ee:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800050f0:	4521                	li	a0,8
    800050f2:	5c4000ef          	jal	ra,800056b6 <uartputc_sync>
    800050f6:	02000513          	li	a0,32
    800050fa:	5bc000ef          	jal	ra,800056b6 <uartputc_sync>
    800050fe:	4521                	li	a0,8
    80005100:	5b6000ef          	jal	ra,800056b6 <uartputc_sync>
    80005104:	b7d5                	j	800050e8 <consputc+0x14>

0000000080005106 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005106:	1101                	addi	sp,sp,-32
    80005108:	ec06                	sd	ra,24(sp)
    8000510a:	e822                	sd	s0,16(sp)
    8000510c:	e426                	sd	s1,8(sp)
    8000510e:	e04a                	sd	s2,0(sp)
    80005110:	1000                	addi	s0,sp,32
    80005112:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005114:	0001c517          	auipc	a0,0x1c
    80005118:	dbc50513          	addi	a0,a0,-580 # 80020ed0 <cons>
    8000511c:	7f6000ef          	jal	ra,80005912 <acquire>

  switch(c){
    80005120:	47d5                	li	a5,21
    80005122:	0af48063          	beq	s1,a5,800051c2 <consoleintr+0xbc>
    80005126:	0297c663          	blt	a5,s1,80005152 <consoleintr+0x4c>
    8000512a:	47a1                	li	a5,8
    8000512c:	0cf48f63          	beq	s1,a5,8000520a <consoleintr+0x104>
    80005130:	47c1                	li	a5,16
    80005132:	10f49063          	bne	s1,a5,80005232 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    80005136:	8fffc0ef          	jal	ra,80001a34 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    8000513a:	0001c517          	auipc	a0,0x1c
    8000513e:	d9650513          	addi	a0,a0,-618 # 80020ed0 <cons>
    80005142:	069000ef          	jal	ra,800059aa <release>
}
    80005146:	60e2                	ld	ra,24(sp)
    80005148:	6442                	ld	s0,16(sp)
    8000514a:	64a2                	ld	s1,8(sp)
    8000514c:	6902                	ld	s2,0(sp)
    8000514e:	6105                	addi	sp,sp,32
    80005150:	8082                	ret
  switch(c){
    80005152:	07f00793          	li	a5,127
    80005156:	0af48a63          	beq	s1,a5,8000520a <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000515a:	0001c717          	auipc	a4,0x1c
    8000515e:	d7670713          	addi	a4,a4,-650 # 80020ed0 <cons>
    80005162:	0a072783          	lw	a5,160(a4)
    80005166:	09872703          	lw	a4,152(a4)
    8000516a:	9f99                	subw	a5,a5,a4
    8000516c:	07f00713          	li	a4,127
    80005170:	fcf765e3          	bltu	a4,a5,8000513a <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    80005174:	47b5                	li	a5,13
    80005176:	0cf48163          	beq	s1,a5,80005238 <consoleintr+0x132>
      consputc(c);
    8000517a:	8526                	mv	a0,s1
    8000517c:	f59ff0ef          	jal	ra,800050d4 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005180:	0001c797          	auipc	a5,0x1c
    80005184:	d5078793          	addi	a5,a5,-688 # 80020ed0 <cons>
    80005188:	0a07a683          	lw	a3,160(a5)
    8000518c:	0016871b          	addiw	a4,a3,1
    80005190:	0007061b          	sext.w	a2,a4
    80005194:	0ae7a023          	sw	a4,160(a5)
    80005198:	07f6f693          	andi	a3,a3,127
    8000519c:	97b6                	add	a5,a5,a3
    8000519e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    800051a2:	47a9                	li	a5,10
    800051a4:	0af48f63          	beq	s1,a5,80005262 <consoleintr+0x15c>
    800051a8:	4791                	li	a5,4
    800051aa:	0af48c63          	beq	s1,a5,80005262 <consoleintr+0x15c>
    800051ae:	0001c797          	auipc	a5,0x1c
    800051b2:	dba7a783          	lw	a5,-582(a5) # 80020f68 <cons+0x98>
    800051b6:	9f1d                	subw	a4,a4,a5
    800051b8:	08000793          	li	a5,128
    800051bc:	f6f71fe3          	bne	a4,a5,8000513a <consoleintr+0x34>
    800051c0:	a04d                	j	80005262 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    800051c2:	0001c717          	auipc	a4,0x1c
    800051c6:	d0e70713          	addi	a4,a4,-754 # 80020ed0 <cons>
    800051ca:	0a072783          	lw	a5,160(a4)
    800051ce:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800051d2:	0001c497          	auipc	s1,0x1c
    800051d6:	cfe48493          	addi	s1,s1,-770 # 80020ed0 <cons>
    while(cons.e != cons.w &&
    800051da:	4929                	li	s2,10
    800051dc:	f4f70fe3          	beq	a4,a5,8000513a <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800051e0:	37fd                	addiw	a5,a5,-1
    800051e2:	07f7f713          	andi	a4,a5,127
    800051e6:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800051e8:	01874703          	lbu	a4,24(a4)
    800051ec:	f52707e3          	beq	a4,s2,8000513a <consoleintr+0x34>
      cons.e--;
    800051f0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800051f4:	10000513          	li	a0,256
    800051f8:	eddff0ef          	jal	ra,800050d4 <consputc>
    while(cons.e != cons.w &&
    800051fc:	0a04a783          	lw	a5,160(s1)
    80005200:	09c4a703          	lw	a4,156(s1)
    80005204:	fcf71ee3          	bne	a4,a5,800051e0 <consoleintr+0xda>
    80005208:	bf0d                	j	8000513a <consoleintr+0x34>
    if(cons.e != cons.w){
    8000520a:	0001c717          	auipc	a4,0x1c
    8000520e:	cc670713          	addi	a4,a4,-826 # 80020ed0 <cons>
    80005212:	0a072783          	lw	a5,160(a4)
    80005216:	09c72703          	lw	a4,156(a4)
    8000521a:	f2f700e3          	beq	a4,a5,8000513a <consoleintr+0x34>
      cons.e--;
    8000521e:	37fd                	addiw	a5,a5,-1
    80005220:	0001c717          	auipc	a4,0x1c
    80005224:	d4f72823          	sw	a5,-688(a4) # 80020f70 <cons+0xa0>
      consputc(BACKSPACE);
    80005228:	10000513          	li	a0,256
    8000522c:	ea9ff0ef          	jal	ra,800050d4 <consputc>
    80005230:	b729                	j	8000513a <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005232:	f00484e3          	beqz	s1,8000513a <consoleintr+0x34>
    80005236:	b715                	j	8000515a <consoleintr+0x54>
      consputc(c);
    80005238:	4529                	li	a0,10
    8000523a:	e9bff0ef          	jal	ra,800050d4 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000523e:	0001c797          	auipc	a5,0x1c
    80005242:	c9278793          	addi	a5,a5,-878 # 80020ed0 <cons>
    80005246:	0a07a703          	lw	a4,160(a5)
    8000524a:	0017069b          	addiw	a3,a4,1
    8000524e:	0006861b          	sext.w	a2,a3
    80005252:	0ad7a023          	sw	a3,160(a5)
    80005256:	07f77713          	andi	a4,a4,127
    8000525a:	97ba                	add	a5,a5,a4
    8000525c:	4729                	li	a4,10
    8000525e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005262:	0001c797          	auipc	a5,0x1c
    80005266:	d0c7a523          	sw	a2,-758(a5) # 80020f6c <cons+0x9c>
        wakeup(&cons.r);
    8000526a:	0001c517          	auipc	a0,0x1c
    8000526e:	cfe50513          	addi	a0,a0,-770 # 80020f68 <cons+0x98>
    80005272:	c1efc0ef          	jal	ra,80001690 <wakeup>
    80005276:	b5d1                	j	8000513a <consoleintr+0x34>

0000000080005278 <consoleinit>:

void
consoleinit(void)
{
    80005278:	1141                	addi	sp,sp,-16
    8000527a:	e406                	sd	ra,8(sp)
    8000527c:	e022                	sd	s0,0(sp)
    8000527e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005280:	00002597          	auipc	a1,0x2
    80005284:	70858593          	addi	a1,a1,1800 # 80007988 <syscalls+0x458>
    80005288:	0001c517          	auipc	a0,0x1c
    8000528c:	c4850513          	addi	a0,a0,-952 # 80020ed0 <cons>
    80005290:	602000ef          	jal	ra,80005892 <initlock>

  uartinit();
    80005294:	3d6000ef          	jal	ra,8000566a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005298:	00013797          	auipc	a5,0x13
    8000529c:	aa078793          	addi	a5,a5,-1376 # 80017d38 <devsw>
    800052a0:	00000717          	auipc	a4,0x0
    800052a4:	d3870713          	addi	a4,a4,-712 # 80004fd8 <consoleread>
    800052a8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800052aa:	00000717          	auipc	a4,0x0
    800052ae:	cd270713          	addi	a4,a4,-814 # 80004f7c <consolewrite>
    800052b2:	ef98                	sd	a4,24(a5)
}
    800052b4:	60a2                	ld	ra,8(sp)
    800052b6:	6402                	ld	s0,0(sp)
    800052b8:	0141                	addi	sp,sp,16
    800052ba:	8082                	ret

00000000800052bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    800052bc:	7179                	addi	sp,sp,-48
    800052be:	f406                	sd	ra,40(sp)
    800052c0:	f022                	sd	s0,32(sp)
    800052c2:	ec26                	sd	s1,24(sp)
    800052c4:	e84a                	sd	s2,16(sp)
    800052c6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    800052c8:	c219                	beqz	a2,800052ce <printint+0x12>
    800052ca:	06054e63          	bltz	a0,80005346 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    800052ce:	4881                	li	a7,0
    800052d0:	fd040693          	addi	a3,s0,-48

  i = 0;
    800052d4:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    800052d6:	00002617          	auipc	a2,0x2
    800052da:	6da60613          	addi	a2,a2,1754 # 800079b0 <digits>
    800052de:	883e                	mv	a6,a5
    800052e0:	2785                	addiw	a5,a5,1
    800052e2:	02b57733          	remu	a4,a0,a1
    800052e6:	9732                	add	a4,a4,a2
    800052e8:	00074703          	lbu	a4,0(a4)
    800052ec:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800052f0:	872a                	mv	a4,a0
    800052f2:	02b55533          	divu	a0,a0,a1
    800052f6:	0685                	addi	a3,a3,1
    800052f8:	feb773e3          	bgeu	a4,a1,800052de <printint+0x22>

  if(sign)
    800052fc:	00088a63          	beqz	a7,80005310 <printint+0x54>
    buf[i++] = '-';
    80005300:	1781                	addi	a5,a5,-32
    80005302:	97a2                	add	a5,a5,s0
    80005304:	02d00713          	li	a4,45
    80005308:	fee78823          	sb	a4,-16(a5)
    8000530c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005310:	02f05563          	blez	a5,8000533a <printint+0x7e>
    80005314:	fd040713          	addi	a4,s0,-48
    80005318:	00f704b3          	add	s1,a4,a5
    8000531c:	fff70913          	addi	s2,a4,-1
    80005320:	993e                	add	s2,s2,a5
    80005322:	37fd                	addiw	a5,a5,-1
    80005324:	1782                	slli	a5,a5,0x20
    80005326:	9381                	srli	a5,a5,0x20
    80005328:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000532c:	fff4c503          	lbu	a0,-1(s1)
    80005330:	da5ff0ef          	jal	ra,800050d4 <consputc>
  while(--i >= 0)
    80005334:	14fd                	addi	s1,s1,-1
    80005336:	ff249be3          	bne	s1,s2,8000532c <printint+0x70>
}
    8000533a:	70a2                	ld	ra,40(sp)
    8000533c:	7402                	ld	s0,32(sp)
    8000533e:	64e2                	ld	s1,24(sp)
    80005340:	6942                	ld	s2,16(sp)
    80005342:	6145                	addi	sp,sp,48
    80005344:	8082                	ret
    x = -xx;
    80005346:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000534a:	4885                	li	a7,1
    x = -xx;
    8000534c:	b751                	j	800052d0 <printint+0x14>

000000008000534e <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000534e:	7155                	addi	sp,sp,-208
    80005350:	e506                	sd	ra,136(sp)
    80005352:	e122                	sd	s0,128(sp)
    80005354:	fca6                	sd	s1,120(sp)
    80005356:	f8ca                	sd	s2,112(sp)
    80005358:	f4ce                	sd	s3,104(sp)
    8000535a:	f0d2                	sd	s4,96(sp)
    8000535c:	ecd6                	sd	s5,88(sp)
    8000535e:	e8da                	sd	s6,80(sp)
    80005360:	e4de                	sd	s7,72(sp)
    80005362:	e0e2                	sd	s8,64(sp)
    80005364:	fc66                	sd	s9,56(sp)
    80005366:	f86a                	sd	s10,48(sp)
    80005368:	f46e                	sd	s11,40(sp)
    8000536a:	0900                	addi	s0,sp,144
    8000536c:	8a2a                	mv	s4,a0
    8000536e:	e40c                	sd	a1,8(s0)
    80005370:	e810                	sd	a2,16(s0)
    80005372:	ec14                	sd	a3,24(s0)
    80005374:	f018                	sd	a4,32(s0)
    80005376:	f41c                	sd	a5,40(s0)
    80005378:	03043823          	sd	a6,48(s0)
    8000537c:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    80005380:	0001c797          	auipc	a5,0x1c
    80005384:	c107a783          	lw	a5,-1008(a5) # 80020f90 <pr+0x18>
    80005388:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    8000538c:	eb9d                	bnez	a5,800053c2 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    8000538e:	00840793          	addi	a5,s0,8
    80005392:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005396:	00054503          	lbu	a0,0(a0)
    8000539a:	24050463          	beqz	a0,800055e2 <printf+0x294>
    8000539e:	4981                	li	s3,0
    if(cx != '%'){
    800053a0:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800053a4:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800053a8:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    800053ac:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    800053b0:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    800053b4:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800053b8:	00002b97          	auipc	s7,0x2
    800053bc:	5f8b8b93          	addi	s7,s7,1528 # 800079b0 <digits>
    800053c0:	a081                	j	80005400 <printf+0xb2>
    acquire(&pr.lock);
    800053c2:	0001c517          	auipc	a0,0x1c
    800053c6:	bb650513          	addi	a0,a0,-1098 # 80020f78 <pr>
    800053ca:	548000ef          	jal	ra,80005912 <acquire>
  va_start(ap, fmt);
    800053ce:	00840793          	addi	a5,s0,8
    800053d2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800053d6:	000a4503          	lbu	a0,0(s4)
    800053da:	f171                	bnez	a0,8000539e <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    800053dc:	0001c517          	auipc	a0,0x1c
    800053e0:	b9c50513          	addi	a0,a0,-1124 # 80020f78 <pr>
    800053e4:	5c6000ef          	jal	ra,800059aa <release>
    800053e8:	aaed                	j	800055e2 <printf+0x294>
      consputc(cx);
    800053ea:	cebff0ef          	jal	ra,800050d4 <consputc>
      continue;
    800053ee:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800053f0:	0014899b          	addiw	s3,s1,1
    800053f4:	013a07b3          	add	a5,s4,s3
    800053f8:	0007c503          	lbu	a0,0(a5)
    800053fc:	1c050f63          	beqz	a0,800055da <printf+0x28c>
    if(cx != '%'){
    80005400:	ff5515e3          	bne	a0,s5,800053ea <printf+0x9c>
    i++;
    80005404:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005408:	009a07b3          	add	a5,s4,s1
    8000540c:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005410:	1c090563          	beqz	s2,800055da <printf+0x28c>
    80005414:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005418:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000541a:	c789                	beqz	a5,80005424 <printf+0xd6>
    8000541c:	009a0733          	add	a4,s4,s1
    80005420:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005424:	03690463          	beq	s2,s6,8000544c <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80005428:	03890e63          	beq	s2,s8,80005464 <printf+0x116>
    } else if(c0 == 'u'){
    8000542c:	0b990d63          	beq	s2,s9,800054e6 <printf+0x198>
    } else if(c0 == 'x'){
    80005430:	11a90363          	beq	s2,s10,80005536 <printf+0x1e8>
    } else if(c0 == 'p'){
    80005434:	13b90b63          	beq	s2,s11,8000556a <printf+0x21c>
    } else if(c0 == 's'){
    80005438:	07300793          	li	a5,115
    8000543c:	16f90363          	beq	s2,a5,800055a2 <printf+0x254>
    } else if(c0 == '%'){
    80005440:	03591c63          	bne	s2,s5,80005478 <printf+0x12a>
      consputc('%');
    80005444:	8556                	mv	a0,s5
    80005446:	c8fff0ef          	jal	ra,800050d4 <consputc>
    8000544a:	b75d                	j	800053f0 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    8000544c:	f8843783          	ld	a5,-120(s0)
    80005450:	00878713          	addi	a4,a5,8
    80005454:	f8e43423          	sd	a4,-120(s0)
    80005458:	4605                	li	a2,1
    8000545a:	45a9                	li	a1,10
    8000545c:	4388                	lw	a0,0(a5)
    8000545e:	e5fff0ef          	jal	ra,800052bc <printint>
    80005462:	b779                	j	800053f0 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    80005464:	03678163          	beq	a5,s6,80005486 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005468:	03878d63          	beq	a5,s8,800054a2 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    8000546c:	09978963          	beq	a5,s9,800054fe <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005470:	03878b63          	beq	a5,s8,800054a6 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    80005474:	0da78d63          	beq	a5,s10,8000554e <printf+0x200>
      consputc('%');
    80005478:	8556                	mv	a0,s5
    8000547a:	c5bff0ef          	jal	ra,800050d4 <consputc>
      consputc(c0);
    8000547e:	854a                	mv	a0,s2
    80005480:	c55ff0ef          	jal	ra,800050d4 <consputc>
    80005484:	b7b5                	j	800053f0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    80005486:	f8843783          	ld	a5,-120(s0)
    8000548a:	00878713          	addi	a4,a5,8
    8000548e:	f8e43423          	sd	a4,-120(s0)
    80005492:	4605                	li	a2,1
    80005494:	45a9                	li	a1,10
    80005496:	6388                	ld	a0,0(a5)
    80005498:	e25ff0ef          	jal	ra,800052bc <printint>
      i += 1;
    8000549c:	0029849b          	addiw	s1,s3,2
    800054a0:	bf81                	j	800053f0 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800054a2:	03668463          	beq	a3,s6,800054ca <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800054a6:	07968a63          	beq	a3,s9,8000551a <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800054aa:	fda697e3          	bne	a3,s10,80005478 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    800054ae:	f8843783          	ld	a5,-120(s0)
    800054b2:	00878713          	addi	a4,a5,8
    800054b6:	f8e43423          	sd	a4,-120(s0)
    800054ba:	4601                	li	a2,0
    800054bc:	45c1                	li	a1,16
    800054be:	6388                	ld	a0,0(a5)
    800054c0:	dfdff0ef          	jal	ra,800052bc <printint>
      i += 2;
    800054c4:	0039849b          	addiw	s1,s3,3
    800054c8:	b725                	j	800053f0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800054ca:	f8843783          	ld	a5,-120(s0)
    800054ce:	00878713          	addi	a4,a5,8
    800054d2:	f8e43423          	sd	a4,-120(s0)
    800054d6:	4605                	li	a2,1
    800054d8:	45a9                	li	a1,10
    800054da:	6388                	ld	a0,0(a5)
    800054dc:	de1ff0ef          	jal	ra,800052bc <printint>
      i += 2;
    800054e0:	0039849b          	addiw	s1,s3,3
    800054e4:	b731                	j	800053f0 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    800054e6:	f8843783          	ld	a5,-120(s0)
    800054ea:	00878713          	addi	a4,a5,8
    800054ee:	f8e43423          	sd	a4,-120(s0)
    800054f2:	4601                	li	a2,0
    800054f4:	45a9                	li	a1,10
    800054f6:	4388                	lw	a0,0(a5)
    800054f8:	dc5ff0ef          	jal	ra,800052bc <printint>
    800054fc:	bdd5                	j	800053f0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    800054fe:	f8843783          	ld	a5,-120(s0)
    80005502:	00878713          	addi	a4,a5,8
    80005506:	f8e43423          	sd	a4,-120(s0)
    8000550a:	4601                	li	a2,0
    8000550c:	45a9                	li	a1,10
    8000550e:	6388                	ld	a0,0(a5)
    80005510:	dadff0ef          	jal	ra,800052bc <printint>
      i += 1;
    80005514:	0029849b          	addiw	s1,s3,2
    80005518:	bde1                	j	800053f0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000551a:	f8843783          	ld	a5,-120(s0)
    8000551e:	00878713          	addi	a4,a5,8
    80005522:	f8e43423          	sd	a4,-120(s0)
    80005526:	4601                	li	a2,0
    80005528:	45a9                	li	a1,10
    8000552a:	6388                	ld	a0,0(a5)
    8000552c:	d91ff0ef          	jal	ra,800052bc <printint>
      i += 2;
    80005530:	0039849b          	addiw	s1,s3,3
    80005534:	bd75                	j	800053f0 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    80005536:	f8843783          	ld	a5,-120(s0)
    8000553a:	00878713          	addi	a4,a5,8
    8000553e:	f8e43423          	sd	a4,-120(s0)
    80005542:	4601                	li	a2,0
    80005544:	45c1                	li	a1,16
    80005546:	4388                	lw	a0,0(a5)
    80005548:	d75ff0ef          	jal	ra,800052bc <printint>
    8000554c:	b555                	j	800053f0 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    8000554e:	f8843783          	ld	a5,-120(s0)
    80005552:	00878713          	addi	a4,a5,8
    80005556:	f8e43423          	sd	a4,-120(s0)
    8000555a:	4601                	li	a2,0
    8000555c:	45c1                	li	a1,16
    8000555e:	6388                	ld	a0,0(a5)
    80005560:	d5dff0ef          	jal	ra,800052bc <printint>
      i += 1;
    80005564:	0029849b          	addiw	s1,s3,2
    80005568:	b561                	j	800053f0 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    8000556a:	f8843783          	ld	a5,-120(s0)
    8000556e:	00878713          	addi	a4,a5,8
    80005572:	f8e43423          	sd	a4,-120(s0)
    80005576:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000557a:	03000513          	li	a0,48
    8000557e:	b57ff0ef          	jal	ra,800050d4 <consputc>
  consputc('x');
    80005582:	856a                	mv	a0,s10
    80005584:	b51ff0ef          	jal	ra,800050d4 <consputc>
    80005588:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000558a:	03c9d793          	srli	a5,s3,0x3c
    8000558e:	97de                	add	a5,a5,s7
    80005590:	0007c503          	lbu	a0,0(a5)
    80005594:	b41ff0ef          	jal	ra,800050d4 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005598:	0992                	slli	s3,s3,0x4
    8000559a:	397d                	addiw	s2,s2,-1
    8000559c:	fe0917e3          	bnez	s2,8000558a <printf+0x23c>
    800055a0:	bd81                	j	800053f0 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    800055a2:	f8843783          	ld	a5,-120(s0)
    800055a6:	00878713          	addi	a4,a5,8
    800055aa:	f8e43423          	sd	a4,-120(s0)
    800055ae:	0007b903          	ld	s2,0(a5)
    800055b2:	00090d63          	beqz	s2,800055cc <printf+0x27e>
      for(; *s; s++)
    800055b6:	00094503          	lbu	a0,0(s2)
    800055ba:	e2050be3          	beqz	a0,800053f0 <printf+0xa2>
        consputc(*s);
    800055be:	b17ff0ef          	jal	ra,800050d4 <consputc>
      for(; *s; s++)
    800055c2:	0905                	addi	s2,s2,1
    800055c4:	00094503          	lbu	a0,0(s2)
    800055c8:	f97d                	bnez	a0,800055be <printf+0x270>
    800055ca:	b51d                	j	800053f0 <printf+0xa2>
        s = "(null)";
    800055cc:	00002917          	auipc	s2,0x2
    800055d0:	3c490913          	addi	s2,s2,964 # 80007990 <syscalls+0x460>
      for(; *s; s++)
    800055d4:	02800513          	li	a0,40
    800055d8:	b7dd                	j	800055be <printf+0x270>
  if(locking)
    800055da:	f7843783          	ld	a5,-136(s0)
    800055de:	de079fe3          	bnez	a5,800053dc <printf+0x8e>

  return 0;
}
    800055e2:	4501                	li	a0,0
    800055e4:	60aa                	ld	ra,136(sp)
    800055e6:	640a                	ld	s0,128(sp)
    800055e8:	74e6                	ld	s1,120(sp)
    800055ea:	7946                	ld	s2,112(sp)
    800055ec:	79a6                	ld	s3,104(sp)
    800055ee:	7a06                	ld	s4,96(sp)
    800055f0:	6ae6                	ld	s5,88(sp)
    800055f2:	6b46                	ld	s6,80(sp)
    800055f4:	6ba6                	ld	s7,72(sp)
    800055f6:	6c06                	ld	s8,64(sp)
    800055f8:	7ce2                	ld	s9,56(sp)
    800055fa:	7d42                	ld	s10,48(sp)
    800055fc:	7da2                	ld	s11,40(sp)
    800055fe:	6169                	addi	sp,sp,208
    80005600:	8082                	ret

0000000080005602 <panic>:

void
panic(char *s)
{
    80005602:	1101                	addi	sp,sp,-32
    80005604:	ec06                	sd	ra,24(sp)
    80005606:	e822                	sd	s0,16(sp)
    80005608:	e426                	sd	s1,8(sp)
    8000560a:	1000                	addi	s0,sp,32
    8000560c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000560e:	0001c797          	auipc	a5,0x1c
    80005612:	9807a123          	sw	zero,-1662(a5) # 80020f90 <pr+0x18>
  printf("panic: ");
    80005616:	00002517          	auipc	a0,0x2
    8000561a:	38250513          	addi	a0,a0,898 # 80007998 <syscalls+0x468>
    8000561e:	d31ff0ef          	jal	ra,8000534e <printf>
  printf("%s\n", s);
    80005622:	85a6                	mv	a1,s1
    80005624:	00002517          	auipc	a0,0x2
    80005628:	37c50513          	addi	a0,a0,892 # 800079a0 <syscalls+0x470>
    8000562c:	d23ff0ef          	jal	ra,8000534e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005630:	4785                	li	a5,1
    80005632:	00002717          	auipc	a4,0x2
    80005636:	44f72d23          	sw	a5,1114(a4) # 80007a8c <panicked>
  for(;;)
    8000563a:	a001                	j	8000563a <panic+0x38>

000000008000563c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000563c:	1101                	addi	sp,sp,-32
    8000563e:	ec06                	sd	ra,24(sp)
    80005640:	e822                	sd	s0,16(sp)
    80005642:	e426                	sd	s1,8(sp)
    80005644:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005646:	0001c497          	auipc	s1,0x1c
    8000564a:	93248493          	addi	s1,s1,-1742 # 80020f78 <pr>
    8000564e:	00002597          	auipc	a1,0x2
    80005652:	35a58593          	addi	a1,a1,858 # 800079a8 <syscalls+0x478>
    80005656:	8526                	mv	a0,s1
    80005658:	23a000ef          	jal	ra,80005892 <initlock>
  pr.locking = 1;
    8000565c:	4785                	li	a5,1
    8000565e:	cc9c                	sw	a5,24(s1)
}
    80005660:	60e2                	ld	ra,24(sp)
    80005662:	6442                	ld	s0,16(sp)
    80005664:	64a2                	ld	s1,8(sp)
    80005666:	6105                	addi	sp,sp,32
    80005668:	8082                	ret

000000008000566a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000566a:	1141                	addi	sp,sp,-16
    8000566c:	e406                	sd	ra,8(sp)
    8000566e:	e022                	sd	s0,0(sp)
    80005670:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005672:	100007b7          	lui	a5,0x10000
    80005676:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000567a:	f8000713          	li	a4,-128
    8000567e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005682:	470d                	li	a4,3
    80005684:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005688:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000568c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005690:	469d                	li	a3,7
    80005692:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005696:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000569a:	00002597          	auipc	a1,0x2
    8000569e:	32e58593          	addi	a1,a1,814 # 800079c8 <digits+0x18>
    800056a2:	0001c517          	auipc	a0,0x1c
    800056a6:	8f650513          	addi	a0,a0,-1802 # 80020f98 <uart_tx_lock>
    800056aa:	1e8000ef          	jal	ra,80005892 <initlock>
}
    800056ae:	60a2                	ld	ra,8(sp)
    800056b0:	6402                	ld	s0,0(sp)
    800056b2:	0141                	addi	sp,sp,16
    800056b4:	8082                	ret

00000000800056b6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800056b6:	1101                	addi	sp,sp,-32
    800056b8:	ec06                	sd	ra,24(sp)
    800056ba:	e822                	sd	s0,16(sp)
    800056bc:	e426                	sd	s1,8(sp)
    800056be:	1000                	addi	s0,sp,32
    800056c0:	84aa                	mv	s1,a0
  push_off();
    800056c2:	210000ef          	jal	ra,800058d2 <push_off>

  if(panicked){
    800056c6:	00002797          	auipc	a5,0x2
    800056ca:	3c67a783          	lw	a5,966(a5) # 80007a8c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800056ce:	10000737          	lui	a4,0x10000
  if(panicked){
    800056d2:	c391                	beqz	a5,800056d6 <uartputc_sync+0x20>
    for(;;)
    800056d4:	a001                	j	800056d4 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800056d6:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800056da:	0207f793          	andi	a5,a5,32
    800056de:	dfe5                	beqz	a5,800056d6 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800056e0:	0ff4f513          	zext.b	a0,s1
    800056e4:	100007b7          	lui	a5,0x10000
    800056e8:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800056ec:	26a000ef          	jal	ra,80005956 <pop_off>
}
    800056f0:	60e2                	ld	ra,24(sp)
    800056f2:	6442                	ld	s0,16(sp)
    800056f4:	64a2                	ld	s1,8(sp)
    800056f6:	6105                	addi	sp,sp,32
    800056f8:	8082                	ret

00000000800056fa <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800056fa:	00002797          	auipc	a5,0x2
    800056fe:	3967b783          	ld	a5,918(a5) # 80007a90 <uart_tx_r>
    80005702:	00002717          	auipc	a4,0x2
    80005706:	39673703          	ld	a4,918(a4) # 80007a98 <uart_tx_w>
    8000570a:	06f70c63          	beq	a4,a5,80005782 <uartstart+0x88>
{
    8000570e:	7139                	addi	sp,sp,-64
    80005710:	fc06                	sd	ra,56(sp)
    80005712:	f822                	sd	s0,48(sp)
    80005714:	f426                	sd	s1,40(sp)
    80005716:	f04a                	sd	s2,32(sp)
    80005718:	ec4e                	sd	s3,24(sp)
    8000571a:	e852                	sd	s4,16(sp)
    8000571c:	e456                	sd	s5,8(sp)
    8000571e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }

    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005720:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }

    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005724:	0001ca17          	auipc	s4,0x1c
    80005728:	874a0a13          	addi	s4,s4,-1932 # 80020f98 <uart_tx_lock>
    uart_tx_r += 1;
    8000572c:	00002497          	auipc	s1,0x2
    80005730:	36448493          	addi	s1,s1,868 # 80007a90 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80005734:	00002997          	auipc	s3,0x2
    80005738:	36498993          	addi	s3,s3,868 # 80007a98 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000573c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80005740:	02077713          	andi	a4,a4,32
    80005744:	c715                	beqz	a4,80005770 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005746:	01f7f713          	andi	a4,a5,31
    8000574a:	9752                	add	a4,a4,s4
    8000574c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80005750:	0785                	addi	a5,a5,1
    80005752:	e09c                	sd	a5,0(s1)

    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80005754:	8526                	mv	a0,s1
    80005756:	f3bfb0ef          	jal	ra,80001690 <wakeup>

    WriteReg(THR, c);
    8000575a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000575e:	609c                	ld	a5,0(s1)
    80005760:	0009b703          	ld	a4,0(s3)
    80005764:	fcf71ce3          	bne	a4,a5,8000573c <uartstart+0x42>
      ReadReg(ISR);
    80005768:	100007b7          	lui	a5,0x10000
    8000576c:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80005770:	70e2                	ld	ra,56(sp)
    80005772:	7442                	ld	s0,48(sp)
    80005774:	74a2                	ld	s1,40(sp)
    80005776:	7902                	ld	s2,32(sp)
    80005778:	69e2                	ld	s3,24(sp)
    8000577a:	6a42                	ld	s4,16(sp)
    8000577c:	6aa2                	ld	s5,8(sp)
    8000577e:	6121                	addi	sp,sp,64
    80005780:	8082                	ret
      ReadReg(ISR);
    80005782:	100007b7          	lui	a5,0x10000
    80005786:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    8000578a:	8082                	ret

000000008000578c <uartputc>:
{
    8000578c:	7179                	addi	sp,sp,-48
    8000578e:	f406                	sd	ra,40(sp)
    80005790:	f022                	sd	s0,32(sp)
    80005792:	ec26                	sd	s1,24(sp)
    80005794:	e84a                	sd	s2,16(sp)
    80005796:	e44e                	sd	s3,8(sp)
    80005798:	e052                	sd	s4,0(sp)
    8000579a:	1800                	addi	s0,sp,48
    8000579c:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000579e:	0001b517          	auipc	a0,0x1b
    800057a2:	7fa50513          	addi	a0,a0,2042 # 80020f98 <uart_tx_lock>
    800057a6:	16c000ef          	jal	ra,80005912 <acquire>
  if(panicked){
    800057aa:	00002797          	auipc	a5,0x2
    800057ae:	2e27a783          	lw	a5,738(a5) # 80007a8c <panicked>
    800057b2:	efbd                	bnez	a5,80005830 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800057b4:	00002717          	auipc	a4,0x2
    800057b8:	2e473703          	ld	a4,740(a4) # 80007a98 <uart_tx_w>
    800057bc:	00002797          	auipc	a5,0x2
    800057c0:	2d47b783          	ld	a5,724(a5) # 80007a90 <uart_tx_r>
    800057c4:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800057c8:	0001b997          	auipc	s3,0x1b
    800057cc:	7d098993          	addi	s3,s3,2000 # 80020f98 <uart_tx_lock>
    800057d0:	00002497          	auipc	s1,0x2
    800057d4:	2c048493          	addi	s1,s1,704 # 80007a90 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800057d8:	00002917          	auipc	s2,0x2
    800057dc:	2c090913          	addi	s2,s2,704 # 80007a98 <uart_tx_w>
    800057e0:	00e79d63          	bne	a5,a4,800057fa <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800057e4:	85ce                	mv	a1,s3
    800057e6:	8526                	mv	a0,s1
    800057e8:	e5dfb0ef          	jal	ra,80001644 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800057ec:	00093703          	ld	a4,0(s2)
    800057f0:	609c                	ld	a5,0(s1)
    800057f2:	02078793          	addi	a5,a5,32
    800057f6:	fee787e3          	beq	a5,a4,800057e4 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800057fa:	0001b497          	auipc	s1,0x1b
    800057fe:	79e48493          	addi	s1,s1,1950 # 80020f98 <uart_tx_lock>
    80005802:	01f77793          	andi	a5,a4,31
    80005806:	97a6                	add	a5,a5,s1
    80005808:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    8000580c:	0705                	addi	a4,a4,1
    8000580e:	00002797          	auipc	a5,0x2
    80005812:	28e7b523          	sd	a4,650(a5) # 80007a98 <uart_tx_w>
  uartstart();
    80005816:	ee5ff0ef          	jal	ra,800056fa <uartstart>
  release(&uart_tx_lock);
    8000581a:	8526                	mv	a0,s1
    8000581c:	18e000ef          	jal	ra,800059aa <release>
}
    80005820:	70a2                	ld	ra,40(sp)
    80005822:	7402                	ld	s0,32(sp)
    80005824:	64e2                	ld	s1,24(sp)
    80005826:	6942                	ld	s2,16(sp)
    80005828:	69a2                	ld	s3,8(sp)
    8000582a:	6a02                	ld	s4,0(sp)
    8000582c:	6145                	addi	sp,sp,48
    8000582e:	8082                	ret
    for(;;)
    80005830:	a001                	j	80005830 <uartputc+0xa4>

0000000080005832 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005832:	1141                	addi	sp,sp,-16
    80005834:	e422                	sd	s0,8(sp)
    80005836:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80005838:	100007b7          	lui	a5,0x10000
    8000583c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80005840:	8b85                	andi	a5,a5,1
    80005842:	cb81                	beqz	a5,80005852 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80005844:	100007b7          	lui	a5,0x10000
    80005848:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000584c:	6422                	ld	s0,8(sp)
    8000584e:	0141                	addi	sp,sp,16
    80005850:	8082                	ret
    return -1;
    80005852:	557d                	li	a0,-1
    80005854:	bfe5                	j	8000584c <uartgetc+0x1a>

0000000080005856 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005856:	1101                	addi	sp,sp,-32
    80005858:	ec06                	sd	ra,24(sp)
    8000585a:	e822                	sd	s0,16(sp)
    8000585c:	e426                	sd	s1,8(sp)
    8000585e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80005860:	54fd                	li	s1,-1
    80005862:	a019                	j	80005868 <uartintr+0x12>
      break;
    consoleintr(c);
    80005864:	8a3ff0ef          	jal	ra,80005106 <consoleintr>
    int c = uartgetc();
    80005868:	fcbff0ef          	jal	ra,80005832 <uartgetc>
    if(c == -1)
    8000586c:	fe951ce3          	bne	a0,s1,80005864 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80005870:	0001b497          	auipc	s1,0x1b
    80005874:	72848493          	addi	s1,s1,1832 # 80020f98 <uart_tx_lock>
    80005878:	8526                	mv	a0,s1
    8000587a:	098000ef          	jal	ra,80005912 <acquire>
  uartstart();
    8000587e:	e7dff0ef          	jal	ra,800056fa <uartstart>
  release(&uart_tx_lock);
    80005882:	8526                	mv	a0,s1
    80005884:	126000ef          	jal	ra,800059aa <release>
}
    80005888:	60e2                	ld	ra,24(sp)
    8000588a:	6442                	ld	s0,16(sp)
    8000588c:	64a2                	ld	s1,8(sp)
    8000588e:	6105                	addi	sp,sp,32
    80005890:	8082                	ret

0000000080005892 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005892:	1141                	addi	sp,sp,-16
    80005894:	e422                	sd	s0,8(sp)
    80005896:	0800                	addi	s0,sp,16
  lk->name = name;
    80005898:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    8000589a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000589e:	00053823          	sd	zero,16(a0)
}
    800058a2:	6422                	ld	s0,8(sp)
    800058a4:	0141                	addi	sp,sp,16
    800058a6:	8082                	ret

00000000800058a8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800058a8:	411c                	lw	a5,0(a0)
    800058aa:	e399                	bnez	a5,800058b0 <holding+0x8>
    800058ac:	4501                	li	a0,0
  return r;
}
    800058ae:	8082                	ret
{
    800058b0:	1101                	addi	sp,sp,-32
    800058b2:	ec06                	sd	ra,24(sp)
    800058b4:	e822                	sd	s0,16(sp)
    800058b6:	e426                	sd	s1,8(sp)
    800058b8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800058ba:	6904                	ld	s1,16(a0)
    800058bc:	fa0fb0ef          	jal	ra,8000105c <mycpu>
    800058c0:	40a48533          	sub	a0,s1,a0
    800058c4:	00153513          	seqz	a0,a0
}
    800058c8:	60e2                	ld	ra,24(sp)
    800058ca:	6442                	ld	s0,16(sp)
    800058cc:	64a2                	ld	s1,8(sp)
    800058ce:	6105                	addi	sp,sp,32
    800058d0:	8082                	ret

00000000800058d2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800058d2:	1101                	addi	sp,sp,-32
    800058d4:	ec06                	sd	ra,24(sp)
    800058d6:	e822                	sd	s0,16(sp)
    800058d8:	e426                	sd	s1,8(sp)
    800058da:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800058dc:	100024f3          	csrr	s1,sstatus
    800058e0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800058e4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800058e6:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800058ea:	f72fb0ef          	jal	ra,8000105c <mycpu>
    800058ee:	5d3c                	lw	a5,120(a0)
    800058f0:	cb99                	beqz	a5,80005906 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800058f2:	f6afb0ef          	jal	ra,8000105c <mycpu>
    800058f6:	5d3c                	lw	a5,120(a0)
    800058f8:	2785                	addiw	a5,a5,1
    800058fa:	dd3c                	sw	a5,120(a0)
}
    800058fc:	60e2                	ld	ra,24(sp)
    800058fe:	6442                	ld	s0,16(sp)
    80005900:	64a2                	ld	s1,8(sp)
    80005902:	6105                	addi	sp,sp,32
    80005904:	8082                	ret
    mycpu()->intena = old;
    80005906:	f56fb0ef          	jal	ra,8000105c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    8000590a:	8085                	srli	s1,s1,0x1
    8000590c:	8885                	andi	s1,s1,1
    8000590e:	dd64                	sw	s1,124(a0)
    80005910:	b7cd                	j	800058f2 <push_off+0x20>

0000000080005912 <acquire>:
{
    80005912:	1101                	addi	sp,sp,-32
    80005914:	ec06                	sd	ra,24(sp)
    80005916:	e822                	sd	s0,16(sp)
    80005918:	e426                	sd	s1,8(sp)
    8000591a:	1000                	addi	s0,sp,32
    8000591c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    8000591e:	fb5ff0ef          	jal	ra,800058d2 <push_off>
  if(holding(lk))
    80005922:	8526                	mv	a0,s1
    80005924:	f85ff0ef          	jal	ra,800058a8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005928:	4705                	li	a4,1
  if(holding(lk))
    8000592a:	e105                	bnez	a0,8000594a <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000592c:	87ba                	mv	a5,a4
    8000592e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005932:	2781                	sext.w	a5,a5
    80005934:	ffe5                	bnez	a5,8000592c <acquire+0x1a>
  __sync_synchronize();
    80005936:	0ff0000f          	fence
  lk->cpu = mycpu();
    8000593a:	f22fb0ef          	jal	ra,8000105c <mycpu>
    8000593e:	e888                	sd	a0,16(s1)
}
    80005940:	60e2                	ld	ra,24(sp)
    80005942:	6442                	ld	s0,16(sp)
    80005944:	64a2                	ld	s1,8(sp)
    80005946:	6105                	addi	sp,sp,32
    80005948:	8082                	ret
    panic("acquire");
    8000594a:	00002517          	auipc	a0,0x2
    8000594e:	08650513          	addi	a0,a0,134 # 800079d0 <digits+0x20>
    80005952:	cb1ff0ef          	jal	ra,80005602 <panic>

0000000080005956 <pop_off>:

void
pop_off(void)
{
    80005956:	1141                	addi	sp,sp,-16
    80005958:	e406                	sd	ra,8(sp)
    8000595a:	e022                	sd	s0,0(sp)
    8000595c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000595e:	efefb0ef          	jal	ra,8000105c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005962:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005966:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005968:	e78d                	bnez	a5,80005992 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    8000596a:	5d3c                	lw	a5,120(a0)
    8000596c:	02f05963          	blez	a5,8000599e <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005970:	37fd                	addiw	a5,a5,-1
    80005972:	0007871b          	sext.w	a4,a5
    80005976:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005978:	eb09                	bnez	a4,8000598a <pop_off+0x34>
    8000597a:	5d7c                	lw	a5,124(a0)
    8000597c:	c799                	beqz	a5,8000598a <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000597e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005982:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005986:	10079073          	csrw	sstatus,a5
    intr_on();
}
    8000598a:	60a2                	ld	ra,8(sp)
    8000598c:	6402                	ld	s0,0(sp)
    8000598e:	0141                	addi	sp,sp,16
    80005990:	8082                	ret
    panic("pop_off - interruptible");
    80005992:	00002517          	auipc	a0,0x2
    80005996:	04650513          	addi	a0,a0,70 # 800079d8 <digits+0x28>
    8000599a:	c69ff0ef          	jal	ra,80005602 <panic>
    panic("pop_off");
    8000599e:	00002517          	auipc	a0,0x2
    800059a2:	05250513          	addi	a0,a0,82 # 800079f0 <digits+0x40>
    800059a6:	c5dff0ef          	jal	ra,80005602 <panic>

00000000800059aa <release>:
{
    800059aa:	1101                	addi	sp,sp,-32
    800059ac:	ec06                	sd	ra,24(sp)
    800059ae:	e822                	sd	s0,16(sp)
    800059b0:	e426                	sd	s1,8(sp)
    800059b2:	1000                	addi	s0,sp,32
    800059b4:	84aa                	mv	s1,a0
  if(!holding(lk))
    800059b6:	ef3ff0ef          	jal	ra,800058a8 <holding>
    800059ba:	c105                	beqz	a0,800059da <release+0x30>
  lk->cpu = 0;
    800059bc:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800059c0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800059c4:	0f50000f          	fence	iorw,ow
    800059c8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800059cc:	f8bff0ef          	jal	ra,80005956 <pop_off>
}
    800059d0:	60e2                	ld	ra,24(sp)
    800059d2:	6442                	ld	s0,16(sp)
    800059d4:	64a2                	ld	s1,8(sp)
    800059d6:	6105                	addi	sp,sp,32
    800059d8:	8082                	ret
    panic("release");
    800059da:	00002517          	auipc	a0,0x2
    800059de:	01e50513          	addi	a0,a0,30 # 800079f8 <digits+0x48>
    800059e2:	c21ff0ef          	jal	ra,80005602 <panic>
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
