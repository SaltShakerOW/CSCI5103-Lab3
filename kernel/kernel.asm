
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	a1013103          	ld	sp,-1520(sp) # 80007a10 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	617040ef          	jal	ra,80004e2c <start>

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
    80000030:	a3450513          	addi	a0,a0,-1484 # 80007a60 <supermem>
    80000034:	77e050ef          	jal	ra,800057b2 <initlock>
  supermem.nfree = 0; //reset number of free superpages

  uint64 top = PHYSTOP; //start allocation at top of memory space
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    80000038:	00008697          	auipc	a3,0x8
    8000003c:	a4068693          	addi	a3,a3,-1472 # 80007a78 <supermem+0x18>
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
    80000064:	beb7ac23          	sw	a1,-1032(a5) # 80007c58 <supermem+0x1f8>
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
    8000008a:	f0a78793          	addi	a5,a5,-246 # 80020f90 <end>
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
    800000a6:	9be98993          	addi	s3,s3,-1602 # 80007a60 <supermem>
    800000aa:	00008917          	auipc	s2,0x8
    800000ae:	bb690913          	addi	s2,s2,-1098 # 80007c60 <kmem>
    800000b2:	854a                	mv	a0,s2
    800000b4:	77e050ef          	jal	ra,80005832 <acquire>
  r->next = kmem.freelist;
    800000b8:	2189b783          	ld	a5,536(s3)
    800000bc:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800000be:	2099bc23          	sd	s1,536(s3)
  release(&kmem.lock);
    800000c2:	854a                	mv	a0,s2
    800000c4:	007050ef          	jal	ra,800058ca <release>
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
    800000de:	444050ef          	jal	ra,80005522 <panic>

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
    8000013e:	b2650513          	addi	a0,a0,-1242 # 80007c60 <kmem>
    80000142:	670050ef          	jal	ra,800057b2 <initlock>
  superinit(); //allocate space for superpages before regular pages
    80000146:	ed7ff0ef          	jal	ra,8000001c <superinit>
  freerange(end, (void*)PHYSTOP - (uint64)NSUPERPAGES * SUPERPGSIZE); //modification made here to ensure space for 60 superpages
    8000014a:	10100593          	li	a1,257
    8000014e:	05de                	slli	a1,a1,0x17
    80000150:	00021517          	auipc	a0,0x21
    80000154:	e4050513          	addi	a0,a0,-448 # 80020f90 <end>
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
    80000172:	af250513          	addi	a0,a0,-1294 # 80007c60 <kmem>
    80000176:	6bc050ef          	jal	ra,80005832 <acquire>
  r = kmem.freelist;
    8000017a:	00008497          	auipc	s1,0x8
    8000017e:	afe4b483          	ld	s1,-1282(s1) # 80007c78 <kmem+0x18>
  if (r) {
    80000182:	c49d                	beqz	s1,800001b0 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000184:	609c                	ld	a5,0(s1)
    80000186:	00008717          	auipc	a4,0x8
    8000018a:	aef73923          	sd	a5,-1294(a4) # 80007c78 <kmem+0x18>
  }
  release(&kmem.lock);
    8000018e:	00008517          	auipc	a0,0x8
    80000192:	ad250513          	addi	a0,a0,-1326 # 80007c60 <kmem>
    80000196:	734050ef          	jal	ra,800058ca <release>

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
    800001b4:	ab050513          	addi	a0,a0,-1360 # 80007c60 <kmem>
    800001b8:	712050ef          	jal	ra,800058ca <release>
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
    800001cc:	89848493          	addi	s1,s1,-1896 # 80007a60 <supermem>
    800001d0:	8526                	mv	a0,s1
    800001d2:	660050ef          	jal	ra,80005832 <acquire>
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
    800001e8:	87c50513          	addi	a0,a0,-1924 # 80007a60 <supermem>
    800001ec:	1ee52c23          	sw	a4,504(a0)
  void *pg = supermem.superpages[supermem.nfree];
    800001f0:	0789                	addi	a5,a5,2
    800001f2:	078e                	slli	a5,a5,0x3
    800001f4:	97aa                	add	a5,a5,a0
    800001f6:	6784                	ld	s1,8(a5)
  release(&supermem.lock);
    800001f8:	6d2050ef          	jal	ra,800058ca <release>
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
    80000216:	6b4050ef          	jal	ra,800058ca <release>
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
  if (((uint64)pa & (SUPERPGSIZE - 1)) != 0) { //check if pa belongs to our address pool (address alignment)
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
    80000250:	81490913          	addi	s2,s2,-2028 # 80007a60 <supermem>
    80000254:	854a                	mv	a0,s2
    80000256:	5dc050ef          	jal	ra,80005832 <acquire>
  if (supermem.nfree >= NSUPERPAGES) {
    8000025a:	1f892783          	lw	a5,504(s2)
    8000025e:	03b00713          	li	a4,59
    80000262:	04f74263          	blt	a4,a5,800002a6 <superfree+0x88>
    panic("superfree: superpage pool overflow");
  }
  supermem.superpages[supermem.nfree] = pa;
    80000266:	00007517          	auipc	a0,0x7
    8000026a:	7fa50513          	addi	a0,a0,2042 # 80007a60 <supermem>
    8000026e:	00278713          	addi	a4,a5,2
    80000272:	070e                	slli	a4,a4,0x3
    80000274:	972a                	add	a4,a4,a0
    80000276:	e704                	sd	s1,8(a4)
  supermem.nfree++;
    80000278:	2785                	addiw	a5,a5,1
    8000027a:	1ef52c23          	sw	a5,504(a0)
  release(&supermem.lock);
    8000027e:	64c050ef          	jal	ra,800058ca <release>
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
    80000296:	28c050ef          	jal	ra,80005522 <panic>
    panic("superfree: pa outside of superpage pool range");
    8000029a:	00007517          	auipc	a0,0x7
    8000029e:	db650513          	addi	a0,a0,-586 # 80007050 <etext+0x50>
    800002a2:	280050ef          	jal	ra,80005522 <panic>
    panic("superfree: superpage pool overflow");
    800002a6:	00007517          	auipc	a0,0x7
    800002aa:	dda50513          	addi	a0,a0,-550 # 80007080 <etext+0x80>
    800002ae:	274050ef          	jal	ra,80005522 <panic>

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
    8000045c:	317000ef          	jal	ra,80000f72 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000460:	00007717          	auipc	a4,0x7
    80000464:	5d070713          	addi	a4,a4,1488 # 80007a30 <started>
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
    80000474:	2ff000ef          	jal	ra,80000f72 <cpuid>
    80000478:	85aa                	mv	a1,a0
    8000047a:	00007517          	auipc	a0,0x7
    8000047e:	c4650513          	addi	a0,a0,-954 # 800070c0 <etext+0xc0>
    80000482:	5ed040ef          	jal	ra,8000526e <printf>
    kvminithart();    // turn on paging
    80000486:	080000ef          	jal	ra,80000506 <kvminithart>
    trapinithart();   // install kernel trap vector
    8000048a:	602010ef          	jal	ra,80001a8c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000048e:	3f6040ef          	jal	ra,80004884 <plicinithart>
  }

  scheduler();
    80000492:	73f000ef          	jal	ra,800013d0 <scheduler>
    consoleinit();
    80000496:	503040ef          	jal	ra,80005198 <consoleinit>
    printfinit();
    8000049a:	0c2050ef          	jal	ra,8000555c <printfinit>
    printf("\n");
    8000049e:	00007517          	auipc	a0,0x7
    800004a2:	c3250513          	addi	a0,a0,-974 # 800070d0 <etext+0xd0>
    800004a6:	5c9040ef          	jal	ra,8000526e <printf>
    printf("xv6 kernel is booting\n");
    800004aa:	00007517          	auipc	a0,0x7
    800004ae:	bfe50513          	addi	a0,a0,-1026 # 800070a8 <etext+0xa8>
    800004b2:	5bd040ef          	jal	ra,8000526e <printf>
    printf("\n");
    800004b6:	00007517          	auipc	a0,0x7
    800004ba:	c1a50513          	addi	a0,a0,-998 # 800070d0 <etext+0xd0>
    800004be:	5b1040ef          	jal	ra,8000526e <printf>
    kinit();         // physical page allocator
    800004c2:	c69ff0ef          	jal	ra,8000012a <kinit>
    kvminit();       // create kernel page table
    800004c6:	2d4000ef          	jal	ra,8000079a <kvminit>
    kvminithart();   // turn on paging
    800004ca:	03c000ef          	jal	ra,80000506 <kvminithart>
    procinit();      // process table
    800004ce:	1fd000ef          	jal	ra,80000eca <procinit>
    trapinit();      // trap vectors
    800004d2:	596010ef          	jal	ra,80001a68 <trapinit>
    trapinithart();  // install kernel trap vector
    800004d6:	5b6010ef          	jal	ra,80001a8c <trapinithart>
    plicinit();      // set up interrupt controller
    800004da:	394040ef          	jal	ra,8000486e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800004de:	3a6040ef          	jal	ra,80004884 <plicinithart>
    binit();         // buffer cache
    800004e2:	429010ef          	jal	ra,8000210a <binit>
    iinit();         // inode table
    800004e6:	204020ef          	jal	ra,800026ea <iinit>
    fileinit();      // file table
    800004ea:	7a7020ef          	jal	ra,80003490 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800004ee:	486040ef          	jal	ra,80004974 <virtio_disk_init>
    userinit();      // first user process
    800004f2:	515000ef          	jal	ra,80001206 <userinit>
    __sync_synchronize();
    800004f6:	0ff0000f          	fence
    started = 1;
    800004fa:	4785                	li	a5,1
    800004fc:	00007717          	auipc	a4,0x7
    80000500:	52f72a23          	sw	a5,1332(a4) # 80007a30 <started>
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
    80000514:	5287b783          	ld	a5,1320(a5) # 80007a38 <kernel_pagetable>
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
    8000055c:	7c7040ef          	jal	ra,80005522 <panic>
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
    80000580:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde067>
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

00000000800005d2 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    800005d2:	57fd                	li	a5,-1
    800005d4:	83e9                	srli	a5,a5,0x1a
    800005d6:	00b7f463          	bgeu	a5,a1,800005de <walkaddr+0xc>
    return 0;
    800005da:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800005dc:	8082                	ret
{
    800005de:	1141                	addi	sp,sp,-16
    800005e0:	e406                	sd	ra,8(sp)
    800005e2:	e022                	sd	s0,0(sp)
    800005e4:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800005e6:	4601                	li	a2,0
    800005e8:	f47ff0ef          	jal	ra,8000052e <walk>
  if (pte == 0)
    800005ec:	c105                	beqz	a0,8000060c <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    800005ee:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    800005f0:	0117f693          	andi	a3,a5,17
    800005f4:	4745                	li	a4,17
    return 0;
    800005f6:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    800005f8:	00e68663          	beq	a3,a4,80000604 <walkaddr+0x32>
}
    800005fc:	60a2                	ld	ra,8(sp)
    800005fe:	6402                	ld	s0,0(sp)
    80000600:	0141                	addi	sp,sp,16
    80000602:	8082                	ret
  pa = PTE2PA(*pte);
    80000604:	83a9                	srli	a5,a5,0xa
    80000606:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000060a:	bfcd                	j	800005fc <walkaddr+0x2a>
    return 0;
    8000060c:	4501                	li	a0,0
    8000060e:	b7fd                	j	800005fc <walkaddr+0x2a>

0000000080000610 <mappages>:
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000610:	715d                	addi	sp,sp,-80
    80000612:	e486                	sd	ra,72(sp)
    80000614:	e0a2                	sd	s0,64(sp)
    80000616:	fc26                	sd	s1,56(sp)
    80000618:	f84a                	sd	s2,48(sp)
    8000061a:	f44e                	sd	s3,40(sp)
    8000061c:	f052                	sd	s4,32(sp)
    8000061e:	ec56                	sd	s5,24(sp)
    80000620:	e85a                	sd	s6,16(sp)
    80000622:	e45e                	sd	s7,8(sp)
    80000624:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80000626:	03459793          	slli	a5,a1,0x34
    8000062a:	e7a9                	bnez	a5,80000674 <mappages+0x64>
    8000062c:	8aaa                	mv	s5,a0
    8000062e:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80000630:	03461793          	slli	a5,a2,0x34
    80000634:	e7b1                	bnez	a5,80000680 <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    80000636:	ca39                	beqz	a2,8000068c <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    80000638:	77fd                	lui	a5,0xfffff
    8000063a:	963e                	add	a2,a2,a5
    8000063c:	00b609b3          	add	s3,a2,a1
  a = va;
    80000640:	892e                	mv	s2,a1
    80000642:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80000646:	6b85                	lui	s7,0x1
    80000648:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000064c:	4605                	li	a2,1
    8000064e:	85ca                	mv	a1,s2
    80000650:	8556                	mv	a0,s5
    80000652:	eddff0ef          	jal	ra,8000052e <walk>
    80000656:	c539                	beqz	a0,800006a4 <mappages+0x94>
    if (*pte & PTE_V)
    80000658:	611c                	ld	a5,0(a0)
    8000065a:	8b85                	andi	a5,a5,1
    8000065c:	ef95                	bnez	a5,80000698 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000065e:	80b1                	srli	s1,s1,0xc
    80000660:	04aa                	slli	s1,s1,0xa
    80000662:	0164e4b3          	or	s1,s1,s6
    80000666:	0014e493          	ori	s1,s1,1
    8000066a:	e104                	sd	s1,0(a0)
    if (a == last)
    8000066c:	05390863          	beq	s2,s3,800006bc <mappages+0xac>
    a += PGSIZE;
    80000670:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80000672:	bfd9                	j	80000648 <mappages+0x38>
    panic("mappages: va not aligned");
    80000674:	00007517          	auipc	a0,0x7
    80000678:	a6c50513          	addi	a0,a0,-1428 # 800070e0 <etext+0xe0>
    8000067c:	6a7040ef          	jal	ra,80005522 <panic>
    panic("mappages: size not aligned");
    80000680:	00007517          	auipc	a0,0x7
    80000684:	a8050513          	addi	a0,a0,-1408 # 80007100 <etext+0x100>
    80000688:	69b040ef          	jal	ra,80005522 <panic>
    panic("mappages: size");
    8000068c:	00007517          	auipc	a0,0x7
    80000690:	a9450513          	addi	a0,a0,-1388 # 80007120 <etext+0x120>
    80000694:	68f040ef          	jal	ra,80005522 <panic>
      panic("mappages: remap");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a9850513          	addi	a0,a0,-1384 # 80007130 <etext+0x130>
    800006a0:	683040ef          	jal	ra,80005522 <panic>
      return -1;
    800006a4:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800006a6:	60a6                	ld	ra,72(sp)
    800006a8:	6406                	ld	s0,64(sp)
    800006aa:	74e2                	ld	s1,56(sp)
    800006ac:	7942                	ld	s2,48(sp)
    800006ae:	79a2                	ld	s3,40(sp)
    800006b0:	7a02                	ld	s4,32(sp)
    800006b2:	6ae2                	ld	s5,24(sp)
    800006b4:	6b42                	ld	s6,16(sp)
    800006b6:	6ba2                	ld	s7,8(sp)
    800006b8:	6161                	addi	sp,sp,80
    800006ba:	8082                	ret
  return 0;
    800006bc:	4501                	li	a0,0
    800006be:	b7e5                	j	800006a6 <mappages+0x96>

00000000800006c0 <kvmmap>:
{
    800006c0:	1141                	addi	sp,sp,-16
    800006c2:	e406                	sd	ra,8(sp)
    800006c4:	e022                	sd	s0,0(sp)
    800006c6:	0800                	addi	s0,sp,16
    800006c8:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    800006ca:	86b2                	mv	a3,a2
    800006cc:	863e                	mv	a2,a5
    800006ce:	f43ff0ef          	jal	ra,80000610 <mappages>
    800006d2:	e509                	bnez	a0,800006dc <kvmmap+0x1c>
}
    800006d4:	60a2                	ld	ra,8(sp)
    800006d6:	6402                	ld	s0,0(sp)
    800006d8:	0141                	addi	sp,sp,16
    800006da:	8082                	ret
    panic("kvmmap");
    800006dc:	00007517          	auipc	a0,0x7
    800006e0:	a6450513          	addi	a0,a0,-1436 # 80007140 <etext+0x140>
    800006e4:	63f040ef          	jal	ra,80005522 <panic>

00000000800006e8 <kvmmake>:
{
    800006e8:	1101                	addi	sp,sp,-32
    800006ea:	ec06                	sd	ra,24(sp)
    800006ec:	e822                	sd	s0,16(sp)
    800006ee:	e426                	sd	s1,8(sp)
    800006f0:	e04a                	sd	s2,0(sp)
    800006f2:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    800006f4:	a71ff0ef          	jal	ra,80000164 <kalloc>
    800006f8:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800006fa:	6605                	lui	a2,0x1
    800006fc:	4581                	li	a1,0
    800006fe:	bb5ff0ef          	jal	ra,800002b2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000702:	4719                	li	a4,6
    80000704:	6685                	lui	a3,0x1
    80000706:	10000637          	lui	a2,0x10000
    8000070a:	100005b7          	lui	a1,0x10000
    8000070e:	8526                	mv	a0,s1
    80000710:	fb1ff0ef          	jal	ra,800006c0 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000714:	4719                	li	a4,6
    80000716:	6685                	lui	a3,0x1
    80000718:	10001637          	lui	a2,0x10001
    8000071c:	100015b7          	lui	a1,0x10001
    80000720:	8526                	mv	a0,s1
    80000722:	f9fff0ef          	jal	ra,800006c0 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80000726:	4719                	li	a4,6
    80000728:	040006b7          	lui	a3,0x4000
    8000072c:	0c000637          	lui	a2,0xc000
    80000730:	0c0005b7          	lui	a1,0xc000
    80000734:	8526                	mv	a0,s1
    80000736:	f8bff0ef          	jal	ra,800006c0 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000073a:	00007917          	auipc	s2,0x7
    8000073e:	8c690913          	addi	s2,s2,-1850 # 80007000 <etext>
    80000742:	4729                	li	a4,10
    80000744:	80007697          	auipc	a3,0x80007
    80000748:	8bc68693          	addi	a3,a3,-1860 # 7000 <_entry-0x7fff9000>
    8000074c:	4605                	li	a2,1
    8000074e:	067e                	slli	a2,a2,0x1f
    80000750:	85b2                	mv	a1,a2
    80000752:	8526                	mv	a0,s1
    80000754:	f6dff0ef          	jal	ra,800006c0 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    80000758:	4719                	li	a4,6
    8000075a:	46c5                	li	a3,17
    8000075c:	06ee                	slli	a3,a3,0x1b
    8000075e:	412686b3          	sub	a3,a3,s2
    80000762:	864a                	mv	a2,s2
    80000764:	85ca                	mv	a1,s2
    80000766:	8526                	mv	a0,s1
    80000768:	f59ff0ef          	jal	ra,800006c0 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000076c:	4729                	li	a4,10
    8000076e:	6685                	lui	a3,0x1
    80000770:	00006617          	auipc	a2,0x6
    80000774:	89060613          	addi	a2,a2,-1904 # 80006000 <_trampoline>
    80000778:	040005b7          	lui	a1,0x4000
    8000077c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000077e:	05b2                	slli	a1,a1,0xc
    80000780:	8526                	mv	a0,s1
    80000782:	f3fff0ef          	jal	ra,800006c0 <kvmmap>
  proc_mapstacks(kpgtbl);
    80000786:	8526                	mv	a0,s1
    80000788:	6b8000ef          	jal	ra,80000e40 <proc_mapstacks>
}
    8000078c:	8526                	mv	a0,s1
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6902                	ld	s2,0(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <kvminit>:
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800007a2:	f47ff0ef          	jal	ra,800006e8 <kvmmake>
    800007a6:	00007797          	auipc	a5,0x7
    800007aa:	28a7b923          	sd	a0,658(a5) # 80007a38 <kernel_pagetable>
}
    800007ae:	60a2                	ld	ra,8(sp)
    800007b0:	6402                	ld	s0,0(sp)
    800007b2:	0141                	addi	sp,sp,16
    800007b4:	8082                	ret

00000000800007b6 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800007b6:	715d                	addi	sp,sp,-80
    800007b8:	e486                	sd	ra,72(sp)
    800007ba:	e0a2                	sd	s0,64(sp)
    800007bc:	fc26                	sd	s1,56(sp)
    800007be:	f84a                	sd	s2,48(sp)
    800007c0:	f44e                	sd	s3,40(sp)
    800007c2:	f052                	sd	s4,32(sp)
    800007c4:	ec56                	sd	s5,24(sp)
    800007c6:	e85a                	sd	s6,16(sp)
    800007c8:	e45e                	sd	s7,8(sp)
    800007ca:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;
  int sz;

  if ((va % PGSIZE) != 0)
    800007cc:	03459793          	slli	a5,a1,0x34
    800007d0:	e795                	bnez	a5,800007fc <uvmunmap+0x46>
    800007d2:	8a2a                	mv	s4,a0
    800007d4:	892e                	mv	s2,a1
    800007d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += sz)
    800007d8:	0632                	slli	a2,a2,0xc
    800007da:	00b609b3          	add	s3,a2,a1
    if ((*pte & PTE_V) == 0)
    {
      printf("va=%ld pte=%ld\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if (PTE_FLAGS(*pte) == PTE_V)
    800007de:	4b85                	li	s7,1
  for (a = va; a < va + npages * PGSIZE; a += sz)
    800007e0:	6b05                	lui	s6,0x1
    800007e2:	0735e163          	bltu	a1,s3,80000844 <uvmunmap+0x8e>
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
  }
}
    800007e6:	60a6                	ld	ra,72(sp)
    800007e8:	6406                	ld	s0,64(sp)
    800007ea:	74e2                	ld	s1,56(sp)
    800007ec:	7942                	ld	s2,48(sp)
    800007ee:	79a2                	ld	s3,40(sp)
    800007f0:	7a02                	ld	s4,32(sp)
    800007f2:	6ae2                	ld	s5,24(sp)
    800007f4:	6b42                	ld	s6,16(sp)
    800007f6:	6ba2                	ld	s7,8(sp)
    800007f8:	6161                	addi	sp,sp,80
    800007fa:	8082                	ret
    panic("uvmunmap: not aligned");
    800007fc:	00007517          	auipc	a0,0x7
    80000800:	94c50513          	addi	a0,a0,-1716 # 80007148 <etext+0x148>
    80000804:	51f040ef          	jal	ra,80005522 <panic>
      panic("uvmunmap: walk");
    80000808:	00007517          	auipc	a0,0x7
    8000080c:	95850513          	addi	a0,a0,-1704 # 80007160 <etext+0x160>
    80000810:	513040ef          	jal	ra,80005522 <panic>
      printf("va=%ld pte=%ld\n", a, *pte);
    80000814:	85ca                	mv	a1,s2
    80000816:	00007517          	auipc	a0,0x7
    8000081a:	95a50513          	addi	a0,a0,-1702 # 80007170 <etext+0x170>
    8000081e:	251040ef          	jal	ra,8000526e <printf>
      panic("uvmunmap: not mapped");
    80000822:	00007517          	auipc	a0,0x7
    80000826:	95e50513          	addi	a0,a0,-1698 # 80007180 <etext+0x180>
    8000082a:	4f9040ef          	jal	ra,80005522 <panic>
      panic("uvmunmap: not a leaf");
    8000082e:	00007517          	auipc	a0,0x7
    80000832:	96a50513          	addi	a0,a0,-1686 # 80007198 <etext+0x198>
    80000836:	4ed040ef          	jal	ra,80005522 <panic>
    *pte = 0;
    8000083a:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += sz)
    8000083e:	995a                	add	s2,s2,s6
    80000840:	fb3973e3          	bgeu	s2,s3,800007e6 <uvmunmap+0x30>
    if ((pte = walk(pagetable, a, 0)) == 0)
    80000844:	4601                	li	a2,0
    80000846:	85ca                	mv	a1,s2
    80000848:	8552                	mv	a0,s4
    8000084a:	ce5ff0ef          	jal	ra,8000052e <walk>
    8000084e:	84aa                	mv	s1,a0
    80000850:	dd45                	beqz	a0,80000808 <uvmunmap+0x52>
    if ((*pte & PTE_V) == 0)
    80000852:	6110                	ld	a2,0(a0)
    80000854:	00167793          	andi	a5,a2,1
    80000858:	dfd5                	beqz	a5,80000814 <uvmunmap+0x5e>
    if (PTE_FLAGS(*pte) == PTE_V)
    8000085a:	3ff67793          	andi	a5,a2,1023
    8000085e:	fd7788e3          	beq	a5,s7,8000082e <uvmunmap+0x78>
    if (do_free)
    80000862:	fc0a8ce3          	beqz	s5,8000083a <uvmunmap+0x84>
      uint64 pa = PTE2PA(*pte);
    80000866:	8229                	srli	a2,a2,0xa
      kfree((void *)pa);
    80000868:	00c61513          	slli	a0,a2,0xc
    8000086c:	805ff0ef          	jal	ra,80000070 <kfree>
    80000870:	b7e9                	j	8000083a <uvmunmap+0x84>

0000000080000872 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80000872:	1101                	addi	sp,sp,-32
    80000874:	ec06                	sd	ra,24(sp)
    80000876:	e822                	sd	s0,16(sp)
    80000878:	e426                	sd	s1,8(sp)
    8000087a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    8000087c:	8e9ff0ef          	jal	ra,80000164 <kalloc>
    80000880:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80000882:	c509                	beqz	a0,8000088c <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000884:	6605                	lui	a2,0x1
    80000886:	4581                	li	a1,0
    80000888:	a2bff0ef          	jal	ra,800002b2 <memset>
  return pagetable;
}
    8000088c:	8526                	mv	a0,s1
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret

0000000080000898 <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000898:	7179                	addi	sp,sp,-48
    8000089a:	f406                	sd	ra,40(sp)
    8000089c:	f022                	sd	s0,32(sp)
    8000089e:	ec26                	sd	s1,24(sp)
    800008a0:	e84a                	sd	s2,16(sp)
    800008a2:	e44e                	sd	s3,8(sp)
    800008a4:	e052                	sd	s4,0(sp)
    800008a6:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    800008a8:	6785                	lui	a5,0x1
    800008aa:	04f67063          	bgeu	a2,a5,800008ea <uvmfirst+0x52>
    800008ae:	8a2a                	mv	s4,a0
    800008b0:	89ae                	mv	s3,a1
    800008b2:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800008b4:	8b1ff0ef          	jal	ra,80000164 <kalloc>
    800008b8:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800008ba:	6605                	lui	a2,0x1
    800008bc:	4581                	li	a1,0
    800008be:	9f5ff0ef          	jal	ra,800002b2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    800008c2:	4779                	li	a4,30
    800008c4:	86ca                	mv	a3,s2
    800008c6:	6605                	lui	a2,0x1
    800008c8:	4581                	li	a1,0
    800008ca:	8552                	mv	a0,s4
    800008cc:	d45ff0ef          	jal	ra,80000610 <mappages>
  memmove(mem, src, sz);
    800008d0:	8626                	mv	a2,s1
    800008d2:	85ce                	mv	a1,s3
    800008d4:	854a                	mv	a0,s2
    800008d6:	a39ff0ef          	jal	ra,8000030e <memmove>
}
    800008da:	70a2                	ld	ra,40(sp)
    800008dc:	7402                	ld	s0,32(sp)
    800008de:	64e2                	ld	s1,24(sp)
    800008e0:	6942                	ld	s2,16(sp)
    800008e2:	69a2                	ld	s3,8(sp)
    800008e4:	6a02                	ld	s4,0(sp)
    800008e6:	6145                	addi	sp,sp,48
    800008e8:	8082                	ret
    panic("uvmfirst: more than a page");
    800008ea:	00007517          	auipc	a0,0x7
    800008ee:	8c650513          	addi	a0,a0,-1850 # 800071b0 <etext+0x1b0>
    800008f2:	431040ef          	jal	ra,80005522 <panic>

00000000800008f6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800008f6:	1101                	addi	sp,sp,-32
    800008f8:	ec06                	sd	ra,24(sp)
    800008fa:	e822                	sd	s0,16(sp)
    800008fc:	e426                	sd	s1,8(sp)
    800008fe:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80000900:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80000902:	00b67d63          	bgeu	a2,a1,8000091c <uvmdealloc+0x26>
    80000906:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    80000908:	6785                	lui	a5,0x1
    8000090a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000090c:	00f60733          	add	a4,a2,a5
    80000910:	76fd                	lui	a3,0xfffff
    80000912:	8f75                	and	a4,a4,a3
    80000914:	97ae                	add	a5,a5,a1
    80000916:	8ff5                	and	a5,a5,a3
    80000918:	00f76863          	bltu	a4,a5,80000928 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000091c:	8526                	mv	a0,s1
    8000091e:	60e2                	ld	ra,24(sp)
    80000920:	6442                	ld	s0,16(sp)
    80000922:	64a2                	ld	s1,8(sp)
    80000924:	6105                	addi	sp,sp,32
    80000926:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000928:	8f99                	sub	a5,a5,a4
    8000092a:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000092c:	4685                	li	a3,1
    8000092e:	0007861b          	sext.w	a2,a5
    80000932:	85ba                	mv	a1,a4
    80000934:	e83ff0ef          	jal	ra,800007b6 <uvmunmap>
    80000938:	b7d5                	j	8000091c <uvmdealloc+0x26>

000000008000093a <uvmalloc>:
  if (newsz < oldsz)
    8000093a:	08b66963          	bltu	a2,a1,800009cc <uvmalloc+0x92>
{
    8000093e:	7139                	addi	sp,sp,-64
    80000940:	fc06                	sd	ra,56(sp)
    80000942:	f822                	sd	s0,48(sp)
    80000944:	f426                	sd	s1,40(sp)
    80000946:	f04a                	sd	s2,32(sp)
    80000948:	ec4e                	sd	s3,24(sp)
    8000094a:	e852                	sd	s4,16(sp)
    8000094c:	e456                	sd	s5,8(sp)
    8000094e:	e05a                	sd	s6,0(sp)
    80000950:	0080                	addi	s0,sp,64
    80000952:	8aaa                	mv	s5,a0
    80000954:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80000956:	6785                	lui	a5,0x1
    80000958:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000095a:	95be                	add	a1,a1,a5
    8000095c:	77fd                	lui	a5,0xfffff
    8000095e:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += sz)
    80000962:	06c9f763          	bgeu	s3,a2,800009d0 <uvmalloc+0x96>
    80000966:	894e                	mv	s2,s3
    if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000968:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000096c:	ff8ff0ef          	jal	ra,80000164 <kalloc>
    80000970:	84aa                	mv	s1,a0
    if (mem == 0)
    80000972:	c11d                	beqz	a0,80000998 <uvmalloc+0x5e>
    memset(mem, 0, sz);
    80000974:	6605                	lui	a2,0x1
    80000976:	4581                	li	a1,0
    80000978:	93bff0ef          	jal	ra,800002b2 <memset>
    if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    8000097c:	875a                	mv	a4,s6
    8000097e:	86a6                	mv	a3,s1
    80000980:	6605                	lui	a2,0x1
    80000982:	85ca                	mv	a1,s2
    80000984:	8556                	mv	a0,s5
    80000986:	c8bff0ef          	jal	ra,80000610 <mappages>
    8000098a:	e51d                	bnez	a0,800009b8 <uvmalloc+0x7e>
  for (a = oldsz; a < newsz; a += sz)
    8000098c:	6785                	lui	a5,0x1
    8000098e:	993e                	add	s2,s2,a5
    80000990:	fd496ee3          	bltu	s2,s4,8000096c <uvmalloc+0x32>
  return newsz;
    80000994:	8552                	mv	a0,s4
    80000996:	a039                	j	800009a4 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    80000998:	864e                	mv	a2,s3
    8000099a:	85ca                	mv	a1,s2
    8000099c:	8556                	mv	a0,s5
    8000099e:	f59ff0ef          	jal	ra,800008f6 <uvmdealloc>
      return 0;
    800009a2:	4501                	li	a0,0
}
    800009a4:	70e2                	ld	ra,56(sp)
    800009a6:	7442                	ld	s0,48(sp)
    800009a8:	74a2                	ld	s1,40(sp)
    800009aa:	7902                	ld	s2,32(sp)
    800009ac:	69e2                	ld	s3,24(sp)
    800009ae:	6a42                	ld	s4,16(sp)
    800009b0:	6aa2                	ld	s5,8(sp)
    800009b2:	6b02                	ld	s6,0(sp)
    800009b4:	6121                	addi	sp,sp,64
    800009b6:	8082                	ret
      kfree(mem);
    800009b8:	8526                	mv	a0,s1
    800009ba:	eb6ff0ef          	jal	ra,80000070 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800009be:	864e                	mv	a2,s3
    800009c0:	85ca                	mv	a1,s2
    800009c2:	8556                	mv	a0,s5
    800009c4:	f33ff0ef          	jal	ra,800008f6 <uvmdealloc>
      return 0;
    800009c8:	4501                	li	a0,0
    800009ca:	bfe9                	j	800009a4 <uvmalloc+0x6a>
    return oldsz;
    800009cc:	852e                	mv	a0,a1
}
    800009ce:	8082                	ret
  return newsz;
    800009d0:	8532                	mv	a0,a2
    800009d2:	bfc9                	j	800009a4 <uvmalloc+0x6a>

00000000800009d4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    800009d4:	7179                	addi	sp,sp,-48
    800009d6:	f406                	sd	ra,40(sp)
    800009d8:	f022                	sd	s0,32(sp)
    800009da:	ec26                	sd	s1,24(sp)
    800009dc:	e84a                	sd	s2,16(sp)
    800009de:	e44e                	sd	s3,8(sp)
    800009e0:	e052                	sd	s4,0(sp)
    800009e2:	1800                	addi	s0,sp,48
    800009e4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    800009e6:	84aa                	mv	s1,a0
    800009e8:	6905                	lui	s2,0x1
    800009ea:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    800009ec:	4985                	li	s3,1
    800009ee:	a819                	j	80000a04 <freewalk+0x30>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800009f0:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800009f2:	00c79513          	slli	a0,a5,0xc
    800009f6:	fdfff0ef          	jal	ra,800009d4 <freewalk>
      pagetable[i] = 0;
    800009fa:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    800009fe:	04a1                	addi	s1,s1,8
    80000a00:	01248f63          	beq	s1,s2,80000a1e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80000a04:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000a06:	00f7f713          	andi	a4,a5,15
    80000a0a:	ff3703e3          	beq	a4,s3,800009f0 <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    80000a0e:	8b85                	andi	a5,a5,1
    80000a10:	d7fd                	beqz	a5,800009fe <freewalk+0x2a>
    {
      panic("freewalk: leaf");
    80000a12:	00006517          	auipc	a0,0x6
    80000a16:	7be50513          	addi	a0,a0,1982 # 800071d0 <etext+0x1d0>
    80000a1a:	309040ef          	jal	ra,80005522 <panic>
    }
  }
  kfree((void *)pagetable);
    80000a1e:	8552                	mv	a0,s4
    80000a20:	e50ff0ef          	jal	ra,80000070 <kfree>
}
    80000a24:	70a2                	ld	ra,40(sp)
    80000a26:	7402                	ld	s0,32(sp)
    80000a28:	64e2                	ld	s1,24(sp)
    80000a2a:	6942                	ld	s2,16(sp)
    80000a2c:	69a2                	ld	s3,8(sp)
    80000a2e:	6a02                	ld	s4,0(sp)
    80000a30:	6145                	addi	sp,sp,48
    80000a32:	8082                	ret

0000000080000a34 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000a34:	1101                	addi	sp,sp,-32
    80000a36:	ec06                	sd	ra,24(sp)
    80000a38:	e822                	sd	s0,16(sp)
    80000a3a:	e426                	sd	s1,8(sp)
    80000a3c:	1000                	addi	s0,sp,32
    80000a3e:	84aa                	mv	s1,a0
  if (sz > 0)
    80000a40:	e989                	bnez	a1,80000a52 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80000a42:	8526                	mv	a0,s1
    80000a44:	f91ff0ef          	jal	ra,800009d4 <freewalk>
}
    80000a48:	60e2                	ld	ra,24(sp)
    80000a4a:	6442                	ld	s0,16(sp)
    80000a4c:	64a2                	ld	s1,8(sp)
    80000a4e:	6105                	addi	sp,sp,32
    80000a50:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80000a52:	6785                	lui	a5,0x1
    80000a54:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000a56:	95be                	add	a1,a1,a5
    80000a58:	4685                	li	a3,1
    80000a5a:	00c5d613          	srli	a2,a1,0xc
    80000a5e:	4581                	li	a1,0
    80000a60:	d57ff0ef          	jal	ra,800007b6 <uvmunmap>
    80000a64:	bff9                	j	80000a42 <uvmfree+0xe>

0000000080000a66 <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;
  int szinc;

  for (i = 0; i < sz; i += szinc)
    80000a66:	c65d                	beqz	a2,80000b14 <uvmcopy+0xae>
{
    80000a68:	715d                	addi	sp,sp,-80
    80000a6a:	e486                	sd	ra,72(sp)
    80000a6c:	e0a2                	sd	s0,64(sp)
    80000a6e:	fc26                	sd	s1,56(sp)
    80000a70:	f84a                	sd	s2,48(sp)
    80000a72:	f44e                	sd	s3,40(sp)
    80000a74:	f052                	sd	s4,32(sp)
    80000a76:	ec56                	sd	s5,24(sp)
    80000a78:	e85a                	sd	s6,16(sp)
    80000a7a:	e45e                	sd	s7,8(sp)
    80000a7c:	0880                	addi	s0,sp,80
    80000a7e:	8b2a                	mv	s6,a0
    80000a80:	8aae                	mv	s5,a1
    80000a82:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += szinc)
    80000a84:	4981                	li	s3,0
  {
    szinc = PGSIZE;
    if ((pte = walk(old, i, 0)) == 0)
    80000a86:	4601                	li	a2,0
    80000a88:	85ce                	mv	a1,s3
    80000a8a:	855a                	mv	a0,s6
    80000a8c:	aa3ff0ef          	jal	ra,8000052e <walk>
    80000a90:	c121                	beqz	a0,80000ad0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    80000a92:	6118                	ld	a4,0(a0)
    80000a94:	00177793          	andi	a5,a4,1
    80000a98:	c3b1                	beqz	a5,80000adc <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000a9a:	00a75593          	srli	a1,a4,0xa
    80000a9e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000aa2:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80000aa6:	ebeff0ef          	jal	ra,80000164 <kalloc>
    80000aaa:	892a                	mv	s2,a0
    80000aac:	c129                	beqz	a0,80000aee <uvmcopy+0x88>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80000aae:	6605                	lui	a2,0x1
    80000ab0:	85de                	mv	a1,s7
    80000ab2:	85dff0ef          	jal	ra,8000030e <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80000ab6:	8726                	mv	a4,s1
    80000ab8:	86ca                	mv	a3,s2
    80000aba:	6605                	lui	a2,0x1
    80000abc:	85ce                	mv	a1,s3
    80000abe:	8556                	mv	a0,s5
    80000ac0:	b51ff0ef          	jal	ra,80000610 <mappages>
    80000ac4:	e115                	bnez	a0,80000ae8 <uvmcopy+0x82>
  for (i = 0; i < sz; i += szinc)
    80000ac6:	6785                	lui	a5,0x1
    80000ac8:	99be                	add	s3,s3,a5
    80000aca:	fb49eee3          	bltu	s3,s4,80000a86 <uvmcopy+0x20>
    80000ace:	a805                	j	80000afe <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80000ad0:	00006517          	auipc	a0,0x6
    80000ad4:	71050513          	addi	a0,a0,1808 # 800071e0 <etext+0x1e0>
    80000ad8:	24b040ef          	jal	ra,80005522 <panic>
      panic("uvmcopy: page not present");
    80000adc:	00006517          	auipc	a0,0x6
    80000ae0:	72450513          	addi	a0,a0,1828 # 80007200 <etext+0x200>
    80000ae4:	23f040ef          	jal	ra,80005522 <panic>
    {
      kfree(mem);
    80000ae8:	854a                	mv	a0,s2
    80000aea:	d86ff0ef          	jal	ra,80000070 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000aee:	4685                	li	a3,1
    80000af0:	00c9d613          	srli	a2,s3,0xc
    80000af4:	4581                	li	a1,0
    80000af6:	8556                	mv	a0,s5
    80000af8:	cbfff0ef          	jal	ra,800007b6 <uvmunmap>
  return -1;
    80000afc:	557d                	li	a0,-1
}
    80000afe:	60a6                	ld	ra,72(sp)
    80000b00:	6406                	ld	s0,64(sp)
    80000b02:	74e2                	ld	s1,56(sp)
    80000b04:	7942                	ld	s2,48(sp)
    80000b06:	79a2                	ld	s3,40(sp)
    80000b08:	7a02                	ld	s4,32(sp)
    80000b0a:	6ae2                	ld	s5,24(sp)
    80000b0c:	6b42                	ld	s6,16(sp)
    80000b0e:	6ba2                	ld	s7,8(sp)
    80000b10:	6161                	addi	sp,sp,80
    80000b12:	8082                	ret
  return 0;
    80000b14:	4501                	li	a0,0
}
    80000b16:	8082                	ret

0000000080000b18 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    80000b18:	1141                	addi	sp,sp,-16
    80000b1a:	e406                	sd	ra,8(sp)
    80000b1c:	e022                	sd	s0,0(sp)
    80000b1e:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80000b20:	4601                	li	a2,0
    80000b22:	a0dff0ef          	jal	ra,8000052e <walk>
  if (pte == 0)
    80000b26:	c901                	beqz	a0,80000b36 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000b28:	611c                	ld	a5,0(a0)
    80000b2a:	9bbd                	andi	a5,a5,-17
    80000b2c:	e11c                	sd	a5,0(a0)
}
    80000b2e:	60a2                	ld	ra,8(sp)
    80000b30:	6402                	ld	s0,0(sp)
    80000b32:	0141                	addi	sp,sp,16
    80000b34:	8082                	ret
    panic("uvmclear");
    80000b36:	00006517          	auipc	a0,0x6
    80000b3a:	6ea50513          	addi	a0,a0,1770 # 80007220 <etext+0x220>
    80000b3e:	1e5040ef          	jal	ra,80005522 <panic>

0000000080000b42 <copyout>:
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while (len > 0)
    80000b42:	c6c1                	beqz	a3,80000bca <copyout+0x88>
{
    80000b44:	711d                	addi	sp,sp,-96
    80000b46:	ec86                	sd	ra,88(sp)
    80000b48:	e8a2                	sd	s0,80(sp)
    80000b4a:	e4a6                	sd	s1,72(sp)
    80000b4c:	e0ca                	sd	s2,64(sp)
    80000b4e:	fc4e                	sd	s3,56(sp)
    80000b50:	f852                	sd	s4,48(sp)
    80000b52:	f456                	sd	s5,40(sp)
    80000b54:	f05a                	sd	s6,32(sp)
    80000b56:	ec5e                	sd	s7,24(sp)
    80000b58:	e862                	sd	s8,16(sp)
    80000b5a:	e466                	sd	s9,8(sp)
    80000b5c:	1080                	addi	s0,sp,96
    80000b5e:	8b2a                	mv	s6,a0
    80000b60:	8a2e                	mv	s4,a1
    80000b62:	8ab2                	mv	s5,a2
    80000b64:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80000b66:	74fd                	lui	s1,0xfffff
    80000b68:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000b6a:	57fd                	li	a5,-1
    80000b6c:	83e9                	srli	a5,a5,0x1a
    80000b6e:	0697e063          	bltu	a5,s1,80000bce <copyout+0x8c>
    80000b72:	6c05                	lui	s8,0x1
    80000b74:	8bbe                	mv	s7,a5
    80000b76:	a015                	j	80000b9a <copyout+0x58>
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000b78:	409a04b3          	sub	s1,s4,s1
    80000b7c:	0009061b          	sext.w	a2,s2
    80000b80:	85d6                	mv	a1,s5
    80000b82:	9526                	add	a0,a0,s1
    80000b84:	f8aff0ef          	jal	ra,8000030e <memmove>

    len -= n;
    80000b88:	412989b3          	sub	s3,s3,s2
    src += n;
    80000b8c:	9aca                	add	s5,s5,s2
  while (len > 0)
    80000b8e:	02098c63          	beqz	s3,80000bc6 <copyout+0x84>
    if (va0 >= MAXVA)
    80000b92:	059be063          	bltu	s7,s9,80000bd2 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80000b96:	84e6                	mv	s1,s9
    dstva = va0 + PGSIZE;
    80000b98:	8a66                	mv	s4,s9
    if ((pte = walk(pagetable, va0, 0)) == 0)
    80000b9a:	4601                	li	a2,0
    80000b9c:	85a6                	mv	a1,s1
    80000b9e:	855a                	mv	a0,s6
    80000ba0:	98fff0ef          	jal	ra,8000052e <walk>
    80000ba4:	c90d                	beqz	a0,80000bd6 <copyout+0x94>
    if ((*pte & PTE_W) == 0)
    80000ba6:	611c                	ld	a5,0(a0)
    80000ba8:	8b91                	andi	a5,a5,4
    80000baa:	c7a1                	beqz	a5,80000bf2 <copyout+0xb0>
    pa0 = walkaddr(pagetable, va0);
    80000bac:	85a6                	mv	a1,s1
    80000bae:	855a                	mv	a0,s6
    80000bb0:	a23ff0ef          	jal	ra,800005d2 <walkaddr>
    if (pa0 == 0)
    80000bb4:	c129                	beqz	a0,80000bf6 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80000bb6:	01848cb3          	add	s9,s1,s8
    80000bba:	414c8933          	sub	s2,s9,s4
    80000bbe:	fb29fde3          	bgeu	s3,s2,80000b78 <copyout+0x36>
    80000bc2:	894e                	mv	s2,s3
    80000bc4:	bf55                	j	80000b78 <copyout+0x36>
  }
  return 0;
    80000bc6:	4501                	li	a0,0
    80000bc8:	a801                	j	80000bd8 <copyout+0x96>
    80000bca:	4501                	li	a0,0
}
    80000bcc:	8082                	ret
      return -1;
    80000bce:	557d                	li	a0,-1
    80000bd0:	a021                	j	80000bd8 <copyout+0x96>
    80000bd2:	557d                	li	a0,-1
    80000bd4:	a011                	j	80000bd8 <copyout+0x96>
      return -1;
    80000bd6:	557d                	li	a0,-1
}
    80000bd8:	60e6                	ld	ra,88(sp)
    80000bda:	6446                	ld	s0,80(sp)
    80000bdc:	64a6                	ld	s1,72(sp)
    80000bde:	6906                	ld	s2,64(sp)
    80000be0:	79e2                	ld	s3,56(sp)
    80000be2:	7a42                	ld	s4,48(sp)
    80000be4:	7aa2                	ld	s5,40(sp)
    80000be6:	7b02                	ld	s6,32(sp)
    80000be8:	6be2                	ld	s7,24(sp)
    80000bea:	6c42                	ld	s8,16(sp)
    80000bec:	6ca2                	ld	s9,8(sp)
    80000bee:	6125                	addi	sp,sp,96
    80000bf0:	8082                	ret
      return -1;
    80000bf2:	557d                	li	a0,-1
    80000bf4:	b7d5                	j	80000bd8 <copyout+0x96>
      return -1;
    80000bf6:	557d                	li	a0,-1
    80000bf8:	b7c5                	j	80000bd8 <copyout+0x96>

0000000080000bfa <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    80000bfa:	c6a5                	beqz	a3,80000c62 <copyin+0x68>
{
    80000bfc:	715d                	addi	sp,sp,-80
    80000bfe:	e486                	sd	ra,72(sp)
    80000c00:	e0a2                	sd	s0,64(sp)
    80000c02:	fc26                	sd	s1,56(sp)
    80000c04:	f84a                	sd	s2,48(sp)
    80000c06:	f44e                	sd	s3,40(sp)
    80000c08:	f052                	sd	s4,32(sp)
    80000c0a:	ec56                	sd	s5,24(sp)
    80000c0c:	e85a                	sd	s6,16(sp)
    80000c0e:	e45e                	sd	s7,8(sp)
    80000c10:	e062                	sd	s8,0(sp)
    80000c12:	0880                	addi	s0,sp,80
    80000c14:	8b2a                	mv	s6,a0
    80000c16:	8a2e                	mv	s4,a1
    80000c18:	8c32                	mv	s8,a2
    80000c1a:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000c1c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c1e:	6a85                	lui	s5,0x1
    80000c20:	a00d                	j	80000c42 <copyin+0x48>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000c22:	018505b3          	add	a1,a0,s8
    80000c26:	0004861b          	sext.w	a2,s1
    80000c2a:	412585b3          	sub	a1,a1,s2
    80000c2e:	8552                	mv	a0,s4
    80000c30:	edeff0ef          	jal	ra,8000030e <memmove>

    len -= n;
    80000c34:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000c38:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000c3a:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80000c3e:	02098063          	beqz	s3,80000c5e <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000c42:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000c46:	85ca                	mv	a1,s2
    80000c48:	855a                	mv	a0,s6
    80000c4a:	989ff0ef          	jal	ra,800005d2 <walkaddr>
    if (pa0 == 0)
    80000c4e:	cd01                	beqz	a0,80000c66 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000c50:	418904b3          	sub	s1,s2,s8
    80000c54:	94d6                	add	s1,s1,s5
    80000c56:	fc99f6e3          	bgeu	s3,s1,80000c22 <copyin+0x28>
    80000c5a:	84ce                	mv	s1,s3
    80000c5c:	b7d9                	j	80000c22 <copyin+0x28>
  }
  return 0;
    80000c5e:	4501                	li	a0,0
    80000c60:	a021                	j	80000c68 <copyin+0x6e>
    80000c62:	4501                	li	a0,0
}
    80000c64:	8082                	ret
      return -1;
    80000c66:	557d                	li	a0,-1
}
    80000c68:	60a6                	ld	ra,72(sp)
    80000c6a:	6406                	ld	s0,64(sp)
    80000c6c:	74e2                	ld	s1,56(sp)
    80000c6e:	7942                	ld	s2,48(sp)
    80000c70:	79a2                	ld	s3,40(sp)
    80000c72:	7a02                	ld	s4,32(sp)
    80000c74:	6ae2                	ld	s5,24(sp)
    80000c76:	6b42                	ld	s6,16(sp)
    80000c78:	6ba2                	ld	s7,8(sp)
    80000c7a:	6c02                	ld	s8,0(sp)
    80000c7c:	6161                	addi	sp,sp,80
    80000c7e:	8082                	ret

0000000080000c80 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80000c80:	c2cd                	beqz	a3,80000d22 <copyinstr+0xa2>
{
    80000c82:	715d                	addi	sp,sp,-80
    80000c84:	e486                	sd	ra,72(sp)
    80000c86:	e0a2                	sd	s0,64(sp)
    80000c88:	fc26                	sd	s1,56(sp)
    80000c8a:	f84a                	sd	s2,48(sp)
    80000c8c:	f44e                	sd	s3,40(sp)
    80000c8e:	f052                	sd	s4,32(sp)
    80000c90:	ec56                	sd	s5,24(sp)
    80000c92:	e85a                	sd	s6,16(sp)
    80000c94:	e45e                	sd	s7,8(sp)
    80000c96:	0880                	addi	s0,sp,80
    80000c98:	8a2a                	mv	s4,a0
    80000c9a:	8b2e                	mv	s6,a1
    80000c9c:	8bb2                	mv	s7,a2
    80000c9e:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000ca0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000ca2:	6985                	lui	s3,0x1
    80000ca4:	a02d                	j	80000cce <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    80000ca6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000caa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80000cac:	37fd                	addiw	a5,a5,-1
    80000cae:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    80000cb2:	60a6                	ld	ra,72(sp)
    80000cb4:	6406                	ld	s0,64(sp)
    80000cb6:	74e2                	ld	s1,56(sp)
    80000cb8:	7942                	ld	s2,48(sp)
    80000cba:	79a2                	ld	s3,40(sp)
    80000cbc:	7a02                	ld	s4,32(sp)
    80000cbe:	6ae2                	ld	s5,24(sp)
    80000cc0:	6b42                	ld	s6,16(sp)
    80000cc2:	6ba2                	ld	s7,8(sp)
    80000cc4:	6161                	addi	sp,sp,80
    80000cc6:	8082                	ret
    srcva = va0 + PGSIZE;
    80000cc8:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80000ccc:	c4b9                	beqz	s1,80000d1a <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80000cce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000cd2:	85ca                	mv	a1,s2
    80000cd4:	8552                	mv	a0,s4
    80000cd6:	8fdff0ef          	jal	ra,800005d2 <walkaddr>
    if (pa0 == 0)
    80000cda:	c131                	beqz	a0,80000d1e <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80000cdc:	417906b3          	sub	a3,s2,s7
    80000ce0:	96ce                	add	a3,a3,s3
    80000ce2:	00d4f363          	bgeu	s1,a3,80000ce8 <copyinstr+0x68>
    80000ce6:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80000ce8:	955e                	add	a0,a0,s7
    80000cea:	41250533          	sub	a0,a0,s2
    while (n > 0)
    80000cee:	dee9                	beqz	a3,80000cc8 <copyinstr+0x48>
    80000cf0:	87da                	mv	a5,s6
      if (*p == '\0')
    80000cf2:	41650633          	sub	a2,a0,s6
    80000cf6:	fff48593          	addi	a1,s1,-1 # ffffffffffffefff <end+0xffffffff7ffde06f>
    80000cfa:	95da                	add	a1,a1,s6
    while (n > 0)
    80000cfc:	96da                	add	a3,a3,s6
      if (*p == '\0')
    80000cfe:	00f60733          	add	a4,a2,a5
    80000d02:	00074703          	lbu	a4,0(a4)
    80000d06:	d345                	beqz	a4,80000ca6 <copyinstr+0x26>
        *dst = *p;
    80000d08:	00e78023          	sb	a4,0(a5)
      --max;
    80000d0c:	40f584b3          	sub	s1,a1,a5
      dst++;
    80000d10:	0785                	addi	a5,a5,1
    while (n > 0)
    80000d12:	fed796e3          	bne	a5,a3,80000cfe <copyinstr+0x7e>
      dst++;
    80000d16:	8b3e                	mv	s6,a5
    80000d18:	bf45                	j	80000cc8 <copyinstr+0x48>
    80000d1a:	4781                	li	a5,0
    80000d1c:	bf41                	j	80000cac <copyinstr+0x2c>
      return -1;
    80000d1e:	557d                	li	a0,-1
    80000d20:	bf49                	j	80000cb2 <copyinstr+0x32>
  int got_null = 0;
    80000d22:	4781                	li	a5,0
  if (got_null)
    80000d24:	37fd                	addiw	a5,a5,-1
    80000d26:	0007851b          	sext.w	a0,a5
}
    80000d2a:	8082                	ret

0000000080000d2c <vmprint_recurse>:
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
}
#endif

void vmprint_recurse(pagetable_t pagetable, int depth, uint64 va_recursive)
{ // seperate function so we can keep track of depth using a parameter
    80000d2c:	7119                	addi	sp,sp,-128
    80000d2e:	fc86                	sd	ra,120(sp)
    80000d30:	f8a2                	sd	s0,112(sp)
    80000d32:	f4a6                	sd	s1,104(sp)
    80000d34:	f0ca                	sd	s2,96(sp)
    80000d36:	ecce                	sd	s3,88(sp)
    80000d38:	e8d2                	sd	s4,80(sp)
    80000d3a:	e4d6                	sd	s5,72(sp)
    80000d3c:	e0da                	sd	s6,64(sp)
    80000d3e:	fc5e                	sd	s7,56(sp)
    80000d40:	f862                	sd	s8,48(sp)
    80000d42:	f466                	sd	s9,40(sp)
    80000d44:	f06a                	sd	s10,32(sp)
    80000d46:	ec6e                	sd	s11,24(sp)
    80000d48:	0100                	addi	s0,sp,128
    80000d4a:	8aae                	mv	s5,a1
    80000d4c:	8d32                	mv	s10,a2
    { // skip the pte if it's not valid per lab spec
      continue;
    }

    // reconstruct va using i, px shift, and the previous va
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000d4e:	4789                	li	a5,2
    80000d50:	9f8d                	subw	a5,a5,a1
    80000d52:	00379c9b          	slliw	s9,a5,0x3
    80000d56:	00fc8cbb          	addw	s9,s9,a5
    80000d5a:	2cb1                	addiw	s9,s9,12
    80000d5c:	8a2a                	mv	s4,a0
    80000d5e:	4981                	li	s3,0
      printf(".. ");
    }
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));

    // recursive block
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000d60:	4d85                	li	s11,1
    {
      uint64 child_pa = PTE2PA(pte); // get child pa to convert to a pagetable
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000d62:	0015879b          	addiw	a5,a1,1
    80000d66:	f8f43423          	sd	a5,-120(s0)
      printf(".. ");
    80000d6a:	00006b17          	auipc	s6,0x6
    80000d6e:	4ceb0b13          	addi	s6,s6,1230 # 80007238 <etext+0x238>
  for (int i = 0; i < 512; i++)
    80000d72:	20000c13          	li	s8,512
    80000d76:	a029                	j	80000d80 <vmprint_recurse+0x54>
    80000d78:	0985                	addi	s3,s3,1 # 1001 <_entry-0x7fffefff>
    80000d7a:	0a21                	addi	s4,s4,8
    80000d7c:	07898163          	beq	s3,s8,80000dde <vmprint_recurse+0xb2>
    pte_t pte = pagetable[i]; // store pte from page table
    80000d80:	000a3903          	ld	s2,0(s4)
    if (!(pte & PTE_V))
    80000d84:	00197793          	andi	a5,s2,1
    80000d88:	dbe5                	beqz	a5,80000d78 <vmprint_recurse+0x4c>
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000d8a:	01999bb3          	sll	s7,s3,s9
    80000d8e:	01abebb3          	or	s7,s7,s10
    printf(" ");
    80000d92:	00006517          	auipc	a0,0x6
    80000d96:	49e50513          	addi	a0,a0,1182 # 80007230 <etext+0x230>
    80000d9a:	4d4040ef          	jal	ra,8000526e <printf>
    for (int j = 0; j < depth; j++)
    80000d9e:	01505963          	blez	s5,80000db0 <vmprint_recurse+0x84>
    80000da2:	4481                	li	s1,0
      printf(".. ");
    80000da4:	855a                	mv	a0,s6
    80000da6:	4c8040ef          	jal	ra,8000526e <printf>
    for (int j = 0; j < depth; j++)
    80000daa:	2485                	addiw	s1,s1,1
    80000dac:	fe9a9ce3          	bne	s5,s1,80000da4 <vmprint_recurse+0x78>
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));
    80000db0:	00a95493          	srli	s1,s2,0xa
    80000db4:	04b2                	slli	s1,s1,0xc
    80000db6:	86a6                	mv	a3,s1
    80000db8:	864a                	mv	a2,s2
    80000dba:	85de                	mv	a1,s7
    80000dbc:	00006517          	auipc	a0,0x6
    80000dc0:	48450513          	addi	a0,a0,1156 # 80007240 <etext+0x240>
    80000dc4:	4aa040ef          	jal	ra,8000526e <printf>
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000dc8:	00f97913          	andi	s2,s2,15
    80000dcc:	fbb916e3          	bne	s2,s11,80000d78 <vmprint_recurse+0x4c>
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000dd0:	865e                	mv	a2,s7
    80000dd2:	f8843583          	ld	a1,-120(s0)
    80000dd6:	8526                	mv	a0,s1
    80000dd8:	f55ff0ef          	jal	ra,80000d2c <vmprint_recurse>
    80000ddc:	bf71                	j	80000d78 <vmprint_recurse+0x4c>
    }
  }
}
    80000dde:	70e6                	ld	ra,120(sp)
    80000de0:	7446                	ld	s0,112(sp)
    80000de2:	74a6                	ld	s1,104(sp)
    80000de4:	7906                	ld	s2,96(sp)
    80000de6:	69e6                	ld	s3,88(sp)
    80000de8:	6a46                	ld	s4,80(sp)
    80000dea:	6aa6                	ld	s5,72(sp)
    80000dec:	6b06                	ld	s6,64(sp)
    80000dee:	7be2                	ld	s7,56(sp)
    80000df0:	7c42                	ld	s8,48(sp)
    80000df2:	7ca2                	ld	s9,40(sp)
    80000df4:	7d02                	ld	s10,32(sp)
    80000df6:	6de2                	ld	s11,24(sp)
    80000df8:	6109                	addi	sp,sp,128
    80000dfa:	8082                	ret

0000000080000dfc <vmprint>:
{
    80000dfc:	1101                	addi	sp,sp,-32
    80000dfe:	ec06                	sd	ra,24(sp)
    80000e00:	e822                	sd	s0,16(sp)
    80000e02:	e426                	sd	s1,8(sp)
    80000e04:	1000                	addi	s0,sp,32
    80000e06:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80000e08:	85aa                	mv	a1,a0
    80000e0a:	00006517          	auipc	a0,0x6
    80000e0e:	44e50513          	addi	a0,a0,1102 # 80007258 <etext+0x258>
    80000e12:	45c040ef          	jal	ra,8000526e <printf>
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
    80000e16:	4601                	li	a2,0
    80000e18:	4581                	li	a1,0
    80000e1a:	8526                	mv	a0,s1
    80000e1c:	f11ff0ef          	jal	ra,80000d2c <vmprint_recurse>
}
    80000e20:	60e2                	ld	ra,24(sp)
    80000e22:	6442                	ld	s0,16(sp)
    80000e24:	64a2                	ld	s1,8(sp)
    80000e26:	6105                	addi	sp,sp,32
    80000e28:	8082                	ret

0000000080000e2a <pgpte>:

#ifdef LAB_PGTBL
pte_t *
pgpte(pagetable_t pagetable, uint64 va)
{
    80000e2a:	1141                	addi	sp,sp,-16
    80000e2c:	e406                	sd	ra,8(sp)
    80000e2e:	e022                	sd	s0,0(sp)
    80000e30:	0800                	addi	s0,sp,16
  return walk(pagetable, va, 0);
    80000e32:	4601                	li	a2,0
    80000e34:	efaff0ef          	jal	ra,8000052e <walk>
}
    80000e38:	60a2                	ld	ra,8(sp)
    80000e3a:	6402                	ld	s0,0(sp)
    80000e3c:	0141                	addi	sp,sp,16
    80000e3e:	8082                	ret

0000000080000e40 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000e40:	7139                	addi	sp,sp,-64
    80000e42:	fc06                	sd	ra,56(sp)
    80000e44:	f822                	sd	s0,48(sp)
    80000e46:	f426                	sd	s1,40(sp)
    80000e48:	f04a                	sd	s2,32(sp)
    80000e4a:	ec4e                	sd	s3,24(sp)
    80000e4c:	e852                	sd	s4,16(sp)
    80000e4e:	e456                	sd	s5,8(sp)
    80000e50:	e05a                	sd	s6,0(sp)
    80000e52:	0080                	addi	s0,sp,64
    80000e54:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80000e56:	00007497          	auipc	s1,0x7
    80000e5a:	25a48493          	addi	s1,s1,602 # 800080b0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000e5e:	8b26                	mv	s6,s1
    80000e60:	00006a97          	auipc	s5,0x6
    80000e64:	1a0a8a93          	addi	s5,s5,416 # 80007000 <etext>
    80000e68:	04000937          	lui	s2,0x4000
    80000e6c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000e6e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e70:	0000da17          	auipc	s4,0xd
    80000e74:	c40a0a13          	addi	s4,s4,-960 # 8000dab0 <tickslock>
    char *pa = kalloc();
    80000e78:	aecff0ef          	jal	ra,80000164 <kalloc>
    80000e7c:	862a                	mv	a2,a0
    if(pa == 0)
    80000e7e:	c121                	beqz	a0,80000ebe <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80000e80:	416485b3          	sub	a1,s1,s6
    80000e84:	858d                	srai	a1,a1,0x3
    80000e86:	000ab783          	ld	a5,0(s5)
    80000e8a:	02f585b3          	mul	a1,a1,a5
    80000e8e:	2585                	addiw	a1,a1,1
    80000e90:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000e94:	4719                	li	a4,6
    80000e96:	6685                	lui	a3,0x1
    80000e98:	40b905b3          	sub	a1,s2,a1
    80000e9c:	854e                	mv	a0,s3
    80000e9e:	823ff0ef          	jal	ra,800006c0 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000ea2:	16848493          	addi	s1,s1,360
    80000ea6:	fd4499e3          	bne	s1,s4,80000e78 <proc_mapstacks+0x38>
  }
}
    80000eaa:	70e2                	ld	ra,56(sp)
    80000eac:	7442                	ld	s0,48(sp)
    80000eae:	74a2                	ld	s1,40(sp)
    80000eb0:	7902                	ld	s2,32(sp)
    80000eb2:	69e2                	ld	s3,24(sp)
    80000eb4:	6a42                	ld	s4,16(sp)
    80000eb6:	6aa2                	ld	s5,8(sp)
    80000eb8:	6b02                	ld	s6,0(sp)
    80000eba:	6121                	addi	sp,sp,64
    80000ebc:	8082                	ret
      panic("kalloc");
    80000ebe:	00006517          	auipc	a0,0x6
    80000ec2:	3aa50513          	addi	a0,a0,938 # 80007268 <etext+0x268>
    80000ec6:	65c040ef          	jal	ra,80005522 <panic>

0000000080000eca <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000eca:	7139                	addi	sp,sp,-64
    80000ecc:	fc06                	sd	ra,56(sp)
    80000ece:	f822                	sd	s0,48(sp)
    80000ed0:	f426                	sd	s1,40(sp)
    80000ed2:	f04a                	sd	s2,32(sp)
    80000ed4:	ec4e                	sd	s3,24(sp)
    80000ed6:	e852                	sd	s4,16(sp)
    80000ed8:	e456                	sd	s5,8(sp)
    80000eda:	e05a                	sd	s6,0(sp)
    80000edc:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80000ede:	00006597          	auipc	a1,0x6
    80000ee2:	39258593          	addi	a1,a1,914 # 80007270 <etext+0x270>
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	d9a50513          	addi	a0,a0,-614 # 80007c80 <pid_lock>
    80000eee:	0c5040ef          	jal	ra,800057b2 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000ef2:	00006597          	auipc	a1,0x6
    80000ef6:	38658593          	addi	a1,a1,902 # 80007278 <etext+0x278>
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	d9e50513          	addi	a0,a0,-610 # 80007c98 <wait_lock>
    80000f02:	0b1040ef          	jal	ra,800057b2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f06:	00007497          	auipc	s1,0x7
    80000f0a:	1aa48493          	addi	s1,s1,426 # 800080b0 <proc>
      initlock(&p->lock, "proc");
    80000f0e:	00006b17          	auipc	s6,0x6
    80000f12:	37ab0b13          	addi	s6,s6,890 # 80007288 <etext+0x288>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000f16:	8aa6                	mv	s5,s1
    80000f18:	00006a17          	auipc	s4,0x6
    80000f1c:	0e8a0a13          	addi	s4,s4,232 # 80007000 <etext>
    80000f20:	04000937          	lui	s2,0x4000
    80000f24:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000f26:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f28:	0000d997          	auipc	s3,0xd
    80000f2c:	b8898993          	addi	s3,s3,-1144 # 8000dab0 <tickslock>
      initlock(&p->lock, "proc");
    80000f30:	85da                	mv	a1,s6
    80000f32:	8526                	mv	a0,s1
    80000f34:	07f040ef          	jal	ra,800057b2 <initlock>
      p->state = UNUSED;
    80000f38:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000f3c:	415487b3          	sub	a5,s1,s5
    80000f40:	878d                	srai	a5,a5,0x3
    80000f42:	000a3703          	ld	a4,0(s4)
    80000f46:	02e787b3          	mul	a5,a5,a4
    80000f4a:	2785                	addiw	a5,a5,1
    80000f4c:	00d7979b          	slliw	a5,a5,0xd
    80000f50:	40f907b3          	sub	a5,s2,a5
    80000f54:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f56:	16848493          	addi	s1,s1,360
    80000f5a:	fd349be3          	bne	s1,s3,80000f30 <procinit+0x66>
  }
}
    80000f5e:	70e2                	ld	ra,56(sp)
    80000f60:	7442                	ld	s0,48(sp)
    80000f62:	74a2                	ld	s1,40(sp)
    80000f64:	7902                	ld	s2,32(sp)
    80000f66:	69e2                	ld	s3,24(sp)
    80000f68:	6a42                	ld	s4,16(sp)
    80000f6a:	6aa2                	ld	s5,8(sp)
    80000f6c:	6b02                	ld	s6,0(sp)
    80000f6e:	6121                	addi	sp,sp,64
    80000f70:	8082                	ret

0000000080000f72 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000f72:	1141                	addi	sp,sp,-16
    80000f74:	e422                	sd	s0,8(sp)
    80000f76:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000f78:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000f7a:	2501                	sext.w	a0,a0
    80000f7c:	6422                	ld	s0,8(sp)
    80000f7e:	0141                	addi	sp,sp,16
    80000f80:	8082                	ret

0000000080000f82 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
    80000f88:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000f8a:	2781                	sext.w	a5,a5
    80000f8c:	079e                	slli	a5,a5,0x7
  return c;
}
    80000f8e:	00007517          	auipc	a0,0x7
    80000f92:	d2250513          	addi	a0,a0,-734 # 80007cb0 <cpus>
    80000f96:	953e                	add	a0,a0,a5
    80000f98:	6422                	ld	s0,8(sp)
    80000f9a:	0141                	addi	sp,sp,16
    80000f9c:	8082                	ret

0000000080000f9e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000f9e:	1101                	addi	sp,sp,-32
    80000fa0:	ec06                	sd	ra,24(sp)
    80000fa2:	e822                	sd	s0,16(sp)
    80000fa4:	e426                	sd	s1,8(sp)
    80000fa6:	1000                	addi	s0,sp,32
  push_off();
    80000fa8:	04b040ef          	jal	ra,800057f2 <push_off>
    80000fac:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000fae:	2781                	sext.w	a5,a5
    80000fb0:	079e                	slli	a5,a5,0x7
    80000fb2:	00007717          	auipc	a4,0x7
    80000fb6:	cce70713          	addi	a4,a4,-818 # 80007c80 <pid_lock>
    80000fba:	97ba                	add	a5,a5,a4
    80000fbc:	7b84                	ld	s1,48(a5)
  pop_off();
    80000fbe:	0b9040ef          	jal	ra,80005876 <pop_off>
  return p;
}
    80000fc2:	8526                	mv	a0,s1
    80000fc4:	60e2                	ld	ra,24(sp)
    80000fc6:	6442                	ld	s0,16(sp)
    80000fc8:	64a2                	ld	s1,8(sp)
    80000fca:	6105                	addi	sp,sp,32
    80000fcc:	8082                	ret

0000000080000fce <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000fce:	1141                	addi	sp,sp,-16
    80000fd0:	e406                	sd	ra,8(sp)
    80000fd2:	e022                	sd	s0,0(sp)
    80000fd4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000fd6:	fc9ff0ef          	jal	ra,80000f9e <myproc>
    80000fda:	0f1040ef          	jal	ra,800058ca <release>

  if (first) {
    80000fde:	00007797          	auipc	a5,0x7
    80000fe2:	9e27a783          	lw	a5,-1566(a5) # 800079c0 <first.1>
    80000fe6:	e799                	bnez	a5,80000ff4 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000fe8:	2bd000ef          	jal	ra,80001aa4 <usertrapret>
}
    80000fec:	60a2                	ld	ra,8(sp)
    80000fee:	6402                	ld	s0,0(sp)
    80000ff0:	0141                	addi	sp,sp,16
    80000ff2:	8082                	ret
    fsinit(ROOTDEV);
    80000ff4:	4505                	li	a0,1
    80000ff6:	688010ef          	jal	ra,8000267e <fsinit>
    first = 0;
    80000ffa:	00007797          	auipc	a5,0x7
    80000ffe:	9c07a323          	sw	zero,-1594(a5) # 800079c0 <first.1>
    __sync_synchronize();
    80001002:	0ff0000f          	fence
    80001006:	b7cd                	j	80000fe8 <forkret+0x1a>

0000000080001008 <allocpid>:
{
    80001008:	1101                	addi	sp,sp,-32
    8000100a:	ec06                	sd	ra,24(sp)
    8000100c:	e822                	sd	s0,16(sp)
    8000100e:	e426                	sd	s1,8(sp)
    80001010:	e04a                	sd	s2,0(sp)
    80001012:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001014:	00007917          	auipc	s2,0x7
    80001018:	c6c90913          	addi	s2,s2,-916 # 80007c80 <pid_lock>
    8000101c:	854a                	mv	a0,s2
    8000101e:	015040ef          	jal	ra,80005832 <acquire>
  pid = nextpid;
    80001022:	00007797          	auipc	a5,0x7
    80001026:	9a278793          	addi	a5,a5,-1630 # 800079c4 <nextpid>
    8000102a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000102c:	0014871b          	addiw	a4,s1,1
    80001030:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001032:	854a                	mv	a0,s2
    80001034:	097040ef          	jal	ra,800058ca <release>
}
    80001038:	8526                	mv	a0,s1
    8000103a:	60e2                	ld	ra,24(sp)
    8000103c:	6442                	ld	s0,16(sp)
    8000103e:	64a2                	ld	s1,8(sp)
    80001040:	6902                	ld	s2,0(sp)
    80001042:	6105                	addi	sp,sp,32
    80001044:	8082                	ret

0000000080001046 <proc_pagetable>:
{
    80001046:	1101                	addi	sp,sp,-32
    80001048:	ec06                	sd	ra,24(sp)
    8000104a:	e822                	sd	s0,16(sp)
    8000104c:	e426                	sd	s1,8(sp)
    8000104e:	e04a                	sd	s2,0(sp)
    80001050:	1000                	addi	s0,sp,32
    80001052:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001054:	81fff0ef          	jal	ra,80000872 <uvmcreate>
    80001058:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000105a:	cd05                	beqz	a0,80001092 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000105c:	4729                	li	a4,10
    8000105e:	00005697          	auipc	a3,0x5
    80001062:	fa268693          	addi	a3,a3,-94 # 80006000 <_trampoline>
    80001066:	6605                	lui	a2,0x1
    80001068:	040005b7          	lui	a1,0x4000
    8000106c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000106e:	05b2                	slli	a1,a1,0xc
    80001070:	da0ff0ef          	jal	ra,80000610 <mappages>
    80001074:	02054663          	bltz	a0,800010a0 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001078:	4719                	li	a4,6
    8000107a:	05893683          	ld	a3,88(s2)
    8000107e:	6605                	lui	a2,0x1
    80001080:	020005b7          	lui	a1,0x2000
    80001084:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001086:	05b6                	slli	a1,a1,0xd
    80001088:	8526                	mv	a0,s1
    8000108a:	d86ff0ef          	jal	ra,80000610 <mappages>
    8000108e:	00054f63          	bltz	a0,800010ac <proc_pagetable+0x66>
}
    80001092:	8526                	mv	a0,s1
    80001094:	60e2                	ld	ra,24(sp)
    80001096:	6442                	ld	s0,16(sp)
    80001098:	64a2                	ld	s1,8(sp)
    8000109a:	6902                	ld	s2,0(sp)
    8000109c:	6105                	addi	sp,sp,32
    8000109e:	8082                	ret
    uvmfree(pagetable, 0);
    800010a0:	4581                	li	a1,0
    800010a2:	8526                	mv	a0,s1
    800010a4:	991ff0ef          	jal	ra,80000a34 <uvmfree>
    return 0;
    800010a8:	4481                	li	s1,0
    800010aa:	b7e5                	j	80001092 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800010ac:	4681                	li	a3,0
    800010ae:	4605                	li	a2,1
    800010b0:	040005b7          	lui	a1,0x4000
    800010b4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800010b6:	05b2                	slli	a1,a1,0xc
    800010b8:	8526                	mv	a0,s1
    800010ba:	efcff0ef          	jal	ra,800007b6 <uvmunmap>
    uvmfree(pagetable, 0);
    800010be:	4581                	li	a1,0
    800010c0:	8526                	mv	a0,s1
    800010c2:	973ff0ef          	jal	ra,80000a34 <uvmfree>
    return 0;
    800010c6:	4481                	li	s1,0
    800010c8:	b7e9                	j	80001092 <proc_pagetable+0x4c>

00000000800010ca <proc_freepagetable>:
{
    800010ca:	1101                	addi	sp,sp,-32
    800010cc:	ec06                	sd	ra,24(sp)
    800010ce:	e822                	sd	s0,16(sp)
    800010d0:	e426                	sd	s1,8(sp)
    800010d2:	e04a                	sd	s2,0(sp)
    800010d4:	1000                	addi	s0,sp,32
    800010d6:	84aa                	mv	s1,a0
    800010d8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800010da:	4681                	li	a3,0
    800010dc:	4605                	li	a2,1
    800010de:	040005b7          	lui	a1,0x4000
    800010e2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800010e4:	05b2                	slli	a1,a1,0xc
    800010e6:	ed0ff0ef          	jal	ra,800007b6 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800010ea:	4681                	li	a3,0
    800010ec:	4605                	li	a2,1
    800010ee:	020005b7          	lui	a1,0x2000
    800010f2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800010f4:	05b6                	slli	a1,a1,0xd
    800010f6:	8526                	mv	a0,s1
    800010f8:	ebeff0ef          	jal	ra,800007b6 <uvmunmap>
  uvmfree(pagetable, sz);
    800010fc:	85ca                	mv	a1,s2
    800010fe:	8526                	mv	a0,s1
    80001100:	935ff0ef          	jal	ra,80000a34 <uvmfree>
}
    80001104:	60e2                	ld	ra,24(sp)
    80001106:	6442                	ld	s0,16(sp)
    80001108:	64a2                	ld	s1,8(sp)
    8000110a:	6902                	ld	s2,0(sp)
    8000110c:	6105                	addi	sp,sp,32
    8000110e:	8082                	ret

0000000080001110 <freeproc>:
{
    80001110:	1101                	addi	sp,sp,-32
    80001112:	ec06                	sd	ra,24(sp)
    80001114:	e822                	sd	s0,16(sp)
    80001116:	e426                	sd	s1,8(sp)
    80001118:	1000                	addi	s0,sp,32
    8000111a:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000111c:	6d28                	ld	a0,88(a0)
    8000111e:	c119                	beqz	a0,80001124 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001120:	f51fe0ef          	jal	ra,80000070 <kfree>
  p->trapframe = 0;
    80001124:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001128:	68a8                	ld	a0,80(s1)
    8000112a:	c501                	beqz	a0,80001132 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    8000112c:	64ac                	ld	a1,72(s1)
    8000112e:	f9dff0ef          	jal	ra,800010ca <proc_freepagetable>
  p->pagetable = 0;
    80001132:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001136:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    8000113a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000113e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001142:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001146:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    8000114a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000114e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001152:	0004ac23          	sw	zero,24(s1)
}
    80001156:	60e2                	ld	ra,24(sp)
    80001158:	6442                	ld	s0,16(sp)
    8000115a:	64a2                	ld	s1,8(sp)
    8000115c:	6105                	addi	sp,sp,32
    8000115e:	8082                	ret

0000000080001160 <allocproc>:
{
    80001160:	1101                	addi	sp,sp,-32
    80001162:	ec06                	sd	ra,24(sp)
    80001164:	e822                	sd	s0,16(sp)
    80001166:	e426                	sd	s1,8(sp)
    80001168:	e04a                	sd	s2,0(sp)
    8000116a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000116c:	00007497          	auipc	s1,0x7
    80001170:	f4448493          	addi	s1,s1,-188 # 800080b0 <proc>
    80001174:	0000d917          	auipc	s2,0xd
    80001178:	93c90913          	addi	s2,s2,-1732 # 8000dab0 <tickslock>
    acquire(&p->lock);
    8000117c:	8526                	mv	a0,s1
    8000117e:	6b4040ef          	jal	ra,80005832 <acquire>
    if(p->state == UNUSED) {
    80001182:	4c9c                	lw	a5,24(s1)
    80001184:	cb91                	beqz	a5,80001198 <allocproc+0x38>
      release(&p->lock);
    80001186:	8526                	mv	a0,s1
    80001188:	742040ef          	jal	ra,800058ca <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000118c:	16848493          	addi	s1,s1,360
    80001190:	ff2496e3          	bne	s1,s2,8000117c <allocproc+0x1c>
  return 0;
    80001194:	4481                	li	s1,0
    80001196:	a089                	j	800011d8 <allocproc+0x78>
  p->pid = allocpid();
    80001198:	e71ff0ef          	jal	ra,80001008 <allocpid>
    8000119c:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000119e:	4785                	li	a5,1
    800011a0:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800011a2:	fc3fe0ef          	jal	ra,80000164 <kalloc>
    800011a6:	892a                	mv	s2,a0
    800011a8:	eca8                	sd	a0,88(s1)
    800011aa:	cd15                	beqz	a0,800011e6 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    800011ac:	8526                	mv	a0,s1
    800011ae:	e99ff0ef          	jal	ra,80001046 <proc_pagetable>
    800011b2:	892a                	mv	s2,a0
    800011b4:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800011b6:	c121                	beqz	a0,800011f6 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    800011b8:	07000613          	li	a2,112
    800011bc:	4581                	li	a1,0
    800011be:	06048513          	addi	a0,s1,96
    800011c2:	8f0ff0ef          	jal	ra,800002b2 <memset>
  p->context.ra = (uint64)forkret;
    800011c6:	00000797          	auipc	a5,0x0
    800011ca:	e0878793          	addi	a5,a5,-504 # 80000fce <forkret>
    800011ce:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800011d0:	60bc                	ld	a5,64(s1)
    800011d2:	6705                	lui	a4,0x1
    800011d4:	97ba                	add	a5,a5,a4
    800011d6:	f4bc                	sd	a5,104(s1)
}
    800011d8:	8526                	mv	a0,s1
    800011da:	60e2                	ld	ra,24(sp)
    800011dc:	6442                	ld	s0,16(sp)
    800011de:	64a2                	ld	s1,8(sp)
    800011e0:	6902                	ld	s2,0(sp)
    800011e2:	6105                	addi	sp,sp,32
    800011e4:	8082                	ret
    freeproc(p);
    800011e6:	8526                	mv	a0,s1
    800011e8:	f29ff0ef          	jal	ra,80001110 <freeproc>
    release(&p->lock);
    800011ec:	8526                	mv	a0,s1
    800011ee:	6dc040ef          	jal	ra,800058ca <release>
    return 0;
    800011f2:	84ca                	mv	s1,s2
    800011f4:	b7d5                	j	800011d8 <allocproc+0x78>
    freeproc(p);
    800011f6:	8526                	mv	a0,s1
    800011f8:	f19ff0ef          	jal	ra,80001110 <freeproc>
    release(&p->lock);
    800011fc:	8526                	mv	a0,s1
    800011fe:	6cc040ef          	jal	ra,800058ca <release>
    return 0;
    80001202:	84ca                	mv	s1,s2
    80001204:	bfd1                	j	800011d8 <allocproc+0x78>

0000000080001206 <userinit>:
{
    80001206:	1101                	addi	sp,sp,-32
    80001208:	ec06                	sd	ra,24(sp)
    8000120a:	e822                	sd	s0,16(sp)
    8000120c:	e426                	sd	s1,8(sp)
    8000120e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001210:	f51ff0ef          	jal	ra,80001160 <allocproc>
    80001214:	84aa                	mv	s1,a0
  initproc = p;
    80001216:	00007797          	auipc	a5,0x7
    8000121a:	82a7b523          	sd	a0,-2006(a5) # 80007a40 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    8000121e:	03400613          	li	a2,52
    80001222:	00006597          	auipc	a1,0x6
    80001226:	7ae58593          	addi	a1,a1,1966 # 800079d0 <initcode>
    8000122a:	6928                	ld	a0,80(a0)
    8000122c:	e6cff0ef          	jal	ra,80000898 <uvmfirst>
  p->sz = PGSIZE;
    80001230:	6785                	lui	a5,0x1
    80001232:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001234:	6cb8                	ld	a4,88(s1)
    80001236:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    8000123a:	6cb8                	ld	a4,88(s1)
    8000123c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    8000123e:	4641                	li	a2,16
    80001240:	00006597          	auipc	a1,0x6
    80001244:	05058593          	addi	a1,a1,80 # 80007290 <etext+0x290>
    80001248:	15848513          	addi	a0,s1,344
    8000124c:	9acff0ef          	jal	ra,800003f8 <safestrcpy>
  p->cwd = namei("/");
    80001250:	00006517          	auipc	a0,0x6
    80001254:	05050513          	addi	a0,a0,80 # 800072a0 <etext+0x2a0>
    80001258:	50d010ef          	jal	ra,80002f64 <namei>
    8000125c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001260:	478d                	li	a5,3
    80001262:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001264:	8526                	mv	a0,s1
    80001266:	664040ef          	jal	ra,800058ca <release>
}
    8000126a:	60e2                	ld	ra,24(sp)
    8000126c:	6442                	ld	s0,16(sp)
    8000126e:	64a2                	ld	s1,8(sp)
    80001270:	6105                	addi	sp,sp,32
    80001272:	8082                	ret

0000000080001274 <growproc>:
{
    80001274:	1101                	addi	sp,sp,-32
    80001276:	ec06                	sd	ra,24(sp)
    80001278:	e822                	sd	s0,16(sp)
    8000127a:	e426                	sd	s1,8(sp)
    8000127c:	e04a                	sd	s2,0(sp)
    8000127e:	1000                	addi	s0,sp,32
    80001280:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001282:	d1dff0ef          	jal	ra,80000f9e <myproc>
    80001286:	84aa                	mv	s1,a0
  sz = p->sz;
    80001288:	652c                	ld	a1,72(a0)
  if(n > 0){
    8000128a:	01204c63          	bgtz	s2,800012a2 <growproc+0x2e>
  } else if(n < 0){
    8000128e:	02094463          	bltz	s2,800012b6 <growproc+0x42>
  p->sz = sz;
    80001292:	e4ac                	sd	a1,72(s1)
  return 0;
    80001294:	4501                	li	a0,0
}
    80001296:	60e2                	ld	ra,24(sp)
    80001298:	6442                	ld	s0,16(sp)
    8000129a:	64a2                	ld	s1,8(sp)
    8000129c:	6902                	ld	s2,0(sp)
    8000129e:	6105                	addi	sp,sp,32
    800012a0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800012a2:	4691                	li	a3,4
    800012a4:	00b90633          	add	a2,s2,a1
    800012a8:	6928                	ld	a0,80(a0)
    800012aa:	e90ff0ef          	jal	ra,8000093a <uvmalloc>
    800012ae:	85aa                	mv	a1,a0
    800012b0:	f16d                	bnez	a0,80001292 <growproc+0x1e>
      return -1;
    800012b2:	557d                	li	a0,-1
    800012b4:	b7cd                	j	80001296 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800012b6:	00b90633          	add	a2,s2,a1
    800012ba:	6928                	ld	a0,80(a0)
    800012bc:	e3aff0ef          	jal	ra,800008f6 <uvmdealloc>
    800012c0:	85aa                	mv	a1,a0
    800012c2:	bfc1                	j	80001292 <growproc+0x1e>

00000000800012c4 <fork>:
{
    800012c4:	7139                	addi	sp,sp,-64
    800012c6:	fc06                	sd	ra,56(sp)
    800012c8:	f822                	sd	s0,48(sp)
    800012ca:	f426                	sd	s1,40(sp)
    800012cc:	f04a                	sd	s2,32(sp)
    800012ce:	ec4e                	sd	s3,24(sp)
    800012d0:	e852                	sd	s4,16(sp)
    800012d2:	e456                	sd	s5,8(sp)
    800012d4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800012d6:	cc9ff0ef          	jal	ra,80000f9e <myproc>
    800012da:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800012dc:	e85ff0ef          	jal	ra,80001160 <allocproc>
    800012e0:	0e050663          	beqz	a0,800013cc <fork+0x108>
    800012e4:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800012e6:	048ab603          	ld	a2,72(s5)
    800012ea:	692c                	ld	a1,80(a0)
    800012ec:	050ab503          	ld	a0,80(s5)
    800012f0:	f76ff0ef          	jal	ra,80000a66 <uvmcopy>
    800012f4:	04054863          	bltz	a0,80001344 <fork+0x80>
  np->sz = p->sz;
    800012f8:	048ab783          	ld	a5,72(s5)
    800012fc:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001300:	058ab683          	ld	a3,88(s5)
    80001304:	87b6                	mv	a5,a3
    80001306:	058a3703          	ld	a4,88(s4)
    8000130a:	12068693          	addi	a3,a3,288
    8000130e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001312:	6788                	ld	a0,8(a5)
    80001314:	6b8c                	ld	a1,16(a5)
    80001316:	6f90                	ld	a2,24(a5)
    80001318:	01073023          	sd	a6,0(a4)
    8000131c:	e708                	sd	a0,8(a4)
    8000131e:	eb0c                	sd	a1,16(a4)
    80001320:	ef10                	sd	a2,24(a4)
    80001322:	02078793          	addi	a5,a5,32
    80001326:	02070713          	addi	a4,a4,32
    8000132a:	fed792e3          	bne	a5,a3,8000130e <fork+0x4a>
  np->trapframe->a0 = 0;
    8000132e:	058a3783          	ld	a5,88(s4)
    80001332:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001336:	0d0a8493          	addi	s1,s5,208
    8000133a:	0d0a0913          	addi	s2,s4,208
    8000133e:	150a8993          	addi	s3,s5,336
    80001342:	a829                	j	8000135c <fork+0x98>
    freeproc(np);
    80001344:	8552                	mv	a0,s4
    80001346:	dcbff0ef          	jal	ra,80001110 <freeproc>
    release(&np->lock);
    8000134a:	8552                	mv	a0,s4
    8000134c:	57e040ef          	jal	ra,800058ca <release>
    return -1;
    80001350:	597d                	li	s2,-1
    80001352:	a09d                	j	800013b8 <fork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001354:	04a1                	addi	s1,s1,8
    80001356:	0921                	addi	s2,s2,8
    80001358:	01348963          	beq	s1,s3,8000136a <fork+0xa6>
    if(p->ofile[i])
    8000135c:	6088                	ld	a0,0(s1)
    8000135e:	d97d                	beqz	a0,80001354 <fork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001360:	1b2020ef          	jal	ra,80003512 <filedup>
    80001364:	00a93023          	sd	a0,0(s2)
    80001368:	b7f5                	j	80001354 <fork+0x90>
  np->cwd = idup(p->cwd);
    8000136a:	150ab503          	ld	a0,336(s5)
    8000136e:	508010ef          	jal	ra,80002876 <idup>
    80001372:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001376:	4641                	li	a2,16
    80001378:	158a8593          	addi	a1,s5,344
    8000137c:	158a0513          	addi	a0,s4,344
    80001380:	878ff0ef          	jal	ra,800003f8 <safestrcpy>
  pid = np->pid;
    80001384:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001388:	8552                	mv	a0,s4
    8000138a:	540040ef          	jal	ra,800058ca <release>
  acquire(&wait_lock);
    8000138e:	00007497          	auipc	s1,0x7
    80001392:	90a48493          	addi	s1,s1,-1782 # 80007c98 <wait_lock>
    80001396:	8526                	mv	a0,s1
    80001398:	49a040ef          	jal	ra,80005832 <acquire>
  np->parent = p;
    8000139c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800013a0:	8526                	mv	a0,s1
    800013a2:	528040ef          	jal	ra,800058ca <release>
  acquire(&np->lock);
    800013a6:	8552                	mv	a0,s4
    800013a8:	48a040ef          	jal	ra,80005832 <acquire>
  np->state = RUNNABLE;
    800013ac:	478d                	li	a5,3
    800013ae:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800013b2:	8552                	mv	a0,s4
    800013b4:	516040ef          	jal	ra,800058ca <release>
}
    800013b8:	854a                	mv	a0,s2
    800013ba:	70e2                	ld	ra,56(sp)
    800013bc:	7442                	ld	s0,48(sp)
    800013be:	74a2                	ld	s1,40(sp)
    800013c0:	7902                	ld	s2,32(sp)
    800013c2:	69e2                	ld	s3,24(sp)
    800013c4:	6a42                	ld	s4,16(sp)
    800013c6:	6aa2                	ld	s5,8(sp)
    800013c8:	6121                	addi	sp,sp,64
    800013ca:	8082                	ret
    return -1;
    800013cc:	597d                	li	s2,-1
    800013ce:	b7ed                	j	800013b8 <fork+0xf4>

00000000800013d0 <scheduler>:
{
    800013d0:	715d                	addi	sp,sp,-80
    800013d2:	e486                	sd	ra,72(sp)
    800013d4:	e0a2                	sd	s0,64(sp)
    800013d6:	fc26                	sd	s1,56(sp)
    800013d8:	f84a                	sd	s2,48(sp)
    800013da:	f44e                	sd	s3,40(sp)
    800013dc:	f052                	sd	s4,32(sp)
    800013de:	ec56                	sd	s5,24(sp)
    800013e0:	e85a                	sd	s6,16(sp)
    800013e2:	e45e                	sd	s7,8(sp)
    800013e4:	e062                	sd	s8,0(sp)
    800013e6:	0880                	addi	s0,sp,80
    800013e8:	8792                	mv	a5,tp
  int id = r_tp();
    800013ea:	2781                	sext.w	a5,a5
  c->proc = 0;
    800013ec:	00779b13          	slli	s6,a5,0x7
    800013f0:	00007717          	auipc	a4,0x7
    800013f4:	89070713          	addi	a4,a4,-1904 # 80007c80 <pid_lock>
    800013f8:	975a                	add	a4,a4,s6
    800013fa:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800013fe:	00007717          	auipc	a4,0x7
    80001402:	8ba70713          	addi	a4,a4,-1862 # 80007cb8 <cpus+0x8>
    80001406:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001408:	4c11                	li	s8,4
        c->proc = p;
    8000140a:	079e                	slli	a5,a5,0x7
    8000140c:	00007a17          	auipc	s4,0x7
    80001410:	874a0a13          	addi	s4,s4,-1932 # 80007c80 <pid_lock>
    80001414:	9a3e                	add	s4,s4,a5
        found = 1;
    80001416:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001418:	0000c997          	auipc	s3,0xc
    8000141c:	69898993          	addi	s3,s3,1688 # 8000dab0 <tickslock>
    80001420:	a0a9                	j	8000146a <scheduler+0x9a>
      release(&p->lock);
    80001422:	8526                	mv	a0,s1
    80001424:	4a6040ef          	jal	ra,800058ca <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001428:	16848493          	addi	s1,s1,360
    8000142c:	03348563          	beq	s1,s3,80001456 <scheduler+0x86>
      acquire(&p->lock);
    80001430:	8526                	mv	a0,s1
    80001432:	400040ef          	jal	ra,80005832 <acquire>
      if(p->state == RUNNABLE) {
    80001436:	4c9c                	lw	a5,24(s1)
    80001438:	ff2795e3          	bne	a5,s2,80001422 <scheduler+0x52>
        p->state = RUNNING;
    8000143c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001440:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001444:	06048593          	addi	a1,s1,96
    80001448:	855a                	mv	a0,s6
    8000144a:	5b4000ef          	jal	ra,800019fe <swtch>
        c->proc = 0;
    8000144e:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001452:	8ade                	mv	s5,s7
    80001454:	b7f9                	j	80001422 <scheduler+0x52>
    if(found == 0) {
    80001456:	000a9a63          	bnez	s5,8000146a <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000145a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000145e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001462:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001466:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000146a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000146e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001472:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001476:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001478:	00007497          	auipc	s1,0x7
    8000147c:	c3848493          	addi	s1,s1,-968 # 800080b0 <proc>
      if(p->state == RUNNABLE) {
    80001480:	490d                	li	s2,3
    80001482:	b77d                	j	80001430 <scheduler+0x60>

0000000080001484 <sched>:
{
    80001484:	7179                	addi	sp,sp,-48
    80001486:	f406                	sd	ra,40(sp)
    80001488:	f022                	sd	s0,32(sp)
    8000148a:	ec26                	sd	s1,24(sp)
    8000148c:	e84a                	sd	s2,16(sp)
    8000148e:	e44e                	sd	s3,8(sp)
    80001490:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001492:	b0dff0ef          	jal	ra,80000f9e <myproc>
    80001496:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001498:	330040ef          	jal	ra,800057c8 <holding>
    8000149c:	c92d                	beqz	a0,8000150e <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000149e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800014a0:	2781                	sext.w	a5,a5
    800014a2:	079e                	slli	a5,a5,0x7
    800014a4:	00006717          	auipc	a4,0x6
    800014a8:	7dc70713          	addi	a4,a4,2012 # 80007c80 <pid_lock>
    800014ac:	97ba                	add	a5,a5,a4
    800014ae:	0a87a703          	lw	a4,168(a5)
    800014b2:	4785                	li	a5,1
    800014b4:	06f71363          	bne	a4,a5,8000151a <sched+0x96>
  if(p->state == RUNNING)
    800014b8:	4c98                	lw	a4,24(s1)
    800014ba:	4791                	li	a5,4
    800014bc:	06f70563          	beq	a4,a5,80001526 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800014c0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800014c4:	8b89                	andi	a5,a5,2
  if(intr_get())
    800014c6:	e7b5                	bnez	a5,80001532 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800014c8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800014ca:	00006917          	auipc	s2,0x6
    800014ce:	7b690913          	addi	s2,s2,1974 # 80007c80 <pid_lock>
    800014d2:	2781                	sext.w	a5,a5
    800014d4:	079e                	slli	a5,a5,0x7
    800014d6:	97ca                	add	a5,a5,s2
    800014d8:	0ac7a983          	lw	s3,172(a5)
    800014dc:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800014de:	2781                	sext.w	a5,a5
    800014e0:	079e                	slli	a5,a5,0x7
    800014e2:	00006597          	auipc	a1,0x6
    800014e6:	7d658593          	addi	a1,a1,2006 # 80007cb8 <cpus+0x8>
    800014ea:	95be                	add	a1,a1,a5
    800014ec:	06048513          	addi	a0,s1,96
    800014f0:	50e000ef          	jal	ra,800019fe <swtch>
    800014f4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800014f6:	2781                	sext.w	a5,a5
    800014f8:	079e                	slli	a5,a5,0x7
    800014fa:	993e                	add	s2,s2,a5
    800014fc:	0b392623          	sw	s3,172(s2)
}
    80001500:	70a2                	ld	ra,40(sp)
    80001502:	7402                	ld	s0,32(sp)
    80001504:	64e2                	ld	s1,24(sp)
    80001506:	6942                	ld	s2,16(sp)
    80001508:	69a2                	ld	s3,8(sp)
    8000150a:	6145                	addi	sp,sp,48
    8000150c:	8082                	ret
    panic("sched p->lock");
    8000150e:	00006517          	auipc	a0,0x6
    80001512:	d9a50513          	addi	a0,a0,-614 # 800072a8 <etext+0x2a8>
    80001516:	00c040ef          	jal	ra,80005522 <panic>
    panic("sched locks");
    8000151a:	00006517          	auipc	a0,0x6
    8000151e:	d9e50513          	addi	a0,a0,-610 # 800072b8 <etext+0x2b8>
    80001522:	000040ef          	jal	ra,80005522 <panic>
    panic("sched running");
    80001526:	00006517          	auipc	a0,0x6
    8000152a:	da250513          	addi	a0,a0,-606 # 800072c8 <etext+0x2c8>
    8000152e:	7f5030ef          	jal	ra,80005522 <panic>
    panic("sched interruptible");
    80001532:	00006517          	auipc	a0,0x6
    80001536:	da650513          	addi	a0,a0,-602 # 800072d8 <etext+0x2d8>
    8000153a:	7e9030ef          	jal	ra,80005522 <panic>

000000008000153e <yield>:
{
    8000153e:	1101                	addi	sp,sp,-32
    80001540:	ec06                	sd	ra,24(sp)
    80001542:	e822                	sd	s0,16(sp)
    80001544:	e426                	sd	s1,8(sp)
    80001546:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001548:	a57ff0ef          	jal	ra,80000f9e <myproc>
    8000154c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000154e:	2e4040ef          	jal	ra,80005832 <acquire>
  p->state = RUNNABLE;
    80001552:	478d                	li	a5,3
    80001554:	cc9c                	sw	a5,24(s1)
  sched();
    80001556:	f2fff0ef          	jal	ra,80001484 <sched>
  release(&p->lock);
    8000155a:	8526                	mv	a0,s1
    8000155c:	36e040ef          	jal	ra,800058ca <release>
}
    80001560:	60e2                	ld	ra,24(sp)
    80001562:	6442                	ld	s0,16(sp)
    80001564:	64a2                	ld	s1,8(sp)
    80001566:	6105                	addi	sp,sp,32
    80001568:	8082                	ret

000000008000156a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000156a:	7179                	addi	sp,sp,-48
    8000156c:	f406                	sd	ra,40(sp)
    8000156e:	f022                	sd	s0,32(sp)
    80001570:	ec26                	sd	s1,24(sp)
    80001572:	e84a                	sd	s2,16(sp)
    80001574:	e44e                	sd	s3,8(sp)
    80001576:	1800                	addi	s0,sp,48
    80001578:	89aa                	mv	s3,a0
    8000157a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000157c:	a23ff0ef          	jal	ra,80000f9e <myproc>
    80001580:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001582:	2b0040ef          	jal	ra,80005832 <acquire>
  release(lk);
    80001586:	854a                	mv	a0,s2
    80001588:	342040ef          	jal	ra,800058ca <release>

  // Go to sleep.
  p->chan = chan;
    8000158c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001590:	4789                	li	a5,2
    80001592:	cc9c                	sw	a5,24(s1)

  sched();
    80001594:	ef1ff0ef          	jal	ra,80001484 <sched>

  // Tidy up.
  p->chan = 0;
    80001598:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000159c:	8526                	mv	a0,s1
    8000159e:	32c040ef          	jal	ra,800058ca <release>
  acquire(lk);
    800015a2:	854a                	mv	a0,s2
    800015a4:	28e040ef          	jal	ra,80005832 <acquire>
}
    800015a8:	70a2                	ld	ra,40(sp)
    800015aa:	7402                	ld	s0,32(sp)
    800015ac:	64e2                	ld	s1,24(sp)
    800015ae:	6942                	ld	s2,16(sp)
    800015b0:	69a2                	ld	s3,8(sp)
    800015b2:	6145                	addi	sp,sp,48
    800015b4:	8082                	ret

00000000800015b6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800015b6:	7139                	addi	sp,sp,-64
    800015b8:	fc06                	sd	ra,56(sp)
    800015ba:	f822                	sd	s0,48(sp)
    800015bc:	f426                	sd	s1,40(sp)
    800015be:	f04a                	sd	s2,32(sp)
    800015c0:	ec4e                	sd	s3,24(sp)
    800015c2:	e852                	sd	s4,16(sp)
    800015c4:	e456                	sd	s5,8(sp)
    800015c6:	0080                	addi	s0,sp,64
    800015c8:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800015ca:	00007497          	auipc	s1,0x7
    800015ce:	ae648493          	addi	s1,s1,-1306 # 800080b0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800015d2:	4989                	li	s3,2
        p->state = RUNNABLE;
    800015d4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800015d6:	0000c917          	auipc	s2,0xc
    800015da:	4da90913          	addi	s2,s2,1242 # 8000dab0 <tickslock>
    800015de:	a801                	j	800015ee <wakeup+0x38>
      }
      release(&p->lock);
    800015e0:	8526                	mv	a0,s1
    800015e2:	2e8040ef          	jal	ra,800058ca <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800015e6:	16848493          	addi	s1,s1,360
    800015ea:	03248263          	beq	s1,s2,8000160e <wakeup+0x58>
    if(p != myproc()){
    800015ee:	9b1ff0ef          	jal	ra,80000f9e <myproc>
    800015f2:	fea48ae3          	beq	s1,a0,800015e6 <wakeup+0x30>
      acquire(&p->lock);
    800015f6:	8526                	mv	a0,s1
    800015f8:	23a040ef          	jal	ra,80005832 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800015fc:	4c9c                	lw	a5,24(s1)
    800015fe:	ff3791e3          	bne	a5,s3,800015e0 <wakeup+0x2a>
    80001602:	709c                	ld	a5,32(s1)
    80001604:	fd479ee3          	bne	a5,s4,800015e0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001608:	0154ac23          	sw	s5,24(s1)
    8000160c:	bfd1                	j	800015e0 <wakeup+0x2a>
    }
  }
}
    8000160e:	70e2                	ld	ra,56(sp)
    80001610:	7442                	ld	s0,48(sp)
    80001612:	74a2                	ld	s1,40(sp)
    80001614:	7902                	ld	s2,32(sp)
    80001616:	69e2                	ld	s3,24(sp)
    80001618:	6a42                	ld	s4,16(sp)
    8000161a:	6aa2                	ld	s5,8(sp)
    8000161c:	6121                	addi	sp,sp,64
    8000161e:	8082                	ret

0000000080001620 <reparent>:
{
    80001620:	7179                	addi	sp,sp,-48
    80001622:	f406                	sd	ra,40(sp)
    80001624:	f022                	sd	s0,32(sp)
    80001626:	ec26                	sd	s1,24(sp)
    80001628:	e84a                	sd	s2,16(sp)
    8000162a:	e44e                	sd	s3,8(sp)
    8000162c:	e052                	sd	s4,0(sp)
    8000162e:	1800                	addi	s0,sp,48
    80001630:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001632:	00007497          	auipc	s1,0x7
    80001636:	a7e48493          	addi	s1,s1,-1410 # 800080b0 <proc>
      pp->parent = initproc;
    8000163a:	00006a17          	auipc	s4,0x6
    8000163e:	406a0a13          	addi	s4,s4,1030 # 80007a40 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001642:	0000c997          	auipc	s3,0xc
    80001646:	46e98993          	addi	s3,s3,1134 # 8000dab0 <tickslock>
    8000164a:	a029                	j	80001654 <reparent+0x34>
    8000164c:	16848493          	addi	s1,s1,360
    80001650:	01348b63          	beq	s1,s3,80001666 <reparent+0x46>
    if(pp->parent == p){
    80001654:	7c9c                	ld	a5,56(s1)
    80001656:	ff279be3          	bne	a5,s2,8000164c <reparent+0x2c>
      pp->parent = initproc;
    8000165a:	000a3503          	ld	a0,0(s4)
    8000165e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001660:	f57ff0ef          	jal	ra,800015b6 <wakeup>
    80001664:	b7e5                	j	8000164c <reparent+0x2c>
}
    80001666:	70a2                	ld	ra,40(sp)
    80001668:	7402                	ld	s0,32(sp)
    8000166a:	64e2                	ld	s1,24(sp)
    8000166c:	6942                	ld	s2,16(sp)
    8000166e:	69a2                	ld	s3,8(sp)
    80001670:	6a02                	ld	s4,0(sp)
    80001672:	6145                	addi	sp,sp,48
    80001674:	8082                	ret

0000000080001676 <exit>:
{
    80001676:	7179                	addi	sp,sp,-48
    80001678:	f406                	sd	ra,40(sp)
    8000167a:	f022                	sd	s0,32(sp)
    8000167c:	ec26                	sd	s1,24(sp)
    8000167e:	e84a                	sd	s2,16(sp)
    80001680:	e44e                	sd	s3,8(sp)
    80001682:	e052                	sd	s4,0(sp)
    80001684:	1800                	addi	s0,sp,48
    80001686:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001688:	917ff0ef          	jal	ra,80000f9e <myproc>
    8000168c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000168e:	00006797          	auipc	a5,0x6
    80001692:	3b27b783          	ld	a5,946(a5) # 80007a40 <initproc>
    80001696:	0d050493          	addi	s1,a0,208
    8000169a:	15050913          	addi	s2,a0,336
    8000169e:	00a79f63          	bne	a5,a0,800016bc <exit+0x46>
    panic("init exiting");
    800016a2:	00006517          	auipc	a0,0x6
    800016a6:	c4e50513          	addi	a0,a0,-946 # 800072f0 <etext+0x2f0>
    800016aa:	679030ef          	jal	ra,80005522 <panic>
      fileclose(f);
    800016ae:	6ab010ef          	jal	ra,80003558 <fileclose>
      p->ofile[fd] = 0;
    800016b2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800016b6:	04a1                	addi	s1,s1,8
    800016b8:	01248563          	beq	s1,s2,800016c2 <exit+0x4c>
    if(p->ofile[fd]){
    800016bc:	6088                	ld	a0,0(s1)
    800016be:	f965                	bnez	a0,800016ae <exit+0x38>
    800016c0:	bfdd                	j	800016b6 <exit+0x40>
  begin_op();
    800016c2:	27f010ef          	jal	ra,80003140 <begin_op>
  iput(p->cwd);
    800016c6:	1509b503          	ld	a0,336(s3)
    800016ca:	360010ef          	jal	ra,80002a2a <iput>
  end_op();
    800016ce:	2e1010ef          	jal	ra,800031ae <end_op>
  p->cwd = 0;
    800016d2:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800016d6:	00006497          	auipc	s1,0x6
    800016da:	5c248493          	addi	s1,s1,1474 # 80007c98 <wait_lock>
    800016de:	8526                	mv	a0,s1
    800016e0:	152040ef          	jal	ra,80005832 <acquire>
  reparent(p);
    800016e4:	854e                	mv	a0,s3
    800016e6:	f3bff0ef          	jal	ra,80001620 <reparent>
  wakeup(p->parent);
    800016ea:	0389b503          	ld	a0,56(s3)
    800016ee:	ec9ff0ef          	jal	ra,800015b6 <wakeup>
  acquire(&p->lock);
    800016f2:	854e                	mv	a0,s3
    800016f4:	13e040ef          	jal	ra,80005832 <acquire>
  p->xstate = status;
    800016f8:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800016fc:	4795                	li	a5,5
    800016fe:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001702:	8526                	mv	a0,s1
    80001704:	1c6040ef          	jal	ra,800058ca <release>
  sched();
    80001708:	d7dff0ef          	jal	ra,80001484 <sched>
  panic("zombie exit");
    8000170c:	00006517          	auipc	a0,0x6
    80001710:	bf450513          	addi	a0,a0,-1036 # 80007300 <etext+0x300>
    80001714:	60f030ef          	jal	ra,80005522 <panic>

0000000080001718 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001718:	7179                	addi	sp,sp,-48
    8000171a:	f406                	sd	ra,40(sp)
    8000171c:	f022                	sd	s0,32(sp)
    8000171e:	ec26                	sd	s1,24(sp)
    80001720:	e84a                	sd	s2,16(sp)
    80001722:	e44e                	sd	s3,8(sp)
    80001724:	1800                	addi	s0,sp,48
    80001726:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001728:	00007497          	auipc	s1,0x7
    8000172c:	98848493          	addi	s1,s1,-1656 # 800080b0 <proc>
    80001730:	0000c997          	auipc	s3,0xc
    80001734:	38098993          	addi	s3,s3,896 # 8000dab0 <tickslock>
    acquire(&p->lock);
    80001738:	8526                	mv	a0,s1
    8000173a:	0f8040ef          	jal	ra,80005832 <acquire>
    if(p->pid == pid){
    8000173e:	589c                	lw	a5,48(s1)
    80001740:	01278b63          	beq	a5,s2,80001756 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001744:	8526                	mv	a0,s1
    80001746:	184040ef          	jal	ra,800058ca <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000174a:	16848493          	addi	s1,s1,360
    8000174e:	ff3495e3          	bne	s1,s3,80001738 <kill+0x20>
  }
  return -1;
    80001752:	557d                	li	a0,-1
    80001754:	a819                	j	8000176a <kill+0x52>
      p->killed = 1;
    80001756:	4785                	li	a5,1
    80001758:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000175a:	4c98                	lw	a4,24(s1)
    8000175c:	4789                	li	a5,2
    8000175e:	00f70d63          	beq	a4,a5,80001778 <kill+0x60>
      release(&p->lock);
    80001762:	8526                	mv	a0,s1
    80001764:	166040ef          	jal	ra,800058ca <release>
      return 0;
    80001768:	4501                	li	a0,0
}
    8000176a:	70a2                	ld	ra,40(sp)
    8000176c:	7402                	ld	s0,32(sp)
    8000176e:	64e2                	ld	s1,24(sp)
    80001770:	6942                	ld	s2,16(sp)
    80001772:	69a2                	ld	s3,8(sp)
    80001774:	6145                	addi	sp,sp,48
    80001776:	8082                	ret
        p->state = RUNNABLE;
    80001778:	478d                	li	a5,3
    8000177a:	cc9c                	sw	a5,24(s1)
    8000177c:	b7dd                	j	80001762 <kill+0x4a>

000000008000177e <setkilled>:

void
setkilled(struct proc *p)
{
    8000177e:	1101                	addi	sp,sp,-32
    80001780:	ec06                	sd	ra,24(sp)
    80001782:	e822                	sd	s0,16(sp)
    80001784:	e426                	sd	s1,8(sp)
    80001786:	1000                	addi	s0,sp,32
    80001788:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000178a:	0a8040ef          	jal	ra,80005832 <acquire>
  p->killed = 1;
    8000178e:	4785                	li	a5,1
    80001790:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001792:	8526                	mv	a0,s1
    80001794:	136040ef          	jal	ra,800058ca <release>
}
    80001798:	60e2                	ld	ra,24(sp)
    8000179a:	6442                	ld	s0,16(sp)
    8000179c:	64a2                	ld	s1,8(sp)
    8000179e:	6105                	addi	sp,sp,32
    800017a0:	8082                	ret

00000000800017a2 <killed>:

int
killed(struct proc *p)
{
    800017a2:	1101                	addi	sp,sp,-32
    800017a4:	ec06                	sd	ra,24(sp)
    800017a6:	e822                	sd	s0,16(sp)
    800017a8:	e426                	sd	s1,8(sp)
    800017aa:	e04a                	sd	s2,0(sp)
    800017ac:	1000                	addi	s0,sp,32
    800017ae:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800017b0:	082040ef          	jal	ra,80005832 <acquire>
  k = p->killed;
    800017b4:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800017b8:	8526                	mv	a0,s1
    800017ba:	110040ef          	jal	ra,800058ca <release>
  return k;
}
    800017be:	854a                	mv	a0,s2
    800017c0:	60e2                	ld	ra,24(sp)
    800017c2:	6442                	ld	s0,16(sp)
    800017c4:	64a2                	ld	s1,8(sp)
    800017c6:	6902                	ld	s2,0(sp)
    800017c8:	6105                	addi	sp,sp,32
    800017ca:	8082                	ret

00000000800017cc <wait>:
{
    800017cc:	715d                	addi	sp,sp,-80
    800017ce:	e486                	sd	ra,72(sp)
    800017d0:	e0a2                	sd	s0,64(sp)
    800017d2:	fc26                	sd	s1,56(sp)
    800017d4:	f84a                	sd	s2,48(sp)
    800017d6:	f44e                	sd	s3,40(sp)
    800017d8:	f052                	sd	s4,32(sp)
    800017da:	ec56                	sd	s5,24(sp)
    800017dc:	e85a                	sd	s6,16(sp)
    800017de:	e45e                	sd	s7,8(sp)
    800017e0:	e062                	sd	s8,0(sp)
    800017e2:	0880                	addi	s0,sp,80
    800017e4:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800017e6:	fb8ff0ef          	jal	ra,80000f9e <myproc>
    800017ea:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800017ec:	00006517          	auipc	a0,0x6
    800017f0:	4ac50513          	addi	a0,a0,1196 # 80007c98 <wait_lock>
    800017f4:	03e040ef          	jal	ra,80005832 <acquire>
    havekids = 0;
    800017f8:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800017fa:	4a15                	li	s4,5
        havekids = 1;
    800017fc:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800017fe:	0000c997          	auipc	s3,0xc
    80001802:	2b298993          	addi	s3,s3,690 # 8000dab0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001806:	00006c17          	auipc	s8,0x6
    8000180a:	492c0c13          	addi	s8,s8,1170 # 80007c98 <wait_lock>
    havekids = 0;
    8000180e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001810:	00007497          	auipc	s1,0x7
    80001814:	8a048493          	addi	s1,s1,-1888 # 800080b0 <proc>
    80001818:	a899                	j	8000186e <wait+0xa2>
          pid = pp->pid;
    8000181a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000181e:	000b0c63          	beqz	s6,80001836 <wait+0x6a>
    80001822:	4691                	li	a3,4
    80001824:	02c48613          	addi	a2,s1,44
    80001828:	85da                	mv	a1,s6
    8000182a:	05093503          	ld	a0,80(s2)
    8000182e:	b14ff0ef          	jal	ra,80000b42 <copyout>
    80001832:	00054f63          	bltz	a0,80001850 <wait+0x84>
          freeproc(pp);
    80001836:	8526                	mv	a0,s1
    80001838:	8d9ff0ef          	jal	ra,80001110 <freeproc>
          release(&pp->lock);
    8000183c:	8526                	mv	a0,s1
    8000183e:	08c040ef          	jal	ra,800058ca <release>
          release(&wait_lock);
    80001842:	00006517          	auipc	a0,0x6
    80001846:	45650513          	addi	a0,a0,1110 # 80007c98 <wait_lock>
    8000184a:	080040ef          	jal	ra,800058ca <release>
          return pid;
    8000184e:	a891                	j	800018a2 <wait+0xd6>
            release(&pp->lock);
    80001850:	8526                	mv	a0,s1
    80001852:	078040ef          	jal	ra,800058ca <release>
            release(&wait_lock);
    80001856:	00006517          	auipc	a0,0x6
    8000185a:	44250513          	addi	a0,a0,1090 # 80007c98 <wait_lock>
    8000185e:	06c040ef          	jal	ra,800058ca <release>
            return -1;
    80001862:	59fd                	li	s3,-1
    80001864:	a83d                	j	800018a2 <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001866:	16848493          	addi	s1,s1,360
    8000186a:	03348063          	beq	s1,s3,8000188a <wait+0xbe>
      if(pp->parent == p){
    8000186e:	7c9c                	ld	a5,56(s1)
    80001870:	ff279be3          	bne	a5,s2,80001866 <wait+0x9a>
        acquire(&pp->lock);
    80001874:	8526                	mv	a0,s1
    80001876:	7bd030ef          	jal	ra,80005832 <acquire>
        if(pp->state == ZOMBIE){
    8000187a:	4c9c                	lw	a5,24(s1)
    8000187c:	f9478fe3          	beq	a5,s4,8000181a <wait+0x4e>
        release(&pp->lock);
    80001880:	8526                	mv	a0,s1
    80001882:	048040ef          	jal	ra,800058ca <release>
        havekids = 1;
    80001886:	8756                	mv	a4,s5
    80001888:	bff9                	j	80001866 <wait+0x9a>
    if(!havekids || killed(p)){
    8000188a:	c709                	beqz	a4,80001894 <wait+0xc8>
    8000188c:	854a                	mv	a0,s2
    8000188e:	f15ff0ef          	jal	ra,800017a2 <killed>
    80001892:	c50d                	beqz	a0,800018bc <wait+0xf0>
      release(&wait_lock);
    80001894:	00006517          	auipc	a0,0x6
    80001898:	40450513          	addi	a0,a0,1028 # 80007c98 <wait_lock>
    8000189c:	02e040ef          	jal	ra,800058ca <release>
      return -1;
    800018a0:	59fd                	li	s3,-1
}
    800018a2:	854e                	mv	a0,s3
    800018a4:	60a6                	ld	ra,72(sp)
    800018a6:	6406                	ld	s0,64(sp)
    800018a8:	74e2                	ld	s1,56(sp)
    800018aa:	7942                	ld	s2,48(sp)
    800018ac:	79a2                	ld	s3,40(sp)
    800018ae:	7a02                	ld	s4,32(sp)
    800018b0:	6ae2                	ld	s5,24(sp)
    800018b2:	6b42                	ld	s6,16(sp)
    800018b4:	6ba2                	ld	s7,8(sp)
    800018b6:	6c02                	ld	s8,0(sp)
    800018b8:	6161                	addi	sp,sp,80
    800018ba:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800018bc:	85e2                	mv	a1,s8
    800018be:	854a                	mv	a0,s2
    800018c0:	cabff0ef          	jal	ra,8000156a <sleep>
    havekids = 0;
    800018c4:	b7a9                	j	8000180e <wait+0x42>

00000000800018c6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800018c6:	7179                	addi	sp,sp,-48
    800018c8:	f406                	sd	ra,40(sp)
    800018ca:	f022                	sd	s0,32(sp)
    800018cc:	ec26                	sd	s1,24(sp)
    800018ce:	e84a                	sd	s2,16(sp)
    800018d0:	e44e                	sd	s3,8(sp)
    800018d2:	e052                	sd	s4,0(sp)
    800018d4:	1800                	addi	s0,sp,48
    800018d6:	84aa                	mv	s1,a0
    800018d8:	892e                	mv	s2,a1
    800018da:	89b2                	mv	s3,a2
    800018dc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800018de:	ec0ff0ef          	jal	ra,80000f9e <myproc>
  if(user_dst){
    800018e2:	cc99                	beqz	s1,80001900 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800018e4:	86d2                	mv	a3,s4
    800018e6:	864e                	mv	a2,s3
    800018e8:	85ca                	mv	a1,s2
    800018ea:	6928                	ld	a0,80(a0)
    800018ec:	a56ff0ef          	jal	ra,80000b42 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800018f0:	70a2                	ld	ra,40(sp)
    800018f2:	7402                	ld	s0,32(sp)
    800018f4:	64e2                	ld	s1,24(sp)
    800018f6:	6942                	ld	s2,16(sp)
    800018f8:	69a2                	ld	s3,8(sp)
    800018fa:	6a02                	ld	s4,0(sp)
    800018fc:	6145                	addi	sp,sp,48
    800018fe:	8082                	ret
    memmove((char *)dst, src, len);
    80001900:	000a061b          	sext.w	a2,s4
    80001904:	85ce                	mv	a1,s3
    80001906:	854a                	mv	a0,s2
    80001908:	a07fe0ef          	jal	ra,8000030e <memmove>
    return 0;
    8000190c:	8526                	mv	a0,s1
    8000190e:	b7cd                	j	800018f0 <either_copyout+0x2a>

0000000080001910 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001910:	7179                	addi	sp,sp,-48
    80001912:	f406                	sd	ra,40(sp)
    80001914:	f022                	sd	s0,32(sp)
    80001916:	ec26                	sd	s1,24(sp)
    80001918:	e84a                	sd	s2,16(sp)
    8000191a:	e44e                	sd	s3,8(sp)
    8000191c:	e052                	sd	s4,0(sp)
    8000191e:	1800                	addi	s0,sp,48
    80001920:	892a                	mv	s2,a0
    80001922:	84ae                	mv	s1,a1
    80001924:	89b2                	mv	s3,a2
    80001926:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001928:	e76ff0ef          	jal	ra,80000f9e <myproc>
  if(user_src){
    8000192c:	cc99                	beqz	s1,8000194a <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000192e:	86d2                	mv	a3,s4
    80001930:	864e                	mv	a2,s3
    80001932:	85ca                	mv	a1,s2
    80001934:	6928                	ld	a0,80(a0)
    80001936:	ac4ff0ef          	jal	ra,80000bfa <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000193a:	70a2                	ld	ra,40(sp)
    8000193c:	7402                	ld	s0,32(sp)
    8000193e:	64e2                	ld	s1,24(sp)
    80001940:	6942                	ld	s2,16(sp)
    80001942:	69a2                	ld	s3,8(sp)
    80001944:	6a02                	ld	s4,0(sp)
    80001946:	6145                	addi	sp,sp,48
    80001948:	8082                	ret
    memmove(dst, (char*)src, len);
    8000194a:	000a061b          	sext.w	a2,s4
    8000194e:	85ce                	mv	a1,s3
    80001950:	854a                	mv	a0,s2
    80001952:	9bdfe0ef          	jal	ra,8000030e <memmove>
    return 0;
    80001956:	8526                	mv	a0,s1
    80001958:	b7cd                	j	8000193a <either_copyin+0x2a>

000000008000195a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000195a:	715d                	addi	sp,sp,-80
    8000195c:	e486                	sd	ra,72(sp)
    8000195e:	e0a2                	sd	s0,64(sp)
    80001960:	fc26                	sd	s1,56(sp)
    80001962:	f84a                	sd	s2,48(sp)
    80001964:	f44e                	sd	s3,40(sp)
    80001966:	f052                	sd	s4,32(sp)
    80001968:	ec56                	sd	s5,24(sp)
    8000196a:	e85a                	sd	s6,16(sp)
    8000196c:	e45e                	sd	s7,8(sp)
    8000196e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001970:	00005517          	auipc	a0,0x5
    80001974:	76050513          	addi	a0,a0,1888 # 800070d0 <etext+0xd0>
    80001978:	0f7030ef          	jal	ra,8000526e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000197c:	00007497          	auipc	s1,0x7
    80001980:	88c48493          	addi	s1,s1,-1908 # 80008208 <proc+0x158>
    80001984:	0000c917          	auipc	s2,0xc
    80001988:	28490913          	addi	s2,s2,644 # 8000dc08 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000198c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000198e:	00006997          	auipc	s3,0x6
    80001992:	98298993          	addi	s3,s3,-1662 # 80007310 <etext+0x310>
    printf("%d %s %s", p->pid, state, p->name);
    80001996:	00006a97          	auipc	s5,0x6
    8000199a:	982a8a93          	addi	s5,s5,-1662 # 80007318 <etext+0x318>
    printf("\n");
    8000199e:	00005a17          	auipc	s4,0x5
    800019a2:	732a0a13          	addi	s4,s4,1842 # 800070d0 <etext+0xd0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800019a6:	00006b97          	auipc	s7,0x6
    800019aa:	9b2b8b93          	addi	s7,s7,-1614 # 80007358 <states.0>
    800019ae:	a829                	j	800019c8 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800019b0:	ed86a583          	lw	a1,-296(a3)
    800019b4:	8556                	mv	a0,s5
    800019b6:	0b9030ef          	jal	ra,8000526e <printf>
    printf("\n");
    800019ba:	8552                	mv	a0,s4
    800019bc:	0b3030ef          	jal	ra,8000526e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800019c0:	16848493          	addi	s1,s1,360
    800019c4:	03248263          	beq	s1,s2,800019e8 <procdump+0x8e>
    if(p->state == UNUSED)
    800019c8:	86a6                	mv	a3,s1
    800019ca:	ec04a783          	lw	a5,-320(s1)
    800019ce:	dbed                	beqz	a5,800019c0 <procdump+0x66>
      state = "???";
    800019d0:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800019d2:	fcfb6fe3          	bltu	s6,a5,800019b0 <procdump+0x56>
    800019d6:	02079713          	slli	a4,a5,0x20
    800019da:	01d75793          	srli	a5,a4,0x1d
    800019de:	97de                	add	a5,a5,s7
    800019e0:	6390                	ld	a2,0(a5)
    800019e2:	f679                	bnez	a2,800019b0 <procdump+0x56>
      state = "???";
    800019e4:	864e                	mv	a2,s3
    800019e6:	b7e9                	j	800019b0 <procdump+0x56>
  }
}
    800019e8:	60a6                	ld	ra,72(sp)
    800019ea:	6406                	ld	s0,64(sp)
    800019ec:	74e2                	ld	s1,56(sp)
    800019ee:	7942                	ld	s2,48(sp)
    800019f0:	79a2                	ld	s3,40(sp)
    800019f2:	7a02                	ld	s4,32(sp)
    800019f4:	6ae2                	ld	s5,24(sp)
    800019f6:	6b42                	ld	s6,16(sp)
    800019f8:	6ba2                	ld	s7,8(sp)
    800019fa:	6161                	addi	sp,sp,80
    800019fc:	8082                	ret

00000000800019fe <swtch>:
    800019fe:	00153023          	sd	ra,0(a0)
    80001a02:	00253423          	sd	sp,8(a0)
    80001a06:	e900                	sd	s0,16(a0)
    80001a08:	ed04                	sd	s1,24(a0)
    80001a0a:	03253023          	sd	s2,32(a0)
    80001a0e:	03353423          	sd	s3,40(a0)
    80001a12:	03453823          	sd	s4,48(a0)
    80001a16:	03553c23          	sd	s5,56(a0)
    80001a1a:	05653023          	sd	s6,64(a0)
    80001a1e:	05753423          	sd	s7,72(a0)
    80001a22:	05853823          	sd	s8,80(a0)
    80001a26:	05953c23          	sd	s9,88(a0)
    80001a2a:	07a53023          	sd	s10,96(a0)
    80001a2e:	07b53423          	sd	s11,104(a0)
    80001a32:	0005b083          	ld	ra,0(a1)
    80001a36:	0085b103          	ld	sp,8(a1)
    80001a3a:	6980                	ld	s0,16(a1)
    80001a3c:	6d84                	ld	s1,24(a1)
    80001a3e:	0205b903          	ld	s2,32(a1)
    80001a42:	0285b983          	ld	s3,40(a1)
    80001a46:	0305ba03          	ld	s4,48(a1)
    80001a4a:	0385ba83          	ld	s5,56(a1)
    80001a4e:	0405bb03          	ld	s6,64(a1)
    80001a52:	0485bb83          	ld	s7,72(a1)
    80001a56:	0505bc03          	ld	s8,80(a1)
    80001a5a:	0585bc83          	ld	s9,88(a1)
    80001a5e:	0605bd03          	ld	s10,96(a1)
    80001a62:	0685bd83          	ld	s11,104(a1)
    80001a66:	8082                	ret

0000000080001a68 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001a68:	1141                	addi	sp,sp,-16
    80001a6a:	e406                	sd	ra,8(sp)
    80001a6c:	e022                	sd	s0,0(sp)
    80001a6e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001a70:	00006597          	auipc	a1,0x6
    80001a74:	91858593          	addi	a1,a1,-1768 # 80007388 <states.0+0x30>
    80001a78:	0000c517          	auipc	a0,0xc
    80001a7c:	03850513          	addi	a0,a0,56 # 8000dab0 <tickslock>
    80001a80:	533030ef          	jal	ra,800057b2 <initlock>
}
    80001a84:	60a2                	ld	ra,8(sp)
    80001a86:	6402                	ld	s0,0(sp)
    80001a88:	0141                	addi	sp,sp,16
    80001a8a:	8082                	ret

0000000080001a8c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001a8c:	1141                	addi	sp,sp,-16
    80001a8e:	e422                	sd	s0,8(sp)
    80001a90:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a92:	00003797          	auipc	a5,0x3
    80001a96:	d7e78793          	addi	a5,a5,-642 # 80004810 <kernelvec>
    80001a9a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001a9e:	6422                	ld	s0,8(sp)
    80001aa0:	0141                	addi	sp,sp,16
    80001aa2:	8082                	ret

0000000080001aa4 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001aa4:	1141                	addi	sp,sp,-16
    80001aa6:	e406                	sd	ra,8(sp)
    80001aa8:	e022                	sd	s0,0(sp)
    80001aaa:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001aac:	cf2ff0ef          	jal	ra,80000f9e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ab0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001ab4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ab6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001aba:	00004697          	auipc	a3,0x4
    80001abe:	54668693          	addi	a3,a3,1350 # 80006000 <_trampoline>
    80001ac2:	00004717          	auipc	a4,0x4
    80001ac6:	53e70713          	addi	a4,a4,1342 # 80006000 <_trampoline>
    80001aca:	8f15                	sub	a4,a4,a3
    80001acc:	040007b7          	lui	a5,0x4000
    80001ad0:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001ad2:	07b2                	slli	a5,a5,0xc
    80001ad4:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001ad6:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001ada:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001adc:	18002673          	csrr	a2,satp
    80001ae0:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001ae2:	6d30                	ld	a2,88(a0)
    80001ae4:	6138                	ld	a4,64(a0)
    80001ae6:	6585                	lui	a1,0x1
    80001ae8:	972e                	add	a4,a4,a1
    80001aea:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001aec:	6d38                	ld	a4,88(a0)
    80001aee:	00000617          	auipc	a2,0x0
    80001af2:	10c60613          	addi	a2,a2,268 # 80001bfa <usertrap>
    80001af6:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001af8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001afa:	8612                	mv	a2,tp
    80001afc:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001afe:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001b02:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001b06:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b0a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001b0e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b10:	6f18                	ld	a4,24(a4)
    80001b12:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b16:	6928                	ld	a0,80(a0)
    80001b18:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b1a:	00004717          	auipc	a4,0x4
    80001b1e:	58270713          	addi	a4,a4,1410 # 8000609c <userret>
    80001b22:	8f15                	sub	a4,a4,a3
    80001b24:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b26:	577d                	li	a4,-1
    80001b28:	177e                	slli	a4,a4,0x3f
    80001b2a:	8d59                	or	a0,a0,a4
    80001b2c:	9782                	jalr	a5
}
    80001b2e:	60a2                	ld	ra,8(sp)
    80001b30:	6402                	ld	s0,0(sp)
    80001b32:	0141                	addi	sp,sp,16
    80001b34:	8082                	ret

0000000080001b36 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001b36:	1101                	addi	sp,sp,-32
    80001b38:	ec06                	sd	ra,24(sp)
    80001b3a:	e822                	sd	s0,16(sp)
    80001b3c:	e426                	sd	s1,8(sp)
    80001b3e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001b40:	c32ff0ef          	jal	ra,80000f72 <cpuid>
    80001b44:	cd19                	beqz	a0,80001b62 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001b46:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001b4a:	000f4737          	lui	a4,0xf4
    80001b4e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001b52:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001b54:	14d79073          	csrw	0x14d,a5
}
    80001b58:	60e2                	ld	ra,24(sp)
    80001b5a:	6442                	ld	s0,16(sp)
    80001b5c:	64a2                	ld	s1,8(sp)
    80001b5e:	6105                	addi	sp,sp,32
    80001b60:	8082                	ret
    acquire(&tickslock);
    80001b62:	0000c497          	auipc	s1,0xc
    80001b66:	f4e48493          	addi	s1,s1,-178 # 8000dab0 <tickslock>
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	4c7030ef          	jal	ra,80005832 <acquire>
    ticks++;
    80001b70:	00006517          	auipc	a0,0x6
    80001b74:	ed850513          	addi	a0,a0,-296 # 80007a48 <ticks>
    80001b78:	411c                	lw	a5,0(a0)
    80001b7a:	2785                	addiw	a5,a5,1
    80001b7c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001b7e:	a39ff0ef          	jal	ra,800015b6 <wakeup>
    release(&tickslock);
    80001b82:	8526                	mv	a0,s1
    80001b84:	547030ef          	jal	ra,800058ca <release>
    80001b88:	bf7d                	j	80001b46 <clockintr+0x10>

0000000080001b8a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001b8a:	1101                	addi	sp,sp,-32
    80001b8c:	ec06                	sd	ra,24(sp)
    80001b8e:	e822                	sd	s0,16(sp)
    80001b90:	e426                	sd	s1,8(sp)
    80001b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b94:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001b98:	57fd                	li	a5,-1
    80001b9a:	17fe                	slli	a5,a5,0x3f
    80001b9c:	07a5                	addi	a5,a5,9
    80001b9e:	00f70d63          	beq	a4,a5,80001bb8 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001ba2:	57fd                	li	a5,-1
    80001ba4:	17fe                	slli	a5,a5,0x3f
    80001ba6:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001ba8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001baa:	04f70463          	beq	a4,a5,80001bf2 <devintr+0x68>
  }
}
    80001bae:	60e2                	ld	ra,24(sp)
    80001bb0:	6442                	ld	s0,16(sp)
    80001bb2:	64a2                	ld	s1,8(sp)
    80001bb4:	6105                	addi	sp,sp,32
    80001bb6:	8082                	ret
    int irq = plic_claim();
    80001bb8:	501020ef          	jal	ra,800048b8 <plic_claim>
    80001bbc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001bbe:	47a9                	li	a5,10
    80001bc0:	02f50363          	beq	a0,a5,80001be6 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001bc4:	4785                	li	a5,1
    80001bc6:	02f50363          	beq	a0,a5,80001bec <devintr+0x62>
    return 1;
    80001bca:	4505                	li	a0,1
    } else if(irq){
    80001bcc:	d0ed                	beqz	s1,80001bae <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001bce:	85a6                	mv	a1,s1
    80001bd0:	00005517          	auipc	a0,0x5
    80001bd4:	7c050513          	addi	a0,a0,1984 # 80007390 <states.0+0x38>
    80001bd8:	696030ef          	jal	ra,8000526e <printf>
      plic_complete(irq);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	4fb020ef          	jal	ra,800048d8 <plic_complete>
    return 1;
    80001be2:	4505                	li	a0,1
    80001be4:	b7e9                	j	80001bae <devintr+0x24>
      uartintr();
    80001be6:	391030ef          	jal	ra,80005776 <uartintr>
    80001bea:	bfcd                	j	80001bdc <devintr+0x52>
      virtio_disk_intr();
    80001bec:	158030ef          	jal	ra,80004d44 <virtio_disk_intr>
    80001bf0:	b7f5                	j	80001bdc <devintr+0x52>
    clockintr();
    80001bf2:	f45ff0ef          	jal	ra,80001b36 <clockintr>
    return 2;
    80001bf6:	4509                	li	a0,2
    80001bf8:	bf5d                	j	80001bae <devintr+0x24>

0000000080001bfa <usertrap>:
{
    80001bfa:	1101                	addi	sp,sp,-32
    80001bfc:	ec06                	sd	ra,24(sp)
    80001bfe:	e822                	sd	s0,16(sp)
    80001c00:	e426                	sd	s1,8(sp)
    80001c02:	e04a                	sd	s2,0(sp)
    80001c04:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c06:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001c0a:	1007f793          	andi	a5,a5,256
    80001c0e:	ef85                	bnez	a5,80001c46 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c10:	00003797          	auipc	a5,0x3
    80001c14:	c0078793          	addi	a5,a5,-1024 # 80004810 <kernelvec>
    80001c18:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001c1c:	b82ff0ef          	jal	ra,80000f9e <myproc>
    80001c20:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001c22:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001c24:	14102773          	csrr	a4,sepc
    80001c28:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c2a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001c2e:	47a1                	li	a5,8
    80001c30:	02f70163          	beq	a4,a5,80001c52 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001c34:	f57ff0ef          	jal	ra,80001b8a <devintr>
    80001c38:	892a                	mv	s2,a0
    80001c3a:	c135                	beqz	a0,80001c9e <usertrap+0xa4>
  if(killed(p))
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	b65ff0ef          	jal	ra,800017a2 <killed>
    80001c42:	cd1d                	beqz	a0,80001c80 <usertrap+0x86>
    80001c44:	a81d                	j	80001c7a <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001c46:	00005517          	auipc	a0,0x5
    80001c4a:	76a50513          	addi	a0,a0,1898 # 800073b0 <states.0+0x58>
    80001c4e:	0d5030ef          	jal	ra,80005522 <panic>
    if(killed(p))
    80001c52:	b51ff0ef          	jal	ra,800017a2 <killed>
    80001c56:	e121                	bnez	a0,80001c96 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001c58:	6cb8                	ld	a4,88(s1)
    80001c5a:	6f1c                	ld	a5,24(a4)
    80001c5c:	0791                	addi	a5,a5,4
    80001c5e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c68:	10079073          	csrw	sstatus,a5
    syscall();
    80001c6c:	248000ef          	jal	ra,80001eb4 <syscall>
  if(killed(p))
    80001c70:	8526                	mv	a0,s1
    80001c72:	b31ff0ef          	jal	ra,800017a2 <killed>
    80001c76:	c901                	beqz	a0,80001c86 <usertrap+0x8c>
    80001c78:	4901                	li	s2,0
    exit(-1);
    80001c7a:	557d                	li	a0,-1
    80001c7c:	9fbff0ef          	jal	ra,80001676 <exit>
  if(which_dev == 2)
    80001c80:	4789                	li	a5,2
    80001c82:	04f90563          	beq	s2,a5,80001ccc <usertrap+0xd2>
  usertrapret();
    80001c86:	e1fff0ef          	jal	ra,80001aa4 <usertrapret>
}
    80001c8a:	60e2                	ld	ra,24(sp)
    80001c8c:	6442                	ld	s0,16(sp)
    80001c8e:	64a2                	ld	s1,8(sp)
    80001c90:	6902                	ld	s2,0(sp)
    80001c92:	6105                	addi	sp,sp,32
    80001c94:	8082                	ret
      exit(-1);
    80001c96:	557d                	li	a0,-1
    80001c98:	9dfff0ef          	jal	ra,80001676 <exit>
    80001c9c:	bf75                	j	80001c58 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c9e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001ca2:	5890                	lw	a2,48(s1)
    80001ca4:	00005517          	auipc	a0,0x5
    80001ca8:	72c50513          	addi	a0,a0,1836 # 800073d0 <states.0+0x78>
    80001cac:	5c2030ef          	jal	ra,8000526e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001cb0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001cb4:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001cb8:	00005517          	auipc	a0,0x5
    80001cbc:	74850513          	addi	a0,a0,1864 # 80007400 <states.0+0xa8>
    80001cc0:	5ae030ef          	jal	ra,8000526e <printf>
    setkilled(p);
    80001cc4:	8526                	mv	a0,s1
    80001cc6:	ab9ff0ef          	jal	ra,8000177e <setkilled>
    80001cca:	b75d                	j	80001c70 <usertrap+0x76>
    yield();
    80001ccc:	873ff0ef          	jal	ra,8000153e <yield>
    80001cd0:	bf5d                	j	80001c86 <usertrap+0x8c>

0000000080001cd2 <kerneltrap>:
{
    80001cd2:	7179                	addi	sp,sp,-48
    80001cd4:	f406                	sd	ra,40(sp)
    80001cd6:	f022                	sd	s0,32(sp)
    80001cd8:	ec26                	sd	s1,24(sp)
    80001cda:	e84a                	sd	s2,16(sp)
    80001cdc:	e44e                	sd	s3,8(sp)
    80001cde:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001ce0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ce4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ce8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001cec:	1004f793          	andi	a5,s1,256
    80001cf0:	c795                	beqz	a5,80001d1c <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cf2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001cf6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001cf8:	eb85                	bnez	a5,80001d28 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001cfa:	e91ff0ef          	jal	ra,80001b8a <devintr>
    80001cfe:	c91d                	beqz	a0,80001d34 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001d00:	4789                	li	a5,2
    80001d02:	04f50a63          	beq	a0,a5,80001d56 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001d06:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d0a:	10049073          	csrw	sstatus,s1
}
    80001d0e:	70a2                	ld	ra,40(sp)
    80001d10:	7402                	ld	s0,32(sp)
    80001d12:	64e2                	ld	s1,24(sp)
    80001d14:	6942                	ld	s2,16(sp)
    80001d16:	69a2                	ld	s3,8(sp)
    80001d18:	6145                	addi	sp,sp,48
    80001d1a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001d1c:	00005517          	auipc	a0,0x5
    80001d20:	70c50513          	addi	a0,a0,1804 # 80007428 <states.0+0xd0>
    80001d24:	7fe030ef          	jal	ra,80005522 <panic>
    panic("kerneltrap: interrupts enabled");
    80001d28:	00005517          	auipc	a0,0x5
    80001d2c:	72850513          	addi	a0,a0,1832 # 80007450 <states.0+0xf8>
    80001d30:	7f2030ef          	jal	ra,80005522 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d34:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001d38:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001d3c:	85ce                	mv	a1,s3
    80001d3e:	00005517          	auipc	a0,0x5
    80001d42:	73250513          	addi	a0,a0,1842 # 80007470 <states.0+0x118>
    80001d46:	528030ef          	jal	ra,8000526e <printf>
    panic("kerneltrap");
    80001d4a:	00005517          	auipc	a0,0x5
    80001d4e:	74e50513          	addi	a0,a0,1870 # 80007498 <states.0+0x140>
    80001d52:	7d0030ef          	jal	ra,80005522 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001d56:	a48ff0ef          	jal	ra,80000f9e <myproc>
    80001d5a:	d555                	beqz	a0,80001d06 <kerneltrap+0x34>
    yield();
    80001d5c:	fe2ff0ef          	jal	ra,8000153e <yield>
    80001d60:	b75d                	j	80001d06 <kerneltrap+0x34>

0000000080001d62 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001d62:	1101                	addi	sp,sp,-32
    80001d64:	ec06                	sd	ra,24(sp)
    80001d66:	e822                	sd	s0,16(sp)
    80001d68:	e426                	sd	s1,8(sp)
    80001d6a:	1000                	addi	s0,sp,32
    80001d6c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d6e:	a30ff0ef          	jal	ra,80000f9e <myproc>
  switch (n) {
    80001d72:	4795                	li	a5,5
    80001d74:	0497e163          	bltu	a5,s1,80001db6 <argraw+0x54>
    80001d78:	048a                	slli	s1,s1,0x2
    80001d7a:	00005717          	auipc	a4,0x5
    80001d7e:	75670713          	addi	a4,a4,1878 # 800074d0 <states.0+0x178>
    80001d82:	94ba                	add	s1,s1,a4
    80001d84:	409c                	lw	a5,0(s1)
    80001d86:	97ba                	add	a5,a5,a4
    80001d88:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001d8a:	6d3c                	ld	a5,88(a0)
    80001d8c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001d8e:	60e2                	ld	ra,24(sp)
    80001d90:	6442                	ld	s0,16(sp)
    80001d92:	64a2                	ld	s1,8(sp)
    80001d94:	6105                	addi	sp,sp,32
    80001d96:	8082                	ret
    return p->trapframe->a1;
    80001d98:	6d3c                	ld	a5,88(a0)
    80001d9a:	7fa8                	ld	a0,120(a5)
    80001d9c:	bfcd                	j	80001d8e <argraw+0x2c>
    return p->trapframe->a2;
    80001d9e:	6d3c                	ld	a5,88(a0)
    80001da0:	63c8                	ld	a0,128(a5)
    80001da2:	b7f5                	j	80001d8e <argraw+0x2c>
    return p->trapframe->a3;
    80001da4:	6d3c                	ld	a5,88(a0)
    80001da6:	67c8                	ld	a0,136(a5)
    80001da8:	b7dd                	j	80001d8e <argraw+0x2c>
    return p->trapframe->a4;
    80001daa:	6d3c                	ld	a5,88(a0)
    80001dac:	6bc8                	ld	a0,144(a5)
    80001dae:	b7c5                	j	80001d8e <argraw+0x2c>
    return p->trapframe->a5;
    80001db0:	6d3c                	ld	a5,88(a0)
    80001db2:	6fc8                	ld	a0,152(a5)
    80001db4:	bfe9                	j	80001d8e <argraw+0x2c>
  panic("argraw");
    80001db6:	00005517          	auipc	a0,0x5
    80001dba:	6f250513          	addi	a0,a0,1778 # 800074a8 <states.0+0x150>
    80001dbe:	764030ef          	jal	ra,80005522 <panic>

0000000080001dc2 <fetchaddr>:
{
    80001dc2:	1101                	addi	sp,sp,-32
    80001dc4:	ec06                	sd	ra,24(sp)
    80001dc6:	e822                	sd	s0,16(sp)
    80001dc8:	e426                	sd	s1,8(sp)
    80001dca:	e04a                	sd	s2,0(sp)
    80001dcc:	1000                	addi	s0,sp,32
    80001dce:	84aa                	mv	s1,a0
    80001dd0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001dd2:	9ccff0ef          	jal	ra,80000f9e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001dd6:	653c                	ld	a5,72(a0)
    80001dd8:	02f4f663          	bgeu	s1,a5,80001e04 <fetchaddr+0x42>
    80001ddc:	00848713          	addi	a4,s1,8
    80001de0:	02e7e463          	bltu	a5,a4,80001e08 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001de4:	46a1                	li	a3,8
    80001de6:	8626                	mv	a2,s1
    80001de8:	85ca                	mv	a1,s2
    80001dea:	6928                	ld	a0,80(a0)
    80001dec:	e0ffe0ef          	jal	ra,80000bfa <copyin>
    80001df0:	00a03533          	snez	a0,a0
    80001df4:	40a00533          	neg	a0,a0
}
    80001df8:	60e2                	ld	ra,24(sp)
    80001dfa:	6442                	ld	s0,16(sp)
    80001dfc:	64a2                	ld	s1,8(sp)
    80001dfe:	6902                	ld	s2,0(sp)
    80001e00:	6105                	addi	sp,sp,32
    80001e02:	8082                	ret
    return -1;
    80001e04:	557d                	li	a0,-1
    80001e06:	bfcd                	j	80001df8 <fetchaddr+0x36>
    80001e08:	557d                	li	a0,-1
    80001e0a:	b7fd                	j	80001df8 <fetchaddr+0x36>

0000000080001e0c <fetchstr>:
{
    80001e0c:	7179                	addi	sp,sp,-48
    80001e0e:	f406                	sd	ra,40(sp)
    80001e10:	f022                	sd	s0,32(sp)
    80001e12:	ec26                	sd	s1,24(sp)
    80001e14:	e84a                	sd	s2,16(sp)
    80001e16:	e44e                	sd	s3,8(sp)
    80001e18:	1800                	addi	s0,sp,48
    80001e1a:	892a                	mv	s2,a0
    80001e1c:	84ae                	mv	s1,a1
    80001e1e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001e20:	97eff0ef          	jal	ra,80000f9e <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001e24:	86ce                	mv	a3,s3
    80001e26:	864a                	mv	a2,s2
    80001e28:	85a6                	mv	a1,s1
    80001e2a:	6928                	ld	a0,80(a0)
    80001e2c:	e55fe0ef          	jal	ra,80000c80 <copyinstr>
    80001e30:	00054c63          	bltz	a0,80001e48 <fetchstr+0x3c>
  return strlen(buf);
    80001e34:	8526                	mv	a0,s1
    80001e36:	df4fe0ef          	jal	ra,8000042a <strlen>
}
    80001e3a:	70a2                	ld	ra,40(sp)
    80001e3c:	7402                	ld	s0,32(sp)
    80001e3e:	64e2                	ld	s1,24(sp)
    80001e40:	6942                	ld	s2,16(sp)
    80001e42:	69a2                	ld	s3,8(sp)
    80001e44:	6145                	addi	sp,sp,48
    80001e46:	8082                	ret
    return -1;
    80001e48:	557d                	li	a0,-1
    80001e4a:	bfc5                	j	80001e3a <fetchstr+0x2e>

0000000080001e4c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001e4c:	1101                	addi	sp,sp,-32
    80001e4e:	ec06                	sd	ra,24(sp)
    80001e50:	e822                	sd	s0,16(sp)
    80001e52:	e426                	sd	s1,8(sp)
    80001e54:	1000                	addi	s0,sp,32
    80001e56:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001e58:	f0bff0ef          	jal	ra,80001d62 <argraw>
    80001e5c:	c088                	sw	a0,0(s1)
}
    80001e5e:	60e2                	ld	ra,24(sp)
    80001e60:	6442                	ld	s0,16(sp)
    80001e62:	64a2                	ld	s1,8(sp)
    80001e64:	6105                	addi	sp,sp,32
    80001e66:	8082                	ret

0000000080001e68 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001e68:	1101                	addi	sp,sp,-32
    80001e6a:	ec06                	sd	ra,24(sp)
    80001e6c:	e822                	sd	s0,16(sp)
    80001e6e:	e426                	sd	s1,8(sp)
    80001e70:	1000                	addi	s0,sp,32
    80001e72:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001e74:	eefff0ef          	jal	ra,80001d62 <argraw>
    80001e78:	e088                	sd	a0,0(s1)
}
    80001e7a:	60e2                	ld	ra,24(sp)
    80001e7c:	6442                	ld	s0,16(sp)
    80001e7e:	64a2                	ld	s1,8(sp)
    80001e80:	6105                	addi	sp,sp,32
    80001e82:	8082                	ret

0000000080001e84 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001e84:	7179                	addi	sp,sp,-48
    80001e86:	f406                	sd	ra,40(sp)
    80001e88:	f022                	sd	s0,32(sp)
    80001e8a:	ec26                	sd	s1,24(sp)
    80001e8c:	e84a                	sd	s2,16(sp)
    80001e8e:	1800                	addi	s0,sp,48
    80001e90:	84ae                	mv	s1,a1
    80001e92:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001e94:	fd840593          	addi	a1,s0,-40
    80001e98:	fd1ff0ef          	jal	ra,80001e68 <argaddr>
  return fetchstr(addr, buf, max);
    80001e9c:	864a                	mv	a2,s2
    80001e9e:	85a6                	mv	a1,s1
    80001ea0:	fd843503          	ld	a0,-40(s0)
    80001ea4:	f69ff0ef          	jal	ra,80001e0c <fetchstr>
}
    80001ea8:	70a2                	ld	ra,40(sp)
    80001eaa:	7402                	ld	s0,32(sp)
    80001eac:	64e2                	ld	s1,24(sp)
    80001eae:	6942                	ld	s2,16(sp)
    80001eb0:	6145                	addi	sp,sp,48
    80001eb2:	8082                	ret

0000000080001eb4 <syscall>:
#endif
};

void
syscall(void)
{
    80001eb4:	1101                	addi	sp,sp,-32
    80001eb6:	ec06                	sd	ra,24(sp)
    80001eb8:	e822                	sd	s0,16(sp)
    80001eba:	e426                	sd	s1,8(sp)
    80001ebc:	e04a                	sd	s2,0(sp)
    80001ebe:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001ec0:	8deff0ef          	jal	ra,80000f9e <myproc>
    80001ec4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001ec6:	05853903          	ld	s2,88(a0)
    80001eca:	0a893783          	ld	a5,168(s2)
    80001ece:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001ed2:	37fd                	addiw	a5,a5,-1
    80001ed4:	02100713          	li	a4,33
    80001ed8:	00f76f63          	bltu	a4,a5,80001ef6 <syscall+0x42>
    80001edc:	00369713          	slli	a4,a3,0x3
    80001ee0:	00005797          	auipc	a5,0x5
    80001ee4:	60878793          	addi	a5,a5,1544 # 800074e8 <syscalls>
    80001ee8:	97ba                	add	a5,a5,a4
    80001eea:	639c                	ld	a5,0(a5)
    80001eec:	c789                	beqz	a5,80001ef6 <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001eee:	9782                	jalr	a5
    80001ef0:	06a93823          	sd	a0,112(s2)
    80001ef4:	a829                	j	80001f0e <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001ef6:	15848613          	addi	a2,s1,344
    80001efa:	588c                	lw	a1,48(s1)
    80001efc:	00005517          	auipc	a0,0x5
    80001f00:	5b450513          	addi	a0,a0,1460 # 800074b0 <states.0+0x158>
    80001f04:	36a030ef          	jal	ra,8000526e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001f08:	6cbc                	ld	a5,88(s1)
    80001f0a:	577d                	li	a4,-1
    80001f0c:	fbb8                	sd	a4,112(a5)
  }
}
    80001f0e:	60e2                	ld	ra,24(sp)
    80001f10:	6442                	ld	s0,16(sp)
    80001f12:	64a2                	ld	s1,8(sp)
    80001f14:	6902                	ld	s2,0(sp)
    80001f16:	6105                	addi	sp,sp,32
    80001f18:	8082                	ret

0000000080001f1a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001f1a:	1101                	addi	sp,sp,-32
    80001f1c:	ec06                	sd	ra,24(sp)
    80001f1e:	e822                	sd	s0,16(sp)
    80001f20:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001f22:	fec40593          	addi	a1,s0,-20
    80001f26:	4501                	li	a0,0
    80001f28:	f25ff0ef          	jal	ra,80001e4c <argint>
  exit(n);
    80001f2c:	fec42503          	lw	a0,-20(s0)
    80001f30:	f46ff0ef          	jal	ra,80001676 <exit>
  return 0;  // not reached
}
    80001f34:	4501                	li	a0,0
    80001f36:	60e2                	ld	ra,24(sp)
    80001f38:	6442                	ld	s0,16(sp)
    80001f3a:	6105                	addi	sp,sp,32
    80001f3c:	8082                	ret

0000000080001f3e <sys_getpid>:

uint64
sys_getpid(void)
{
    80001f3e:	1141                	addi	sp,sp,-16
    80001f40:	e406                	sd	ra,8(sp)
    80001f42:	e022                	sd	s0,0(sp)
    80001f44:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001f46:	858ff0ef          	jal	ra,80000f9e <myproc>
}
    80001f4a:	5908                	lw	a0,48(a0)
    80001f4c:	60a2                	ld	ra,8(sp)
    80001f4e:	6402                	ld	s0,0(sp)
    80001f50:	0141                	addi	sp,sp,16
    80001f52:	8082                	ret

0000000080001f54 <sys_fork>:

uint64
sys_fork(void)
{
    80001f54:	1141                	addi	sp,sp,-16
    80001f56:	e406                	sd	ra,8(sp)
    80001f58:	e022                	sd	s0,0(sp)
    80001f5a:	0800                	addi	s0,sp,16
  return fork();
    80001f5c:	b68ff0ef          	jal	ra,800012c4 <fork>
}
    80001f60:	60a2                	ld	ra,8(sp)
    80001f62:	6402                	ld	s0,0(sp)
    80001f64:	0141                	addi	sp,sp,16
    80001f66:	8082                	ret

0000000080001f68 <sys_wait>:

uint64
sys_wait(void)
{
    80001f68:	1101                	addi	sp,sp,-32
    80001f6a:	ec06                	sd	ra,24(sp)
    80001f6c:	e822                	sd	s0,16(sp)
    80001f6e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001f70:	fe840593          	addi	a1,s0,-24
    80001f74:	4501                	li	a0,0
    80001f76:	ef3ff0ef          	jal	ra,80001e68 <argaddr>
  return wait(p);
    80001f7a:	fe843503          	ld	a0,-24(s0)
    80001f7e:	84fff0ef          	jal	ra,800017cc <wait>
}
    80001f82:	60e2                	ld	ra,24(sp)
    80001f84:	6442                	ld	s0,16(sp)
    80001f86:	6105                	addi	sp,sp,32
    80001f88:	8082                	ret

0000000080001f8a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001f8a:	7179                	addi	sp,sp,-48
    80001f8c:	f406                	sd	ra,40(sp)
    80001f8e:	f022                	sd	s0,32(sp)
    80001f90:	ec26                	sd	s1,24(sp)
    80001f92:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001f94:	fdc40593          	addi	a1,s0,-36
    80001f98:	4501                	li	a0,0
    80001f9a:	eb3ff0ef          	jal	ra,80001e4c <argint>
  addr = myproc()->sz;
    80001f9e:	800ff0ef          	jal	ra,80000f9e <myproc>
    80001fa2:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001fa4:	fdc42503          	lw	a0,-36(s0)
    80001fa8:	accff0ef          	jal	ra,80001274 <growproc>
    80001fac:	00054863          	bltz	a0,80001fbc <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001fb0:	8526                	mv	a0,s1
    80001fb2:	70a2                	ld	ra,40(sp)
    80001fb4:	7402                	ld	s0,32(sp)
    80001fb6:	64e2                	ld	s1,24(sp)
    80001fb8:	6145                	addi	sp,sp,48
    80001fba:	8082                	ret
    return -1;
    80001fbc:	54fd                	li	s1,-1
    80001fbe:	bfcd                	j	80001fb0 <sys_sbrk+0x26>

0000000080001fc0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80001fc0:	7139                	addi	sp,sp,-64
    80001fc2:	fc06                	sd	ra,56(sp)
    80001fc4:	f822                	sd	s0,48(sp)
    80001fc6:	f426                	sd	s1,40(sp)
    80001fc8:	f04a                	sd	s2,32(sp)
    80001fca:	ec4e                	sd	s3,24(sp)
    80001fcc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001fce:	fcc40593          	addi	a1,s0,-52
    80001fd2:	4501                	li	a0,0
    80001fd4:	e79ff0ef          	jal	ra,80001e4c <argint>
  if(n < 0)
    80001fd8:	fcc42783          	lw	a5,-52(s0)
    80001fdc:	0607c563          	bltz	a5,80002046 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001fe0:	0000c517          	auipc	a0,0xc
    80001fe4:	ad050513          	addi	a0,a0,-1328 # 8000dab0 <tickslock>
    80001fe8:	04b030ef          	jal	ra,80005832 <acquire>
  ticks0 = ticks;
    80001fec:	00006917          	auipc	s2,0x6
    80001ff0:	a5c92903          	lw	s2,-1444(s2) # 80007a48 <ticks>
  while(ticks - ticks0 < n){
    80001ff4:	fcc42783          	lw	a5,-52(s0)
    80001ff8:	cb8d                	beqz	a5,8000202a <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001ffa:	0000c997          	auipc	s3,0xc
    80001ffe:	ab698993          	addi	s3,s3,-1354 # 8000dab0 <tickslock>
    80002002:	00006497          	auipc	s1,0x6
    80002006:	a4648493          	addi	s1,s1,-1466 # 80007a48 <ticks>
    if(killed(myproc())){
    8000200a:	f95fe0ef          	jal	ra,80000f9e <myproc>
    8000200e:	f94ff0ef          	jal	ra,800017a2 <killed>
    80002012:	ed0d                	bnez	a0,8000204c <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002014:	85ce                	mv	a1,s3
    80002016:	8526                	mv	a0,s1
    80002018:	d52ff0ef          	jal	ra,8000156a <sleep>
  while(ticks - ticks0 < n){
    8000201c:	409c                	lw	a5,0(s1)
    8000201e:	412787bb          	subw	a5,a5,s2
    80002022:	fcc42703          	lw	a4,-52(s0)
    80002026:	fee7e2e3          	bltu	a5,a4,8000200a <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000202a:	0000c517          	auipc	a0,0xc
    8000202e:	a8650513          	addi	a0,a0,-1402 # 8000dab0 <tickslock>
    80002032:	099030ef          	jal	ra,800058ca <release>
  return 0;
    80002036:	4501                	li	a0,0
}
    80002038:	70e2                	ld	ra,56(sp)
    8000203a:	7442                	ld	s0,48(sp)
    8000203c:	74a2                	ld	s1,40(sp)
    8000203e:	7902                	ld	s2,32(sp)
    80002040:	69e2                	ld	s3,24(sp)
    80002042:	6121                	addi	sp,sp,64
    80002044:	8082                	ret
    n = 0;
    80002046:	fc042623          	sw	zero,-52(s0)
    8000204a:	bf59                	j	80001fe0 <sys_sleep+0x20>
      release(&tickslock);
    8000204c:	0000c517          	auipc	a0,0xc
    80002050:	a6450513          	addi	a0,a0,-1436 # 8000dab0 <tickslock>
    80002054:	077030ef          	jal	ra,800058ca <release>
      return -1;
    80002058:	557d                	li	a0,-1
    8000205a:	bff9                	j	80002038 <sys_sleep+0x78>

000000008000205c <sys_pgpte>:


#ifdef LAB_PGTBL
int
sys_pgpte(void)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	1800                	addi	s0,sp,48
  uint64 va;
  struct proc *p;

  p = myproc();
    80002066:	f39fe0ef          	jal	ra,80000f9e <myproc>
    8000206a:	84aa                	mv	s1,a0
  argaddr(0, &va);
    8000206c:	fd840593          	addi	a1,s0,-40
    80002070:	4501                	li	a0,0
    80002072:	df7ff0ef          	jal	ra,80001e68 <argaddr>
  pte_t *pte = pgpte(p->pagetable, va);
    80002076:	fd843583          	ld	a1,-40(s0)
    8000207a:	68a8                	ld	a0,80(s1)
    8000207c:	daffe0ef          	jal	ra,80000e2a <pgpte>
    80002080:	87aa                	mv	a5,a0
  if(pte != 0) {
      return (uint64) *pte;
  }
  return 0;
    80002082:	4501                	li	a0,0
  if(pte != 0) {
    80002084:	c391                	beqz	a5,80002088 <sys_pgpte+0x2c>
      return (uint64) *pte;
    80002086:	4388                	lw	a0,0(a5)
}
    80002088:	70a2                	ld	ra,40(sp)
    8000208a:	7402                	ld	s0,32(sp)
    8000208c:	64e2                	ld	s1,24(sp)
    8000208e:	6145                	addi	sp,sp,48
    80002090:	8082                	ret

0000000080002092 <sys_kpgtbl>:
#endif

#ifdef LAB_PGTBL
int
sys_kpgtbl(void)
{
    80002092:	1141                	addi	sp,sp,-16
    80002094:	e406                	sd	ra,8(sp)
    80002096:	e022                	sd	s0,0(sp)
    80002098:	0800                	addi	s0,sp,16
  struct proc *p;

  p = myproc();
    8000209a:	f05fe0ef          	jal	ra,80000f9e <myproc>
  vmprint(p->pagetable);
    8000209e:	6928                	ld	a0,80(a0)
    800020a0:	d5dfe0ef          	jal	ra,80000dfc <vmprint>
  return 0;
}
    800020a4:	4501                	li	a0,0
    800020a6:	60a2                	ld	ra,8(sp)
    800020a8:	6402                	ld	s0,0(sp)
    800020aa:	0141                	addi	sp,sp,16
    800020ac:	8082                	ret

00000000800020ae <sys_kill>:
#endif


uint64
sys_kill(void)
{
    800020ae:	1101                	addi	sp,sp,-32
    800020b0:	ec06                	sd	ra,24(sp)
    800020b2:	e822                	sd	s0,16(sp)
    800020b4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800020b6:	fec40593          	addi	a1,s0,-20
    800020ba:	4501                	li	a0,0
    800020bc:	d91ff0ef          	jal	ra,80001e4c <argint>
  return kill(pid);
    800020c0:	fec42503          	lw	a0,-20(s0)
    800020c4:	e54ff0ef          	jal	ra,80001718 <kill>
}
    800020c8:	60e2                	ld	ra,24(sp)
    800020ca:	6442                	ld	s0,16(sp)
    800020cc:	6105                	addi	sp,sp,32
    800020ce:	8082                	ret

00000000800020d0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800020d0:	1101                	addi	sp,sp,-32
    800020d2:	ec06                	sd	ra,24(sp)
    800020d4:	e822                	sd	s0,16(sp)
    800020d6:	e426                	sd	s1,8(sp)
    800020d8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800020da:	0000c517          	auipc	a0,0xc
    800020de:	9d650513          	addi	a0,a0,-1578 # 8000dab0 <tickslock>
    800020e2:	750030ef          	jal	ra,80005832 <acquire>
  xticks = ticks;
    800020e6:	00006497          	auipc	s1,0x6
    800020ea:	9624a483          	lw	s1,-1694(s1) # 80007a48 <ticks>
  release(&tickslock);
    800020ee:	0000c517          	auipc	a0,0xc
    800020f2:	9c250513          	addi	a0,a0,-1598 # 8000dab0 <tickslock>
    800020f6:	7d4030ef          	jal	ra,800058ca <release>
  return xticks;
}
    800020fa:	02049513          	slli	a0,s1,0x20
    800020fe:	9101                	srli	a0,a0,0x20
    80002100:	60e2                	ld	ra,24(sp)
    80002102:	6442                	ld	s0,16(sp)
    80002104:	64a2                	ld	s1,8(sp)
    80002106:	6105                	addi	sp,sp,32
    80002108:	8082                	ret

000000008000210a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000210a:	7179                	addi	sp,sp,-48
    8000210c:	f406                	sd	ra,40(sp)
    8000210e:	f022                	sd	s0,32(sp)
    80002110:	ec26                	sd	s1,24(sp)
    80002112:	e84a                	sd	s2,16(sp)
    80002114:	e44e                	sd	s3,8(sp)
    80002116:	e052                	sd	s4,0(sp)
    80002118:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000211a:	00005597          	auipc	a1,0x5
    8000211e:	4e658593          	addi	a1,a1,1254 # 80007600 <syscalls+0x118>
    80002122:	0000c517          	auipc	a0,0xc
    80002126:	9a650513          	addi	a0,a0,-1626 # 8000dac8 <bcache>
    8000212a:	688030ef          	jal	ra,800057b2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000212e:	00014797          	auipc	a5,0x14
    80002132:	99a78793          	addi	a5,a5,-1638 # 80015ac8 <bcache+0x8000>
    80002136:	00014717          	auipc	a4,0x14
    8000213a:	bfa70713          	addi	a4,a4,-1030 # 80015d30 <bcache+0x8268>
    8000213e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002142:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002146:	0000c497          	auipc	s1,0xc
    8000214a:	99a48493          	addi	s1,s1,-1638 # 8000dae0 <bcache+0x18>
    b->next = bcache.head.next;
    8000214e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002150:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002152:	00005a17          	auipc	s4,0x5
    80002156:	4b6a0a13          	addi	s4,s4,1206 # 80007608 <syscalls+0x120>
    b->next = bcache.head.next;
    8000215a:	2b893783          	ld	a5,696(s2)
    8000215e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002160:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002164:	85d2                	mv	a1,s4
    80002166:	01048513          	addi	a0,s1,16
    8000216a:	228010ef          	jal	ra,80003392 <initsleeplock>
    bcache.head.next->prev = b;
    8000216e:	2b893783          	ld	a5,696(s2)
    80002172:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002174:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002178:	45848493          	addi	s1,s1,1112
    8000217c:	fd349fe3          	bne	s1,s3,8000215a <binit+0x50>
  }
}
    80002180:	70a2                	ld	ra,40(sp)
    80002182:	7402                	ld	s0,32(sp)
    80002184:	64e2                	ld	s1,24(sp)
    80002186:	6942                	ld	s2,16(sp)
    80002188:	69a2                	ld	s3,8(sp)
    8000218a:	6a02                	ld	s4,0(sp)
    8000218c:	6145                	addi	sp,sp,48
    8000218e:	8082                	ret

0000000080002190 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002190:	7179                	addi	sp,sp,-48
    80002192:	f406                	sd	ra,40(sp)
    80002194:	f022                	sd	s0,32(sp)
    80002196:	ec26                	sd	s1,24(sp)
    80002198:	e84a                	sd	s2,16(sp)
    8000219a:	e44e                	sd	s3,8(sp)
    8000219c:	1800                	addi	s0,sp,48
    8000219e:	892a                	mv	s2,a0
    800021a0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800021a2:	0000c517          	auipc	a0,0xc
    800021a6:	92650513          	addi	a0,a0,-1754 # 8000dac8 <bcache>
    800021aa:	688030ef          	jal	ra,80005832 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800021ae:	00014497          	auipc	s1,0x14
    800021b2:	bd24b483          	ld	s1,-1070(s1) # 80015d80 <bcache+0x82b8>
    800021b6:	00014797          	auipc	a5,0x14
    800021ba:	b7a78793          	addi	a5,a5,-1158 # 80015d30 <bcache+0x8268>
    800021be:	02f48b63          	beq	s1,a5,800021f4 <bread+0x64>
    800021c2:	873e                	mv	a4,a5
    800021c4:	a021                	j	800021cc <bread+0x3c>
    800021c6:	68a4                	ld	s1,80(s1)
    800021c8:	02e48663          	beq	s1,a4,800021f4 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800021cc:	449c                	lw	a5,8(s1)
    800021ce:	ff279ce3          	bne	a5,s2,800021c6 <bread+0x36>
    800021d2:	44dc                	lw	a5,12(s1)
    800021d4:	ff3799e3          	bne	a5,s3,800021c6 <bread+0x36>
      b->refcnt++;
    800021d8:	40bc                	lw	a5,64(s1)
    800021da:	2785                	addiw	a5,a5,1
    800021dc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800021de:	0000c517          	auipc	a0,0xc
    800021e2:	8ea50513          	addi	a0,a0,-1814 # 8000dac8 <bcache>
    800021e6:	6e4030ef          	jal	ra,800058ca <release>
      acquiresleep(&b->lock);
    800021ea:	01048513          	addi	a0,s1,16
    800021ee:	1da010ef          	jal	ra,800033c8 <acquiresleep>
      return b;
    800021f2:	a889                	j	80002244 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800021f4:	00014497          	auipc	s1,0x14
    800021f8:	b844b483          	ld	s1,-1148(s1) # 80015d78 <bcache+0x82b0>
    800021fc:	00014797          	auipc	a5,0x14
    80002200:	b3478793          	addi	a5,a5,-1228 # 80015d30 <bcache+0x8268>
    80002204:	00f48863          	beq	s1,a5,80002214 <bread+0x84>
    80002208:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000220a:	40bc                	lw	a5,64(s1)
    8000220c:	cb91                	beqz	a5,80002220 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000220e:	64a4                	ld	s1,72(s1)
    80002210:	fee49de3          	bne	s1,a4,8000220a <bread+0x7a>
  panic("bget: no buffers");
    80002214:	00005517          	auipc	a0,0x5
    80002218:	3fc50513          	addi	a0,a0,1020 # 80007610 <syscalls+0x128>
    8000221c:	306030ef          	jal	ra,80005522 <panic>
      b->dev = dev;
    80002220:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002224:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002228:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000222c:	4785                	li	a5,1
    8000222e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002230:	0000c517          	auipc	a0,0xc
    80002234:	89850513          	addi	a0,a0,-1896 # 8000dac8 <bcache>
    80002238:	692030ef          	jal	ra,800058ca <release>
      acquiresleep(&b->lock);
    8000223c:	01048513          	addi	a0,s1,16
    80002240:	188010ef          	jal	ra,800033c8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002244:	409c                	lw	a5,0(s1)
    80002246:	cb89                	beqz	a5,80002258 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002248:	8526                	mv	a0,s1
    8000224a:	70a2                	ld	ra,40(sp)
    8000224c:	7402                	ld	s0,32(sp)
    8000224e:	64e2                	ld	s1,24(sp)
    80002250:	6942                	ld	s2,16(sp)
    80002252:	69a2                	ld	s3,8(sp)
    80002254:	6145                	addi	sp,sp,48
    80002256:	8082                	ret
    virtio_disk_rw(b, 0);
    80002258:	4581                	li	a1,0
    8000225a:	8526                	mv	a0,s1
    8000225c:	0cf020ef          	jal	ra,80004b2a <virtio_disk_rw>
    b->valid = 1;
    80002260:	4785                	li	a5,1
    80002262:	c09c                	sw	a5,0(s1)
  return b;
    80002264:	b7d5                	j	80002248 <bread+0xb8>

0000000080002266 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002266:	1101                	addi	sp,sp,-32
    80002268:	ec06                	sd	ra,24(sp)
    8000226a:	e822                	sd	s0,16(sp)
    8000226c:	e426                	sd	s1,8(sp)
    8000226e:	1000                	addi	s0,sp,32
    80002270:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002272:	0541                	addi	a0,a0,16
    80002274:	1d2010ef          	jal	ra,80003446 <holdingsleep>
    80002278:	c911                	beqz	a0,8000228c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000227a:	4585                	li	a1,1
    8000227c:	8526                	mv	a0,s1
    8000227e:	0ad020ef          	jal	ra,80004b2a <virtio_disk_rw>
}
    80002282:	60e2                	ld	ra,24(sp)
    80002284:	6442                	ld	s0,16(sp)
    80002286:	64a2                	ld	s1,8(sp)
    80002288:	6105                	addi	sp,sp,32
    8000228a:	8082                	ret
    panic("bwrite");
    8000228c:	00005517          	auipc	a0,0x5
    80002290:	39c50513          	addi	a0,a0,924 # 80007628 <syscalls+0x140>
    80002294:	28e030ef          	jal	ra,80005522 <panic>

0000000080002298 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002298:	1101                	addi	sp,sp,-32
    8000229a:	ec06                	sd	ra,24(sp)
    8000229c:	e822                	sd	s0,16(sp)
    8000229e:	e426                	sd	s1,8(sp)
    800022a0:	e04a                	sd	s2,0(sp)
    800022a2:	1000                	addi	s0,sp,32
    800022a4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800022a6:	01050913          	addi	s2,a0,16
    800022aa:	854a                	mv	a0,s2
    800022ac:	19a010ef          	jal	ra,80003446 <holdingsleep>
    800022b0:	c13d                	beqz	a0,80002316 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    800022b2:	854a                	mv	a0,s2
    800022b4:	15a010ef          	jal	ra,8000340e <releasesleep>

  acquire(&bcache.lock);
    800022b8:	0000c517          	auipc	a0,0xc
    800022bc:	81050513          	addi	a0,a0,-2032 # 8000dac8 <bcache>
    800022c0:	572030ef          	jal	ra,80005832 <acquire>
  b->refcnt--;
    800022c4:	40bc                	lw	a5,64(s1)
    800022c6:	37fd                	addiw	a5,a5,-1
    800022c8:	0007871b          	sext.w	a4,a5
    800022cc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800022ce:	eb05                	bnez	a4,800022fe <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800022d0:	68bc                	ld	a5,80(s1)
    800022d2:	64b8                	ld	a4,72(s1)
    800022d4:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800022d6:	64bc                	ld	a5,72(s1)
    800022d8:	68b8                	ld	a4,80(s1)
    800022da:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800022dc:	00013797          	auipc	a5,0x13
    800022e0:	7ec78793          	addi	a5,a5,2028 # 80015ac8 <bcache+0x8000>
    800022e4:	2b87b703          	ld	a4,696(a5)
    800022e8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800022ea:	00014717          	auipc	a4,0x14
    800022ee:	a4670713          	addi	a4,a4,-1466 # 80015d30 <bcache+0x8268>
    800022f2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800022f4:	2b87b703          	ld	a4,696(a5)
    800022f8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800022fa:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    800022fe:	0000b517          	auipc	a0,0xb
    80002302:	7ca50513          	addi	a0,a0,1994 # 8000dac8 <bcache>
    80002306:	5c4030ef          	jal	ra,800058ca <release>
}
    8000230a:	60e2                	ld	ra,24(sp)
    8000230c:	6442                	ld	s0,16(sp)
    8000230e:	64a2                	ld	s1,8(sp)
    80002310:	6902                	ld	s2,0(sp)
    80002312:	6105                	addi	sp,sp,32
    80002314:	8082                	ret
    panic("brelse");
    80002316:	00005517          	auipc	a0,0x5
    8000231a:	31a50513          	addi	a0,a0,794 # 80007630 <syscalls+0x148>
    8000231e:	204030ef          	jal	ra,80005522 <panic>

0000000080002322 <bpin>:

void
bpin(struct buf *b) {
    80002322:	1101                	addi	sp,sp,-32
    80002324:	ec06                	sd	ra,24(sp)
    80002326:	e822                	sd	s0,16(sp)
    80002328:	e426                	sd	s1,8(sp)
    8000232a:	1000                	addi	s0,sp,32
    8000232c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000232e:	0000b517          	auipc	a0,0xb
    80002332:	79a50513          	addi	a0,a0,1946 # 8000dac8 <bcache>
    80002336:	4fc030ef          	jal	ra,80005832 <acquire>
  b->refcnt++;
    8000233a:	40bc                	lw	a5,64(s1)
    8000233c:	2785                	addiw	a5,a5,1
    8000233e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002340:	0000b517          	auipc	a0,0xb
    80002344:	78850513          	addi	a0,a0,1928 # 8000dac8 <bcache>
    80002348:	582030ef          	jal	ra,800058ca <release>
}
    8000234c:	60e2                	ld	ra,24(sp)
    8000234e:	6442                	ld	s0,16(sp)
    80002350:	64a2                	ld	s1,8(sp)
    80002352:	6105                	addi	sp,sp,32
    80002354:	8082                	ret

0000000080002356 <bunpin>:

void
bunpin(struct buf *b) {
    80002356:	1101                	addi	sp,sp,-32
    80002358:	ec06                	sd	ra,24(sp)
    8000235a:	e822                	sd	s0,16(sp)
    8000235c:	e426                	sd	s1,8(sp)
    8000235e:	1000                	addi	s0,sp,32
    80002360:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002362:	0000b517          	auipc	a0,0xb
    80002366:	76650513          	addi	a0,a0,1894 # 8000dac8 <bcache>
    8000236a:	4c8030ef          	jal	ra,80005832 <acquire>
  b->refcnt--;
    8000236e:	40bc                	lw	a5,64(s1)
    80002370:	37fd                	addiw	a5,a5,-1
    80002372:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002374:	0000b517          	auipc	a0,0xb
    80002378:	75450513          	addi	a0,a0,1876 # 8000dac8 <bcache>
    8000237c:	54e030ef          	jal	ra,800058ca <release>
}
    80002380:	60e2                	ld	ra,24(sp)
    80002382:	6442                	ld	s0,16(sp)
    80002384:	64a2                	ld	s1,8(sp)
    80002386:	6105                	addi	sp,sp,32
    80002388:	8082                	ret

000000008000238a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000238a:	1101                	addi	sp,sp,-32
    8000238c:	ec06                	sd	ra,24(sp)
    8000238e:	e822                	sd	s0,16(sp)
    80002390:	e426                	sd	s1,8(sp)
    80002392:	e04a                	sd	s2,0(sp)
    80002394:	1000                	addi	s0,sp,32
    80002396:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002398:	00d5d59b          	srliw	a1,a1,0xd
    8000239c:	00014797          	auipc	a5,0x14
    800023a0:	e087a783          	lw	a5,-504(a5) # 800161a4 <sb+0x1c>
    800023a4:	9dbd                	addw	a1,a1,a5
    800023a6:	debff0ef          	jal	ra,80002190 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800023aa:	0074f713          	andi	a4,s1,7
    800023ae:	4785                	li	a5,1
    800023b0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800023b4:	14ce                	slli	s1,s1,0x33
    800023b6:	90d9                	srli	s1,s1,0x36
    800023b8:	00950733          	add	a4,a0,s1
    800023bc:	05874703          	lbu	a4,88(a4)
    800023c0:	00e7f6b3          	and	a3,a5,a4
    800023c4:	c29d                	beqz	a3,800023ea <bfree+0x60>
    800023c6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800023c8:	94aa                	add	s1,s1,a0
    800023ca:	fff7c793          	not	a5,a5
    800023ce:	8f7d                	and	a4,a4,a5
    800023d0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800023d4:	6ef000ef          	jal	ra,800032c2 <log_write>
  brelse(bp);
    800023d8:	854a                	mv	a0,s2
    800023da:	ebfff0ef          	jal	ra,80002298 <brelse>
}
    800023de:	60e2                	ld	ra,24(sp)
    800023e0:	6442                	ld	s0,16(sp)
    800023e2:	64a2                	ld	s1,8(sp)
    800023e4:	6902                	ld	s2,0(sp)
    800023e6:	6105                	addi	sp,sp,32
    800023e8:	8082                	ret
    panic("freeing free block");
    800023ea:	00005517          	auipc	a0,0x5
    800023ee:	24e50513          	addi	a0,a0,590 # 80007638 <syscalls+0x150>
    800023f2:	130030ef          	jal	ra,80005522 <panic>

00000000800023f6 <balloc>:
{
    800023f6:	711d                	addi	sp,sp,-96
    800023f8:	ec86                	sd	ra,88(sp)
    800023fa:	e8a2                	sd	s0,80(sp)
    800023fc:	e4a6                	sd	s1,72(sp)
    800023fe:	e0ca                	sd	s2,64(sp)
    80002400:	fc4e                	sd	s3,56(sp)
    80002402:	f852                	sd	s4,48(sp)
    80002404:	f456                	sd	s5,40(sp)
    80002406:	f05a                	sd	s6,32(sp)
    80002408:	ec5e                	sd	s7,24(sp)
    8000240a:	e862                	sd	s8,16(sp)
    8000240c:	e466                	sd	s9,8(sp)
    8000240e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002410:	00014797          	auipc	a5,0x14
    80002414:	d7c7a783          	lw	a5,-644(a5) # 8001618c <sb+0x4>
    80002418:	cff1                	beqz	a5,800024f4 <balloc+0xfe>
    8000241a:	8baa                	mv	s7,a0
    8000241c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000241e:	00014b17          	auipc	s6,0x14
    80002422:	d6ab0b13          	addi	s6,s6,-662 # 80016188 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002426:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002428:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000242a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000242c:	6c89                	lui	s9,0x2
    8000242e:	a0b5                	j	8000249a <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002430:	97ca                	add	a5,a5,s2
    80002432:	8e55                	or	a2,a2,a3
    80002434:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002438:	854a                	mv	a0,s2
    8000243a:	689000ef          	jal	ra,800032c2 <log_write>
        brelse(bp);
    8000243e:	854a                	mv	a0,s2
    80002440:	e59ff0ef          	jal	ra,80002298 <brelse>
  bp = bread(dev, bno);
    80002444:	85a6                	mv	a1,s1
    80002446:	855e                	mv	a0,s7
    80002448:	d49ff0ef          	jal	ra,80002190 <bread>
    8000244c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000244e:	40000613          	li	a2,1024
    80002452:	4581                	li	a1,0
    80002454:	05850513          	addi	a0,a0,88
    80002458:	e5bfd0ef          	jal	ra,800002b2 <memset>
  log_write(bp);
    8000245c:	854a                	mv	a0,s2
    8000245e:	665000ef          	jal	ra,800032c2 <log_write>
  brelse(bp);
    80002462:	854a                	mv	a0,s2
    80002464:	e35ff0ef          	jal	ra,80002298 <brelse>
}
    80002468:	8526                	mv	a0,s1
    8000246a:	60e6                	ld	ra,88(sp)
    8000246c:	6446                	ld	s0,80(sp)
    8000246e:	64a6                	ld	s1,72(sp)
    80002470:	6906                	ld	s2,64(sp)
    80002472:	79e2                	ld	s3,56(sp)
    80002474:	7a42                	ld	s4,48(sp)
    80002476:	7aa2                	ld	s5,40(sp)
    80002478:	7b02                	ld	s6,32(sp)
    8000247a:	6be2                	ld	s7,24(sp)
    8000247c:	6c42                	ld	s8,16(sp)
    8000247e:	6ca2                	ld	s9,8(sp)
    80002480:	6125                	addi	sp,sp,96
    80002482:	8082                	ret
    brelse(bp);
    80002484:	854a                	mv	a0,s2
    80002486:	e13ff0ef          	jal	ra,80002298 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000248a:	015c87bb          	addw	a5,s9,s5
    8000248e:	00078a9b          	sext.w	s5,a5
    80002492:	004b2703          	lw	a4,4(s6)
    80002496:	04eaff63          	bgeu	s5,a4,800024f4 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    8000249a:	41fad79b          	sraiw	a5,s5,0x1f
    8000249e:	0137d79b          	srliw	a5,a5,0x13
    800024a2:	015787bb          	addw	a5,a5,s5
    800024a6:	40d7d79b          	sraiw	a5,a5,0xd
    800024aa:	01cb2583          	lw	a1,28(s6)
    800024ae:	9dbd                	addw	a1,a1,a5
    800024b0:	855e                	mv	a0,s7
    800024b2:	cdfff0ef          	jal	ra,80002190 <bread>
    800024b6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800024b8:	004b2503          	lw	a0,4(s6)
    800024bc:	000a849b          	sext.w	s1,s5
    800024c0:	8762                	mv	a4,s8
    800024c2:	fca4f1e3          	bgeu	s1,a0,80002484 <balloc+0x8e>
      m = 1 << (bi % 8);
    800024c6:	00777693          	andi	a3,a4,7
    800024ca:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800024ce:	41f7579b          	sraiw	a5,a4,0x1f
    800024d2:	01d7d79b          	srliw	a5,a5,0x1d
    800024d6:	9fb9                	addw	a5,a5,a4
    800024d8:	4037d79b          	sraiw	a5,a5,0x3
    800024dc:	00f90633          	add	a2,s2,a5
    800024e0:	05864603          	lbu	a2,88(a2)
    800024e4:	00c6f5b3          	and	a1,a3,a2
    800024e8:	d5a1                	beqz	a1,80002430 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800024ea:	2705                	addiw	a4,a4,1
    800024ec:	2485                	addiw	s1,s1,1
    800024ee:	fd471ae3          	bne	a4,s4,800024c2 <balloc+0xcc>
    800024f2:	bf49                	j	80002484 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    800024f4:	00005517          	auipc	a0,0x5
    800024f8:	15c50513          	addi	a0,a0,348 # 80007650 <syscalls+0x168>
    800024fc:	573020ef          	jal	ra,8000526e <printf>
  return 0;
    80002500:	4481                	li	s1,0
    80002502:	b79d                	j	80002468 <balloc+0x72>

0000000080002504 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002504:	7179                	addi	sp,sp,-48
    80002506:	f406                	sd	ra,40(sp)
    80002508:	f022                	sd	s0,32(sp)
    8000250a:	ec26                	sd	s1,24(sp)
    8000250c:	e84a                	sd	s2,16(sp)
    8000250e:	e44e                	sd	s3,8(sp)
    80002510:	e052                	sd	s4,0(sp)
    80002512:	1800                	addi	s0,sp,48
    80002514:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002516:	47ad                	li	a5,11
    80002518:	02b7e663          	bltu	a5,a1,80002544 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    8000251c:	02059793          	slli	a5,a1,0x20
    80002520:	01e7d593          	srli	a1,a5,0x1e
    80002524:	00b504b3          	add	s1,a0,a1
    80002528:	0504a903          	lw	s2,80(s1)
    8000252c:	06091663          	bnez	s2,80002598 <bmap+0x94>
      addr = balloc(ip->dev);
    80002530:	4108                	lw	a0,0(a0)
    80002532:	ec5ff0ef          	jal	ra,800023f6 <balloc>
    80002536:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000253a:	04090f63          	beqz	s2,80002598 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    8000253e:	0524a823          	sw	s2,80(s1)
    80002542:	a899                	j	80002598 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002544:	ff45849b          	addiw	s1,a1,-12
    80002548:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000254c:	0ff00793          	li	a5,255
    80002550:	06e7eb63          	bltu	a5,a4,800025c6 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002554:	08052903          	lw	s2,128(a0)
    80002558:	00091b63          	bnez	s2,8000256e <bmap+0x6a>
      addr = balloc(ip->dev);
    8000255c:	4108                	lw	a0,0(a0)
    8000255e:	e99ff0ef          	jal	ra,800023f6 <balloc>
    80002562:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002566:	02090963          	beqz	s2,80002598 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000256a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000256e:	85ca                	mv	a1,s2
    80002570:	0009a503          	lw	a0,0(s3)
    80002574:	c1dff0ef          	jal	ra,80002190 <bread>
    80002578:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000257a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000257e:	02049713          	slli	a4,s1,0x20
    80002582:	01e75593          	srli	a1,a4,0x1e
    80002586:	00b784b3          	add	s1,a5,a1
    8000258a:	0004a903          	lw	s2,0(s1)
    8000258e:	00090e63          	beqz	s2,800025aa <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002592:	8552                	mv	a0,s4
    80002594:	d05ff0ef          	jal	ra,80002298 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002598:	854a                	mv	a0,s2
    8000259a:	70a2                	ld	ra,40(sp)
    8000259c:	7402                	ld	s0,32(sp)
    8000259e:	64e2                	ld	s1,24(sp)
    800025a0:	6942                	ld	s2,16(sp)
    800025a2:	69a2                	ld	s3,8(sp)
    800025a4:	6a02                	ld	s4,0(sp)
    800025a6:	6145                	addi	sp,sp,48
    800025a8:	8082                	ret
      addr = balloc(ip->dev);
    800025aa:	0009a503          	lw	a0,0(s3)
    800025ae:	e49ff0ef          	jal	ra,800023f6 <balloc>
    800025b2:	0005091b          	sext.w	s2,a0
      if(addr){
    800025b6:	fc090ee3          	beqz	s2,80002592 <bmap+0x8e>
        a[bn] = addr;
    800025ba:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800025be:	8552                	mv	a0,s4
    800025c0:	503000ef          	jal	ra,800032c2 <log_write>
    800025c4:	b7f9                	j	80002592 <bmap+0x8e>
  panic("bmap: out of range");
    800025c6:	00005517          	auipc	a0,0x5
    800025ca:	0a250513          	addi	a0,a0,162 # 80007668 <syscalls+0x180>
    800025ce:	755020ef          	jal	ra,80005522 <panic>

00000000800025d2 <iget>:
{
    800025d2:	7179                	addi	sp,sp,-48
    800025d4:	f406                	sd	ra,40(sp)
    800025d6:	f022                	sd	s0,32(sp)
    800025d8:	ec26                	sd	s1,24(sp)
    800025da:	e84a                	sd	s2,16(sp)
    800025dc:	e44e                	sd	s3,8(sp)
    800025de:	e052                	sd	s4,0(sp)
    800025e0:	1800                	addi	s0,sp,48
    800025e2:	89aa                	mv	s3,a0
    800025e4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800025e6:	00014517          	auipc	a0,0x14
    800025ea:	bc250513          	addi	a0,a0,-1086 # 800161a8 <itable>
    800025ee:	244030ef          	jal	ra,80005832 <acquire>
  empty = 0;
    800025f2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800025f4:	00014497          	auipc	s1,0x14
    800025f8:	bcc48493          	addi	s1,s1,-1076 # 800161c0 <itable+0x18>
    800025fc:	00015697          	auipc	a3,0x15
    80002600:	65468693          	addi	a3,a3,1620 # 80017c50 <log>
    80002604:	a039                	j	80002612 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002606:	02090963          	beqz	s2,80002638 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000260a:	08848493          	addi	s1,s1,136
    8000260e:	02d48863          	beq	s1,a3,8000263e <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002612:	449c                	lw	a5,8(s1)
    80002614:	fef059e3          	blez	a5,80002606 <iget+0x34>
    80002618:	4098                	lw	a4,0(s1)
    8000261a:	ff3716e3          	bne	a4,s3,80002606 <iget+0x34>
    8000261e:	40d8                	lw	a4,4(s1)
    80002620:	ff4713e3          	bne	a4,s4,80002606 <iget+0x34>
      ip->ref++;
    80002624:	2785                	addiw	a5,a5,1
    80002626:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002628:	00014517          	auipc	a0,0x14
    8000262c:	b8050513          	addi	a0,a0,-1152 # 800161a8 <itable>
    80002630:	29a030ef          	jal	ra,800058ca <release>
      return ip;
    80002634:	8926                	mv	s2,s1
    80002636:	a02d                	j	80002660 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002638:	fbe9                	bnez	a5,8000260a <iget+0x38>
    8000263a:	8926                	mv	s2,s1
    8000263c:	b7f9                	j	8000260a <iget+0x38>
  if(empty == 0)
    8000263e:	02090a63          	beqz	s2,80002672 <iget+0xa0>
  ip->dev = dev;
    80002642:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002646:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000264a:	4785                	li	a5,1
    8000264c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002650:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002654:	00014517          	auipc	a0,0x14
    80002658:	b5450513          	addi	a0,a0,-1196 # 800161a8 <itable>
    8000265c:	26e030ef          	jal	ra,800058ca <release>
}
    80002660:	854a                	mv	a0,s2
    80002662:	70a2                	ld	ra,40(sp)
    80002664:	7402                	ld	s0,32(sp)
    80002666:	64e2                	ld	s1,24(sp)
    80002668:	6942                	ld	s2,16(sp)
    8000266a:	69a2                	ld	s3,8(sp)
    8000266c:	6a02                	ld	s4,0(sp)
    8000266e:	6145                	addi	sp,sp,48
    80002670:	8082                	ret
    panic("iget: no inodes");
    80002672:	00005517          	auipc	a0,0x5
    80002676:	00e50513          	addi	a0,a0,14 # 80007680 <syscalls+0x198>
    8000267a:	6a9020ef          	jal	ra,80005522 <panic>

000000008000267e <fsinit>:
fsinit(int dev) {
    8000267e:	7179                	addi	sp,sp,-48
    80002680:	f406                	sd	ra,40(sp)
    80002682:	f022                	sd	s0,32(sp)
    80002684:	ec26                	sd	s1,24(sp)
    80002686:	e84a                	sd	s2,16(sp)
    80002688:	e44e                	sd	s3,8(sp)
    8000268a:	1800                	addi	s0,sp,48
    8000268c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000268e:	4585                	li	a1,1
    80002690:	b01ff0ef          	jal	ra,80002190 <bread>
    80002694:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002696:	00014997          	auipc	s3,0x14
    8000269a:	af298993          	addi	s3,s3,-1294 # 80016188 <sb>
    8000269e:	02000613          	li	a2,32
    800026a2:	05850593          	addi	a1,a0,88
    800026a6:	854e                	mv	a0,s3
    800026a8:	c67fd0ef          	jal	ra,8000030e <memmove>
  brelse(bp);
    800026ac:	8526                	mv	a0,s1
    800026ae:	bebff0ef          	jal	ra,80002298 <brelse>
  if(sb.magic != FSMAGIC)
    800026b2:	0009a703          	lw	a4,0(s3)
    800026b6:	102037b7          	lui	a5,0x10203
    800026ba:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800026be:	02f71063          	bne	a4,a5,800026de <fsinit+0x60>
  initlog(dev, &sb);
    800026c2:	00014597          	auipc	a1,0x14
    800026c6:	ac658593          	addi	a1,a1,-1338 # 80016188 <sb>
    800026ca:	854a                	mv	a0,s2
    800026cc:	1e3000ef          	jal	ra,800030ae <initlog>
}
    800026d0:	70a2                	ld	ra,40(sp)
    800026d2:	7402                	ld	s0,32(sp)
    800026d4:	64e2                	ld	s1,24(sp)
    800026d6:	6942                	ld	s2,16(sp)
    800026d8:	69a2                	ld	s3,8(sp)
    800026da:	6145                	addi	sp,sp,48
    800026dc:	8082                	ret
    panic("invalid file system");
    800026de:	00005517          	auipc	a0,0x5
    800026e2:	fb250513          	addi	a0,a0,-78 # 80007690 <syscalls+0x1a8>
    800026e6:	63d020ef          	jal	ra,80005522 <panic>

00000000800026ea <iinit>:
{
    800026ea:	7179                	addi	sp,sp,-48
    800026ec:	f406                	sd	ra,40(sp)
    800026ee:	f022                	sd	s0,32(sp)
    800026f0:	ec26                	sd	s1,24(sp)
    800026f2:	e84a                	sd	s2,16(sp)
    800026f4:	e44e                	sd	s3,8(sp)
    800026f6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800026f8:	00005597          	auipc	a1,0x5
    800026fc:	fb058593          	addi	a1,a1,-80 # 800076a8 <syscalls+0x1c0>
    80002700:	00014517          	auipc	a0,0x14
    80002704:	aa850513          	addi	a0,a0,-1368 # 800161a8 <itable>
    80002708:	0aa030ef          	jal	ra,800057b2 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000270c:	00014497          	auipc	s1,0x14
    80002710:	ac448493          	addi	s1,s1,-1340 # 800161d0 <itable+0x28>
    80002714:	00015997          	auipc	s3,0x15
    80002718:	54c98993          	addi	s3,s3,1356 # 80017c60 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000271c:	00005917          	auipc	s2,0x5
    80002720:	f9490913          	addi	s2,s2,-108 # 800076b0 <syscalls+0x1c8>
    80002724:	85ca                	mv	a1,s2
    80002726:	8526                	mv	a0,s1
    80002728:	46b000ef          	jal	ra,80003392 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000272c:	08848493          	addi	s1,s1,136
    80002730:	ff349ae3          	bne	s1,s3,80002724 <iinit+0x3a>
}
    80002734:	70a2                	ld	ra,40(sp)
    80002736:	7402                	ld	s0,32(sp)
    80002738:	64e2                	ld	s1,24(sp)
    8000273a:	6942                	ld	s2,16(sp)
    8000273c:	69a2                	ld	s3,8(sp)
    8000273e:	6145                	addi	sp,sp,48
    80002740:	8082                	ret

0000000080002742 <ialloc>:
{
    80002742:	715d                	addi	sp,sp,-80
    80002744:	e486                	sd	ra,72(sp)
    80002746:	e0a2                	sd	s0,64(sp)
    80002748:	fc26                	sd	s1,56(sp)
    8000274a:	f84a                	sd	s2,48(sp)
    8000274c:	f44e                	sd	s3,40(sp)
    8000274e:	f052                	sd	s4,32(sp)
    80002750:	ec56                	sd	s5,24(sp)
    80002752:	e85a                	sd	s6,16(sp)
    80002754:	e45e                	sd	s7,8(sp)
    80002756:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002758:	00014717          	auipc	a4,0x14
    8000275c:	a3c72703          	lw	a4,-1476(a4) # 80016194 <sb+0xc>
    80002760:	4785                	li	a5,1
    80002762:	04e7f663          	bgeu	a5,a4,800027ae <ialloc+0x6c>
    80002766:	8aaa                	mv	s5,a0
    80002768:	8bae                	mv	s7,a1
    8000276a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000276c:	00014a17          	auipc	s4,0x14
    80002770:	a1ca0a13          	addi	s4,s4,-1508 # 80016188 <sb>
    80002774:	00048b1b          	sext.w	s6,s1
    80002778:	0044d593          	srli	a1,s1,0x4
    8000277c:	018a2783          	lw	a5,24(s4)
    80002780:	9dbd                	addw	a1,a1,a5
    80002782:	8556                	mv	a0,s5
    80002784:	a0dff0ef          	jal	ra,80002190 <bread>
    80002788:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000278a:	05850993          	addi	s3,a0,88
    8000278e:	00f4f793          	andi	a5,s1,15
    80002792:	079a                	slli	a5,a5,0x6
    80002794:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002796:	00099783          	lh	a5,0(s3)
    8000279a:	cf85                	beqz	a5,800027d2 <ialloc+0x90>
    brelse(bp);
    8000279c:	afdff0ef          	jal	ra,80002298 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800027a0:	0485                	addi	s1,s1,1
    800027a2:	00ca2703          	lw	a4,12(s4)
    800027a6:	0004879b          	sext.w	a5,s1
    800027aa:	fce7e5e3          	bltu	a5,a4,80002774 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800027ae:	00005517          	auipc	a0,0x5
    800027b2:	f0a50513          	addi	a0,a0,-246 # 800076b8 <syscalls+0x1d0>
    800027b6:	2b9020ef          	jal	ra,8000526e <printf>
  return 0;
    800027ba:	4501                	li	a0,0
}
    800027bc:	60a6                	ld	ra,72(sp)
    800027be:	6406                	ld	s0,64(sp)
    800027c0:	74e2                	ld	s1,56(sp)
    800027c2:	7942                	ld	s2,48(sp)
    800027c4:	79a2                	ld	s3,40(sp)
    800027c6:	7a02                	ld	s4,32(sp)
    800027c8:	6ae2                	ld	s5,24(sp)
    800027ca:	6b42                	ld	s6,16(sp)
    800027cc:	6ba2                	ld	s7,8(sp)
    800027ce:	6161                	addi	sp,sp,80
    800027d0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800027d2:	04000613          	li	a2,64
    800027d6:	4581                	li	a1,0
    800027d8:	854e                	mv	a0,s3
    800027da:	ad9fd0ef          	jal	ra,800002b2 <memset>
      dip->type = type;
    800027de:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800027e2:	854a                	mv	a0,s2
    800027e4:	2df000ef          	jal	ra,800032c2 <log_write>
      brelse(bp);
    800027e8:	854a                	mv	a0,s2
    800027ea:	aafff0ef          	jal	ra,80002298 <brelse>
      return iget(dev, inum);
    800027ee:	85da                	mv	a1,s6
    800027f0:	8556                	mv	a0,s5
    800027f2:	de1ff0ef          	jal	ra,800025d2 <iget>
    800027f6:	b7d9                	j	800027bc <ialloc+0x7a>

00000000800027f8 <iupdate>:
{
    800027f8:	1101                	addi	sp,sp,-32
    800027fa:	ec06                	sd	ra,24(sp)
    800027fc:	e822                	sd	s0,16(sp)
    800027fe:	e426                	sd	s1,8(sp)
    80002800:	e04a                	sd	s2,0(sp)
    80002802:	1000                	addi	s0,sp,32
    80002804:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002806:	415c                	lw	a5,4(a0)
    80002808:	0047d79b          	srliw	a5,a5,0x4
    8000280c:	00014597          	auipc	a1,0x14
    80002810:	9945a583          	lw	a1,-1644(a1) # 800161a0 <sb+0x18>
    80002814:	9dbd                	addw	a1,a1,a5
    80002816:	4108                	lw	a0,0(a0)
    80002818:	979ff0ef          	jal	ra,80002190 <bread>
    8000281c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000281e:	05850793          	addi	a5,a0,88
    80002822:	40d8                	lw	a4,4(s1)
    80002824:	8b3d                	andi	a4,a4,15
    80002826:	071a                	slli	a4,a4,0x6
    80002828:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000282a:	04449703          	lh	a4,68(s1)
    8000282e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002832:	04649703          	lh	a4,70(s1)
    80002836:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000283a:	04849703          	lh	a4,72(s1)
    8000283e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002842:	04a49703          	lh	a4,74(s1)
    80002846:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000284a:	44f8                	lw	a4,76(s1)
    8000284c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000284e:	03400613          	li	a2,52
    80002852:	05048593          	addi	a1,s1,80
    80002856:	00c78513          	addi	a0,a5,12
    8000285a:	ab5fd0ef          	jal	ra,8000030e <memmove>
  log_write(bp);
    8000285e:	854a                	mv	a0,s2
    80002860:	263000ef          	jal	ra,800032c2 <log_write>
  brelse(bp);
    80002864:	854a                	mv	a0,s2
    80002866:	a33ff0ef          	jal	ra,80002298 <brelse>
}
    8000286a:	60e2                	ld	ra,24(sp)
    8000286c:	6442                	ld	s0,16(sp)
    8000286e:	64a2                	ld	s1,8(sp)
    80002870:	6902                	ld	s2,0(sp)
    80002872:	6105                	addi	sp,sp,32
    80002874:	8082                	ret

0000000080002876 <idup>:
{
    80002876:	1101                	addi	sp,sp,-32
    80002878:	ec06                	sd	ra,24(sp)
    8000287a:	e822                	sd	s0,16(sp)
    8000287c:	e426                	sd	s1,8(sp)
    8000287e:	1000                	addi	s0,sp,32
    80002880:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002882:	00014517          	auipc	a0,0x14
    80002886:	92650513          	addi	a0,a0,-1754 # 800161a8 <itable>
    8000288a:	7a9020ef          	jal	ra,80005832 <acquire>
  ip->ref++;
    8000288e:	449c                	lw	a5,8(s1)
    80002890:	2785                	addiw	a5,a5,1
    80002892:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002894:	00014517          	auipc	a0,0x14
    80002898:	91450513          	addi	a0,a0,-1772 # 800161a8 <itable>
    8000289c:	02e030ef          	jal	ra,800058ca <release>
}
    800028a0:	8526                	mv	a0,s1
    800028a2:	60e2                	ld	ra,24(sp)
    800028a4:	6442                	ld	s0,16(sp)
    800028a6:	64a2                	ld	s1,8(sp)
    800028a8:	6105                	addi	sp,sp,32
    800028aa:	8082                	ret

00000000800028ac <ilock>:
{
    800028ac:	1101                	addi	sp,sp,-32
    800028ae:	ec06                	sd	ra,24(sp)
    800028b0:	e822                	sd	s0,16(sp)
    800028b2:	e426                	sd	s1,8(sp)
    800028b4:	e04a                	sd	s2,0(sp)
    800028b6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800028b8:	c105                	beqz	a0,800028d8 <ilock+0x2c>
    800028ba:	84aa                	mv	s1,a0
    800028bc:	451c                	lw	a5,8(a0)
    800028be:	00f05d63          	blez	a5,800028d8 <ilock+0x2c>
  acquiresleep(&ip->lock);
    800028c2:	0541                	addi	a0,a0,16
    800028c4:	305000ef          	jal	ra,800033c8 <acquiresleep>
  if(ip->valid == 0){
    800028c8:	40bc                	lw	a5,64(s1)
    800028ca:	cf89                	beqz	a5,800028e4 <ilock+0x38>
}
    800028cc:	60e2                	ld	ra,24(sp)
    800028ce:	6442                	ld	s0,16(sp)
    800028d0:	64a2                	ld	s1,8(sp)
    800028d2:	6902                	ld	s2,0(sp)
    800028d4:	6105                	addi	sp,sp,32
    800028d6:	8082                	ret
    panic("ilock");
    800028d8:	00005517          	auipc	a0,0x5
    800028dc:	df850513          	addi	a0,a0,-520 # 800076d0 <syscalls+0x1e8>
    800028e0:	443020ef          	jal	ra,80005522 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800028e4:	40dc                	lw	a5,4(s1)
    800028e6:	0047d79b          	srliw	a5,a5,0x4
    800028ea:	00014597          	auipc	a1,0x14
    800028ee:	8b65a583          	lw	a1,-1866(a1) # 800161a0 <sb+0x18>
    800028f2:	9dbd                	addw	a1,a1,a5
    800028f4:	4088                	lw	a0,0(s1)
    800028f6:	89bff0ef          	jal	ra,80002190 <bread>
    800028fa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800028fc:	05850593          	addi	a1,a0,88
    80002900:	40dc                	lw	a5,4(s1)
    80002902:	8bbd                	andi	a5,a5,15
    80002904:	079a                	slli	a5,a5,0x6
    80002906:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002908:	00059783          	lh	a5,0(a1)
    8000290c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002910:	00259783          	lh	a5,2(a1)
    80002914:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002918:	00459783          	lh	a5,4(a1)
    8000291c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002920:	00659783          	lh	a5,6(a1)
    80002924:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002928:	459c                	lw	a5,8(a1)
    8000292a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000292c:	03400613          	li	a2,52
    80002930:	05b1                	addi	a1,a1,12
    80002932:	05048513          	addi	a0,s1,80
    80002936:	9d9fd0ef          	jal	ra,8000030e <memmove>
    brelse(bp);
    8000293a:	854a                	mv	a0,s2
    8000293c:	95dff0ef          	jal	ra,80002298 <brelse>
    ip->valid = 1;
    80002940:	4785                	li	a5,1
    80002942:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002944:	04449783          	lh	a5,68(s1)
    80002948:	f3d1                	bnez	a5,800028cc <ilock+0x20>
      panic("ilock: no type");
    8000294a:	00005517          	auipc	a0,0x5
    8000294e:	d8e50513          	addi	a0,a0,-626 # 800076d8 <syscalls+0x1f0>
    80002952:	3d1020ef          	jal	ra,80005522 <panic>

0000000080002956 <iunlock>:
{
    80002956:	1101                	addi	sp,sp,-32
    80002958:	ec06                	sd	ra,24(sp)
    8000295a:	e822                	sd	s0,16(sp)
    8000295c:	e426                	sd	s1,8(sp)
    8000295e:	e04a                	sd	s2,0(sp)
    80002960:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002962:	c505                	beqz	a0,8000298a <iunlock+0x34>
    80002964:	84aa                	mv	s1,a0
    80002966:	01050913          	addi	s2,a0,16
    8000296a:	854a                	mv	a0,s2
    8000296c:	2db000ef          	jal	ra,80003446 <holdingsleep>
    80002970:	cd09                	beqz	a0,8000298a <iunlock+0x34>
    80002972:	449c                	lw	a5,8(s1)
    80002974:	00f05b63          	blez	a5,8000298a <iunlock+0x34>
  releasesleep(&ip->lock);
    80002978:	854a                	mv	a0,s2
    8000297a:	295000ef          	jal	ra,8000340e <releasesleep>
}
    8000297e:	60e2                	ld	ra,24(sp)
    80002980:	6442                	ld	s0,16(sp)
    80002982:	64a2                	ld	s1,8(sp)
    80002984:	6902                	ld	s2,0(sp)
    80002986:	6105                	addi	sp,sp,32
    80002988:	8082                	ret
    panic("iunlock");
    8000298a:	00005517          	auipc	a0,0x5
    8000298e:	d5e50513          	addi	a0,a0,-674 # 800076e8 <syscalls+0x200>
    80002992:	391020ef          	jal	ra,80005522 <panic>

0000000080002996 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002996:	7179                	addi	sp,sp,-48
    80002998:	f406                	sd	ra,40(sp)
    8000299a:	f022                	sd	s0,32(sp)
    8000299c:	ec26                	sd	s1,24(sp)
    8000299e:	e84a                	sd	s2,16(sp)
    800029a0:	e44e                	sd	s3,8(sp)
    800029a2:	e052                	sd	s4,0(sp)
    800029a4:	1800                	addi	s0,sp,48
    800029a6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800029a8:	05050493          	addi	s1,a0,80
    800029ac:	08050913          	addi	s2,a0,128
    800029b0:	a021                	j	800029b8 <itrunc+0x22>
    800029b2:	0491                	addi	s1,s1,4
    800029b4:	01248b63          	beq	s1,s2,800029ca <itrunc+0x34>
    if(ip->addrs[i]){
    800029b8:	408c                	lw	a1,0(s1)
    800029ba:	dde5                	beqz	a1,800029b2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800029bc:	0009a503          	lw	a0,0(s3)
    800029c0:	9cbff0ef          	jal	ra,8000238a <bfree>
      ip->addrs[i] = 0;
    800029c4:	0004a023          	sw	zero,0(s1)
    800029c8:	b7ed                	j	800029b2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800029ca:	0809a583          	lw	a1,128(s3)
    800029ce:	ed91                	bnez	a1,800029ea <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800029d0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800029d4:	854e                	mv	a0,s3
    800029d6:	e23ff0ef          	jal	ra,800027f8 <iupdate>
}
    800029da:	70a2                	ld	ra,40(sp)
    800029dc:	7402                	ld	s0,32(sp)
    800029de:	64e2                	ld	s1,24(sp)
    800029e0:	6942                	ld	s2,16(sp)
    800029e2:	69a2                	ld	s3,8(sp)
    800029e4:	6a02                	ld	s4,0(sp)
    800029e6:	6145                	addi	sp,sp,48
    800029e8:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800029ea:	0009a503          	lw	a0,0(s3)
    800029ee:	fa2ff0ef          	jal	ra,80002190 <bread>
    800029f2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800029f4:	05850493          	addi	s1,a0,88
    800029f8:	45850913          	addi	s2,a0,1112
    800029fc:	a021                	j	80002a04 <itrunc+0x6e>
    800029fe:	0491                	addi	s1,s1,4
    80002a00:	01248963          	beq	s1,s2,80002a12 <itrunc+0x7c>
      if(a[j])
    80002a04:	408c                	lw	a1,0(s1)
    80002a06:	dde5                	beqz	a1,800029fe <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80002a08:	0009a503          	lw	a0,0(s3)
    80002a0c:	97fff0ef          	jal	ra,8000238a <bfree>
    80002a10:	b7fd                	j	800029fe <itrunc+0x68>
    brelse(bp);
    80002a12:	8552                	mv	a0,s4
    80002a14:	885ff0ef          	jal	ra,80002298 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002a18:	0809a583          	lw	a1,128(s3)
    80002a1c:	0009a503          	lw	a0,0(s3)
    80002a20:	96bff0ef          	jal	ra,8000238a <bfree>
    ip->addrs[NDIRECT] = 0;
    80002a24:	0809a023          	sw	zero,128(s3)
    80002a28:	b765                	j	800029d0 <itrunc+0x3a>

0000000080002a2a <iput>:
{
    80002a2a:	1101                	addi	sp,sp,-32
    80002a2c:	ec06                	sd	ra,24(sp)
    80002a2e:	e822                	sd	s0,16(sp)
    80002a30:	e426                	sd	s1,8(sp)
    80002a32:	e04a                	sd	s2,0(sp)
    80002a34:	1000                	addi	s0,sp,32
    80002a36:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002a38:	00013517          	auipc	a0,0x13
    80002a3c:	77050513          	addi	a0,a0,1904 # 800161a8 <itable>
    80002a40:	5f3020ef          	jal	ra,80005832 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a44:	4498                	lw	a4,8(s1)
    80002a46:	4785                	li	a5,1
    80002a48:	02f70163          	beq	a4,a5,80002a6a <iput+0x40>
  ip->ref--;
    80002a4c:	449c                	lw	a5,8(s1)
    80002a4e:	37fd                	addiw	a5,a5,-1
    80002a50:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002a52:	00013517          	auipc	a0,0x13
    80002a56:	75650513          	addi	a0,a0,1878 # 800161a8 <itable>
    80002a5a:	671020ef          	jal	ra,800058ca <release>
}
    80002a5e:	60e2                	ld	ra,24(sp)
    80002a60:	6442                	ld	s0,16(sp)
    80002a62:	64a2                	ld	s1,8(sp)
    80002a64:	6902                	ld	s2,0(sp)
    80002a66:	6105                	addi	sp,sp,32
    80002a68:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a6a:	40bc                	lw	a5,64(s1)
    80002a6c:	d3e5                	beqz	a5,80002a4c <iput+0x22>
    80002a6e:	04a49783          	lh	a5,74(s1)
    80002a72:	ffe9                	bnez	a5,80002a4c <iput+0x22>
    acquiresleep(&ip->lock);
    80002a74:	01048913          	addi	s2,s1,16
    80002a78:	854a                	mv	a0,s2
    80002a7a:	14f000ef          	jal	ra,800033c8 <acquiresleep>
    release(&itable.lock);
    80002a7e:	00013517          	auipc	a0,0x13
    80002a82:	72a50513          	addi	a0,a0,1834 # 800161a8 <itable>
    80002a86:	645020ef          	jal	ra,800058ca <release>
    itrunc(ip);
    80002a8a:	8526                	mv	a0,s1
    80002a8c:	f0bff0ef          	jal	ra,80002996 <itrunc>
    ip->type = 0;
    80002a90:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002a94:	8526                	mv	a0,s1
    80002a96:	d63ff0ef          	jal	ra,800027f8 <iupdate>
    ip->valid = 0;
    80002a9a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002a9e:	854a                	mv	a0,s2
    80002aa0:	16f000ef          	jal	ra,8000340e <releasesleep>
    acquire(&itable.lock);
    80002aa4:	00013517          	auipc	a0,0x13
    80002aa8:	70450513          	addi	a0,a0,1796 # 800161a8 <itable>
    80002aac:	587020ef          	jal	ra,80005832 <acquire>
    80002ab0:	bf71                	j	80002a4c <iput+0x22>

0000000080002ab2 <iunlockput>:
{
    80002ab2:	1101                	addi	sp,sp,-32
    80002ab4:	ec06                	sd	ra,24(sp)
    80002ab6:	e822                	sd	s0,16(sp)
    80002ab8:	e426                	sd	s1,8(sp)
    80002aba:	1000                	addi	s0,sp,32
    80002abc:	84aa                	mv	s1,a0
  iunlock(ip);
    80002abe:	e99ff0ef          	jal	ra,80002956 <iunlock>
  iput(ip);
    80002ac2:	8526                	mv	a0,s1
    80002ac4:	f67ff0ef          	jal	ra,80002a2a <iput>
}
    80002ac8:	60e2                	ld	ra,24(sp)
    80002aca:	6442                	ld	s0,16(sp)
    80002acc:	64a2                	ld	s1,8(sp)
    80002ace:	6105                	addi	sp,sp,32
    80002ad0:	8082                	ret

0000000080002ad2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002ad2:	1141                	addi	sp,sp,-16
    80002ad4:	e422                	sd	s0,8(sp)
    80002ad6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002ad8:	411c                	lw	a5,0(a0)
    80002ada:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002adc:	415c                	lw	a5,4(a0)
    80002ade:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002ae0:	04451783          	lh	a5,68(a0)
    80002ae4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002ae8:	04a51783          	lh	a5,74(a0)
    80002aec:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002af0:	04c56783          	lwu	a5,76(a0)
    80002af4:	e99c                	sd	a5,16(a1)
}
    80002af6:	6422                	ld	s0,8(sp)
    80002af8:	0141                	addi	sp,sp,16
    80002afa:	8082                	ret

0000000080002afc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002afc:	457c                	lw	a5,76(a0)
    80002afe:	0cd7ef63          	bltu	a5,a3,80002bdc <readi+0xe0>
{
    80002b02:	7159                	addi	sp,sp,-112
    80002b04:	f486                	sd	ra,104(sp)
    80002b06:	f0a2                	sd	s0,96(sp)
    80002b08:	eca6                	sd	s1,88(sp)
    80002b0a:	e8ca                	sd	s2,80(sp)
    80002b0c:	e4ce                	sd	s3,72(sp)
    80002b0e:	e0d2                	sd	s4,64(sp)
    80002b10:	fc56                	sd	s5,56(sp)
    80002b12:	f85a                	sd	s6,48(sp)
    80002b14:	f45e                	sd	s7,40(sp)
    80002b16:	f062                	sd	s8,32(sp)
    80002b18:	ec66                	sd	s9,24(sp)
    80002b1a:	e86a                	sd	s10,16(sp)
    80002b1c:	e46e                	sd	s11,8(sp)
    80002b1e:	1880                	addi	s0,sp,112
    80002b20:	8b2a                	mv	s6,a0
    80002b22:	8bae                	mv	s7,a1
    80002b24:	8a32                	mv	s4,a2
    80002b26:	84b6                	mv	s1,a3
    80002b28:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002b2a:	9f35                	addw	a4,a4,a3
    return 0;
    80002b2c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002b2e:	08d76663          	bltu	a4,a3,80002bba <readi+0xbe>
  if(off + n > ip->size)
    80002b32:	00e7f463          	bgeu	a5,a4,80002b3a <readi+0x3e>
    n = ip->size - off;
    80002b36:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b3a:	080a8f63          	beqz	s5,80002bd8 <readi+0xdc>
    80002b3e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b40:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002b44:	5c7d                	li	s8,-1
    80002b46:	a80d                	j	80002b78 <readi+0x7c>
    80002b48:	020d1d93          	slli	s11,s10,0x20
    80002b4c:	020ddd93          	srli	s11,s11,0x20
    80002b50:	05890613          	addi	a2,s2,88
    80002b54:	86ee                	mv	a3,s11
    80002b56:	963a                	add	a2,a2,a4
    80002b58:	85d2                	mv	a1,s4
    80002b5a:	855e                	mv	a0,s7
    80002b5c:	d6bfe0ef          	jal	ra,800018c6 <either_copyout>
    80002b60:	05850763          	beq	a0,s8,80002bae <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002b64:	854a                	mv	a0,s2
    80002b66:	f32ff0ef          	jal	ra,80002298 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b6a:	013d09bb          	addw	s3,s10,s3
    80002b6e:	009d04bb          	addw	s1,s10,s1
    80002b72:	9a6e                	add	s4,s4,s11
    80002b74:	0559f163          	bgeu	s3,s5,80002bb6 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80002b78:	00a4d59b          	srliw	a1,s1,0xa
    80002b7c:	855a                	mv	a0,s6
    80002b7e:	987ff0ef          	jal	ra,80002504 <bmap>
    80002b82:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002b86:	c985                	beqz	a1,80002bb6 <readi+0xba>
    bp = bread(ip->dev, addr);
    80002b88:	000b2503          	lw	a0,0(s6)
    80002b8c:	e04ff0ef          	jal	ra,80002190 <bread>
    80002b90:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b92:	3ff4f713          	andi	a4,s1,1023
    80002b96:	40ec87bb          	subw	a5,s9,a4
    80002b9a:	413a86bb          	subw	a3,s5,s3
    80002b9e:	8d3e                	mv	s10,a5
    80002ba0:	2781                	sext.w	a5,a5
    80002ba2:	0006861b          	sext.w	a2,a3
    80002ba6:	faf671e3          	bgeu	a2,a5,80002b48 <readi+0x4c>
    80002baa:	8d36                	mv	s10,a3
    80002bac:	bf71                	j	80002b48 <readi+0x4c>
      brelse(bp);
    80002bae:	854a                	mv	a0,s2
    80002bb0:	ee8ff0ef          	jal	ra,80002298 <brelse>
      tot = -1;
    80002bb4:	59fd                	li	s3,-1
  }
  return tot;
    80002bb6:	0009851b          	sext.w	a0,s3
}
    80002bba:	70a6                	ld	ra,104(sp)
    80002bbc:	7406                	ld	s0,96(sp)
    80002bbe:	64e6                	ld	s1,88(sp)
    80002bc0:	6946                	ld	s2,80(sp)
    80002bc2:	69a6                	ld	s3,72(sp)
    80002bc4:	6a06                	ld	s4,64(sp)
    80002bc6:	7ae2                	ld	s5,56(sp)
    80002bc8:	7b42                	ld	s6,48(sp)
    80002bca:	7ba2                	ld	s7,40(sp)
    80002bcc:	7c02                	ld	s8,32(sp)
    80002bce:	6ce2                	ld	s9,24(sp)
    80002bd0:	6d42                	ld	s10,16(sp)
    80002bd2:	6da2                	ld	s11,8(sp)
    80002bd4:	6165                	addi	sp,sp,112
    80002bd6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002bd8:	89d6                	mv	s3,s5
    80002bda:	bff1                	j	80002bb6 <readi+0xba>
    return 0;
    80002bdc:	4501                	li	a0,0
}
    80002bde:	8082                	ret

0000000080002be0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002be0:	457c                	lw	a5,76(a0)
    80002be2:	0ed7ea63          	bltu	a5,a3,80002cd6 <writei+0xf6>
{
    80002be6:	7159                	addi	sp,sp,-112
    80002be8:	f486                	sd	ra,104(sp)
    80002bea:	f0a2                	sd	s0,96(sp)
    80002bec:	eca6                	sd	s1,88(sp)
    80002bee:	e8ca                	sd	s2,80(sp)
    80002bf0:	e4ce                	sd	s3,72(sp)
    80002bf2:	e0d2                	sd	s4,64(sp)
    80002bf4:	fc56                	sd	s5,56(sp)
    80002bf6:	f85a                	sd	s6,48(sp)
    80002bf8:	f45e                	sd	s7,40(sp)
    80002bfa:	f062                	sd	s8,32(sp)
    80002bfc:	ec66                	sd	s9,24(sp)
    80002bfe:	e86a                	sd	s10,16(sp)
    80002c00:	e46e                	sd	s11,8(sp)
    80002c02:	1880                	addi	s0,sp,112
    80002c04:	8aaa                	mv	s5,a0
    80002c06:	8bae                	mv	s7,a1
    80002c08:	8a32                	mv	s4,a2
    80002c0a:	8936                	mv	s2,a3
    80002c0c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002c0e:	00e687bb          	addw	a5,a3,a4
    80002c12:	0cd7e463          	bltu	a5,a3,80002cda <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002c16:	00043737          	lui	a4,0x43
    80002c1a:	0cf76263          	bltu	a4,a5,80002cde <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c1e:	0a0b0a63          	beqz	s6,80002cd2 <writei+0xf2>
    80002c22:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c24:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002c28:	5c7d                	li	s8,-1
    80002c2a:	a825                	j	80002c62 <writei+0x82>
    80002c2c:	020d1d93          	slli	s11,s10,0x20
    80002c30:	020ddd93          	srli	s11,s11,0x20
    80002c34:	05848513          	addi	a0,s1,88
    80002c38:	86ee                	mv	a3,s11
    80002c3a:	8652                	mv	a2,s4
    80002c3c:	85de                	mv	a1,s7
    80002c3e:	953a                	add	a0,a0,a4
    80002c40:	cd1fe0ef          	jal	ra,80001910 <either_copyin>
    80002c44:	05850a63          	beq	a0,s8,80002c98 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002c48:	8526                	mv	a0,s1
    80002c4a:	678000ef          	jal	ra,800032c2 <log_write>
    brelse(bp);
    80002c4e:	8526                	mv	a0,s1
    80002c50:	e48ff0ef          	jal	ra,80002298 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c54:	013d09bb          	addw	s3,s10,s3
    80002c58:	012d093b          	addw	s2,s10,s2
    80002c5c:	9a6e                	add	s4,s4,s11
    80002c5e:	0569f063          	bgeu	s3,s6,80002c9e <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002c62:	00a9559b          	srliw	a1,s2,0xa
    80002c66:	8556                	mv	a0,s5
    80002c68:	89dff0ef          	jal	ra,80002504 <bmap>
    80002c6c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002c70:	c59d                	beqz	a1,80002c9e <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002c72:	000aa503          	lw	a0,0(s5)
    80002c76:	d1aff0ef          	jal	ra,80002190 <bread>
    80002c7a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c7c:	3ff97713          	andi	a4,s2,1023
    80002c80:	40ec87bb          	subw	a5,s9,a4
    80002c84:	413b06bb          	subw	a3,s6,s3
    80002c88:	8d3e                	mv	s10,a5
    80002c8a:	2781                	sext.w	a5,a5
    80002c8c:	0006861b          	sext.w	a2,a3
    80002c90:	f8f67ee3          	bgeu	a2,a5,80002c2c <writei+0x4c>
    80002c94:	8d36                	mv	s10,a3
    80002c96:	bf59                	j	80002c2c <writei+0x4c>
      brelse(bp);
    80002c98:	8526                	mv	a0,s1
    80002c9a:	dfeff0ef          	jal	ra,80002298 <brelse>
  }

  if(off > ip->size)
    80002c9e:	04caa783          	lw	a5,76(s5)
    80002ca2:	0127f463          	bgeu	a5,s2,80002caa <writei+0xca>
    ip->size = off;
    80002ca6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002caa:	8556                	mv	a0,s5
    80002cac:	b4dff0ef          	jal	ra,800027f8 <iupdate>

  return tot;
    80002cb0:	0009851b          	sext.w	a0,s3
}
    80002cb4:	70a6                	ld	ra,104(sp)
    80002cb6:	7406                	ld	s0,96(sp)
    80002cb8:	64e6                	ld	s1,88(sp)
    80002cba:	6946                	ld	s2,80(sp)
    80002cbc:	69a6                	ld	s3,72(sp)
    80002cbe:	6a06                	ld	s4,64(sp)
    80002cc0:	7ae2                	ld	s5,56(sp)
    80002cc2:	7b42                	ld	s6,48(sp)
    80002cc4:	7ba2                	ld	s7,40(sp)
    80002cc6:	7c02                	ld	s8,32(sp)
    80002cc8:	6ce2                	ld	s9,24(sp)
    80002cca:	6d42                	ld	s10,16(sp)
    80002ccc:	6da2                	ld	s11,8(sp)
    80002cce:	6165                	addi	sp,sp,112
    80002cd0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002cd2:	89da                	mv	s3,s6
    80002cd4:	bfd9                	j	80002caa <writei+0xca>
    return -1;
    80002cd6:	557d                	li	a0,-1
}
    80002cd8:	8082                	ret
    return -1;
    80002cda:	557d                	li	a0,-1
    80002cdc:	bfe1                	j	80002cb4 <writei+0xd4>
    return -1;
    80002cde:	557d                	li	a0,-1
    80002ce0:	bfd1                	j	80002cb4 <writei+0xd4>

0000000080002ce2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002ce2:	1141                	addi	sp,sp,-16
    80002ce4:	e406                	sd	ra,8(sp)
    80002ce6:	e022                	sd	s0,0(sp)
    80002ce8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002cea:	4639                	li	a2,14
    80002cec:	e92fd0ef          	jal	ra,8000037e <strncmp>
}
    80002cf0:	60a2                	ld	ra,8(sp)
    80002cf2:	6402                	ld	s0,0(sp)
    80002cf4:	0141                	addi	sp,sp,16
    80002cf6:	8082                	ret

0000000080002cf8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002cf8:	7139                	addi	sp,sp,-64
    80002cfa:	fc06                	sd	ra,56(sp)
    80002cfc:	f822                	sd	s0,48(sp)
    80002cfe:	f426                	sd	s1,40(sp)
    80002d00:	f04a                	sd	s2,32(sp)
    80002d02:	ec4e                	sd	s3,24(sp)
    80002d04:	e852                	sd	s4,16(sp)
    80002d06:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002d08:	04451703          	lh	a4,68(a0)
    80002d0c:	4785                	li	a5,1
    80002d0e:	00f71a63          	bne	a4,a5,80002d22 <dirlookup+0x2a>
    80002d12:	892a                	mv	s2,a0
    80002d14:	89ae                	mv	s3,a1
    80002d16:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d18:	457c                	lw	a5,76(a0)
    80002d1a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002d1c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d1e:	e39d                	bnez	a5,80002d44 <dirlookup+0x4c>
    80002d20:	a095                	j	80002d84 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002d22:	00005517          	auipc	a0,0x5
    80002d26:	9ce50513          	addi	a0,a0,-1586 # 800076f0 <syscalls+0x208>
    80002d2a:	7f8020ef          	jal	ra,80005522 <panic>
      panic("dirlookup read");
    80002d2e:	00005517          	auipc	a0,0x5
    80002d32:	9da50513          	addi	a0,a0,-1574 # 80007708 <syscalls+0x220>
    80002d36:	7ec020ef          	jal	ra,80005522 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d3a:	24c1                	addiw	s1,s1,16
    80002d3c:	04c92783          	lw	a5,76(s2)
    80002d40:	04f4f163          	bgeu	s1,a5,80002d82 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d44:	4741                	li	a4,16
    80002d46:	86a6                	mv	a3,s1
    80002d48:	fc040613          	addi	a2,s0,-64
    80002d4c:	4581                	li	a1,0
    80002d4e:	854a                	mv	a0,s2
    80002d50:	dadff0ef          	jal	ra,80002afc <readi>
    80002d54:	47c1                	li	a5,16
    80002d56:	fcf51ce3          	bne	a0,a5,80002d2e <dirlookup+0x36>
    if(de.inum == 0)
    80002d5a:	fc045783          	lhu	a5,-64(s0)
    80002d5e:	dff1                	beqz	a5,80002d3a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002d60:	fc240593          	addi	a1,s0,-62
    80002d64:	854e                	mv	a0,s3
    80002d66:	f7dff0ef          	jal	ra,80002ce2 <namecmp>
    80002d6a:	f961                	bnez	a0,80002d3a <dirlookup+0x42>
      if(poff)
    80002d6c:	000a0463          	beqz	s4,80002d74 <dirlookup+0x7c>
        *poff = off;
    80002d70:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002d74:	fc045583          	lhu	a1,-64(s0)
    80002d78:	00092503          	lw	a0,0(s2)
    80002d7c:	857ff0ef          	jal	ra,800025d2 <iget>
    80002d80:	a011                	j	80002d84 <dirlookup+0x8c>
  return 0;
    80002d82:	4501                	li	a0,0
}
    80002d84:	70e2                	ld	ra,56(sp)
    80002d86:	7442                	ld	s0,48(sp)
    80002d88:	74a2                	ld	s1,40(sp)
    80002d8a:	7902                	ld	s2,32(sp)
    80002d8c:	69e2                	ld	s3,24(sp)
    80002d8e:	6a42                	ld	s4,16(sp)
    80002d90:	6121                	addi	sp,sp,64
    80002d92:	8082                	ret

0000000080002d94 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002d94:	711d                	addi	sp,sp,-96
    80002d96:	ec86                	sd	ra,88(sp)
    80002d98:	e8a2                	sd	s0,80(sp)
    80002d9a:	e4a6                	sd	s1,72(sp)
    80002d9c:	e0ca                	sd	s2,64(sp)
    80002d9e:	fc4e                	sd	s3,56(sp)
    80002da0:	f852                	sd	s4,48(sp)
    80002da2:	f456                	sd	s5,40(sp)
    80002da4:	f05a                	sd	s6,32(sp)
    80002da6:	ec5e                	sd	s7,24(sp)
    80002da8:	e862                	sd	s8,16(sp)
    80002daa:	e466                	sd	s9,8(sp)
    80002dac:	e06a                	sd	s10,0(sp)
    80002dae:	1080                	addi	s0,sp,96
    80002db0:	84aa                	mv	s1,a0
    80002db2:	8b2e                	mv	s6,a1
    80002db4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002db6:	00054703          	lbu	a4,0(a0)
    80002dba:	02f00793          	li	a5,47
    80002dbe:	00f70f63          	beq	a4,a5,80002ddc <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002dc2:	9dcfe0ef          	jal	ra,80000f9e <myproc>
    80002dc6:	15053503          	ld	a0,336(a0)
    80002dca:	aadff0ef          	jal	ra,80002876 <idup>
    80002dce:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002dd0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002dd4:	4cb5                	li	s9,13
  len = path - s;
    80002dd6:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002dd8:	4c05                	li	s8,1
    80002dda:	a879                	j	80002e78 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80002ddc:	4585                	li	a1,1
    80002dde:	4505                	li	a0,1
    80002de0:	ff2ff0ef          	jal	ra,800025d2 <iget>
    80002de4:	8a2a                	mv	s4,a0
    80002de6:	b7ed                	j	80002dd0 <namex+0x3c>
      iunlockput(ip);
    80002de8:	8552                	mv	a0,s4
    80002dea:	cc9ff0ef          	jal	ra,80002ab2 <iunlockput>
      return 0;
    80002dee:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002df0:	8552                	mv	a0,s4
    80002df2:	60e6                	ld	ra,88(sp)
    80002df4:	6446                	ld	s0,80(sp)
    80002df6:	64a6                	ld	s1,72(sp)
    80002df8:	6906                	ld	s2,64(sp)
    80002dfa:	79e2                	ld	s3,56(sp)
    80002dfc:	7a42                	ld	s4,48(sp)
    80002dfe:	7aa2                	ld	s5,40(sp)
    80002e00:	7b02                	ld	s6,32(sp)
    80002e02:	6be2                	ld	s7,24(sp)
    80002e04:	6c42                	ld	s8,16(sp)
    80002e06:	6ca2                	ld	s9,8(sp)
    80002e08:	6d02                	ld	s10,0(sp)
    80002e0a:	6125                	addi	sp,sp,96
    80002e0c:	8082                	ret
      iunlock(ip);
    80002e0e:	8552                	mv	a0,s4
    80002e10:	b47ff0ef          	jal	ra,80002956 <iunlock>
      return ip;
    80002e14:	bff1                	j	80002df0 <namex+0x5c>
      iunlockput(ip);
    80002e16:	8552                	mv	a0,s4
    80002e18:	c9bff0ef          	jal	ra,80002ab2 <iunlockput>
      return 0;
    80002e1c:	8a4e                	mv	s4,s3
    80002e1e:	bfc9                	j	80002df0 <namex+0x5c>
  len = path - s;
    80002e20:	40998633          	sub	a2,s3,s1
    80002e24:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80002e28:	09acd063          	bge	s9,s10,80002ea8 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80002e2c:	4639                	li	a2,14
    80002e2e:	85a6                	mv	a1,s1
    80002e30:	8556                	mv	a0,s5
    80002e32:	cdcfd0ef          	jal	ra,8000030e <memmove>
    80002e36:	84ce                	mv	s1,s3
  while(*path == '/')
    80002e38:	0004c783          	lbu	a5,0(s1)
    80002e3c:	01279763          	bne	a5,s2,80002e4a <namex+0xb6>
    path++;
    80002e40:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002e42:	0004c783          	lbu	a5,0(s1)
    80002e46:	ff278de3          	beq	a5,s2,80002e40 <namex+0xac>
    ilock(ip);
    80002e4a:	8552                	mv	a0,s4
    80002e4c:	a61ff0ef          	jal	ra,800028ac <ilock>
    if(ip->type != T_DIR){
    80002e50:	044a1783          	lh	a5,68(s4)
    80002e54:	f9879ae3          	bne	a5,s8,80002de8 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80002e58:	000b0563          	beqz	s6,80002e62 <namex+0xce>
    80002e5c:	0004c783          	lbu	a5,0(s1)
    80002e60:	d7dd                	beqz	a5,80002e0e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002e62:	865e                	mv	a2,s7
    80002e64:	85d6                	mv	a1,s5
    80002e66:	8552                	mv	a0,s4
    80002e68:	e91ff0ef          	jal	ra,80002cf8 <dirlookup>
    80002e6c:	89aa                	mv	s3,a0
    80002e6e:	d545                	beqz	a0,80002e16 <namex+0x82>
    iunlockput(ip);
    80002e70:	8552                	mv	a0,s4
    80002e72:	c41ff0ef          	jal	ra,80002ab2 <iunlockput>
    ip = next;
    80002e76:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002e78:	0004c783          	lbu	a5,0(s1)
    80002e7c:	01279763          	bne	a5,s2,80002e8a <namex+0xf6>
    path++;
    80002e80:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002e82:	0004c783          	lbu	a5,0(s1)
    80002e86:	ff278de3          	beq	a5,s2,80002e80 <namex+0xec>
  if(*path == 0)
    80002e8a:	cb8d                	beqz	a5,80002ebc <namex+0x128>
  while(*path != '/' && *path != 0)
    80002e8c:	0004c783          	lbu	a5,0(s1)
    80002e90:	89a6                	mv	s3,s1
  len = path - s;
    80002e92:	8d5e                	mv	s10,s7
    80002e94:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80002e96:	01278963          	beq	a5,s2,80002ea8 <namex+0x114>
    80002e9a:	d3d9                	beqz	a5,80002e20 <namex+0x8c>
    path++;
    80002e9c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002e9e:	0009c783          	lbu	a5,0(s3)
    80002ea2:	ff279ce3          	bne	a5,s2,80002e9a <namex+0x106>
    80002ea6:	bfad                	j	80002e20 <namex+0x8c>
    memmove(name, s, len);
    80002ea8:	2601                	sext.w	a2,a2
    80002eaa:	85a6                	mv	a1,s1
    80002eac:	8556                	mv	a0,s5
    80002eae:	c60fd0ef          	jal	ra,8000030e <memmove>
    name[len] = 0;
    80002eb2:	9d56                	add	s10,s10,s5
    80002eb4:	000d0023          	sb	zero,0(s10)
    80002eb8:	84ce                	mv	s1,s3
    80002eba:	bfbd                	j	80002e38 <namex+0xa4>
  if(nameiparent){
    80002ebc:	f20b0ae3          	beqz	s6,80002df0 <namex+0x5c>
    iput(ip);
    80002ec0:	8552                	mv	a0,s4
    80002ec2:	b69ff0ef          	jal	ra,80002a2a <iput>
    return 0;
    80002ec6:	4a01                	li	s4,0
    80002ec8:	b725                	j	80002df0 <namex+0x5c>

0000000080002eca <dirlink>:
{
    80002eca:	7139                	addi	sp,sp,-64
    80002ecc:	fc06                	sd	ra,56(sp)
    80002ece:	f822                	sd	s0,48(sp)
    80002ed0:	f426                	sd	s1,40(sp)
    80002ed2:	f04a                	sd	s2,32(sp)
    80002ed4:	ec4e                	sd	s3,24(sp)
    80002ed6:	e852                	sd	s4,16(sp)
    80002ed8:	0080                	addi	s0,sp,64
    80002eda:	892a                	mv	s2,a0
    80002edc:	8a2e                	mv	s4,a1
    80002ede:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002ee0:	4601                	li	a2,0
    80002ee2:	e17ff0ef          	jal	ra,80002cf8 <dirlookup>
    80002ee6:	e52d                	bnez	a0,80002f50 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002ee8:	04c92483          	lw	s1,76(s2)
    80002eec:	c48d                	beqz	s1,80002f16 <dirlink+0x4c>
    80002eee:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002ef0:	4741                	li	a4,16
    80002ef2:	86a6                	mv	a3,s1
    80002ef4:	fc040613          	addi	a2,s0,-64
    80002ef8:	4581                	li	a1,0
    80002efa:	854a                	mv	a0,s2
    80002efc:	c01ff0ef          	jal	ra,80002afc <readi>
    80002f00:	47c1                	li	a5,16
    80002f02:	04f51b63          	bne	a0,a5,80002f58 <dirlink+0x8e>
    if(de.inum == 0)
    80002f06:	fc045783          	lhu	a5,-64(s0)
    80002f0a:	c791                	beqz	a5,80002f16 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f0c:	24c1                	addiw	s1,s1,16
    80002f0e:	04c92783          	lw	a5,76(s2)
    80002f12:	fcf4efe3          	bltu	s1,a5,80002ef0 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002f16:	4639                	li	a2,14
    80002f18:	85d2                	mv	a1,s4
    80002f1a:	fc240513          	addi	a0,s0,-62
    80002f1e:	c9cfd0ef          	jal	ra,800003ba <strncpy>
  de.inum = inum;
    80002f22:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f26:	4741                	li	a4,16
    80002f28:	86a6                	mv	a3,s1
    80002f2a:	fc040613          	addi	a2,s0,-64
    80002f2e:	4581                	li	a1,0
    80002f30:	854a                	mv	a0,s2
    80002f32:	cafff0ef          	jal	ra,80002be0 <writei>
    80002f36:	1541                	addi	a0,a0,-16
    80002f38:	00a03533          	snez	a0,a0
    80002f3c:	40a00533          	neg	a0,a0
}
    80002f40:	70e2                	ld	ra,56(sp)
    80002f42:	7442                	ld	s0,48(sp)
    80002f44:	74a2                	ld	s1,40(sp)
    80002f46:	7902                	ld	s2,32(sp)
    80002f48:	69e2                	ld	s3,24(sp)
    80002f4a:	6a42                	ld	s4,16(sp)
    80002f4c:	6121                	addi	sp,sp,64
    80002f4e:	8082                	ret
    iput(ip);
    80002f50:	adbff0ef          	jal	ra,80002a2a <iput>
    return -1;
    80002f54:	557d                	li	a0,-1
    80002f56:	b7ed                	j	80002f40 <dirlink+0x76>
      panic("dirlink read");
    80002f58:	00004517          	auipc	a0,0x4
    80002f5c:	7c050513          	addi	a0,a0,1984 # 80007718 <syscalls+0x230>
    80002f60:	5c2020ef          	jal	ra,80005522 <panic>

0000000080002f64 <namei>:

struct inode*
namei(char *path)
{
    80002f64:	1101                	addi	sp,sp,-32
    80002f66:	ec06                	sd	ra,24(sp)
    80002f68:	e822                	sd	s0,16(sp)
    80002f6a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002f6c:	fe040613          	addi	a2,s0,-32
    80002f70:	4581                	li	a1,0
    80002f72:	e23ff0ef          	jal	ra,80002d94 <namex>
}
    80002f76:	60e2                	ld	ra,24(sp)
    80002f78:	6442                	ld	s0,16(sp)
    80002f7a:	6105                	addi	sp,sp,32
    80002f7c:	8082                	ret

0000000080002f7e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002f7e:	1141                	addi	sp,sp,-16
    80002f80:	e406                	sd	ra,8(sp)
    80002f82:	e022                	sd	s0,0(sp)
    80002f84:	0800                	addi	s0,sp,16
    80002f86:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002f88:	4585                	li	a1,1
    80002f8a:	e0bff0ef          	jal	ra,80002d94 <namex>
}
    80002f8e:	60a2                	ld	ra,8(sp)
    80002f90:	6402                	ld	s0,0(sp)
    80002f92:	0141                	addi	sp,sp,16
    80002f94:	8082                	ret

0000000080002f96 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002f96:	1101                	addi	sp,sp,-32
    80002f98:	ec06                	sd	ra,24(sp)
    80002f9a:	e822                	sd	s0,16(sp)
    80002f9c:	e426                	sd	s1,8(sp)
    80002f9e:	e04a                	sd	s2,0(sp)
    80002fa0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002fa2:	00015917          	auipc	s2,0x15
    80002fa6:	cae90913          	addi	s2,s2,-850 # 80017c50 <log>
    80002faa:	01892583          	lw	a1,24(s2)
    80002fae:	02892503          	lw	a0,40(s2)
    80002fb2:	9deff0ef          	jal	ra,80002190 <bread>
    80002fb6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002fb8:	02c92683          	lw	a3,44(s2)
    80002fbc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002fbe:	02d05863          	blez	a3,80002fee <write_head+0x58>
    80002fc2:	00015797          	auipc	a5,0x15
    80002fc6:	cbe78793          	addi	a5,a5,-834 # 80017c80 <log+0x30>
    80002fca:	05c50713          	addi	a4,a0,92
    80002fce:	36fd                	addiw	a3,a3,-1
    80002fd0:	02069613          	slli	a2,a3,0x20
    80002fd4:	01e65693          	srli	a3,a2,0x1e
    80002fd8:	00015617          	auipc	a2,0x15
    80002fdc:	cac60613          	addi	a2,a2,-852 # 80017c84 <log+0x34>
    80002fe0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80002fe2:	4390                	lw	a2,0(a5)
    80002fe4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002fe6:	0791                	addi	a5,a5,4
    80002fe8:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80002fea:	fed79ce3          	bne	a5,a3,80002fe2 <write_head+0x4c>
  }
  bwrite(buf);
    80002fee:	8526                	mv	a0,s1
    80002ff0:	a76ff0ef          	jal	ra,80002266 <bwrite>
  brelse(buf);
    80002ff4:	8526                	mv	a0,s1
    80002ff6:	aa2ff0ef          	jal	ra,80002298 <brelse>
}
    80002ffa:	60e2                	ld	ra,24(sp)
    80002ffc:	6442                	ld	s0,16(sp)
    80002ffe:	64a2                	ld	s1,8(sp)
    80003000:	6902                	ld	s2,0(sp)
    80003002:	6105                	addi	sp,sp,32
    80003004:	8082                	ret

0000000080003006 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003006:	00015797          	auipc	a5,0x15
    8000300a:	c767a783          	lw	a5,-906(a5) # 80017c7c <log+0x2c>
    8000300e:	08f05f63          	blez	a5,800030ac <install_trans+0xa6>
{
    80003012:	7139                	addi	sp,sp,-64
    80003014:	fc06                	sd	ra,56(sp)
    80003016:	f822                	sd	s0,48(sp)
    80003018:	f426                	sd	s1,40(sp)
    8000301a:	f04a                	sd	s2,32(sp)
    8000301c:	ec4e                	sd	s3,24(sp)
    8000301e:	e852                	sd	s4,16(sp)
    80003020:	e456                	sd	s5,8(sp)
    80003022:	e05a                	sd	s6,0(sp)
    80003024:	0080                	addi	s0,sp,64
    80003026:	8b2a                	mv	s6,a0
    80003028:	00015a97          	auipc	s5,0x15
    8000302c:	c58a8a93          	addi	s5,s5,-936 # 80017c80 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003030:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003032:	00015997          	auipc	s3,0x15
    80003036:	c1e98993          	addi	s3,s3,-994 # 80017c50 <log>
    8000303a:	a829                	j	80003054 <install_trans+0x4e>
    brelse(lbuf);
    8000303c:	854a                	mv	a0,s2
    8000303e:	a5aff0ef          	jal	ra,80002298 <brelse>
    brelse(dbuf);
    80003042:	8526                	mv	a0,s1
    80003044:	a54ff0ef          	jal	ra,80002298 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003048:	2a05                	addiw	s4,s4,1
    8000304a:	0a91                	addi	s5,s5,4
    8000304c:	02c9a783          	lw	a5,44(s3)
    80003050:	04fa5463          	bge	s4,a5,80003098 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003054:	0189a583          	lw	a1,24(s3)
    80003058:	014585bb          	addw	a1,a1,s4
    8000305c:	2585                	addiw	a1,a1,1
    8000305e:	0289a503          	lw	a0,40(s3)
    80003062:	92eff0ef          	jal	ra,80002190 <bread>
    80003066:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003068:	000aa583          	lw	a1,0(s5)
    8000306c:	0289a503          	lw	a0,40(s3)
    80003070:	920ff0ef          	jal	ra,80002190 <bread>
    80003074:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003076:	40000613          	li	a2,1024
    8000307a:	05890593          	addi	a1,s2,88
    8000307e:	05850513          	addi	a0,a0,88
    80003082:	a8cfd0ef          	jal	ra,8000030e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003086:	8526                	mv	a0,s1
    80003088:	9deff0ef          	jal	ra,80002266 <bwrite>
    if(recovering == 0)
    8000308c:	fa0b18e3          	bnez	s6,8000303c <install_trans+0x36>
      bunpin(dbuf);
    80003090:	8526                	mv	a0,s1
    80003092:	ac4ff0ef          	jal	ra,80002356 <bunpin>
    80003096:	b75d                	j	8000303c <install_trans+0x36>
}
    80003098:	70e2                	ld	ra,56(sp)
    8000309a:	7442                	ld	s0,48(sp)
    8000309c:	74a2                	ld	s1,40(sp)
    8000309e:	7902                	ld	s2,32(sp)
    800030a0:	69e2                	ld	s3,24(sp)
    800030a2:	6a42                	ld	s4,16(sp)
    800030a4:	6aa2                	ld	s5,8(sp)
    800030a6:	6b02                	ld	s6,0(sp)
    800030a8:	6121                	addi	sp,sp,64
    800030aa:	8082                	ret
    800030ac:	8082                	ret

00000000800030ae <initlog>:
{
    800030ae:	7179                	addi	sp,sp,-48
    800030b0:	f406                	sd	ra,40(sp)
    800030b2:	f022                	sd	s0,32(sp)
    800030b4:	ec26                	sd	s1,24(sp)
    800030b6:	e84a                	sd	s2,16(sp)
    800030b8:	e44e                	sd	s3,8(sp)
    800030ba:	1800                	addi	s0,sp,48
    800030bc:	892a                	mv	s2,a0
    800030be:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800030c0:	00015497          	auipc	s1,0x15
    800030c4:	b9048493          	addi	s1,s1,-1136 # 80017c50 <log>
    800030c8:	00004597          	auipc	a1,0x4
    800030cc:	66058593          	addi	a1,a1,1632 # 80007728 <syscalls+0x240>
    800030d0:	8526                	mv	a0,s1
    800030d2:	6e0020ef          	jal	ra,800057b2 <initlock>
  log.start = sb->logstart;
    800030d6:	0149a583          	lw	a1,20(s3)
    800030da:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800030dc:	0109a783          	lw	a5,16(s3)
    800030e0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800030e2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800030e6:	854a                	mv	a0,s2
    800030e8:	8a8ff0ef          	jal	ra,80002190 <bread>
  log.lh.n = lh->n;
    800030ec:	4d34                	lw	a3,88(a0)
    800030ee:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800030f0:	02d05663          	blez	a3,8000311c <initlog+0x6e>
    800030f4:	05c50793          	addi	a5,a0,92
    800030f8:	00015717          	auipc	a4,0x15
    800030fc:	b8870713          	addi	a4,a4,-1144 # 80017c80 <log+0x30>
    80003100:	36fd                	addiw	a3,a3,-1
    80003102:	02069613          	slli	a2,a3,0x20
    80003106:	01e65693          	srli	a3,a2,0x1e
    8000310a:	06050613          	addi	a2,a0,96
    8000310e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003110:	4390                	lw	a2,0(a5)
    80003112:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003114:	0791                	addi	a5,a5,4
    80003116:	0711                	addi	a4,a4,4
    80003118:	fed79ce3          	bne	a5,a3,80003110 <initlog+0x62>
  brelse(buf);
    8000311c:	97cff0ef          	jal	ra,80002298 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003120:	4505                	li	a0,1
    80003122:	ee5ff0ef          	jal	ra,80003006 <install_trans>
  log.lh.n = 0;
    80003126:	00015797          	auipc	a5,0x15
    8000312a:	b407ab23          	sw	zero,-1194(a5) # 80017c7c <log+0x2c>
  write_head(); // clear the log
    8000312e:	e69ff0ef          	jal	ra,80002f96 <write_head>
}
    80003132:	70a2                	ld	ra,40(sp)
    80003134:	7402                	ld	s0,32(sp)
    80003136:	64e2                	ld	s1,24(sp)
    80003138:	6942                	ld	s2,16(sp)
    8000313a:	69a2                	ld	s3,8(sp)
    8000313c:	6145                	addi	sp,sp,48
    8000313e:	8082                	ret

0000000080003140 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003140:	1101                	addi	sp,sp,-32
    80003142:	ec06                	sd	ra,24(sp)
    80003144:	e822                	sd	s0,16(sp)
    80003146:	e426                	sd	s1,8(sp)
    80003148:	e04a                	sd	s2,0(sp)
    8000314a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000314c:	00015517          	auipc	a0,0x15
    80003150:	b0450513          	addi	a0,a0,-1276 # 80017c50 <log>
    80003154:	6de020ef          	jal	ra,80005832 <acquire>
  while(1){
    if(log.committing){
    80003158:	00015497          	auipc	s1,0x15
    8000315c:	af848493          	addi	s1,s1,-1288 # 80017c50 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003160:	4979                	li	s2,30
    80003162:	a029                	j	8000316c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003164:	85a6                	mv	a1,s1
    80003166:	8526                	mv	a0,s1
    80003168:	c02fe0ef          	jal	ra,8000156a <sleep>
    if(log.committing){
    8000316c:	50dc                	lw	a5,36(s1)
    8000316e:	fbfd                	bnez	a5,80003164 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003170:	5098                	lw	a4,32(s1)
    80003172:	2705                	addiw	a4,a4,1
    80003174:	0007069b          	sext.w	a3,a4
    80003178:	0027179b          	slliw	a5,a4,0x2
    8000317c:	9fb9                	addw	a5,a5,a4
    8000317e:	0017979b          	slliw	a5,a5,0x1
    80003182:	54d8                	lw	a4,44(s1)
    80003184:	9fb9                	addw	a5,a5,a4
    80003186:	00f95763          	bge	s2,a5,80003194 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000318a:	85a6                	mv	a1,s1
    8000318c:	8526                	mv	a0,s1
    8000318e:	bdcfe0ef          	jal	ra,8000156a <sleep>
    80003192:	bfe9                	j	8000316c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003194:	00015517          	auipc	a0,0x15
    80003198:	abc50513          	addi	a0,a0,-1348 # 80017c50 <log>
    8000319c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000319e:	72c020ef          	jal	ra,800058ca <release>
      break;
    }
  }
}
    800031a2:	60e2                	ld	ra,24(sp)
    800031a4:	6442                	ld	s0,16(sp)
    800031a6:	64a2                	ld	s1,8(sp)
    800031a8:	6902                	ld	s2,0(sp)
    800031aa:	6105                	addi	sp,sp,32
    800031ac:	8082                	ret

00000000800031ae <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800031ae:	7139                	addi	sp,sp,-64
    800031b0:	fc06                	sd	ra,56(sp)
    800031b2:	f822                	sd	s0,48(sp)
    800031b4:	f426                	sd	s1,40(sp)
    800031b6:	f04a                	sd	s2,32(sp)
    800031b8:	ec4e                	sd	s3,24(sp)
    800031ba:	e852                	sd	s4,16(sp)
    800031bc:	e456                	sd	s5,8(sp)
    800031be:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800031c0:	00015497          	auipc	s1,0x15
    800031c4:	a9048493          	addi	s1,s1,-1392 # 80017c50 <log>
    800031c8:	8526                	mv	a0,s1
    800031ca:	668020ef          	jal	ra,80005832 <acquire>
  log.outstanding -= 1;
    800031ce:	509c                	lw	a5,32(s1)
    800031d0:	37fd                	addiw	a5,a5,-1
    800031d2:	0007891b          	sext.w	s2,a5
    800031d6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800031d8:	50dc                	lw	a5,36(s1)
    800031da:	ef9d                	bnez	a5,80003218 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    800031dc:	04091463          	bnez	s2,80003224 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800031e0:	00015497          	auipc	s1,0x15
    800031e4:	a7048493          	addi	s1,s1,-1424 # 80017c50 <log>
    800031e8:	4785                	li	a5,1
    800031ea:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800031ec:	8526                	mv	a0,s1
    800031ee:	6dc020ef          	jal	ra,800058ca <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800031f2:	54dc                	lw	a5,44(s1)
    800031f4:	04f04b63          	bgtz	a5,8000324a <end_op+0x9c>
    acquire(&log.lock);
    800031f8:	00015497          	auipc	s1,0x15
    800031fc:	a5848493          	addi	s1,s1,-1448 # 80017c50 <log>
    80003200:	8526                	mv	a0,s1
    80003202:	630020ef          	jal	ra,80005832 <acquire>
    log.committing = 0;
    80003206:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000320a:	8526                	mv	a0,s1
    8000320c:	baafe0ef          	jal	ra,800015b6 <wakeup>
    release(&log.lock);
    80003210:	8526                	mv	a0,s1
    80003212:	6b8020ef          	jal	ra,800058ca <release>
}
    80003216:	a00d                	j	80003238 <end_op+0x8a>
    panic("log.committing");
    80003218:	00004517          	auipc	a0,0x4
    8000321c:	51850513          	addi	a0,a0,1304 # 80007730 <syscalls+0x248>
    80003220:	302020ef          	jal	ra,80005522 <panic>
    wakeup(&log);
    80003224:	00015497          	auipc	s1,0x15
    80003228:	a2c48493          	addi	s1,s1,-1492 # 80017c50 <log>
    8000322c:	8526                	mv	a0,s1
    8000322e:	b88fe0ef          	jal	ra,800015b6 <wakeup>
  release(&log.lock);
    80003232:	8526                	mv	a0,s1
    80003234:	696020ef          	jal	ra,800058ca <release>
}
    80003238:	70e2                	ld	ra,56(sp)
    8000323a:	7442                	ld	s0,48(sp)
    8000323c:	74a2                	ld	s1,40(sp)
    8000323e:	7902                	ld	s2,32(sp)
    80003240:	69e2                	ld	s3,24(sp)
    80003242:	6a42                	ld	s4,16(sp)
    80003244:	6aa2                	ld	s5,8(sp)
    80003246:	6121                	addi	sp,sp,64
    80003248:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000324a:	00015a97          	auipc	s5,0x15
    8000324e:	a36a8a93          	addi	s5,s5,-1482 # 80017c80 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003252:	00015a17          	auipc	s4,0x15
    80003256:	9fea0a13          	addi	s4,s4,-1538 # 80017c50 <log>
    8000325a:	018a2583          	lw	a1,24(s4)
    8000325e:	012585bb          	addw	a1,a1,s2
    80003262:	2585                	addiw	a1,a1,1
    80003264:	028a2503          	lw	a0,40(s4)
    80003268:	f29fe0ef          	jal	ra,80002190 <bread>
    8000326c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000326e:	000aa583          	lw	a1,0(s5)
    80003272:	028a2503          	lw	a0,40(s4)
    80003276:	f1bfe0ef          	jal	ra,80002190 <bread>
    8000327a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000327c:	40000613          	li	a2,1024
    80003280:	05850593          	addi	a1,a0,88
    80003284:	05848513          	addi	a0,s1,88
    80003288:	886fd0ef          	jal	ra,8000030e <memmove>
    bwrite(to);  // write the log
    8000328c:	8526                	mv	a0,s1
    8000328e:	fd9fe0ef          	jal	ra,80002266 <bwrite>
    brelse(from);
    80003292:	854e                	mv	a0,s3
    80003294:	804ff0ef          	jal	ra,80002298 <brelse>
    brelse(to);
    80003298:	8526                	mv	a0,s1
    8000329a:	ffffe0ef          	jal	ra,80002298 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000329e:	2905                	addiw	s2,s2,1
    800032a0:	0a91                	addi	s5,s5,4
    800032a2:	02ca2783          	lw	a5,44(s4)
    800032a6:	faf94ae3          	blt	s2,a5,8000325a <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800032aa:	cedff0ef          	jal	ra,80002f96 <write_head>
    install_trans(0); // Now install writes to home locations
    800032ae:	4501                	li	a0,0
    800032b0:	d57ff0ef          	jal	ra,80003006 <install_trans>
    log.lh.n = 0;
    800032b4:	00015797          	auipc	a5,0x15
    800032b8:	9c07a423          	sw	zero,-1592(a5) # 80017c7c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800032bc:	cdbff0ef          	jal	ra,80002f96 <write_head>
    800032c0:	bf25                	j	800031f8 <end_op+0x4a>

00000000800032c2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800032c2:	1101                	addi	sp,sp,-32
    800032c4:	ec06                	sd	ra,24(sp)
    800032c6:	e822                	sd	s0,16(sp)
    800032c8:	e426                	sd	s1,8(sp)
    800032ca:	e04a                	sd	s2,0(sp)
    800032cc:	1000                	addi	s0,sp,32
    800032ce:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800032d0:	00015917          	auipc	s2,0x15
    800032d4:	98090913          	addi	s2,s2,-1664 # 80017c50 <log>
    800032d8:	854a                	mv	a0,s2
    800032da:	558020ef          	jal	ra,80005832 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800032de:	02c92603          	lw	a2,44(s2)
    800032e2:	47f5                	li	a5,29
    800032e4:	06c7c363          	blt	a5,a2,8000334a <log_write+0x88>
    800032e8:	00015797          	auipc	a5,0x15
    800032ec:	9847a783          	lw	a5,-1660(a5) # 80017c6c <log+0x1c>
    800032f0:	37fd                	addiw	a5,a5,-1
    800032f2:	04f65c63          	bge	a2,a5,8000334a <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800032f6:	00015797          	auipc	a5,0x15
    800032fa:	97a7a783          	lw	a5,-1670(a5) # 80017c70 <log+0x20>
    800032fe:	04f05c63          	blez	a5,80003356 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003302:	4781                	li	a5,0
    80003304:	04c05f63          	blez	a2,80003362 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003308:	44cc                	lw	a1,12(s1)
    8000330a:	00015717          	auipc	a4,0x15
    8000330e:	97670713          	addi	a4,a4,-1674 # 80017c80 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003312:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003314:	4314                	lw	a3,0(a4)
    80003316:	04b68663          	beq	a3,a1,80003362 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    8000331a:	2785                	addiw	a5,a5,1
    8000331c:	0711                	addi	a4,a4,4
    8000331e:	fef61be3          	bne	a2,a5,80003314 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003322:	0621                	addi	a2,a2,8
    80003324:	060a                	slli	a2,a2,0x2
    80003326:	00015797          	auipc	a5,0x15
    8000332a:	92a78793          	addi	a5,a5,-1750 # 80017c50 <log>
    8000332e:	97b2                	add	a5,a5,a2
    80003330:	44d8                	lw	a4,12(s1)
    80003332:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003334:	8526                	mv	a0,s1
    80003336:	fedfe0ef          	jal	ra,80002322 <bpin>
    log.lh.n++;
    8000333a:	00015717          	auipc	a4,0x15
    8000333e:	91670713          	addi	a4,a4,-1770 # 80017c50 <log>
    80003342:	575c                	lw	a5,44(a4)
    80003344:	2785                	addiw	a5,a5,1
    80003346:	d75c                	sw	a5,44(a4)
    80003348:	a80d                	j	8000337a <log_write+0xb8>
    panic("too big a transaction");
    8000334a:	00004517          	auipc	a0,0x4
    8000334e:	3f650513          	addi	a0,a0,1014 # 80007740 <syscalls+0x258>
    80003352:	1d0020ef          	jal	ra,80005522 <panic>
    panic("log_write outside of trans");
    80003356:	00004517          	auipc	a0,0x4
    8000335a:	40250513          	addi	a0,a0,1026 # 80007758 <syscalls+0x270>
    8000335e:	1c4020ef          	jal	ra,80005522 <panic>
  log.lh.block[i] = b->blockno;
    80003362:	00878693          	addi	a3,a5,8
    80003366:	068a                	slli	a3,a3,0x2
    80003368:	00015717          	auipc	a4,0x15
    8000336c:	8e870713          	addi	a4,a4,-1816 # 80017c50 <log>
    80003370:	9736                	add	a4,a4,a3
    80003372:	44d4                	lw	a3,12(s1)
    80003374:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003376:	faf60fe3          	beq	a2,a5,80003334 <log_write+0x72>
  }
  release(&log.lock);
    8000337a:	00015517          	auipc	a0,0x15
    8000337e:	8d650513          	addi	a0,a0,-1834 # 80017c50 <log>
    80003382:	548020ef          	jal	ra,800058ca <release>
}
    80003386:	60e2                	ld	ra,24(sp)
    80003388:	6442                	ld	s0,16(sp)
    8000338a:	64a2                	ld	s1,8(sp)
    8000338c:	6902                	ld	s2,0(sp)
    8000338e:	6105                	addi	sp,sp,32
    80003390:	8082                	ret

0000000080003392 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003392:	1101                	addi	sp,sp,-32
    80003394:	ec06                	sd	ra,24(sp)
    80003396:	e822                	sd	s0,16(sp)
    80003398:	e426                	sd	s1,8(sp)
    8000339a:	e04a                	sd	s2,0(sp)
    8000339c:	1000                	addi	s0,sp,32
    8000339e:	84aa                	mv	s1,a0
    800033a0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800033a2:	00004597          	auipc	a1,0x4
    800033a6:	3d658593          	addi	a1,a1,982 # 80007778 <syscalls+0x290>
    800033aa:	0521                	addi	a0,a0,8
    800033ac:	406020ef          	jal	ra,800057b2 <initlock>
  lk->name = name;
    800033b0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800033b4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800033b8:	0204a423          	sw	zero,40(s1)
}
    800033bc:	60e2                	ld	ra,24(sp)
    800033be:	6442                	ld	s0,16(sp)
    800033c0:	64a2                	ld	s1,8(sp)
    800033c2:	6902                	ld	s2,0(sp)
    800033c4:	6105                	addi	sp,sp,32
    800033c6:	8082                	ret

00000000800033c8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800033c8:	1101                	addi	sp,sp,-32
    800033ca:	ec06                	sd	ra,24(sp)
    800033cc:	e822                	sd	s0,16(sp)
    800033ce:	e426                	sd	s1,8(sp)
    800033d0:	e04a                	sd	s2,0(sp)
    800033d2:	1000                	addi	s0,sp,32
    800033d4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800033d6:	00850913          	addi	s2,a0,8
    800033da:	854a                	mv	a0,s2
    800033dc:	456020ef          	jal	ra,80005832 <acquire>
  while (lk->locked) {
    800033e0:	409c                	lw	a5,0(s1)
    800033e2:	c799                	beqz	a5,800033f0 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800033e4:	85ca                	mv	a1,s2
    800033e6:	8526                	mv	a0,s1
    800033e8:	982fe0ef          	jal	ra,8000156a <sleep>
  while (lk->locked) {
    800033ec:	409c                	lw	a5,0(s1)
    800033ee:	fbfd                	bnez	a5,800033e4 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800033f0:	4785                	li	a5,1
    800033f2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800033f4:	babfd0ef          	jal	ra,80000f9e <myproc>
    800033f8:	591c                	lw	a5,48(a0)
    800033fa:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800033fc:	854a                	mv	a0,s2
    800033fe:	4cc020ef          	jal	ra,800058ca <release>
}
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6902                	ld	s2,0(sp)
    8000340a:	6105                	addi	sp,sp,32
    8000340c:	8082                	ret

000000008000340e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000340e:	1101                	addi	sp,sp,-32
    80003410:	ec06                	sd	ra,24(sp)
    80003412:	e822                	sd	s0,16(sp)
    80003414:	e426                	sd	s1,8(sp)
    80003416:	e04a                	sd	s2,0(sp)
    80003418:	1000                	addi	s0,sp,32
    8000341a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000341c:	00850913          	addi	s2,a0,8
    80003420:	854a                	mv	a0,s2
    80003422:	410020ef          	jal	ra,80005832 <acquire>
  lk->locked = 0;
    80003426:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000342a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000342e:	8526                	mv	a0,s1
    80003430:	986fe0ef          	jal	ra,800015b6 <wakeup>
  release(&lk->lk);
    80003434:	854a                	mv	a0,s2
    80003436:	494020ef          	jal	ra,800058ca <release>
}
    8000343a:	60e2                	ld	ra,24(sp)
    8000343c:	6442                	ld	s0,16(sp)
    8000343e:	64a2                	ld	s1,8(sp)
    80003440:	6902                	ld	s2,0(sp)
    80003442:	6105                	addi	sp,sp,32
    80003444:	8082                	ret

0000000080003446 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003446:	7179                	addi	sp,sp,-48
    80003448:	f406                	sd	ra,40(sp)
    8000344a:	f022                	sd	s0,32(sp)
    8000344c:	ec26                	sd	s1,24(sp)
    8000344e:	e84a                	sd	s2,16(sp)
    80003450:	e44e                	sd	s3,8(sp)
    80003452:	1800                	addi	s0,sp,48
    80003454:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80003456:	00850913          	addi	s2,a0,8
    8000345a:	854a                	mv	a0,s2
    8000345c:	3d6020ef          	jal	ra,80005832 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003460:	409c                	lw	a5,0(s1)
    80003462:	ef89                	bnez	a5,8000347c <holdingsleep+0x36>
    80003464:	4481                	li	s1,0
  release(&lk->lk);
    80003466:	854a                	mv	a0,s2
    80003468:	462020ef          	jal	ra,800058ca <release>
  return r;
}
    8000346c:	8526                	mv	a0,s1
    8000346e:	70a2                	ld	ra,40(sp)
    80003470:	7402                	ld	s0,32(sp)
    80003472:	64e2                	ld	s1,24(sp)
    80003474:	6942                	ld	s2,16(sp)
    80003476:	69a2                	ld	s3,8(sp)
    80003478:	6145                	addi	sp,sp,48
    8000347a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000347c:	0284a983          	lw	s3,40(s1)
    80003480:	b1ffd0ef          	jal	ra,80000f9e <myproc>
    80003484:	5904                	lw	s1,48(a0)
    80003486:	413484b3          	sub	s1,s1,s3
    8000348a:	0014b493          	seqz	s1,s1
    8000348e:	bfe1                	j	80003466 <holdingsleep+0x20>

0000000080003490 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003490:	1141                	addi	sp,sp,-16
    80003492:	e406                	sd	ra,8(sp)
    80003494:	e022                	sd	s0,0(sp)
    80003496:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003498:	00004597          	auipc	a1,0x4
    8000349c:	2f058593          	addi	a1,a1,752 # 80007788 <syscalls+0x2a0>
    800034a0:	00015517          	auipc	a0,0x15
    800034a4:	8f850513          	addi	a0,a0,-1800 # 80017d98 <ftable>
    800034a8:	30a020ef          	jal	ra,800057b2 <initlock>
}
    800034ac:	60a2                	ld	ra,8(sp)
    800034ae:	6402                	ld	s0,0(sp)
    800034b0:	0141                	addi	sp,sp,16
    800034b2:	8082                	ret

00000000800034b4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800034b4:	1101                	addi	sp,sp,-32
    800034b6:	ec06                	sd	ra,24(sp)
    800034b8:	e822                	sd	s0,16(sp)
    800034ba:	e426                	sd	s1,8(sp)
    800034bc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800034be:	00015517          	auipc	a0,0x15
    800034c2:	8da50513          	addi	a0,a0,-1830 # 80017d98 <ftable>
    800034c6:	36c020ef          	jal	ra,80005832 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800034ca:	00015497          	auipc	s1,0x15
    800034ce:	8e648493          	addi	s1,s1,-1818 # 80017db0 <ftable+0x18>
    800034d2:	00016717          	auipc	a4,0x16
    800034d6:	87e70713          	addi	a4,a4,-1922 # 80018d50 <disk>
    if(f->ref == 0){
    800034da:	40dc                	lw	a5,4(s1)
    800034dc:	cf89                	beqz	a5,800034f6 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800034de:	02848493          	addi	s1,s1,40
    800034e2:	fee49ce3          	bne	s1,a4,800034da <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800034e6:	00015517          	auipc	a0,0x15
    800034ea:	8b250513          	addi	a0,a0,-1870 # 80017d98 <ftable>
    800034ee:	3dc020ef          	jal	ra,800058ca <release>
  return 0;
    800034f2:	4481                	li	s1,0
    800034f4:	a809                	j	80003506 <filealloc+0x52>
      f->ref = 1;
    800034f6:	4785                	li	a5,1
    800034f8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800034fa:	00015517          	auipc	a0,0x15
    800034fe:	89e50513          	addi	a0,a0,-1890 # 80017d98 <ftable>
    80003502:	3c8020ef          	jal	ra,800058ca <release>
}
    80003506:	8526                	mv	a0,s1
    80003508:	60e2                	ld	ra,24(sp)
    8000350a:	6442                	ld	s0,16(sp)
    8000350c:	64a2                	ld	s1,8(sp)
    8000350e:	6105                	addi	sp,sp,32
    80003510:	8082                	ret

0000000080003512 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003512:	1101                	addi	sp,sp,-32
    80003514:	ec06                	sd	ra,24(sp)
    80003516:	e822                	sd	s0,16(sp)
    80003518:	e426                	sd	s1,8(sp)
    8000351a:	1000                	addi	s0,sp,32
    8000351c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000351e:	00015517          	auipc	a0,0x15
    80003522:	87a50513          	addi	a0,a0,-1926 # 80017d98 <ftable>
    80003526:	30c020ef          	jal	ra,80005832 <acquire>
  if(f->ref < 1)
    8000352a:	40dc                	lw	a5,4(s1)
    8000352c:	02f05063          	blez	a5,8000354c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003530:	2785                	addiw	a5,a5,1
    80003532:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003534:	00015517          	auipc	a0,0x15
    80003538:	86450513          	addi	a0,a0,-1948 # 80017d98 <ftable>
    8000353c:	38e020ef          	jal	ra,800058ca <release>
  return f;
}
    80003540:	8526                	mv	a0,s1
    80003542:	60e2                	ld	ra,24(sp)
    80003544:	6442                	ld	s0,16(sp)
    80003546:	64a2                	ld	s1,8(sp)
    80003548:	6105                	addi	sp,sp,32
    8000354a:	8082                	ret
    panic("filedup");
    8000354c:	00004517          	auipc	a0,0x4
    80003550:	24450513          	addi	a0,a0,580 # 80007790 <syscalls+0x2a8>
    80003554:	7cf010ef          	jal	ra,80005522 <panic>

0000000080003558 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003558:	7139                	addi	sp,sp,-64
    8000355a:	fc06                	sd	ra,56(sp)
    8000355c:	f822                	sd	s0,48(sp)
    8000355e:	f426                	sd	s1,40(sp)
    80003560:	f04a                	sd	s2,32(sp)
    80003562:	ec4e                	sd	s3,24(sp)
    80003564:	e852                	sd	s4,16(sp)
    80003566:	e456                	sd	s5,8(sp)
    80003568:	0080                	addi	s0,sp,64
    8000356a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000356c:	00015517          	auipc	a0,0x15
    80003570:	82c50513          	addi	a0,a0,-2004 # 80017d98 <ftable>
    80003574:	2be020ef          	jal	ra,80005832 <acquire>
  if(f->ref < 1)
    80003578:	40dc                	lw	a5,4(s1)
    8000357a:	04f05963          	blez	a5,800035cc <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    8000357e:	37fd                	addiw	a5,a5,-1
    80003580:	0007871b          	sext.w	a4,a5
    80003584:	c0dc                	sw	a5,4(s1)
    80003586:	04e04963          	bgtz	a4,800035d8 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000358a:	0004a903          	lw	s2,0(s1)
    8000358e:	0094ca83          	lbu	s5,9(s1)
    80003592:	0104ba03          	ld	s4,16(s1)
    80003596:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000359a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000359e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800035a2:	00014517          	auipc	a0,0x14
    800035a6:	7f650513          	addi	a0,a0,2038 # 80017d98 <ftable>
    800035aa:	320020ef          	jal	ra,800058ca <release>

  if(ff.type == FD_PIPE){
    800035ae:	4785                	li	a5,1
    800035b0:	04f90363          	beq	s2,a5,800035f6 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800035b4:	3979                	addiw	s2,s2,-2
    800035b6:	4785                	li	a5,1
    800035b8:	0327e663          	bltu	a5,s2,800035e4 <fileclose+0x8c>
    begin_op();
    800035bc:	b85ff0ef          	jal	ra,80003140 <begin_op>
    iput(ff.ip);
    800035c0:	854e                	mv	a0,s3
    800035c2:	c68ff0ef          	jal	ra,80002a2a <iput>
    end_op();
    800035c6:	be9ff0ef          	jal	ra,800031ae <end_op>
    800035ca:	a829                	j	800035e4 <fileclose+0x8c>
    panic("fileclose");
    800035cc:	00004517          	auipc	a0,0x4
    800035d0:	1cc50513          	addi	a0,a0,460 # 80007798 <syscalls+0x2b0>
    800035d4:	74f010ef          	jal	ra,80005522 <panic>
    release(&ftable.lock);
    800035d8:	00014517          	auipc	a0,0x14
    800035dc:	7c050513          	addi	a0,a0,1984 # 80017d98 <ftable>
    800035e0:	2ea020ef          	jal	ra,800058ca <release>
  }
}
    800035e4:	70e2                	ld	ra,56(sp)
    800035e6:	7442                	ld	s0,48(sp)
    800035e8:	74a2                	ld	s1,40(sp)
    800035ea:	7902                	ld	s2,32(sp)
    800035ec:	69e2                	ld	s3,24(sp)
    800035ee:	6a42                	ld	s4,16(sp)
    800035f0:	6aa2                	ld	s5,8(sp)
    800035f2:	6121                	addi	sp,sp,64
    800035f4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800035f6:	85d6                	mv	a1,s5
    800035f8:	8552                	mv	a0,s4
    800035fa:	2ec000ef          	jal	ra,800038e6 <pipeclose>
    800035fe:	b7dd                	j	800035e4 <fileclose+0x8c>

0000000080003600 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003600:	715d                	addi	sp,sp,-80
    80003602:	e486                	sd	ra,72(sp)
    80003604:	e0a2                	sd	s0,64(sp)
    80003606:	fc26                	sd	s1,56(sp)
    80003608:	f84a                	sd	s2,48(sp)
    8000360a:	f44e                	sd	s3,40(sp)
    8000360c:	0880                	addi	s0,sp,80
    8000360e:	84aa                	mv	s1,a0
    80003610:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003612:	98dfd0ef          	jal	ra,80000f9e <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003616:	409c                	lw	a5,0(s1)
    80003618:	37f9                	addiw	a5,a5,-2
    8000361a:	4705                	li	a4,1
    8000361c:	02f76f63          	bltu	a4,a5,8000365a <filestat+0x5a>
    80003620:	892a                	mv	s2,a0
    ilock(f->ip);
    80003622:	6c88                	ld	a0,24(s1)
    80003624:	a88ff0ef          	jal	ra,800028ac <ilock>
    stati(f->ip, &st);
    80003628:	fb840593          	addi	a1,s0,-72
    8000362c:	6c88                	ld	a0,24(s1)
    8000362e:	ca4ff0ef          	jal	ra,80002ad2 <stati>
    iunlock(f->ip);
    80003632:	6c88                	ld	a0,24(s1)
    80003634:	b22ff0ef          	jal	ra,80002956 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003638:	46e1                	li	a3,24
    8000363a:	fb840613          	addi	a2,s0,-72
    8000363e:	85ce                	mv	a1,s3
    80003640:	05093503          	ld	a0,80(s2)
    80003644:	cfefd0ef          	jal	ra,80000b42 <copyout>
    80003648:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000364c:	60a6                	ld	ra,72(sp)
    8000364e:	6406                	ld	s0,64(sp)
    80003650:	74e2                	ld	s1,56(sp)
    80003652:	7942                	ld	s2,48(sp)
    80003654:	79a2                	ld	s3,40(sp)
    80003656:	6161                	addi	sp,sp,80
    80003658:	8082                	ret
  return -1;
    8000365a:	557d                	li	a0,-1
    8000365c:	bfc5                	j	8000364c <filestat+0x4c>

000000008000365e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000365e:	7179                	addi	sp,sp,-48
    80003660:	f406                	sd	ra,40(sp)
    80003662:	f022                	sd	s0,32(sp)
    80003664:	ec26                	sd	s1,24(sp)
    80003666:	e84a                	sd	s2,16(sp)
    80003668:	e44e                	sd	s3,8(sp)
    8000366a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000366c:	00854783          	lbu	a5,8(a0)
    80003670:	cbc1                	beqz	a5,80003700 <fileread+0xa2>
    80003672:	84aa                	mv	s1,a0
    80003674:	89ae                	mv	s3,a1
    80003676:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003678:	411c                	lw	a5,0(a0)
    8000367a:	4705                	li	a4,1
    8000367c:	04e78363          	beq	a5,a4,800036c2 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003680:	470d                	li	a4,3
    80003682:	04e78563          	beq	a5,a4,800036cc <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003686:	4709                	li	a4,2
    80003688:	06e79663          	bne	a5,a4,800036f4 <fileread+0x96>
    ilock(f->ip);
    8000368c:	6d08                	ld	a0,24(a0)
    8000368e:	a1eff0ef          	jal	ra,800028ac <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003692:	874a                	mv	a4,s2
    80003694:	5094                	lw	a3,32(s1)
    80003696:	864e                	mv	a2,s3
    80003698:	4585                	li	a1,1
    8000369a:	6c88                	ld	a0,24(s1)
    8000369c:	c60ff0ef          	jal	ra,80002afc <readi>
    800036a0:	892a                	mv	s2,a0
    800036a2:	00a05563          	blez	a0,800036ac <fileread+0x4e>
      f->off += r;
    800036a6:	509c                	lw	a5,32(s1)
    800036a8:	9fa9                	addw	a5,a5,a0
    800036aa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800036ac:	6c88                	ld	a0,24(s1)
    800036ae:	aa8ff0ef          	jal	ra,80002956 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800036b2:	854a                	mv	a0,s2
    800036b4:	70a2                	ld	ra,40(sp)
    800036b6:	7402                	ld	s0,32(sp)
    800036b8:	64e2                	ld	s1,24(sp)
    800036ba:	6942                	ld	s2,16(sp)
    800036bc:	69a2                	ld	s3,8(sp)
    800036be:	6145                	addi	sp,sp,48
    800036c0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800036c2:	6908                	ld	a0,16(a0)
    800036c4:	34e000ef          	jal	ra,80003a12 <piperead>
    800036c8:	892a                	mv	s2,a0
    800036ca:	b7e5                	j	800036b2 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800036cc:	02451783          	lh	a5,36(a0)
    800036d0:	03079693          	slli	a3,a5,0x30
    800036d4:	92c1                	srli	a3,a3,0x30
    800036d6:	4725                	li	a4,9
    800036d8:	02d76663          	bltu	a4,a3,80003704 <fileread+0xa6>
    800036dc:	0792                	slli	a5,a5,0x4
    800036de:	00014717          	auipc	a4,0x14
    800036e2:	61a70713          	addi	a4,a4,1562 # 80017cf8 <devsw>
    800036e6:	97ba                	add	a5,a5,a4
    800036e8:	639c                	ld	a5,0(a5)
    800036ea:	cf99                	beqz	a5,80003708 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800036ec:	4505                	li	a0,1
    800036ee:	9782                	jalr	a5
    800036f0:	892a                	mv	s2,a0
    800036f2:	b7c1                	j	800036b2 <fileread+0x54>
    panic("fileread");
    800036f4:	00004517          	auipc	a0,0x4
    800036f8:	0b450513          	addi	a0,a0,180 # 800077a8 <syscalls+0x2c0>
    800036fc:	627010ef          	jal	ra,80005522 <panic>
    return -1;
    80003700:	597d                	li	s2,-1
    80003702:	bf45                	j	800036b2 <fileread+0x54>
      return -1;
    80003704:	597d                	li	s2,-1
    80003706:	b775                	j	800036b2 <fileread+0x54>
    80003708:	597d                	li	s2,-1
    8000370a:	b765                	j	800036b2 <fileread+0x54>

000000008000370c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000370c:	715d                	addi	sp,sp,-80
    8000370e:	e486                	sd	ra,72(sp)
    80003710:	e0a2                	sd	s0,64(sp)
    80003712:	fc26                	sd	s1,56(sp)
    80003714:	f84a                	sd	s2,48(sp)
    80003716:	f44e                	sd	s3,40(sp)
    80003718:	f052                	sd	s4,32(sp)
    8000371a:	ec56                	sd	s5,24(sp)
    8000371c:	e85a                	sd	s6,16(sp)
    8000371e:	e45e                	sd	s7,8(sp)
    80003720:	e062                	sd	s8,0(sp)
    80003722:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003724:	00954783          	lbu	a5,9(a0)
    80003728:	0e078863          	beqz	a5,80003818 <filewrite+0x10c>
    8000372c:	892a                	mv	s2,a0
    8000372e:	8b2e                	mv	s6,a1
    80003730:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003732:	411c                	lw	a5,0(a0)
    80003734:	4705                	li	a4,1
    80003736:	02e78263          	beq	a5,a4,8000375a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000373a:	470d                	li	a4,3
    8000373c:	02e78463          	beq	a5,a4,80003764 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003740:	4709                	li	a4,2
    80003742:	0ce79563          	bne	a5,a4,8000380c <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003746:	0ac05163          	blez	a2,800037e8 <filewrite+0xdc>
    int i = 0;
    8000374a:	4981                	li	s3,0
    8000374c:	6b85                	lui	s7,0x1
    8000374e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003752:	6c05                	lui	s8,0x1
    80003754:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003758:	a041                	j	800037d8 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    8000375a:	6908                	ld	a0,16(a0)
    8000375c:	1e2000ef          	jal	ra,8000393e <pipewrite>
    80003760:	8a2a                	mv	s4,a0
    80003762:	a071                	j	800037ee <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003764:	02451783          	lh	a5,36(a0)
    80003768:	03079693          	slli	a3,a5,0x30
    8000376c:	92c1                	srli	a3,a3,0x30
    8000376e:	4725                	li	a4,9
    80003770:	0ad76663          	bltu	a4,a3,8000381c <filewrite+0x110>
    80003774:	0792                	slli	a5,a5,0x4
    80003776:	00014717          	auipc	a4,0x14
    8000377a:	58270713          	addi	a4,a4,1410 # 80017cf8 <devsw>
    8000377e:	97ba                	add	a5,a5,a4
    80003780:	679c                	ld	a5,8(a5)
    80003782:	cfd9                	beqz	a5,80003820 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80003784:	4505                	li	a0,1
    80003786:	9782                	jalr	a5
    80003788:	8a2a                	mv	s4,a0
    8000378a:	a095                	j	800037ee <filewrite+0xe2>
    8000378c:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003790:	9b1ff0ef          	jal	ra,80003140 <begin_op>
      ilock(f->ip);
    80003794:	01893503          	ld	a0,24(s2)
    80003798:	914ff0ef          	jal	ra,800028ac <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000379c:	8756                	mv	a4,s5
    8000379e:	02092683          	lw	a3,32(s2)
    800037a2:	01698633          	add	a2,s3,s6
    800037a6:	4585                	li	a1,1
    800037a8:	01893503          	ld	a0,24(s2)
    800037ac:	c34ff0ef          	jal	ra,80002be0 <writei>
    800037b0:	84aa                	mv	s1,a0
    800037b2:	00a05763          	blez	a0,800037c0 <filewrite+0xb4>
        f->off += r;
    800037b6:	02092783          	lw	a5,32(s2)
    800037ba:	9fa9                	addw	a5,a5,a0
    800037bc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800037c0:	01893503          	ld	a0,24(s2)
    800037c4:	992ff0ef          	jal	ra,80002956 <iunlock>
      end_op();
    800037c8:	9e7ff0ef          	jal	ra,800031ae <end_op>

      if(r != n1){
    800037cc:	009a9f63          	bne	s5,s1,800037ea <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800037d0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800037d4:	0149db63          	bge	s3,s4,800037ea <filewrite+0xde>
      int n1 = n - i;
    800037d8:	413a04bb          	subw	s1,s4,s3
    800037dc:	0004879b          	sext.w	a5,s1
    800037e0:	fafbd6e3          	bge	s7,a5,8000378c <filewrite+0x80>
    800037e4:	84e2                	mv	s1,s8
    800037e6:	b75d                	j	8000378c <filewrite+0x80>
    int i = 0;
    800037e8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800037ea:	013a1f63          	bne	s4,s3,80003808 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800037ee:	8552                	mv	a0,s4
    800037f0:	60a6                	ld	ra,72(sp)
    800037f2:	6406                	ld	s0,64(sp)
    800037f4:	74e2                	ld	s1,56(sp)
    800037f6:	7942                	ld	s2,48(sp)
    800037f8:	79a2                	ld	s3,40(sp)
    800037fa:	7a02                	ld	s4,32(sp)
    800037fc:	6ae2                	ld	s5,24(sp)
    800037fe:	6b42                	ld	s6,16(sp)
    80003800:	6ba2                	ld	s7,8(sp)
    80003802:	6c02                	ld	s8,0(sp)
    80003804:	6161                	addi	sp,sp,80
    80003806:	8082                	ret
    ret = (i == n ? n : -1);
    80003808:	5a7d                	li	s4,-1
    8000380a:	b7d5                	j	800037ee <filewrite+0xe2>
    panic("filewrite");
    8000380c:	00004517          	auipc	a0,0x4
    80003810:	fac50513          	addi	a0,a0,-84 # 800077b8 <syscalls+0x2d0>
    80003814:	50f010ef          	jal	ra,80005522 <panic>
    return -1;
    80003818:	5a7d                	li	s4,-1
    8000381a:	bfd1                	j	800037ee <filewrite+0xe2>
      return -1;
    8000381c:	5a7d                	li	s4,-1
    8000381e:	bfc1                	j	800037ee <filewrite+0xe2>
    80003820:	5a7d                	li	s4,-1
    80003822:	b7f1                	j	800037ee <filewrite+0xe2>

0000000080003824 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003824:	7179                	addi	sp,sp,-48
    80003826:	f406                	sd	ra,40(sp)
    80003828:	f022                	sd	s0,32(sp)
    8000382a:	ec26                	sd	s1,24(sp)
    8000382c:	e84a                	sd	s2,16(sp)
    8000382e:	e44e                	sd	s3,8(sp)
    80003830:	e052                	sd	s4,0(sp)
    80003832:	1800                	addi	s0,sp,48
    80003834:	84aa                	mv	s1,a0
    80003836:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003838:	0005b023          	sd	zero,0(a1)
    8000383c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003840:	c75ff0ef          	jal	ra,800034b4 <filealloc>
    80003844:	e088                	sd	a0,0(s1)
    80003846:	cd35                	beqz	a0,800038c2 <pipealloc+0x9e>
    80003848:	c6dff0ef          	jal	ra,800034b4 <filealloc>
    8000384c:	00aa3023          	sd	a0,0(s4)
    80003850:	c52d                	beqz	a0,800038ba <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003852:	913fc0ef          	jal	ra,80000164 <kalloc>
    80003856:	892a                	mv	s2,a0
    80003858:	cd31                	beqz	a0,800038b4 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    8000385a:	4985                	li	s3,1
    8000385c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003860:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003864:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003868:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000386c:	00004597          	auipc	a1,0x4
    80003870:	f5c58593          	addi	a1,a1,-164 # 800077c8 <syscalls+0x2e0>
    80003874:	73f010ef          	jal	ra,800057b2 <initlock>
  (*f0)->type = FD_PIPE;
    80003878:	609c                	ld	a5,0(s1)
    8000387a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000387e:	609c                	ld	a5,0(s1)
    80003880:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003884:	609c                	ld	a5,0(s1)
    80003886:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000388a:	609c                	ld	a5,0(s1)
    8000388c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003890:	000a3783          	ld	a5,0(s4)
    80003894:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003898:	000a3783          	ld	a5,0(s4)
    8000389c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800038a0:	000a3783          	ld	a5,0(s4)
    800038a4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800038a8:	000a3783          	ld	a5,0(s4)
    800038ac:	0127b823          	sd	s2,16(a5)
  return 0;
    800038b0:	4501                	li	a0,0
    800038b2:	a005                	j	800038d2 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800038b4:	6088                	ld	a0,0(s1)
    800038b6:	e501                	bnez	a0,800038be <pipealloc+0x9a>
    800038b8:	a029                	j	800038c2 <pipealloc+0x9e>
    800038ba:	6088                	ld	a0,0(s1)
    800038bc:	c11d                	beqz	a0,800038e2 <pipealloc+0xbe>
    fileclose(*f0);
    800038be:	c9bff0ef          	jal	ra,80003558 <fileclose>
  if(*f1)
    800038c2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800038c6:	557d                	li	a0,-1
  if(*f1)
    800038c8:	c789                	beqz	a5,800038d2 <pipealloc+0xae>
    fileclose(*f1);
    800038ca:	853e                	mv	a0,a5
    800038cc:	c8dff0ef          	jal	ra,80003558 <fileclose>
  return -1;
    800038d0:	557d                	li	a0,-1
}
    800038d2:	70a2                	ld	ra,40(sp)
    800038d4:	7402                	ld	s0,32(sp)
    800038d6:	64e2                	ld	s1,24(sp)
    800038d8:	6942                	ld	s2,16(sp)
    800038da:	69a2                	ld	s3,8(sp)
    800038dc:	6a02                	ld	s4,0(sp)
    800038de:	6145                	addi	sp,sp,48
    800038e0:	8082                	ret
  return -1;
    800038e2:	557d                	li	a0,-1
    800038e4:	b7fd                	j	800038d2 <pipealloc+0xae>

00000000800038e6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800038e6:	1101                	addi	sp,sp,-32
    800038e8:	ec06                	sd	ra,24(sp)
    800038ea:	e822                	sd	s0,16(sp)
    800038ec:	e426                	sd	s1,8(sp)
    800038ee:	e04a                	sd	s2,0(sp)
    800038f0:	1000                	addi	s0,sp,32
    800038f2:	84aa                	mv	s1,a0
    800038f4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800038f6:	73d010ef          	jal	ra,80005832 <acquire>
  if(writable){
    800038fa:	02090763          	beqz	s2,80003928 <pipeclose+0x42>
    pi->writeopen = 0;
    800038fe:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003902:	21848513          	addi	a0,s1,536
    80003906:	cb1fd0ef          	jal	ra,800015b6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000390a:	2204b783          	ld	a5,544(s1)
    8000390e:	e785                	bnez	a5,80003936 <pipeclose+0x50>
    release(&pi->lock);
    80003910:	8526                	mv	a0,s1
    80003912:	7b9010ef          	jal	ra,800058ca <release>
    kfree((char*)pi);
    80003916:	8526                	mv	a0,s1
    80003918:	f58fc0ef          	jal	ra,80000070 <kfree>
  } else
    release(&pi->lock);
}
    8000391c:	60e2                	ld	ra,24(sp)
    8000391e:	6442                	ld	s0,16(sp)
    80003920:	64a2                	ld	s1,8(sp)
    80003922:	6902                	ld	s2,0(sp)
    80003924:	6105                	addi	sp,sp,32
    80003926:	8082                	ret
    pi->readopen = 0;
    80003928:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000392c:	21c48513          	addi	a0,s1,540
    80003930:	c87fd0ef          	jal	ra,800015b6 <wakeup>
    80003934:	bfd9                	j	8000390a <pipeclose+0x24>
    release(&pi->lock);
    80003936:	8526                	mv	a0,s1
    80003938:	793010ef          	jal	ra,800058ca <release>
}
    8000393c:	b7c5                	j	8000391c <pipeclose+0x36>

000000008000393e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000393e:	711d                	addi	sp,sp,-96
    80003940:	ec86                	sd	ra,88(sp)
    80003942:	e8a2                	sd	s0,80(sp)
    80003944:	e4a6                	sd	s1,72(sp)
    80003946:	e0ca                	sd	s2,64(sp)
    80003948:	fc4e                	sd	s3,56(sp)
    8000394a:	f852                	sd	s4,48(sp)
    8000394c:	f456                	sd	s5,40(sp)
    8000394e:	f05a                	sd	s6,32(sp)
    80003950:	ec5e                	sd	s7,24(sp)
    80003952:	e862                	sd	s8,16(sp)
    80003954:	1080                	addi	s0,sp,96
    80003956:	84aa                	mv	s1,a0
    80003958:	8aae                	mv	s5,a1
    8000395a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000395c:	e42fd0ef          	jal	ra,80000f9e <myproc>
    80003960:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003962:	8526                	mv	a0,s1
    80003964:	6cf010ef          	jal	ra,80005832 <acquire>
  while(i < n){
    80003968:	09405c63          	blez	s4,80003a00 <pipewrite+0xc2>
  int i = 0;
    8000396c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000396e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003970:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003974:	21c48b93          	addi	s7,s1,540
    80003978:	a81d                	j	800039ae <pipewrite+0x70>
      release(&pi->lock);
    8000397a:	8526                	mv	a0,s1
    8000397c:	74f010ef          	jal	ra,800058ca <release>
      return -1;
    80003980:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003982:	854a                	mv	a0,s2
    80003984:	60e6                	ld	ra,88(sp)
    80003986:	6446                	ld	s0,80(sp)
    80003988:	64a6                	ld	s1,72(sp)
    8000398a:	6906                	ld	s2,64(sp)
    8000398c:	79e2                	ld	s3,56(sp)
    8000398e:	7a42                	ld	s4,48(sp)
    80003990:	7aa2                	ld	s5,40(sp)
    80003992:	7b02                	ld	s6,32(sp)
    80003994:	6be2                	ld	s7,24(sp)
    80003996:	6c42                	ld	s8,16(sp)
    80003998:	6125                	addi	sp,sp,96
    8000399a:	8082                	ret
      wakeup(&pi->nread);
    8000399c:	8562                	mv	a0,s8
    8000399e:	c19fd0ef          	jal	ra,800015b6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800039a2:	85a6                	mv	a1,s1
    800039a4:	855e                	mv	a0,s7
    800039a6:	bc5fd0ef          	jal	ra,8000156a <sleep>
  while(i < n){
    800039aa:	05495c63          	bge	s2,s4,80003a02 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    800039ae:	2204a783          	lw	a5,544(s1)
    800039b2:	d7e1                	beqz	a5,8000397a <pipewrite+0x3c>
    800039b4:	854e                	mv	a0,s3
    800039b6:	dedfd0ef          	jal	ra,800017a2 <killed>
    800039ba:	f161                	bnez	a0,8000397a <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800039bc:	2184a783          	lw	a5,536(s1)
    800039c0:	21c4a703          	lw	a4,540(s1)
    800039c4:	2007879b          	addiw	a5,a5,512
    800039c8:	fcf70ae3          	beq	a4,a5,8000399c <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800039cc:	4685                	li	a3,1
    800039ce:	01590633          	add	a2,s2,s5
    800039d2:	faf40593          	addi	a1,s0,-81
    800039d6:	0509b503          	ld	a0,80(s3)
    800039da:	a20fd0ef          	jal	ra,80000bfa <copyin>
    800039de:	03650263          	beq	a0,s6,80003a02 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800039e2:	21c4a783          	lw	a5,540(s1)
    800039e6:	0017871b          	addiw	a4,a5,1
    800039ea:	20e4ae23          	sw	a4,540(s1)
    800039ee:	1ff7f793          	andi	a5,a5,511
    800039f2:	97a6                	add	a5,a5,s1
    800039f4:	faf44703          	lbu	a4,-81(s0)
    800039f8:	00e78c23          	sb	a4,24(a5)
      i++;
    800039fc:	2905                	addiw	s2,s2,1
    800039fe:	b775                	j	800039aa <pipewrite+0x6c>
  int i = 0;
    80003a00:	4901                	li	s2,0
  wakeup(&pi->nread);
    80003a02:	21848513          	addi	a0,s1,536
    80003a06:	bb1fd0ef          	jal	ra,800015b6 <wakeup>
  release(&pi->lock);
    80003a0a:	8526                	mv	a0,s1
    80003a0c:	6bf010ef          	jal	ra,800058ca <release>
  return i;
    80003a10:	bf8d                	j	80003982 <pipewrite+0x44>

0000000080003a12 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003a12:	715d                	addi	sp,sp,-80
    80003a14:	e486                	sd	ra,72(sp)
    80003a16:	e0a2                	sd	s0,64(sp)
    80003a18:	fc26                	sd	s1,56(sp)
    80003a1a:	f84a                	sd	s2,48(sp)
    80003a1c:	f44e                	sd	s3,40(sp)
    80003a1e:	f052                	sd	s4,32(sp)
    80003a20:	ec56                	sd	s5,24(sp)
    80003a22:	e85a                	sd	s6,16(sp)
    80003a24:	0880                	addi	s0,sp,80
    80003a26:	84aa                	mv	s1,a0
    80003a28:	892e                	mv	s2,a1
    80003a2a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003a2c:	d72fd0ef          	jal	ra,80000f9e <myproc>
    80003a30:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003a32:	8526                	mv	a0,s1
    80003a34:	5ff010ef          	jal	ra,80005832 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003a38:	2184a703          	lw	a4,536(s1)
    80003a3c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003a40:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003a44:	02f71363          	bne	a4,a5,80003a6a <piperead+0x58>
    80003a48:	2244a783          	lw	a5,548(s1)
    80003a4c:	cf99                	beqz	a5,80003a6a <piperead+0x58>
    if(killed(pr)){
    80003a4e:	8552                	mv	a0,s4
    80003a50:	d53fd0ef          	jal	ra,800017a2 <killed>
    80003a54:	e149                	bnez	a0,80003ad6 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003a56:	85a6                	mv	a1,s1
    80003a58:	854e                	mv	a0,s3
    80003a5a:	b11fd0ef          	jal	ra,8000156a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003a5e:	2184a703          	lw	a4,536(s1)
    80003a62:	21c4a783          	lw	a5,540(s1)
    80003a66:	fef701e3          	beq	a4,a5,80003a48 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a6a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003a6c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a6e:	05505263          	blez	s5,80003ab2 <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    80003a72:	2184a783          	lw	a5,536(s1)
    80003a76:	21c4a703          	lw	a4,540(s1)
    80003a7a:	02f70c63          	beq	a4,a5,80003ab2 <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003a7e:	0017871b          	addiw	a4,a5,1
    80003a82:	20e4ac23          	sw	a4,536(s1)
    80003a86:	1ff7f793          	andi	a5,a5,511
    80003a8a:	97a6                	add	a5,a5,s1
    80003a8c:	0187c783          	lbu	a5,24(a5)
    80003a90:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003a94:	4685                	li	a3,1
    80003a96:	fbf40613          	addi	a2,s0,-65
    80003a9a:	85ca                	mv	a1,s2
    80003a9c:	050a3503          	ld	a0,80(s4)
    80003aa0:	8a2fd0ef          	jal	ra,80000b42 <copyout>
    80003aa4:	01650763          	beq	a0,s6,80003ab2 <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003aa8:	2985                	addiw	s3,s3,1
    80003aaa:	0905                	addi	s2,s2,1
    80003aac:	fd3a93e3          	bne	s5,s3,80003a72 <piperead+0x60>
    80003ab0:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003ab2:	21c48513          	addi	a0,s1,540
    80003ab6:	b01fd0ef          	jal	ra,800015b6 <wakeup>
  release(&pi->lock);
    80003aba:	8526                	mv	a0,s1
    80003abc:	60f010ef          	jal	ra,800058ca <release>
  return i;
}
    80003ac0:	854e                	mv	a0,s3
    80003ac2:	60a6                	ld	ra,72(sp)
    80003ac4:	6406                	ld	s0,64(sp)
    80003ac6:	74e2                	ld	s1,56(sp)
    80003ac8:	7942                	ld	s2,48(sp)
    80003aca:	79a2                	ld	s3,40(sp)
    80003acc:	7a02                	ld	s4,32(sp)
    80003ace:	6ae2                	ld	s5,24(sp)
    80003ad0:	6b42                	ld	s6,16(sp)
    80003ad2:	6161                	addi	sp,sp,80
    80003ad4:	8082                	ret
      release(&pi->lock);
    80003ad6:	8526                	mv	a0,s1
    80003ad8:	5f3010ef          	jal	ra,800058ca <release>
      return -1;
    80003adc:	59fd                	li	s3,-1
    80003ade:	b7cd                	j	80003ac0 <piperead+0xae>

0000000080003ae0 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003ae0:	1141                	addi	sp,sp,-16
    80003ae2:	e422                	sd	s0,8(sp)
    80003ae4:	0800                	addi	s0,sp,16
    80003ae6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003ae8:	8905                	andi	a0,a0,1
    80003aea:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003aec:	8b89                	andi	a5,a5,2
    80003aee:	c399                	beqz	a5,80003af4 <flags2perm+0x14>
      perm |= PTE_W;
    80003af0:	00456513          	ori	a0,a0,4
    return perm;
}
    80003af4:	6422                	ld	s0,8(sp)
    80003af6:	0141                	addi	sp,sp,16
    80003af8:	8082                	ret

0000000080003afa <exec>:

int
exec(char *path, char **argv)
{
    80003afa:	de010113          	addi	sp,sp,-544
    80003afe:	20113c23          	sd	ra,536(sp)
    80003b02:	20813823          	sd	s0,528(sp)
    80003b06:	20913423          	sd	s1,520(sp)
    80003b0a:	21213023          	sd	s2,512(sp)
    80003b0e:	ffce                	sd	s3,504(sp)
    80003b10:	fbd2                	sd	s4,496(sp)
    80003b12:	f7d6                	sd	s5,488(sp)
    80003b14:	f3da                	sd	s6,480(sp)
    80003b16:	efde                	sd	s7,472(sp)
    80003b18:	ebe2                	sd	s8,464(sp)
    80003b1a:	e7e6                	sd	s9,456(sp)
    80003b1c:	e3ea                	sd	s10,448(sp)
    80003b1e:	ff6e                	sd	s11,440(sp)
    80003b20:	1400                	addi	s0,sp,544
    80003b22:	892a                	mv	s2,a0
    80003b24:	dea43423          	sd	a0,-536(s0)
    80003b28:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003b2c:	c72fd0ef          	jal	ra,80000f9e <myproc>
    80003b30:	84aa                	mv	s1,a0

  begin_op();
    80003b32:	e0eff0ef          	jal	ra,80003140 <begin_op>

  if((ip = namei(path)) == 0){
    80003b36:	854a                	mv	a0,s2
    80003b38:	c2cff0ef          	jal	ra,80002f64 <namei>
    80003b3c:	c13d                	beqz	a0,80003ba2 <exec+0xa8>
    80003b3e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003b40:	d6dfe0ef          	jal	ra,800028ac <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003b44:	04000713          	li	a4,64
    80003b48:	4681                	li	a3,0
    80003b4a:	e5040613          	addi	a2,s0,-432
    80003b4e:	4581                	li	a1,0
    80003b50:	8556                	mv	a0,s5
    80003b52:	fabfe0ef          	jal	ra,80002afc <readi>
    80003b56:	04000793          	li	a5,64
    80003b5a:	00f51a63          	bne	a0,a5,80003b6e <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003b5e:	e5042703          	lw	a4,-432(s0)
    80003b62:	464c47b7          	lui	a5,0x464c4
    80003b66:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003b6a:	04f70063          	beq	a4,a5,80003baa <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003b6e:	8556                	mv	a0,s5
    80003b70:	f43fe0ef          	jal	ra,80002ab2 <iunlockput>
    end_op();
    80003b74:	e3aff0ef          	jal	ra,800031ae <end_op>
  }
  return -1;
    80003b78:	557d                	li	a0,-1
}
    80003b7a:	21813083          	ld	ra,536(sp)
    80003b7e:	21013403          	ld	s0,528(sp)
    80003b82:	20813483          	ld	s1,520(sp)
    80003b86:	20013903          	ld	s2,512(sp)
    80003b8a:	79fe                	ld	s3,504(sp)
    80003b8c:	7a5e                	ld	s4,496(sp)
    80003b8e:	7abe                	ld	s5,488(sp)
    80003b90:	7b1e                	ld	s6,480(sp)
    80003b92:	6bfe                	ld	s7,472(sp)
    80003b94:	6c5e                	ld	s8,464(sp)
    80003b96:	6cbe                	ld	s9,456(sp)
    80003b98:	6d1e                	ld	s10,448(sp)
    80003b9a:	7dfa                	ld	s11,440(sp)
    80003b9c:	22010113          	addi	sp,sp,544
    80003ba0:	8082                	ret
    end_op();
    80003ba2:	e0cff0ef          	jal	ra,800031ae <end_op>
    return -1;
    80003ba6:	557d                	li	a0,-1
    80003ba8:	bfc9                	j	80003b7a <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    80003baa:	8526                	mv	a0,s1
    80003bac:	c9afd0ef          	jal	ra,80001046 <proc_pagetable>
    80003bb0:	8b2a                	mv	s6,a0
    80003bb2:	dd55                	beqz	a0,80003b6e <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003bb4:	e7042783          	lw	a5,-400(s0)
    80003bb8:	e8845703          	lhu	a4,-376(s0)
    80003bbc:	c325                	beqz	a4,80003c1c <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003bbe:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003bc0:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80003bc4:	6a05                	lui	s4,0x1
    80003bc6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80003bca:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80003bce:	6d85                	lui	s11,0x1
    80003bd0:	7d7d                	lui	s10,0xfffff
    80003bd2:	a409                	j	80003dd4 <exec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80003bd4:	00004517          	auipc	a0,0x4
    80003bd8:	bfc50513          	addi	a0,a0,-1028 # 800077d0 <syscalls+0x2e8>
    80003bdc:	147010ef          	jal	ra,80005522 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003be0:	874a                	mv	a4,s2
    80003be2:	009c86bb          	addw	a3,s9,s1
    80003be6:	4581                	li	a1,0
    80003be8:	8556                	mv	a0,s5
    80003bea:	f13fe0ef          	jal	ra,80002afc <readi>
    80003bee:	2501                	sext.w	a0,a0
    80003bf0:	18a91163          	bne	s2,a0,80003d72 <exec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80003bf4:	009d84bb          	addw	s1,s11,s1
    80003bf8:	013d09bb          	addw	s3,s10,s3
    80003bfc:	1b74fc63          	bgeu	s1,s7,80003db4 <exec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80003c00:	02049593          	slli	a1,s1,0x20
    80003c04:	9181                	srli	a1,a1,0x20
    80003c06:	95e2                	add	a1,a1,s8
    80003c08:	855a                	mv	a0,s6
    80003c0a:	9c9fc0ef          	jal	ra,800005d2 <walkaddr>
    80003c0e:	862a                	mv	a2,a0
    if(pa == 0)
    80003c10:	d171                	beqz	a0,80003bd4 <exec+0xda>
      n = PGSIZE;
    80003c12:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80003c14:	fd49f6e3          	bgeu	s3,s4,80003be0 <exec+0xe6>
      n = sz - i;
    80003c18:	894e                	mv	s2,s3
    80003c1a:	b7d9                	j	80003be0 <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003c1c:	4901                	li	s2,0
  iunlockput(ip);
    80003c1e:	8556                	mv	a0,s5
    80003c20:	e93fe0ef          	jal	ra,80002ab2 <iunlockput>
  end_op();
    80003c24:	d8aff0ef          	jal	ra,800031ae <end_op>
  p = myproc();
    80003c28:	b76fd0ef          	jal	ra,80000f9e <myproc>
    80003c2c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80003c2e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003c32:	6785                	lui	a5,0x1
    80003c34:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80003c36:	97ca                	add	a5,a5,s2
    80003c38:	777d                	lui	a4,0xfffff
    80003c3a:	8ff9                	and	a5,a5,a4
    80003c3c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003c40:	4691                	li	a3,4
    80003c42:	6609                	lui	a2,0x2
    80003c44:	963e                	add	a2,a2,a5
    80003c46:	85be                	mv	a1,a5
    80003c48:	855a                	mv	a0,s6
    80003c4a:	cf1fc0ef          	jal	ra,8000093a <uvmalloc>
    80003c4e:	8c2a                	mv	s8,a0
  ip = 0;
    80003c50:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003c52:	12050063          	beqz	a0,80003d72 <exec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003c56:	75f9                	lui	a1,0xffffe
    80003c58:	95aa                	add	a1,a1,a0
    80003c5a:	855a                	mv	a0,s6
    80003c5c:	ebdfc0ef          	jal	ra,80000b18 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003c60:	7afd                	lui	s5,0xfffff
    80003c62:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80003c64:	df043783          	ld	a5,-528(s0)
    80003c68:	6388                	ld	a0,0(a5)
    80003c6a:	c135                	beqz	a0,80003cce <exec+0x1d4>
    80003c6c:	e9040993          	addi	s3,s0,-368
    80003c70:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80003c74:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003c76:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003c78:	fb2fc0ef          	jal	ra,8000042a <strlen>
    80003c7c:	0015079b          	addiw	a5,a0,1
    80003c80:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003c84:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003c88:	11596a63          	bltu	s2,s5,80003d9c <exec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003c8c:	df043d83          	ld	s11,-528(s0)
    80003c90:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80003c94:	8552                	mv	a0,s4
    80003c96:	f94fc0ef          	jal	ra,8000042a <strlen>
    80003c9a:	0015069b          	addiw	a3,a0,1
    80003c9e:	8652                	mv	a2,s4
    80003ca0:	85ca                	mv	a1,s2
    80003ca2:	855a                	mv	a0,s6
    80003ca4:	e9ffc0ef          	jal	ra,80000b42 <copyout>
    80003ca8:	0e054e63          	bltz	a0,80003da4 <exec+0x2aa>
    ustack[argc] = sp;
    80003cac:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003cb0:	0485                	addi	s1,s1,1
    80003cb2:	008d8793          	addi	a5,s11,8
    80003cb6:	def43823          	sd	a5,-528(s0)
    80003cba:	008db503          	ld	a0,8(s11)
    80003cbe:	c911                	beqz	a0,80003cd2 <exec+0x1d8>
    if(argc >= MAXARG)
    80003cc0:	09a1                	addi	s3,s3,8
    80003cc2:	fb3c9be3          	bne	s9,s3,80003c78 <exec+0x17e>
  sz = sz1;
    80003cc6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003cca:	4a81                	li	s5,0
    80003ccc:	a05d                	j	80003d72 <exec+0x278>
  sp = sz;
    80003cce:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003cd0:	4481                	li	s1,0
  ustack[argc] = 0;
    80003cd2:	00349793          	slli	a5,s1,0x3
    80003cd6:	f9078793          	addi	a5,a5,-112
    80003cda:	97a2                	add	a5,a5,s0
    80003cdc:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003ce0:	00148693          	addi	a3,s1,1
    80003ce4:	068e                	slli	a3,a3,0x3
    80003ce6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003cea:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80003cee:	01597663          	bgeu	s2,s5,80003cfa <exec+0x200>
  sz = sz1;
    80003cf2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003cf6:	4a81                	li	s5,0
    80003cf8:	a8ad                	j	80003d72 <exec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003cfa:	e9040613          	addi	a2,s0,-368
    80003cfe:	85ca                	mv	a1,s2
    80003d00:	855a                	mv	a0,s6
    80003d02:	e41fc0ef          	jal	ra,80000b42 <copyout>
    80003d06:	0a054363          	bltz	a0,80003dac <exec+0x2b2>
  p->trapframe->a1 = sp;
    80003d0a:	058bb783          	ld	a5,88(s7)
    80003d0e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003d12:	de843783          	ld	a5,-536(s0)
    80003d16:	0007c703          	lbu	a4,0(a5)
    80003d1a:	cf11                	beqz	a4,80003d36 <exec+0x23c>
    80003d1c:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003d1e:	02f00693          	li	a3,47
    80003d22:	a039                	j	80003d30 <exec+0x236>
      last = s+1;
    80003d24:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80003d28:	0785                	addi	a5,a5,1
    80003d2a:	fff7c703          	lbu	a4,-1(a5)
    80003d2e:	c701                	beqz	a4,80003d36 <exec+0x23c>
    if(*s == '/')
    80003d30:	fed71ce3          	bne	a4,a3,80003d28 <exec+0x22e>
    80003d34:	bfc5                	j	80003d24 <exec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80003d36:	4641                	li	a2,16
    80003d38:	de843583          	ld	a1,-536(s0)
    80003d3c:	158b8513          	addi	a0,s7,344
    80003d40:	eb8fc0ef          	jal	ra,800003f8 <safestrcpy>
  oldpagetable = p->pagetable;
    80003d44:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80003d48:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80003d4c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003d50:	058bb783          	ld	a5,88(s7)
    80003d54:	e6843703          	ld	a4,-408(s0)
    80003d58:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003d5a:	058bb783          	ld	a5,88(s7)
    80003d5e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003d62:	85ea                	mv	a1,s10
    80003d64:	b66fd0ef          	jal	ra,800010ca <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003d68:	0004851b          	sext.w	a0,s1
    80003d6c:	b539                	j	80003b7a <exec+0x80>
    80003d6e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80003d72:	df843583          	ld	a1,-520(s0)
    80003d76:	855a                	mv	a0,s6
    80003d78:	b52fd0ef          	jal	ra,800010ca <proc_freepagetable>
  if(ip){
    80003d7c:	de0a99e3          	bnez	s5,80003b6e <exec+0x74>
  return -1;
    80003d80:	557d                	li	a0,-1
    80003d82:	bbe5                	j	80003b7a <exec+0x80>
    80003d84:	df243c23          	sd	s2,-520(s0)
    80003d88:	b7ed                	j	80003d72 <exec+0x278>
    80003d8a:	df243c23          	sd	s2,-520(s0)
    80003d8e:	b7d5                	j	80003d72 <exec+0x278>
    80003d90:	df243c23          	sd	s2,-520(s0)
    80003d94:	bff9                	j	80003d72 <exec+0x278>
    80003d96:	df243c23          	sd	s2,-520(s0)
    80003d9a:	bfe1                	j	80003d72 <exec+0x278>
  sz = sz1;
    80003d9c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003da0:	4a81                	li	s5,0
    80003da2:	bfc1                	j	80003d72 <exec+0x278>
  sz = sz1;
    80003da4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003da8:	4a81                	li	s5,0
    80003daa:	b7e1                	j	80003d72 <exec+0x278>
  sz = sz1;
    80003dac:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003db0:	4a81                	li	s5,0
    80003db2:	b7c1                	j	80003d72 <exec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003db4:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003db8:	e0843783          	ld	a5,-504(s0)
    80003dbc:	0017869b          	addiw	a3,a5,1
    80003dc0:	e0d43423          	sd	a3,-504(s0)
    80003dc4:	e0043783          	ld	a5,-512(s0)
    80003dc8:	0387879b          	addiw	a5,a5,56
    80003dcc:	e8845703          	lhu	a4,-376(s0)
    80003dd0:	e4e6d7e3          	bge	a3,a4,80003c1e <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003dd4:	2781                	sext.w	a5,a5
    80003dd6:	e0f43023          	sd	a5,-512(s0)
    80003dda:	03800713          	li	a4,56
    80003dde:	86be                	mv	a3,a5
    80003de0:	e1840613          	addi	a2,s0,-488
    80003de4:	4581                	li	a1,0
    80003de6:	8556                	mv	a0,s5
    80003de8:	d15fe0ef          	jal	ra,80002afc <readi>
    80003dec:	03800793          	li	a5,56
    80003df0:	f6f51fe3          	bne	a0,a5,80003d6e <exec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80003df4:	e1842783          	lw	a5,-488(s0)
    80003df8:	4705                	li	a4,1
    80003dfa:	fae79fe3          	bne	a5,a4,80003db8 <exec+0x2be>
    if(ph.memsz < ph.filesz)
    80003dfe:	e4043483          	ld	s1,-448(s0)
    80003e02:	e3843783          	ld	a5,-456(s0)
    80003e06:	f6f4efe3          	bltu	s1,a5,80003d84 <exec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003e0a:	e2843783          	ld	a5,-472(s0)
    80003e0e:	94be                	add	s1,s1,a5
    80003e10:	f6f4ede3          	bltu	s1,a5,80003d8a <exec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80003e14:	de043703          	ld	a4,-544(s0)
    80003e18:	8ff9                	and	a5,a5,a4
    80003e1a:	fbbd                	bnez	a5,80003d90 <exec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003e1c:	e1c42503          	lw	a0,-484(s0)
    80003e20:	cc1ff0ef          	jal	ra,80003ae0 <flags2perm>
    80003e24:	86aa                	mv	a3,a0
    80003e26:	8626                	mv	a2,s1
    80003e28:	85ca                	mv	a1,s2
    80003e2a:	855a                	mv	a0,s6
    80003e2c:	b0ffc0ef          	jal	ra,8000093a <uvmalloc>
    80003e30:	dea43c23          	sd	a0,-520(s0)
    80003e34:	d12d                	beqz	a0,80003d96 <exec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003e36:	e2843c03          	ld	s8,-472(s0)
    80003e3a:	e2042c83          	lw	s9,-480(s0)
    80003e3e:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003e42:	f60b89e3          	beqz	s7,80003db4 <exec+0x2ba>
    80003e46:	89de                	mv	s3,s7
    80003e48:	4481                	li	s1,0
    80003e4a:	bb5d                	j	80003c00 <exec+0x106>

0000000080003e4c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003e4c:	7179                	addi	sp,sp,-48
    80003e4e:	f406                	sd	ra,40(sp)
    80003e50:	f022                	sd	s0,32(sp)
    80003e52:	ec26                	sd	s1,24(sp)
    80003e54:	e84a                	sd	s2,16(sp)
    80003e56:	1800                	addi	s0,sp,48
    80003e58:	892e                	mv	s2,a1
    80003e5a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003e5c:	fdc40593          	addi	a1,s0,-36
    80003e60:	fedfd0ef          	jal	ra,80001e4c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003e64:	fdc42703          	lw	a4,-36(s0)
    80003e68:	47bd                	li	a5,15
    80003e6a:	02e7e963          	bltu	a5,a4,80003e9c <argfd+0x50>
    80003e6e:	930fd0ef          	jal	ra,80000f9e <myproc>
    80003e72:	fdc42703          	lw	a4,-36(s0)
    80003e76:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffde08a>
    80003e7a:	078e                	slli	a5,a5,0x3
    80003e7c:	953e                	add	a0,a0,a5
    80003e7e:	611c                	ld	a5,0(a0)
    80003e80:	c385                	beqz	a5,80003ea0 <argfd+0x54>
    return -1;
  if(pfd)
    80003e82:	00090463          	beqz	s2,80003e8a <argfd+0x3e>
    *pfd = fd;
    80003e86:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003e8a:	4501                	li	a0,0
  if(pf)
    80003e8c:	c091                	beqz	s1,80003e90 <argfd+0x44>
    *pf = f;
    80003e8e:	e09c                	sd	a5,0(s1)
}
    80003e90:	70a2                	ld	ra,40(sp)
    80003e92:	7402                	ld	s0,32(sp)
    80003e94:	64e2                	ld	s1,24(sp)
    80003e96:	6942                	ld	s2,16(sp)
    80003e98:	6145                	addi	sp,sp,48
    80003e9a:	8082                	ret
    return -1;
    80003e9c:	557d                	li	a0,-1
    80003e9e:	bfcd                	j	80003e90 <argfd+0x44>
    80003ea0:	557d                	li	a0,-1
    80003ea2:	b7fd                	j	80003e90 <argfd+0x44>

0000000080003ea4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003ea4:	1101                	addi	sp,sp,-32
    80003ea6:	ec06                	sd	ra,24(sp)
    80003ea8:	e822                	sd	s0,16(sp)
    80003eaa:	e426                	sd	s1,8(sp)
    80003eac:	1000                	addi	s0,sp,32
    80003eae:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003eb0:	8eefd0ef          	jal	ra,80000f9e <myproc>
    80003eb4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003eb6:	0d050793          	addi	a5,a0,208
    80003eba:	4501                	li	a0,0
    80003ebc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003ebe:	6398                	ld	a4,0(a5)
    80003ec0:	cb19                	beqz	a4,80003ed6 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003ec2:	2505                	addiw	a0,a0,1
    80003ec4:	07a1                	addi	a5,a5,8
    80003ec6:	fed51ce3          	bne	a0,a3,80003ebe <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003eca:	557d                	li	a0,-1
}
    80003ecc:	60e2                	ld	ra,24(sp)
    80003ece:	6442                	ld	s0,16(sp)
    80003ed0:	64a2                	ld	s1,8(sp)
    80003ed2:	6105                	addi	sp,sp,32
    80003ed4:	8082                	ret
      p->ofile[fd] = f;
    80003ed6:	01a50793          	addi	a5,a0,26
    80003eda:	078e                	slli	a5,a5,0x3
    80003edc:	963e                	add	a2,a2,a5
    80003ede:	e204                	sd	s1,0(a2)
      return fd;
    80003ee0:	b7f5                	j	80003ecc <fdalloc+0x28>

0000000080003ee2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003ee2:	715d                	addi	sp,sp,-80
    80003ee4:	e486                	sd	ra,72(sp)
    80003ee6:	e0a2                	sd	s0,64(sp)
    80003ee8:	fc26                	sd	s1,56(sp)
    80003eea:	f84a                	sd	s2,48(sp)
    80003eec:	f44e                	sd	s3,40(sp)
    80003eee:	f052                	sd	s4,32(sp)
    80003ef0:	ec56                	sd	s5,24(sp)
    80003ef2:	e85a                	sd	s6,16(sp)
    80003ef4:	0880                	addi	s0,sp,80
    80003ef6:	8b2e                	mv	s6,a1
    80003ef8:	89b2                	mv	s3,a2
    80003efa:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003efc:	fb040593          	addi	a1,s0,-80
    80003f00:	87eff0ef          	jal	ra,80002f7e <nameiparent>
    80003f04:	84aa                	mv	s1,a0
    80003f06:	10050b63          	beqz	a0,8000401c <create+0x13a>
    return 0;

  ilock(dp);
    80003f0a:	9a3fe0ef          	jal	ra,800028ac <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f0e:	4601                	li	a2,0
    80003f10:	fb040593          	addi	a1,s0,-80
    80003f14:	8526                	mv	a0,s1
    80003f16:	de3fe0ef          	jal	ra,80002cf8 <dirlookup>
    80003f1a:	8aaa                	mv	s5,a0
    80003f1c:	c521                	beqz	a0,80003f64 <create+0x82>
    iunlockput(dp);
    80003f1e:	8526                	mv	a0,s1
    80003f20:	b93fe0ef          	jal	ra,80002ab2 <iunlockput>
    ilock(ip);
    80003f24:	8556                	mv	a0,s5
    80003f26:	987fe0ef          	jal	ra,800028ac <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003f2a:	000b059b          	sext.w	a1,s6
    80003f2e:	4789                	li	a5,2
    80003f30:	02f59563          	bne	a1,a5,80003f5a <create+0x78>
    80003f34:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde0b4>
    80003f38:	37f9                	addiw	a5,a5,-2
    80003f3a:	17c2                	slli	a5,a5,0x30
    80003f3c:	93c1                	srli	a5,a5,0x30
    80003f3e:	4705                	li	a4,1
    80003f40:	00f76d63          	bltu	a4,a5,80003f5a <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003f44:	8556                	mv	a0,s5
    80003f46:	60a6                	ld	ra,72(sp)
    80003f48:	6406                	ld	s0,64(sp)
    80003f4a:	74e2                	ld	s1,56(sp)
    80003f4c:	7942                	ld	s2,48(sp)
    80003f4e:	79a2                	ld	s3,40(sp)
    80003f50:	7a02                	ld	s4,32(sp)
    80003f52:	6ae2                	ld	s5,24(sp)
    80003f54:	6b42                	ld	s6,16(sp)
    80003f56:	6161                	addi	sp,sp,80
    80003f58:	8082                	ret
    iunlockput(ip);
    80003f5a:	8556                	mv	a0,s5
    80003f5c:	b57fe0ef          	jal	ra,80002ab2 <iunlockput>
    return 0;
    80003f60:	4a81                	li	s5,0
    80003f62:	b7cd                	j	80003f44 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80003f64:	85da                	mv	a1,s6
    80003f66:	4088                	lw	a0,0(s1)
    80003f68:	fdafe0ef          	jal	ra,80002742 <ialloc>
    80003f6c:	8a2a                	mv	s4,a0
    80003f6e:	cd1d                	beqz	a0,80003fac <create+0xca>
  ilock(ip);
    80003f70:	93dfe0ef          	jal	ra,800028ac <ilock>
  ip->major = major;
    80003f74:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003f78:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003f7c:	4905                	li	s2,1
    80003f7e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003f82:	8552                	mv	a0,s4
    80003f84:	875fe0ef          	jal	ra,800027f8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003f88:	000b059b          	sext.w	a1,s6
    80003f8c:	03258563          	beq	a1,s2,80003fb6 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80003f90:	004a2603          	lw	a2,4(s4)
    80003f94:	fb040593          	addi	a1,s0,-80
    80003f98:	8526                	mv	a0,s1
    80003f9a:	f31fe0ef          	jal	ra,80002eca <dirlink>
    80003f9e:	06054363          	bltz	a0,80004004 <create+0x122>
  iunlockput(dp);
    80003fa2:	8526                	mv	a0,s1
    80003fa4:	b0ffe0ef          	jal	ra,80002ab2 <iunlockput>
  return ip;
    80003fa8:	8ad2                	mv	s5,s4
    80003faa:	bf69                	j	80003f44 <create+0x62>
    iunlockput(dp);
    80003fac:	8526                	mv	a0,s1
    80003fae:	b05fe0ef          	jal	ra,80002ab2 <iunlockput>
    return 0;
    80003fb2:	8ad2                	mv	s5,s4
    80003fb4:	bf41                	j	80003f44 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003fb6:	004a2603          	lw	a2,4(s4)
    80003fba:	00004597          	auipc	a1,0x4
    80003fbe:	83658593          	addi	a1,a1,-1994 # 800077f0 <syscalls+0x308>
    80003fc2:	8552                	mv	a0,s4
    80003fc4:	f07fe0ef          	jal	ra,80002eca <dirlink>
    80003fc8:	02054e63          	bltz	a0,80004004 <create+0x122>
    80003fcc:	40d0                	lw	a2,4(s1)
    80003fce:	00004597          	auipc	a1,0x4
    80003fd2:	82a58593          	addi	a1,a1,-2006 # 800077f8 <syscalls+0x310>
    80003fd6:	8552                	mv	a0,s4
    80003fd8:	ef3fe0ef          	jal	ra,80002eca <dirlink>
    80003fdc:	02054463          	bltz	a0,80004004 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80003fe0:	004a2603          	lw	a2,4(s4)
    80003fe4:	fb040593          	addi	a1,s0,-80
    80003fe8:	8526                	mv	a0,s1
    80003fea:	ee1fe0ef          	jal	ra,80002eca <dirlink>
    80003fee:	00054b63          	bltz	a0,80004004 <create+0x122>
    dp->nlink++;  // for ".."
    80003ff2:	04a4d783          	lhu	a5,74(s1)
    80003ff6:	2785                	addiw	a5,a5,1
    80003ff8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	ffafe0ef          	jal	ra,800027f8 <iupdate>
    80004002:	b745                	j	80003fa2 <create+0xc0>
  ip->nlink = 0;
    80004004:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004008:	8552                	mv	a0,s4
    8000400a:	feefe0ef          	jal	ra,800027f8 <iupdate>
  iunlockput(ip);
    8000400e:	8552                	mv	a0,s4
    80004010:	aa3fe0ef          	jal	ra,80002ab2 <iunlockput>
  iunlockput(dp);
    80004014:	8526                	mv	a0,s1
    80004016:	a9dfe0ef          	jal	ra,80002ab2 <iunlockput>
  return 0;
    8000401a:	b72d                	j	80003f44 <create+0x62>
    return 0;
    8000401c:	8aaa                	mv	s5,a0
    8000401e:	b71d                	j	80003f44 <create+0x62>

0000000080004020 <sys_dup>:
{
    80004020:	7179                	addi	sp,sp,-48
    80004022:	f406                	sd	ra,40(sp)
    80004024:	f022                	sd	s0,32(sp)
    80004026:	ec26                	sd	s1,24(sp)
    80004028:	e84a                	sd	s2,16(sp)
    8000402a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000402c:	fd840613          	addi	a2,s0,-40
    80004030:	4581                	li	a1,0
    80004032:	4501                	li	a0,0
    80004034:	e19ff0ef          	jal	ra,80003e4c <argfd>
    return -1;
    80004038:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000403a:	00054f63          	bltz	a0,80004058 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    8000403e:	fd843903          	ld	s2,-40(s0)
    80004042:	854a                	mv	a0,s2
    80004044:	e61ff0ef          	jal	ra,80003ea4 <fdalloc>
    80004048:	84aa                	mv	s1,a0
    return -1;
    8000404a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000404c:	00054663          	bltz	a0,80004058 <sys_dup+0x38>
  filedup(f);
    80004050:	854a                	mv	a0,s2
    80004052:	cc0ff0ef          	jal	ra,80003512 <filedup>
  return fd;
    80004056:	87a6                	mv	a5,s1
}
    80004058:	853e                	mv	a0,a5
    8000405a:	70a2                	ld	ra,40(sp)
    8000405c:	7402                	ld	s0,32(sp)
    8000405e:	64e2                	ld	s1,24(sp)
    80004060:	6942                	ld	s2,16(sp)
    80004062:	6145                	addi	sp,sp,48
    80004064:	8082                	ret

0000000080004066 <sys_read>:
{
    80004066:	7179                	addi	sp,sp,-48
    80004068:	f406                	sd	ra,40(sp)
    8000406a:	f022                	sd	s0,32(sp)
    8000406c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000406e:	fd840593          	addi	a1,s0,-40
    80004072:	4505                	li	a0,1
    80004074:	df5fd0ef          	jal	ra,80001e68 <argaddr>
  argint(2, &n);
    80004078:	fe440593          	addi	a1,s0,-28
    8000407c:	4509                	li	a0,2
    8000407e:	dcffd0ef          	jal	ra,80001e4c <argint>
  if(argfd(0, 0, &f) < 0)
    80004082:	fe840613          	addi	a2,s0,-24
    80004086:	4581                	li	a1,0
    80004088:	4501                	li	a0,0
    8000408a:	dc3ff0ef          	jal	ra,80003e4c <argfd>
    8000408e:	87aa                	mv	a5,a0
    return -1;
    80004090:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004092:	0007ca63          	bltz	a5,800040a6 <sys_read+0x40>
  return fileread(f, p, n);
    80004096:	fe442603          	lw	a2,-28(s0)
    8000409a:	fd843583          	ld	a1,-40(s0)
    8000409e:	fe843503          	ld	a0,-24(s0)
    800040a2:	dbcff0ef          	jal	ra,8000365e <fileread>
}
    800040a6:	70a2                	ld	ra,40(sp)
    800040a8:	7402                	ld	s0,32(sp)
    800040aa:	6145                	addi	sp,sp,48
    800040ac:	8082                	ret

00000000800040ae <sys_write>:
{
    800040ae:	7179                	addi	sp,sp,-48
    800040b0:	f406                	sd	ra,40(sp)
    800040b2:	f022                	sd	s0,32(sp)
    800040b4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800040b6:	fd840593          	addi	a1,s0,-40
    800040ba:	4505                	li	a0,1
    800040bc:	dadfd0ef          	jal	ra,80001e68 <argaddr>
  argint(2, &n);
    800040c0:	fe440593          	addi	a1,s0,-28
    800040c4:	4509                	li	a0,2
    800040c6:	d87fd0ef          	jal	ra,80001e4c <argint>
  if(argfd(0, 0, &f) < 0)
    800040ca:	fe840613          	addi	a2,s0,-24
    800040ce:	4581                	li	a1,0
    800040d0:	4501                	li	a0,0
    800040d2:	d7bff0ef          	jal	ra,80003e4c <argfd>
    800040d6:	87aa                	mv	a5,a0
    return -1;
    800040d8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800040da:	0007ca63          	bltz	a5,800040ee <sys_write+0x40>
  return filewrite(f, p, n);
    800040de:	fe442603          	lw	a2,-28(s0)
    800040e2:	fd843583          	ld	a1,-40(s0)
    800040e6:	fe843503          	ld	a0,-24(s0)
    800040ea:	e22ff0ef          	jal	ra,8000370c <filewrite>
}
    800040ee:	70a2                	ld	ra,40(sp)
    800040f0:	7402                	ld	s0,32(sp)
    800040f2:	6145                	addi	sp,sp,48
    800040f4:	8082                	ret

00000000800040f6 <sys_close>:
{
    800040f6:	1101                	addi	sp,sp,-32
    800040f8:	ec06                	sd	ra,24(sp)
    800040fa:	e822                	sd	s0,16(sp)
    800040fc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800040fe:	fe040613          	addi	a2,s0,-32
    80004102:	fec40593          	addi	a1,s0,-20
    80004106:	4501                	li	a0,0
    80004108:	d45ff0ef          	jal	ra,80003e4c <argfd>
    return -1;
    8000410c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000410e:	02054063          	bltz	a0,8000412e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004112:	e8dfc0ef          	jal	ra,80000f9e <myproc>
    80004116:	fec42783          	lw	a5,-20(s0)
    8000411a:	07e9                	addi	a5,a5,26
    8000411c:	078e                	slli	a5,a5,0x3
    8000411e:	953e                	add	a0,a0,a5
    80004120:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004124:	fe043503          	ld	a0,-32(s0)
    80004128:	c30ff0ef          	jal	ra,80003558 <fileclose>
  return 0;
    8000412c:	4781                	li	a5,0
}
    8000412e:	853e                	mv	a0,a5
    80004130:	60e2                	ld	ra,24(sp)
    80004132:	6442                	ld	s0,16(sp)
    80004134:	6105                	addi	sp,sp,32
    80004136:	8082                	ret

0000000080004138 <sys_fstat>:
{
    80004138:	1101                	addi	sp,sp,-32
    8000413a:	ec06                	sd	ra,24(sp)
    8000413c:	e822                	sd	s0,16(sp)
    8000413e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004140:	fe040593          	addi	a1,s0,-32
    80004144:	4505                	li	a0,1
    80004146:	d23fd0ef          	jal	ra,80001e68 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000414a:	fe840613          	addi	a2,s0,-24
    8000414e:	4581                	li	a1,0
    80004150:	4501                	li	a0,0
    80004152:	cfbff0ef          	jal	ra,80003e4c <argfd>
    80004156:	87aa                	mv	a5,a0
    return -1;
    80004158:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000415a:	0007c863          	bltz	a5,8000416a <sys_fstat+0x32>
  return filestat(f, st);
    8000415e:	fe043583          	ld	a1,-32(s0)
    80004162:	fe843503          	ld	a0,-24(s0)
    80004166:	c9aff0ef          	jal	ra,80003600 <filestat>
}
    8000416a:	60e2                	ld	ra,24(sp)
    8000416c:	6442                	ld	s0,16(sp)
    8000416e:	6105                	addi	sp,sp,32
    80004170:	8082                	ret

0000000080004172 <sys_link>:
{
    80004172:	7169                	addi	sp,sp,-304
    80004174:	f606                	sd	ra,296(sp)
    80004176:	f222                	sd	s0,288(sp)
    80004178:	ee26                	sd	s1,280(sp)
    8000417a:	ea4a                	sd	s2,272(sp)
    8000417c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000417e:	08000613          	li	a2,128
    80004182:	ed040593          	addi	a1,s0,-304
    80004186:	4501                	li	a0,0
    80004188:	cfdfd0ef          	jal	ra,80001e84 <argstr>
    return -1;
    8000418c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000418e:	0c054663          	bltz	a0,8000425a <sys_link+0xe8>
    80004192:	08000613          	li	a2,128
    80004196:	f5040593          	addi	a1,s0,-176
    8000419a:	4505                	li	a0,1
    8000419c:	ce9fd0ef          	jal	ra,80001e84 <argstr>
    return -1;
    800041a0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800041a2:	0a054c63          	bltz	a0,8000425a <sys_link+0xe8>
  begin_op();
    800041a6:	f9bfe0ef          	jal	ra,80003140 <begin_op>
  if((ip = namei(old)) == 0){
    800041aa:	ed040513          	addi	a0,s0,-304
    800041ae:	db7fe0ef          	jal	ra,80002f64 <namei>
    800041b2:	84aa                	mv	s1,a0
    800041b4:	c525                	beqz	a0,8000421c <sys_link+0xaa>
  ilock(ip);
    800041b6:	ef6fe0ef          	jal	ra,800028ac <ilock>
  if(ip->type == T_DIR){
    800041ba:	04449703          	lh	a4,68(s1)
    800041be:	4785                	li	a5,1
    800041c0:	06f70263          	beq	a4,a5,80004224 <sys_link+0xb2>
  ip->nlink++;
    800041c4:	04a4d783          	lhu	a5,74(s1)
    800041c8:	2785                	addiw	a5,a5,1
    800041ca:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800041ce:	8526                	mv	a0,s1
    800041d0:	e28fe0ef          	jal	ra,800027f8 <iupdate>
  iunlock(ip);
    800041d4:	8526                	mv	a0,s1
    800041d6:	f80fe0ef          	jal	ra,80002956 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800041da:	fd040593          	addi	a1,s0,-48
    800041de:	f5040513          	addi	a0,s0,-176
    800041e2:	d9dfe0ef          	jal	ra,80002f7e <nameiparent>
    800041e6:	892a                	mv	s2,a0
    800041e8:	c921                	beqz	a0,80004238 <sys_link+0xc6>
  ilock(dp);
    800041ea:	ec2fe0ef          	jal	ra,800028ac <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800041ee:	00092703          	lw	a4,0(s2)
    800041f2:	409c                	lw	a5,0(s1)
    800041f4:	02f71f63          	bne	a4,a5,80004232 <sys_link+0xc0>
    800041f8:	40d0                	lw	a2,4(s1)
    800041fa:	fd040593          	addi	a1,s0,-48
    800041fe:	854a                	mv	a0,s2
    80004200:	ccbfe0ef          	jal	ra,80002eca <dirlink>
    80004204:	02054763          	bltz	a0,80004232 <sys_link+0xc0>
  iunlockput(dp);
    80004208:	854a                	mv	a0,s2
    8000420a:	8a9fe0ef          	jal	ra,80002ab2 <iunlockput>
  iput(ip);
    8000420e:	8526                	mv	a0,s1
    80004210:	81bfe0ef          	jal	ra,80002a2a <iput>
  end_op();
    80004214:	f9bfe0ef          	jal	ra,800031ae <end_op>
  return 0;
    80004218:	4781                	li	a5,0
    8000421a:	a081                	j	8000425a <sys_link+0xe8>
    end_op();
    8000421c:	f93fe0ef          	jal	ra,800031ae <end_op>
    return -1;
    80004220:	57fd                	li	a5,-1
    80004222:	a825                	j	8000425a <sys_link+0xe8>
    iunlockput(ip);
    80004224:	8526                	mv	a0,s1
    80004226:	88dfe0ef          	jal	ra,80002ab2 <iunlockput>
    end_op();
    8000422a:	f85fe0ef          	jal	ra,800031ae <end_op>
    return -1;
    8000422e:	57fd                	li	a5,-1
    80004230:	a02d                	j	8000425a <sys_link+0xe8>
    iunlockput(dp);
    80004232:	854a                	mv	a0,s2
    80004234:	87ffe0ef          	jal	ra,80002ab2 <iunlockput>
  ilock(ip);
    80004238:	8526                	mv	a0,s1
    8000423a:	e72fe0ef          	jal	ra,800028ac <ilock>
  ip->nlink--;
    8000423e:	04a4d783          	lhu	a5,74(s1)
    80004242:	37fd                	addiw	a5,a5,-1
    80004244:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004248:	8526                	mv	a0,s1
    8000424a:	daefe0ef          	jal	ra,800027f8 <iupdate>
  iunlockput(ip);
    8000424e:	8526                	mv	a0,s1
    80004250:	863fe0ef          	jal	ra,80002ab2 <iunlockput>
  end_op();
    80004254:	f5bfe0ef          	jal	ra,800031ae <end_op>
  return -1;
    80004258:	57fd                	li	a5,-1
}
    8000425a:	853e                	mv	a0,a5
    8000425c:	70b2                	ld	ra,296(sp)
    8000425e:	7412                	ld	s0,288(sp)
    80004260:	64f2                	ld	s1,280(sp)
    80004262:	6952                	ld	s2,272(sp)
    80004264:	6155                	addi	sp,sp,304
    80004266:	8082                	ret

0000000080004268 <sys_unlink>:
{
    80004268:	7151                	addi	sp,sp,-240
    8000426a:	f586                	sd	ra,232(sp)
    8000426c:	f1a2                	sd	s0,224(sp)
    8000426e:	eda6                	sd	s1,216(sp)
    80004270:	e9ca                	sd	s2,208(sp)
    80004272:	e5ce                	sd	s3,200(sp)
    80004274:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004276:	08000613          	li	a2,128
    8000427a:	f3040593          	addi	a1,s0,-208
    8000427e:	4501                	li	a0,0
    80004280:	c05fd0ef          	jal	ra,80001e84 <argstr>
    80004284:	12054b63          	bltz	a0,800043ba <sys_unlink+0x152>
  begin_op();
    80004288:	eb9fe0ef          	jal	ra,80003140 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000428c:	fb040593          	addi	a1,s0,-80
    80004290:	f3040513          	addi	a0,s0,-208
    80004294:	cebfe0ef          	jal	ra,80002f7e <nameiparent>
    80004298:	84aa                	mv	s1,a0
    8000429a:	c54d                	beqz	a0,80004344 <sys_unlink+0xdc>
  ilock(dp);
    8000429c:	e10fe0ef          	jal	ra,800028ac <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800042a0:	00003597          	auipc	a1,0x3
    800042a4:	55058593          	addi	a1,a1,1360 # 800077f0 <syscalls+0x308>
    800042a8:	fb040513          	addi	a0,s0,-80
    800042ac:	a37fe0ef          	jal	ra,80002ce2 <namecmp>
    800042b0:	10050a63          	beqz	a0,800043c4 <sys_unlink+0x15c>
    800042b4:	00003597          	auipc	a1,0x3
    800042b8:	54458593          	addi	a1,a1,1348 # 800077f8 <syscalls+0x310>
    800042bc:	fb040513          	addi	a0,s0,-80
    800042c0:	a23fe0ef          	jal	ra,80002ce2 <namecmp>
    800042c4:	10050063          	beqz	a0,800043c4 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800042c8:	f2c40613          	addi	a2,s0,-212
    800042cc:	fb040593          	addi	a1,s0,-80
    800042d0:	8526                	mv	a0,s1
    800042d2:	a27fe0ef          	jal	ra,80002cf8 <dirlookup>
    800042d6:	892a                	mv	s2,a0
    800042d8:	0e050663          	beqz	a0,800043c4 <sys_unlink+0x15c>
  ilock(ip);
    800042dc:	dd0fe0ef          	jal	ra,800028ac <ilock>
  if(ip->nlink < 1)
    800042e0:	04a91783          	lh	a5,74(s2)
    800042e4:	06f05463          	blez	a5,8000434c <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800042e8:	04491703          	lh	a4,68(s2)
    800042ec:	4785                	li	a5,1
    800042ee:	06f70563          	beq	a4,a5,80004358 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    800042f2:	4641                	li	a2,16
    800042f4:	4581                	li	a1,0
    800042f6:	fc040513          	addi	a0,s0,-64
    800042fa:	fb9fb0ef          	jal	ra,800002b2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042fe:	4741                	li	a4,16
    80004300:	f2c42683          	lw	a3,-212(s0)
    80004304:	fc040613          	addi	a2,s0,-64
    80004308:	4581                	li	a1,0
    8000430a:	8526                	mv	a0,s1
    8000430c:	8d5fe0ef          	jal	ra,80002be0 <writei>
    80004310:	47c1                	li	a5,16
    80004312:	08f51563          	bne	a0,a5,8000439c <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004316:	04491703          	lh	a4,68(s2)
    8000431a:	4785                	li	a5,1
    8000431c:	08f70663          	beq	a4,a5,800043a8 <sys_unlink+0x140>
  iunlockput(dp);
    80004320:	8526                	mv	a0,s1
    80004322:	f90fe0ef          	jal	ra,80002ab2 <iunlockput>
  ip->nlink--;
    80004326:	04a95783          	lhu	a5,74(s2)
    8000432a:	37fd                	addiw	a5,a5,-1
    8000432c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004330:	854a                	mv	a0,s2
    80004332:	cc6fe0ef          	jal	ra,800027f8 <iupdate>
  iunlockput(ip);
    80004336:	854a                	mv	a0,s2
    80004338:	f7afe0ef          	jal	ra,80002ab2 <iunlockput>
  end_op();
    8000433c:	e73fe0ef          	jal	ra,800031ae <end_op>
  return 0;
    80004340:	4501                	li	a0,0
    80004342:	a079                	j	800043d0 <sys_unlink+0x168>
    end_op();
    80004344:	e6bfe0ef          	jal	ra,800031ae <end_op>
    return -1;
    80004348:	557d                	li	a0,-1
    8000434a:	a059                	j	800043d0 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000434c:	00003517          	auipc	a0,0x3
    80004350:	4b450513          	addi	a0,a0,1204 # 80007800 <syscalls+0x318>
    80004354:	1ce010ef          	jal	ra,80005522 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004358:	04c92703          	lw	a4,76(s2)
    8000435c:	02000793          	li	a5,32
    80004360:	f8e7f9e3          	bgeu	a5,a4,800042f2 <sys_unlink+0x8a>
    80004364:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004368:	4741                	li	a4,16
    8000436a:	86ce                	mv	a3,s3
    8000436c:	f1840613          	addi	a2,s0,-232
    80004370:	4581                	li	a1,0
    80004372:	854a                	mv	a0,s2
    80004374:	f88fe0ef          	jal	ra,80002afc <readi>
    80004378:	47c1                	li	a5,16
    8000437a:	00f51b63          	bne	a0,a5,80004390 <sys_unlink+0x128>
    if(de.inum != 0)
    8000437e:	f1845783          	lhu	a5,-232(s0)
    80004382:	ef95                	bnez	a5,800043be <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004384:	29c1                	addiw	s3,s3,16
    80004386:	04c92783          	lw	a5,76(s2)
    8000438a:	fcf9efe3          	bltu	s3,a5,80004368 <sys_unlink+0x100>
    8000438e:	b795                	j	800042f2 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004390:	00003517          	auipc	a0,0x3
    80004394:	48850513          	addi	a0,a0,1160 # 80007818 <syscalls+0x330>
    80004398:	18a010ef          	jal	ra,80005522 <panic>
    panic("unlink: writei");
    8000439c:	00003517          	auipc	a0,0x3
    800043a0:	49450513          	addi	a0,a0,1172 # 80007830 <syscalls+0x348>
    800043a4:	17e010ef          	jal	ra,80005522 <panic>
    dp->nlink--;
    800043a8:	04a4d783          	lhu	a5,74(s1)
    800043ac:	37fd                	addiw	a5,a5,-1
    800043ae:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800043b2:	8526                	mv	a0,s1
    800043b4:	c44fe0ef          	jal	ra,800027f8 <iupdate>
    800043b8:	b7a5                	j	80004320 <sys_unlink+0xb8>
    return -1;
    800043ba:	557d                	li	a0,-1
    800043bc:	a811                	j	800043d0 <sys_unlink+0x168>
    iunlockput(ip);
    800043be:	854a                	mv	a0,s2
    800043c0:	ef2fe0ef          	jal	ra,80002ab2 <iunlockput>
  iunlockput(dp);
    800043c4:	8526                	mv	a0,s1
    800043c6:	eecfe0ef          	jal	ra,80002ab2 <iunlockput>
  end_op();
    800043ca:	de5fe0ef          	jal	ra,800031ae <end_op>
  return -1;
    800043ce:	557d                	li	a0,-1
}
    800043d0:	70ae                	ld	ra,232(sp)
    800043d2:	740e                	ld	s0,224(sp)
    800043d4:	64ee                	ld	s1,216(sp)
    800043d6:	694e                	ld	s2,208(sp)
    800043d8:	69ae                	ld	s3,200(sp)
    800043da:	616d                	addi	sp,sp,240
    800043dc:	8082                	ret

00000000800043de <sys_open>:

uint64
sys_open(void)
{
    800043de:	7131                	addi	sp,sp,-192
    800043e0:	fd06                	sd	ra,184(sp)
    800043e2:	f922                	sd	s0,176(sp)
    800043e4:	f526                	sd	s1,168(sp)
    800043e6:	f14a                	sd	s2,160(sp)
    800043e8:	ed4e                	sd	s3,152(sp)
    800043ea:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800043ec:	f4c40593          	addi	a1,s0,-180
    800043f0:	4505                	li	a0,1
    800043f2:	a5bfd0ef          	jal	ra,80001e4c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800043f6:	08000613          	li	a2,128
    800043fa:	f5040593          	addi	a1,s0,-176
    800043fe:	4501                	li	a0,0
    80004400:	a85fd0ef          	jal	ra,80001e84 <argstr>
    80004404:	87aa                	mv	a5,a0
    return -1;
    80004406:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004408:	0807cd63          	bltz	a5,800044a2 <sys_open+0xc4>

  begin_op();
    8000440c:	d35fe0ef          	jal	ra,80003140 <begin_op>

  if(omode & O_CREATE){
    80004410:	f4c42783          	lw	a5,-180(s0)
    80004414:	2007f793          	andi	a5,a5,512
    80004418:	c3c5                	beqz	a5,800044b8 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000441a:	4681                	li	a3,0
    8000441c:	4601                	li	a2,0
    8000441e:	4589                	li	a1,2
    80004420:	f5040513          	addi	a0,s0,-176
    80004424:	abfff0ef          	jal	ra,80003ee2 <create>
    80004428:	84aa                	mv	s1,a0
    if(ip == 0){
    8000442a:	c159                	beqz	a0,800044b0 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000442c:	04449703          	lh	a4,68(s1)
    80004430:	478d                	li	a5,3
    80004432:	00f71763          	bne	a4,a5,80004440 <sys_open+0x62>
    80004436:	0464d703          	lhu	a4,70(s1)
    8000443a:	47a5                	li	a5,9
    8000443c:	0ae7e963          	bltu	a5,a4,800044ee <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004440:	874ff0ef          	jal	ra,800034b4 <filealloc>
    80004444:	89aa                	mv	s3,a0
    80004446:	0c050963          	beqz	a0,80004518 <sys_open+0x13a>
    8000444a:	a5bff0ef          	jal	ra,80003ea4 <fdalloc>
    8000444e:	892a                	mv	s2,a0
    80004450:	0c054163          	bltz	a0,80004512 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004454:	04449703          	lh	a4,68(s1)
    80004458:	478d                	li	a5,3
    8000445a:	0af70163          	beq	a4,a5,800044fc <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000445e:	4789                	li	a5,2
    80004460:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004464:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004468:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000446c:	f4c42783          	lw	a5,-180(s0)
    80004470:	0017c713          	xori	a4,a5,1
    80004474:	8b05                	andi	a4,a4,1
    80004476:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000447a:	0037f713          	andi	a4,a5,3
    8000447e:	00e03733          	snez	a4,a4
    80004482:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004486:	4007f793          	andi	a5,a5,1024
    8000448a:	c791                	beqz	a5,80004496 <sys_open+0xb8>
    8000448c:	04449703          	lh	a4,68(s1)
    80004490:	4789                	li	a5,2
    80004492:	06f70c63          	beq	a4,a5,8000450a <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004496:	8526                	mv	a0,s1
    80004498:	cbefe0ef          	jal	ra,80002956 <iunlock>
  end_op();
    8000449c:	d13fe0ef          	jal	ra,800031ae <end_op>

  return fd;
    800044a0:	854a                	mv	a0,s2
}
    800044a2:	70ea                	ld	ra,184(sp)
    800044a4:	744a                	ld	s0,176(sp)
    800044a6:	74aa                	ld	s1,168(sp)
    800044a8:	790a                	ld	s2,160(sp)
    800044aa:	69ea                	ld	s3,152(sp)
    800044ac:	6129                	addi	sp,sp,192
    800044ae:	8082                	ret
      end_op();
    800044b0:	cfffe0ef          	jal	ra,800031ae <end_op>
      return -1;
    800044b4:	557d                	li	a0,-1
    800044b6:	b7f5                	j	800044a2 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    800044b8:	f5040513          	addi	a0,s0,-176
    800044bc:	aa9fe0ef          	jal	ra,80002f64 <namei>
    800044c0:	84aa                	mv	s1,a0
    800044c2:	c115                	beqz	a0,800044e6 <sys_open+0x108>
    ilock(ip);
    800044c4:	be8fe0ef          	jal	ra,800028ac <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800044c8:	04449703          	lh	a4,68(s1)
    800044cc:	4785                	li	a5,1
    800044ce:	f4f71fe3          	bne	a4,a5,8000442c <sys_open+0x4e>
    800044d2:	f4c42783          	lw	a5,-180(s0)
    800044d6:	d7ad                	beqz	a5,80004440 <sys_open+0x62>
      iunlockput(ip);
    800044d8:	8526                	mv	a0,s1
    800044da:	dd8fe0ef          	jal	ra,80002ab2 <iunlockput>
      end_op();
    800044de:	cd1fe0ef          	jal	ra,800031ae <end_op>
      return -1;
    800044e2:	557d                	li	a0,-1
    800044e4:	bf7d                	j	800044a2 <sys_open+0xc4>
      end_op();
    800044e6:	cc9fe0ef          	jal	ra,800031ae <end_op>
      return -1;
    800044ea:	557d                	li	a0,-1
    800044ec:	bf5d                	j	800044a2 <sys_open+0xc4>
    iunlockput(ip);
    800044ee:	8526                	mv	a0,s1
    800044f0:	dc2fe0ef          	jal	ra,80002ab2 <iunlockput>
    end_op();
    800044f4:	cbbfe0ef          	jal	ra,800031ae <end_op>
    return -1;
    800044f8:	557d                	li	a0,-1
    800044fa:	b765                	j	800044a2 <sys_open+0xc4>
    f->type = FD_DEVICE;
    800044fc:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004500:	04649783          	lh	a5,70(s1)
    80004504:	02f99223          	sh	a5,36(s3)
    80004508:	b785                	j	80004468 <sys_open+0x8a>
    itrunc(ip);
    8000450a:	8526                	mv	a0,s1
    8000450c:	c8afe0ef          	jal	ra,80002996 <itrunc>
    80004510:	b759                	j	80004496 <sys_open+0xb8>
      fileclose(f);
    80004512:	854e                	mv	a0,s3
    80004514:	844ff0ef          	jal	ra,80003558 <fileclose>
    iunlockput(ip);
    80004518:	8526                	mv	a0,s1
    8000451a:	d98fe0ef          	jal	ra,80002ab2 <iunlockput>
    end_op();
    8000451e:	c91fe0ef          	jal	ra,800031ae <end_op>
    return -1;
    80004522:	557d                	li	a0,-1
    80004524:	bfbd                	j	800044a2 <sys_open+0xc4>

0000000080004526 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004526:	7175                	addi	sp,sp,-144
    80004528:	e506                	sd	ra,136(sp)
    8000452a:	e122                	sd	s0,128(sp)
    8000452c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000452e:	c13fe0ef          	jal	ra,80003140 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004532:	08000613          	li	a2,128
    80004536:	f7040593          	addi	a1,s0,-144
    8000453a:	4501                	li	a0,0
    8000453c:	949fd0ef          	jal	ra,80001e84 <argstr>
    80004540:	02054363          	bltz	a0,80004566 <sys_mkdir+0x40>
    80004544:	4681                	li	a3,0
    80004546:	4601                	li	a2,0
    80004548:	4585                	li	a1,1
    8000454a:	f7040513          	addi	a0,s0,-144
    8000454e:	995ff0ef          	jal	ra,80003ee2 <create>
    80004552:	c911                	beqz	a0,80004566 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004554:	d5efe0ef          	jal	ra,80002ab2 <iunlockput>
  end_op();
    80004558:	c57fe0ef          	jal	ra,800031ae <end_op>
  return 0;
    8000455c:	4501                	li	a0,0
}
    8000455e:	60aa                	ld	ra,136(sp)
    80004560:	640a                	ld	s0,128(sp)
    80004562:	6149                	addi	sp,sp,144
    80004564:	8082                	ret
    end_op();
    80004566:	c49fe0ef          	jal	ra,800031ae <end_op>
    return -1;
    8000456a:	557d                	li	a0,-1
    8000456c:	bfcd                	j	8000455e <sys_mkdir+0x38>

000000008000456e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000456e:	7135                	addi	sp,sp,-160
    80004570:	ed06                	sd	ra,152(sp)
    80004572:	e922                	sd	s0,144(sp)
    80004574:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004576:	bcbfe0ef          	jal	ra,80003140 <begin_op>
  argint(1, &major);
    8000457a:	f6c40593          	addi	a1,s0,-148
    8000457e:	4505                	li	a0,1
    80004580:	8cdfd0ef          	jal	ra,80001e4c <argint>
  argint(2, &minor);
    80004584:	f6840593          	addi	a1,s0,-152
    80004588:	4509                	li	a0,2
    8000458a:	8c3fd0ef          	jal	ra,80001e4c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000458e:	08000613          	li	a2,128
    80004592:	f7040593          	addi	a1,s0,-144
    80004596:	4501                	li	a0,0
    80004598:	8edfd0ef          	jal	ra,80001e84 <argstr>
    8000459c:	02054563          	bltz	a0,800045c6 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800045a0:	f6841683          	lh	a3,-152(s0)
    800045a4:	f6c41603          	lh	a2,-148(s0)
    800045a8:	458d                	li	a1,3
    800045aa:	f7040513          	addi	a0,s0,-144
    800045ae:	935ff0ef          	jal	ra,80003ee2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800045b2:	c911                	beqz	a0,800045c6 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800045b4:	cfefe0ef          	jal	ra,80002ab2 <iunlockput>
  end_op();
    800045b8:	bf7fe0ef          	jal	ra,800031ae <end_op>
  return 0;
    800045bc:	4501                	li	a0,0
}
    800045be:	60ea                	ld	ra,152(sp)
    800045c0:	644a                	ld	s0,144(sp)
    800045c2:	610d                	addi	sp,sp,160
    800045c4:	8082                	ret
    end_op();
    800045c6:	be9fe0ef          	jal	ra,800031ae <end_op>
    return -1;
    800045ca:	557d                	li	a0,-1
    800045cc:	bfcd                	j	800045be <sys_mknod+0x50>

00000000800045ce <sys_chdir>:

uint64
sys_chdir(void)
{
    800045ce:	7135                	addi	sp,sp,-160
    800045d0:	ed06                	sd	ra,152(sp)
    800045d2:	e922                	sd	s0,144(sp)
    800045d4:	e526                	sd	s1,136(sp)
    800045d6:	e14a                	sd	s2,128(sp)
    800045d8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800045da:	9c5fc0ef          	jal	ra,80000f9e <myproc>
    800045de:	892a                	mv	s2,a0

  begin_op();
    800045e0:	b61fe0ef          	jal	ra,80003140 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800045e4:	08000613          	li	a2,128
    800045e8:	f6040593          	addi	a1,s0,-160
    800045ec:	4501                	li	a0,0
    800045ee:	897fd0ef          	jal	ra,80001e84 <argstr>
    800045f2:	04054163          	bltz	a0,80004634 <sys_chdir+0x66>
    800045f6:	f6040513          	addi	a0,s0,-160
    800045fa:	96bfe0ef          	jal	ra,80002f64 <namei>
    800045fe:	84aa                	mv	s1,a0
    80004600:	c915                	beqz	a0,80004634 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004602:	aaafe0ef          	jal	ra,800028ac <ilock>
  if(ip->type != T_DIR){
    80004606:	04449703          	lh	a4,68(s1)
    8000460a:	4785                	li	a5,1
    8000460c:	02f71863          	bne	a4,a5,8000463c <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004610:	8526                	mv	a0,s1
    80004612:	b44fe0ef          	jal	ra,80002956 <iunlock>
  iput(p->cwd);
    80004616:	15093503          	ld	a0,336(s2)
    8000461a:	c10fe0ef          	jal	ra,80002a2a <iput>
  end_op();
    8000461e:	b91fe0ef          	jal	ra,800031ae <end_op>
  p->cwd = ip;
    80004622:	14993823          	sd	s1,336(s2)
  return 0;
    80004626:	4501                	li	a0,0
}
    80004628:	60ea                	ld	ra,152(sp)
    8000462a:	644a                	ld	s0,144(sp)
    8000462c:	64aa                	ld	s1,136(sp)
    8000462e:	690a                	ld	s2,128(sp)
    80004630:	610d                	addi	sp,sp,160
    80004632:	8082                	ret
    end_op();
    80004634:	b7bfe0ef          	jal	ra,800031ae <end_op>
    return -1;
    80004638:	557d                	li	a0,-1
    8000463a:	b7fd                	j	80004628 <sys_chdir+0x5a>
    iunlockput(ip);
    8000463c:	8526                	mv	a0,s1
    8000463e:	c74fe0ef          	jal	ra,80002ab2 <iunlockput>
    end_op();
    80004642:	b6dfe0ef          	jal	ra,800031ae <end_op>
    return -1;
    80004646:	557d                	li	a0,-1
    80004648:	b7c5                	j	80004628 <sys_chdir+0x5a>

000000008000464a <sys_exec>:

uint64
sys_exec(void)
{
    8000464a:	7145                	addi	sp,sp,-464
    8000464c:	e786                	sd	ra,456(sp)
    8000464e:	e3a2                	sd	s0,448(sp)
    80004650:	ff26                	sd	s1,440(sp)
    80004652:	fb4a                	sd	s2,432(sp)
    80004654:	f74e                	sd	s3,424(sp)
    80004656:	f352                	sd	s4,416(sp)
    80004658:	ef56                	sd	s5,408(sp)
    8000465a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000465c:	e3840593          	addi	a1,s0,-456
    80004660:	4505                	li	a0,1
    80004662:	807fd0ef          	jal	ra,80001e68 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004666:	08000613          	li	a2,128
    8000466a:	f4040593          	addi	a1,s0,-192
    8000466e:	4501                	li	a0,0
    80004670:	815fd0ef          	jal	ra,80001e84 <argstr>
    80004674:	87aa                	mv	a5,a0
    return -1;
    80004676:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004678:	0a07c563          	bltz	a5,80004722 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    8000467c:	10000613          	li	a2,256
    80004680:	4581                	li	a1,0
    80004682:	e4040513          	addi	a0,s0,-448
    80004686:	c2dfb0ef          	jal	ra,800002b2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000468a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000468e:	89a6                	mv	s3,s1
    80004690:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004692:	02000a13          	li	s4,32
    80004696:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000469a:	00391513          	slli	a0,s2,0x3
    8000469e:	e3040593          	addi	a1,s0,-464
    800046a2:	e3843783          	ld	a5,-456(s0)
    800046a6:	953e                	add	a0,a0,a5
    800046a8:	f1afd0ef          	jal	ra,80001dc2 <fetchaddr>
    800046ac:	02054663          	bltz	a0,800046d8 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800046b0:	e3043783          	ld	a5,-464(s0)
    800046b4:	cf8d                	beqz	a5,800046ee <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800046b6:	aaffb0ef          	jal	ra,80000164 <kalloc>
    800046ba:	85aa                	mv	a1,a0
    800046bc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800046c0:	cd01                	beqz	a0,800046d8 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800046c2:	6605                	lui	a2,0x1
    800046c4:	e3043503          	ld	a0,-464(s0)
    800046c8:	f44fd0ef          	jal	ra,80001e0c <fetchstr>
    800046cc:	00054663          	bltz	a0,800046d8 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800046d0:	0905                	addi	s2,s2,1
    800046d2:	09a1                	addi	s3,s3,8
    800046d4:	fd4911e3          	bne	s2,s4,80004696 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046d8:	f4040913          	addi	s2,s0,-192
    800046dc:	6088                	ld	a0,0(s1)
    800046de:	c129                	beqz	a0,80004720 <sys_exec+0xd6>
    kfree(argv[i]);
    800046e0:	991fb0ef          	jal	ra,80000070 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046e4:	04a1                	addi	s1,s1,8
    800046e6:	ff249be3          	bne	s1,s2,800046dc <sys_exec+0x92>
  return -1;
    800046ea:	557d                	li	a0,-1
    800046ec:	a81d                	j	80004722 <sys_exec+0xd8>
      argv[i] = 0;
    800046ee:	0a8e                	slli	s5,s5,0x3
    800046f0:	fc0a8793          	addi	a5,s5,-64
    800046f4:	00878ab3          	add	s5,a5,s0
    800046f8:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800046fc:	e4040593          	addi	a1,s0,-448
    80004700:	f4040513          	addi	a0,s0,-192
    80004704:	bf6ff0ef          	jal	ra,80003afa <exec>
    80004708:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000470a:	f4040993          	addi	s3,s0,-192
    8000470e:	6088                	ld	a0,0(s1)
    80004710:	c511                	beqz	a0,8000471c <sys_exec+0xd2>
    kfree(argv[i]);
    80004712:	95ffb0ef          	jal	ra,80000070 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004716:	04a1                	addi	s1,s1,8
    80004718:	ff349be3          	bne	s1,s3,8000470e <sys_exec+0xc4>
  return ret;
    8000471c:	854a                	mv	a0,s2
    8000471e:	a011                	j	80004722 <sys_exec+0xd8>
  return -1;
    80004720:	557d                	li	a0,-1
}
    80004722:	60be                	ld	ra,456(sp)
    80004724:	641e                	ld	s0,448(sp)
    80004726:	74fa                	ld	s1,440(sp)
    80004728:	795a                	ld	s2,432(sp)
    8000472a:	79ba                	ld	s3,424(sp)
    8000472c:	7a1a                	ld	s4,416(sp)
    8000472e:	6afa                	ld	s5,408(sp)
    80004730:	6179                	addi	sp,sp,464
    80004732:	8082                	ret

0000000080004734 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004734:	7139                	addi	sp,sp,-64
    80004736:	fc06                	sd	ra,56(sp)
    80004738:	f822                	sd	s0,48(sp)
    8000473a:	f426                	sd	s1,40(sp)
    8000473c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000473e:	861fc0ef          	jal	ra,80000f9e <myproc>
    80004742:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004744:	fd840593          	addi	a1,s0,-40
    80004748:	4501                	li	a0,0
    8000474a:	f1efd0ef          	jal	ra,80001e68 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000474e:	fc840593          	addi	a1,s0,-56
    80004752:	fd040513          	addi	a0,s0,-48
    80004756:	8ceff0ef          	jal	ra,80003824 <pipealloc>
    return -1;
    8000475a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000475c:	0a054463          	bltz	a0,80004804 <sys_pipe+0xd0>
  fd0 = -1;
    80004760:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004764:	fd043503          	ld	a0,-48(s0)
    80004768:	f3cff0ef          	jal	ra,80003ea4 <fdalloc>
    8000476c:	fca42223          	sw	a0,-60(s0)
    80004770:	08054163          	bltz	a0,800047f2 <sys_pipe+0xbe>
    80004774:	fc843503          	ld	a0,-56(s0)
    80004778:	f2cff0ef          	jal	ra,80003ea4 <fdalloc>
    8000477c:	fca42023          	sw	a0,-64(s0)
    80004780:	06054063          	bltz	a0,800047e0 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004784:	4691                	li	a3,4
    80004786:	fc440613          	addi	a2,s0,-60
    8000478a:	fd843583          	ld	a1,-40(s0)
    8000478e:	68a8                	ld	a0,80(s1)
    80004790:	bb2fc0ef          	jal	ra,80000b42 <copyout>
    80004794:	00054e63          	bltz	a0,800047b0 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004798:	4691                	li	a3,4
    8000479a:	fc040613          	addi	a2,s0,-64
    8000479e:	fd843583          	ld	a1,-40(s0)
    800047a2:	0591                	addi	a1,a1,4
    800047a4:	68a8                	ld	a0,80(s1)
    800047a6:	b9cfc0ef          	jal	ra,80000b42 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800047aa:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800047ac:	04055c63          	bgez	a0,80004804 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800047b0:	fc442783          	lw	a5,-60(s0)
    800047b4:	07e9                	addi	a5,a5,26
    800047b6:	078e                	slli	a5,a5,0x3
    800047b8:	97a6                	add	a5,a5,s1
    800047ba:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800047be:	fc042783          	lw	a5,-64(s0)
    800047c2:	07e9                	addi	a5,a5,26
    800047c4:	078e                	slli	a5,a5,0x3
    800047c6:	94be                	add	s1,s1,a5
    800047c8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800047cc:	fd043503          	ld	a0,-48(s0)
    800047d0:	d89fe0ef          	jal	ra,80003558 <fileclose>
    fileclose(wf);
    800047d4:	fc843503          	ld	a0,-56(s0)
    800047d8:	d81fe0ef          	jal	ra,80003558 <fileclose>
    return -1;
    800047dc:	57fd                	li	a5,-1
    800047de:	a01d                	j	80004804 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800047e0:	fc442783          	lw	a5,-60(s0)
    800047e4:	0007c763          	bltz	a5,800047f2 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800047e8:	07e9                	addi	a5,a5,26
    800047ea:	078e                	slli	a5,a5,0x3
    800047ec:	97a6                	add	a5,a5,s1
    800047ee:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800047f2:	fd043503          	ld	a0,-48(s0)
    800047f6:	d63fe0ef          	jal	ra,80003558 <fileclose>
    fileclose(wf);
    800047fa:	fc843503          	ld	a0,-56(s0)
    800047fe:	d5bfe0ef          	jal	ra,80003558 <fileclose>
    return -1;
    80004802:	57fd                	li	a5,-1
}
    80004804:	853e                	mv	a0,a5
    80004806:	70e2                	ld	ra,56(sp)
    80004808:	7442                	ld	s0,48(sp)
    8000480a:	74a2                	ld	s1,40(sp)
    8000480c:	6121                	addi	sp,sp,64
    8000480e:	8082                	ret

0000000080004810 <kernelvec>:
    80004810:	7111                	addi	sp,sp,-256
    80004812:	e006                	sd	ra,0(sp)
    80004814:	e40a                	sd	sp,8(sp)
    80004816:	e80e                	sd	gp,16(sp)
    80004818:	ec12                	sd	tp,24(sp)
    8000481a:	f016                	sd	t0,32(sp)
    8000481c:	f41a                	sd	t1,40(sp)
    8000481e:	f81e                	sd	t2,48(sp)
    80004820:	e4aa                	sd	a0,72(sp)
    80004822:	e8ae                	sd	a1,80(sp)
    80004824:	ecb2                	sd	a2,88(sp)
    80004826:	f0b6                	sd	a3,96(sp)
    80004828:	f4ba                	sd	a4,104(sp)
    8000482a:	f8be                	sd	a5,112(sp)
    8000482c:	fcc2                	sd	a6,120(sp)
    8000482e:	e146                	sd	a7,128(sp)
    80004830:	edf2                	sd	t3,216(sp)
    80004832:	f1f6                	sd	t4,224(sp)
    80004834:	f5fa                	sd	t5,232(sp)
    80004836:	f9fe                	sd	t6,240(sp)
    80004838:	c9afd0ef          	jal	ra,80001cd2 <kerneltrap>
    8000483c:	6082                	ld	ra,0(sp)
    8000483e:	6122                	ld	sp,8(sp)
    80004840:	61c2                	ld	gp,16(sp)
    80004842:	7282                	ld	t0,32(sp)
    80004844:	7322                	ld	t1,40(sp)
    80004846:	73c2                	ld	t2,48(sp)
    80004848:	6526                	ld	a0,72(sp)
    8000484a:	65c6                	ld	a1,80(sp)
    8000484c:	6666                	ld	a2,88(sp)
    8000484e:	7686                	ld	a3,96(sp)
    80004850:	7726                	ld	a4,104(sp)
    80004852:	77c6                	ld	a5,112(sp)
    80004854:	7866                	ld	a6,120(sp)
    80004856:	688a                	ld	a7,128(sp)
    80004858:	6e6e                	ld	t3,216(sp)
    8000485a:	7e8e                	ld	t4,224(sp)
    8000485c:	7f2e                	ld	t5,232(sp)
    8000485e:	7fce                	ld	t6,240(sp)
    80004860:	6111                	addi	sp,sp,256
    80004862:	10200073          	sret
	...

000000008000486e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000486e:	1141                	addi	sp,sp,-16
    80004870:	e422                	sd	s0,8(sp)
    80004872:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004874:	0c0007b7          	lui	a5,0xc000
    80004878:	4705                	li	a4,1
    8000487a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000487c:	c3d8                	sw	a4,4(a5)
}
    8000487e:	6422                	ld	s0,8(sp)
    80004880:	0141                	addi	sp,sp,16
    80004882:	8082                	ret

0000000080004884 <plicinithart>:

void
plicinithart(void)
{
    80004884:	1141                	addi	sp,sp,-16
    80004886:	e406                	sd	ra,8(sp)
    80004888:	e022                	sd	s0,0(sp)
    8000488a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000488c:	ee6fc0ef          	jal	ra,80000f72 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004890:	0085171b          	slliw	a4,a0,0x8
    80004894:	0c0027b7          	lui	a5,0xc002
    80004898:	97ba                	add	a5,a5,a4
    8000489a:	40200713          	li	a4,1026
    8000489e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800048a2:	00d5151b          	slliw	a0,a0,0xd
    800048a6:	0c2017b7          	lui	a5,0xc201
    800048aa:	97aa                	add	a5,a5,a0
    800048ac:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800048b0:	60a2                	ld	ra,8(sp)
    800048b2:	6402                	ld	s0,0(sp)
    800048b4:	0141                	addi	sp,sp,16
    800048b6:	8082                	ret

00000000800048b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800048b8:	1141                	addi	sp,sp,-16
    800048ba:	e406                	sd	ra,8(sp)
    800048bc:	e022                	sd	s0,0(sp)
    800048be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800048c0:	eb2fc0ef          	jal	ra,80000f72 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800048c4:	00d5151b          	slliw	a0,a0,0xd
    800048c8:	0c2017b7          	lui	a5,0xc201
    800048cc:	97aa                	add	a5,a5,a0
  return irq;
}
    800048ce:	43c8                	lw	a0,4(a5)
    800048d0:	60a2                	ld	ra,8(sp)
    800048d2:	6402                	ld	s0,0(sp)
    800048d4:	0141                	addi	sp,sp,16
    800048d6:	8082                	ret

00000000800048d8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800048d8:	1101                	addi	sp,sp,-32
    800048da:	ec06                	sd	ra,24(sp)
    800048dc:	e822                	sd	s0,16(sp)
    800048de:	e426                	sd	s1,8(sp)
    800048e0:	1000                	addi	s0,sp,32
    800048e2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800048e4:	e8efc0ef          	jal	ra,80000f72 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800048e8:	00d5151b          	slliw	a0,a0,0xd
    800048ec:	0c2017b7          	lui	a5,0xc201
    800048f0:	97aa                	add	a5,a5,a0
    800048f2:	c3c4                	sw	s1,4(a5)
}
    800048f4:	60e2                	ld	ra,24(sp)
    800048f6:	6442                	ld	s0,16(sp)
    800048f8:	64a2                	ld	s1,8(sp)
    800048fa:	6105                	addi	sp,sp,32
    800048fc:	8082                	ret

00000000800048fe <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800048fe:	1141                	addi	sp,sp,-16
    80004900:	e406                	sd	ra,8(sp)
    80004902:	e022                	sd	s0,0(sp)
    80004904:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80004906:	479d                	li	a5,7
    80004908:	04a7ca63          	blt	a5,a0,8000495c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000490c:	00014797          	auipc	a5,0x14
    80004910:	44478793          	addi	a5,a5,1092 # 80018d50 <disk>
    80004914:	97aa                	add	a5,a5,a0
    80004916:	0187c783          	lbu	a5,24(a5)
    8000491a:	e7b9                	bnez	a5,80004968 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000491c:	00451693          	slli	a3,a0,0x4
    80004920:	00014797          	auipc	a5,0x14
    80004924:	43078793          	addi	a5,a5,1072 # 80018d50 <disk>
    80004928:	6398                	ld	a4,0(a5)
    8000492a:	9736                	add	a4,a4,a3
    8000492c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004930:	6398                	ld	a4,0(a5)
    80004932:	9736                	add	a4,a4,a3
    80004934:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004938:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000493c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004940:	97aa                	add	a5,a5,a0
    80004942:	4705                	li	a4,1
    80004944:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004948:	00014517          	auipc	a0,0x14
    8000494c:	42050513          	addi	a0,a0,1056 # 80018d68 <disk+0x18>
    80004950:	c67fc0ef          	jal	ra,800015b6 <wakeup>
}
    80004954:	60a2                	ld	ra,8(sp)
    80004956:	6402                	ld	s0,0(sp)
    80004958:	0141                	addi	sp,sp,16
    8000495a:	8082                	ret
    panic("free_desc 1");
    8000495c:	00003517          	auipc	a0,0x3
    80004960:	ee450513          	addi	a0,a0,-284 # 80007840 <syscalls+0x358>
    80004964:	3bf000ef          	jal	ra,80005522 <panic>
    panic("free_desc 2");
    80004968:	00003517          	auipc	a0,0x3
    8000496c:	ee850513          	addi	a0,a0,-280 # 80007850 <syscalls+0x368>
    80004970:	3b3000ef          	jal	ra,80005522 <panic>

0000000080004974 <virtio_disk_init>:
{
    80004974:	1101                	addi	sp,sp,-32
    80004976:	ec06                	sd	ra,24(sp)
    80004978:	e822                	sd	s0,16(sp)
    8000497a:	e426                	sd	s1,8(sp)
    8000497c:	e04a                	sd	s2,0(sp)
    8000497e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004980:	00003597          	auipc	a1,0x3
    80004984:	ee058593          	addi	a1,a1,-288 # 80007860 <syscalls+0x378>
    80004988:	00014517          	auipc	a0,0x14
    8000498c:	4f050513          	addi	a0,a0,1264 # 80018e78 <disk+0x128>
    80004990:	623000ef          	jal	ra,800057b2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004994:	100017b7          	lui	a5,0x10001
    80004998:	4398                	lw	a4,0(a5)
    8000499a:	2701                	sext.w	a4,a4
    8000499c:	747277b7          	lui	a5,0x74727
    800049a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800049a4:	12f71f63          	bne	a4,a5,80004ae2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800049a8:	100017b7          	lui	a5,0x10001
    800049ac:	43dc                	lw	a5,4(a5)
    800049ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800049b0:	4709                	li	a4,2
    800049b2:	12e79863          	bne	a5,a4,80004ae2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800049b6:	100017b7          	lui	a5,0x10001
    800049ba:	479c                	lw	a5,8(a5)
    800049bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800049be:	12e79263          	bne	a5,a4,80004ae2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800049c2:	100017b7          	lui	a5,0x10001
    800049c6:	47d8                	lw	a4,12(a5)
    800049c8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800049ca:	554d47b7          	lui	a5,0x554d4
    800049ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800049d2:	10f71863          	bne	a4,a5,80004ae2 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    800049d6:	100017b7          	lui	a5,0x10001
    800049da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800049de:	4705                	li	a4,1
    800049e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800049e2:	470d                	li	a4,3
    800049e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800049e6:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800049e8:	c7ffe6b7          	lui	a3,0xc7ffe
    800049ec:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd7cf>
    800049f0:	8f75                	and	a4,a4,a3
    800049f2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800049f4:	472d                	li	a4,11
    800049f6:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800049f8:	5bbc                	lw	a5,112(a5)
    800049fa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800049fe:	8ba1                	andi	a5,a5,8
    80004a00:	0e078763          	beqz	a5,80004aee <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004a04:	100017b7          	lui	a5,0x10001
    80004a08:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004a0c:	43fc                	lw	a5,68(a5)
    80004a0e:	2781                	sext.w	a5,a5
    80004a10:	0e079563          	bnez	a5,80004afa <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004a14:	100017b7          	lui	a5,0x10001
    80004a18:	5bdc                	lw	a5,52(a5)
    80004a1a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004a1c:	0e078563          	beqz	a5,80004b06 <virtio_disk_init+0x192>
  if(max < NUM)
    80004a20:	471d                	li	a4,7
    80004a22:	0ef77863          	bgeu	a4,a5,80004b12 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80004a26:	f3efb0ef          	jal	ra,80000164 <kalloc>
    80004a2a:	00014497          	auipc	s1,0x14
    80004a2e:	32648493          	addi	s1,s1,806 # 80018d50 <disk>
    80004a32:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004a34:	f30fb0ef          	jal	ra,80000164 <kalloc>
    80004a38:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004a3a:	f2afb0ef          	jal	ra,80000164 <kalloc>
    80004a3e:	87aa                	mv	a5,a0
    80004a40:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004a42:	6088                	ld	a0,0(s1)
    80004a44:	cd69                	beqz	a0,80004b1e <virtio_disk_init+0x1aa>
    80004a46:	00014717          	auipc	a4,0x14
    80004a4a:	31273703          	ld	a4,786(a4) # 80018d58 <disk+0x8>
    80004a4e:	cb61                	beqz	a4,80004b1e <virtio_disk_init+0x1aa>
    80004a50:	c7f9                	beqz	a5,80004b1e <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80004a52:	6605                	lui	a2,0x1
    80004a54:	4581                	li	a1,0
    80004a56:	85dfb0ef          	jal	ra,800002b2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004a5a:	00014497          	auipc	s1,0x14
    80004a5e:	2f648493          	addi	s1,s1,758 # 80018d50 <disk>
    80004a62:	6605                	lui	a2,0x1
    80004a64:	4581                	li	a1,0
    80004a66:	6488                	ld	a0,8(s1)
    80004a68:	84bfb0ef          	jal	ra,800002b2 <memset>
  memset(disk.used, 0, PGSIZE);
    80004a6c:	6605                	lui	a2,0x1
    80004a6e:	4581                	li	a1,0
    80004a70:	6888                	ld	a0,16(s1)
    80004a72:	841fb0ef          	jal	ra,800002b2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004a76:	100017b7          	lui	a5,0x10001
    80004a7a:	4721                	li	a4,8
    80004a7c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004a7e:	4098                	lw	a4,0(s1)
    80004a80:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004a84:	40d8                	lw	a4,4(s1)
    80004a86:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004a8a:	6498                	ld	a4,8(s1)
    80004a8c:	0007069b          	sext.w	a3,a4
    80004a90:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004a94:	9701                	srai	a4,a4,0x20
    80004a96:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004a9a:	6898                	ld	a4,16(s1)
    80004a9c:	0007069b          	sext.w	a3,a4
    80004aa0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004aa4:	9701                	srai	a4,a4,0x20
    80004aa6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004aaa:	4705                	li	a4,1
    80004aac:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80004aae:	00e48c23          	sb	a4,24(s1)
    80004ab2:	00e48ca3          	sb	a4,25(s1)
    80004ab6:	00e48d23          	sb	a4,26(s1)
    80004aba:	00e48da3          	sb	a4,27(s1)
    80004abe:	00e48e23          	sb	a4,28(s1)
    80004ac2:	00e48ea3          	sb	a4,29(s1)
    80004ac6:	00e48f23          	sb	a4,30(s1)
    80004aca:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004ace:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ad2:	0727a823          	sw	s2,112(a5)
}
    80004ad6:	60e2                	ld	ra,24(sp)
    80004ad8:	6442                	ld	s0,16(sp)
    80004ada:	64a2                	ld	s1,8(sp)
    80004adc:	6902                	ld	s2,0(sp)
    80004ade:	6105                	addi	sp,sp,32
    80004ae0:	8082                	ret
    panic("could not find virtio disk");
    80004ae2:	00003517          	auipc	a0,0x3
    80004ae6:	d8e50513          	addi	a0,a0,-626 # 80007870 <syscalls+0x388>
    80004aea:	239000ef          	jal	ra,80005522 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004aee:	00003517          	auipc	a0,0x3
    80004af2:	da250513          	addi	a0,a0,-606 # 80007890 <syscalls+0x3a8>
    80004af6:	22d000ef          	jal	ra,80005522 <panic>
    panic("virtio disk should not be ready");
    80004afa:	00003517          	auipc	a0,0x3
    80004afe:	db650513          	addi	a0,a0,-586 # 800078b0 <syscalls+0x3c8>
    80004b02:	221000ef          	jal	ra,80005522 <panic>
    panic("virtio disk has no queue 0");
    80004b06:	00003517          	auipc	a0,0x3
    80004b0a:	dca50513          	addi	a0,a0,-566 # 800078d0 <syscalls+0x3e8>
    80004b0e:	215000ef          	jal	ra,80005522 <panic>
    panic("virtio disk max queue too short");
    80004b12:	00003517          	auipc	a0,0x3
    80004b16:	dde50513          	addi	a0,a0,-546 # 800078f0 <syscalls+0x408>
    80004b1a:	209000ef          	jal	ra,80005522 <panic>
    panic("virtio disk kalloc");
    80004b1e:	00003517          	auipc	a0,0x3
    80004b22:	df250513          	addi	a0,a0,-526 # 80007910 <syscalls+0x428>
    80004b26:	1fd000ef          	jal	ra,80005522 <panic>

0000000080004b2a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004b2a:	7119                	addi	sp,sp,-128
    80004b2c:	fc86                	sd	ra,120(sp)
    80004b2e:	f8a2                	sd	s0,112(sp)
    80004b30:	f4a6                	sd	s1,104(sp)
    80004b32:	f0ca                	sd	s2,96(sp)
    80004b34:	ecce                	sd	s3,88(sp)
    80004b36:	e8d2                	sd	s4,80(sp)
    80004b38:	e4d6                	sd	s5,72(sp)
    80004b3a:	e0da                	sd	s6,64(sp)
    80004b3c:	fc5e                	sd	s7,56(sp)
    80004b3e:	f862                	sd	s8,48(sp)
    80004b40:	f466                	sd	s9,40(sp)
    80004b42:	f06a                	sd	s10,32(sp)
    80004b44:	ec6e                	sd	s11,24(sp)
    80004b46:	0100                	addi	s0,sp,128
    80004b48:	8aaa                	mv	s5,a0
    80004b4a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004b4c:	00c52d03          	lw	s10,12(a0)
    80004b50:	001d1d1b          	slliw	s10,s10,0x1
    80004b54:	1d02                	slli	s10,s10,0x20
    80004b56:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80004b5a:	00014517          	auipc	a0,0x14
    80004b5e:	31e50513          	addi	a0,a0,798 # 80018e78 <disk+0x128>
    80004b62:	4d1000ef          	jal	ra,80005832 <acquire>
  for(int i = 0; i < 3; i++){
    80004b66:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004b68:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004b6a:	00014b97          	auipc	s7,0x14
    80004b6e:	1e6b8b93          	addi	s7,s7,486 # 80018d50 <disk>
  for(int i = 0; i < 3; i++){
    80004b72:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004b74:	00014c97          	auipc	s9,0x14
    80004b78:	304c8c93          	addi	s9,s9,772 # 80018e78 <disk+0x128>
    80004b7c:	a8a9                	j	80004bd6 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004b7e:	00fb8733          	add	a4,s7,a5
    80004b82:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80004b86:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004b88:	0207c563          	bltz	a5,80004bb2 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80004b8c:	2905                	addiw	s2,s2,1
    80004b8e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004b90:	05690863          	beq	s2,s6,80004be0 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80004b94:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004b96:	00014717          	auipc	a4,0x14
    80004b9a:	1ba70713          	addi	a4,a4,442 # 80018d50 <disk>
    80004b9e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004ba0:	01874683          	lbu	a3,24(a4)
    80004ba4:	fee9                	bnez	a3,80004b7e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80004ba6:	2785                	addiw	a5,a5,1
    80004ba8:	0705                	addi	a4,a4,1
    80004baa:	fe979be3          	bne	a5,s1,80004ba0 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80004bae:	57fd                	li	a5,-1
    80004bb0:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004bb2:	01205b63          	blez	s2,80004bc8 <virtio_disk_rw+0x9e>
    80004bb6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80004bb8:	000a2503          	lw	a0,0(s4)
    80004bbc:	d43ff0ef          	jal	ra,800048fe <free_desc>
      for(int j = 0; j < i; j++)
    80004bc0:	2d85                	addiw	s11,s11,1
    80004bc2:	0a11                	addi	s4,s4,4
    80004bc4:	ff2d9ae3          	bne	s11,s2,80004bb8 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004bc8:	85e6                	mv	a1,s9
    80004bca:	00014517          	auipc	a0,0x14
    80004bce:	19e50513          	addi	a0,a0,414 # 80018d68 <disk+0x18>
    80004bd2:	999fc0ef          	jal	ra,8000156a <sleep>
  for(int i = 0; i < 3; i++){
    80004bd6:	f8040a13          	addi	s4,s0,-128
{
    80004bda:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80004bdc:	894e                	mv	s2,s3
    80004bde:	bf5d                	j	80004b94 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004be0:	f8042503          	lw	a0,-128(s0)
    80004be4:	00a50713          	addi	a4,a0,10
    80004be8:	0712                	slli	a4,a4,0x4

  if(write)
    80004bea:	00014797          	auipc	a5,0x14
    80004bee:	16678793          	addi	a5,a5,358 # 80018d50 <disk>
    80004bf2:	00e786b3          	add	a3,a5,a4
    80004bf6:	01803633          	snez	a2,s8
    80004bfa:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004bfc:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80004c00:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c04:	f6070613          	addi	a2,a4,-160
    80004c08:	6394                	ld	a3,0(a5)
    80004c0a:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004c0c:	00870593          	addi	a1,a4,8
    80004c10:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c12:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004c14:	0007b803          	ld	a6,0(a5)
    80004c18:	9642                	add	a2,a2,a6
    80004c1a:	46c1                	li	a3,16
    80004c1c:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004c1e:	4585                	li	a1,1
    80004c20:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80004c24:	f8442683          	lw	a3,-124(s0)
    80004c28:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004c2c:	0692                	slli	a3,a3,0x4
    80004c2e:	9836                	add	a6,a6,a3
    80004c30:	058a8613          	addi	a2,s5,88
    80004c34:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80004c38:	0007b803          	ld	a6,0(a5)
    80004c3c:	96c2                	add	a3,a3,a6
    80004c3e:	40000613          	li	a2,1024
    80004c42:	c690                	sw	a2,8(a3)
  if(write)
    80004c44:	001c3613          	seqz	a2,s8
    80004c48:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004c4c:	00166613          	ori	a2,a2,1
    80004c50:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80004c54:	f8842603          	lw	a2,-120(s0)
    80004c58:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004c5c:	00250693          	addi	a3,a0,2
    80004c60:	0692                	slli	a3,a3,0x4
    80004c62:	96be                	add	a3,a3,a5
    80004c64:	58fd                	li	a7,-1
    80004c66:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004c6a:	0612                	slli	a2,a2,0x4
    80004c6c:	9832                	add	a6,a6,a2
    80004c6e:	f9070713          	addi	a4,a4,-112
    80004c72:	973e                	add	a4,a4,a5
    80004c74:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80004c78:	6398                	ld	a4,0(a5)
    80004c7a:	9732                	add	a4,a4,a2
    80004c7c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004c7e:	4609                	li	a2,2
    80004c80:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80004c84:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004c88:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80004c8c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004c90:	6794                	ld	a3,8(a5)
    80004c92:	0026d703          	lhu	a4,2(a3)
    80004c96:	8b1d                	andi	a4,a4,7
    80004c98:	0706                	slli	a4,a4,0x1
    80004c9a:	96ba                	add	a3,a3,a4
    80004c9c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004ca0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004ca4:	6798                	ld	a4,8(a5)
    80004ca6:	00275783          	lhu	a5,2(a4)
    80004caa:	2785                	addiw	a5,a5,1
    80004cac:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004cb0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004cb4:	100017b7          	lui	a5,0x10001
    80004cb8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004cbc:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80004cc0:	00014917          	auipc	s2,0x14
    80004cc4:	1b890913          	addi	s2,s2,440 # 80018e78 <disk+0x128>
  while(b->disk == 1) {
    80004cc8:	4485                	li	s1,1
    80004cca:	00b79a63          	bne	a5,a1,80004cde <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80004cce:	85ca                	mv	a1,s2
    80004cd0:	8556                	mv	a0,s5
    80004cd2:	899fc0ef          	jal	ra,8000156a <sleep>
  while(b->disk == 1) {
    80004cd6:	004aa783          	lw	a5,4(s5)
    80004cda:	fe978ae3          	beq	a5,s1,80004cce <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80004cde:	f8042903          	lw	s2,-128(s0)
    80004ce2:	00290713          	addi	a4,s2,2
    80004ce6:	0712                	slli	a4,a4,0x4
    80004ce8:	00014797          	auipc	a5,0x14
    80004cec:	06878793          	addi	a5,a5,104 # 80018d50 <disk>
    80004cf0:	97ba                	add	a5,a5,a4
    80004cf2:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004cf6:	00014997          	auipc	s3,0x14
    80004cfa:	05a98993          	addi	s3,s3,90 # 80018d50 <disk>
    80004cfe:	00491713          	slli	a4,s2,0x4
    80004d02:	0009b783          	ld	a5,0(s3)
    80004d06:	97ba                	add	a5,a5,a4
    80004d08:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004d0c:	854a                	mv	a0,s2
    80004d0e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004d12:	bedff0ef          	jal	ra,800048fe <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004d16:	8885                	andi	s1,s1,1
    80004d18:	f0fd                	bnez	s1,80004cfe <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004d1a:	00014517          	auipc	a0,0x14
    80004d1e:	15e50513          	addi	a0,a0,350 # 80018e78 <disk+0x128>
    80004d22:	3a9000ef          	jal	ra,800058ca <release>
}
    80004d26:	70e6                	ld	ra,120(sp)
    80004d28:	7446                	ld	s0,112(sp)
    80004d2a:	74a6                	ld	s1,104(sp)
    80004d2c:	7906                	ld	s2,96(sp)
    80004d2e:	69e6                	ld	s3,88(sp)
    80004d30:	6a46                	ld	s4,80(sp)
    80004d32:	6aa6                	ld	s5,72(sp)
    80004d34:	6b06                	ld	s6,64(sp)
    80004d36:	7be2                	ld	s7,56(sp)
    80004d38:	7c42                	ld	s8,48(sp)
    80004d3a:	7ca2                	ld	s9,40(sp)
    80004d3c:	7d02                	ld	s10,32(sp)
    80004d3e:	6de2                	ld	s11,24(sp)
    80004d40:	6109                	addi	sp,sp,128
    80004d42:	8082                	ret

0000000080004d44 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004d44:	1101                	addi	sp,sp,-32
    80004d46:	ec06                	sd	ra,24(sp)
    80004d48:	e822                	sd	s0,16(sp)
    80004d4a:	e426                	sd	s1,8(sp)
    80004d4c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004d4e:	00014497          	auipc	s1,0x14
    80004d52:	00248493          	addi	s1,s1,2 # 80018d50 <disk>
    80004d56:	00014517          	auipc	a0,0x14
    80004d5a:	12250513          	addi	a0,a0,290 # 80018e78 <disk+0x128>
    80004d5e:	2d5000ef          	jal	ra,80005832 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004d62:	10001737          	lui	a4,0x10001
    80004d66:	533c                	lw	a5,96(a4)
    80004d68:	8b8d                	andi	a5,a5,3
    80004d6a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80004d6c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004d70:	689c                	ld	a5,16(s1)
    80004d72:	0204d703          	lhu	a4,32(s1)
    80004d76:	0027d783          	lhu	a5,2(a5)
    80004d7a:	04f70663          	beq	a4,a5,80004dc6 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80004d7e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004d82:	6898                	ld	a4,16(s1)
    80004d84:	0204d783          	lhu	a5,32(s1)
    80004d88:	8b9d                	andi	a5,a5,7
    80004d8a:	078e                	slli	a5,a5,0x3
    80004d8c:	97ba                	add	a5,a5,a4
    80004d8e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004d90:	00278713          	addi	a4,a5,2
    80004d94:	0712                	slli	a4,a4,0x4
    80004d96:	9726                	add	a4,a4,s1
    80004d98:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80004d9c:	e321                	bnez	a4,80004ddc <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004d9e:	0789                	addi	a5,a5,2
    80004da0:	0792                	slli	a5,a5,0x4
    80004da2:	97a6                	add	a5,a5,s1
    80004da4:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004da6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004daa:	80dfc0ef          	jal	ra,800015b6 <wakeup>

    disk.used_idx += 1;
    80004dae:	0204d783          	lhu	a5,32(s1)
    80004db2:	2785                	addiw	a5,a5,1
    80004db4:	17c2                	slli	a5,a5,0x30
    80004db6:	93c1                	srli	a5,a5,0x30
    80004db8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004dbc:	6898                	ld	a4,16(s1)
    80004dbe:	00275703          	lhu	a4,2(a4)
    80004dc2:	faf71ee3          	bne	a4,a5,80004d7e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80004dc6:	00014517          	auipc	a0,0x14
    80004dca:	0b250513          	addi	a0,a0,178 # 80018e78 <disk+0x128>
    80004dce:	2fd000ef          	jal	ra,800058ca <release>
}
    80004dd2:	60e2                	ld	ra,24(sp)
    80004dd4:	6442                	ld	s0,16(sp)
    80004dd6:	64a2                	ld	s1,8(sp)
    80004dd8:	6105                	addi	sp,sp,32
    80004dda:	8082                	ret
      panic("virtio_disk_intr status");
    80004ddc:	00003517          	auipc	a0,0x3
    80004de0:	b4c50513          	addi	a0,a0,-1204 # 80007928 <syscalls+0x440>
    80004de4:	73e000ef          	jal	ra,80005522 <panic>

0000000080004de8 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004de8:	1141                	addi	sp,sp,-16
    80004dea:	e422                	sd	s0,8(sp)
    80004dec:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004dee:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004df2:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004df6:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004dfa:	30a027f3          	csrr	a5,0x30a

  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63));
    80004dfe:	577d                	li	a4,-1
    80004e00:	177e                	slli	a4,a4,0x3f
    80004e02:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004e04:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004e08:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004e0c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004e10:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004e14:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004e18:	000f4737          	lui	a4,0xf4
    80004e1c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004e20:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004e22:	14d79073          	csrw	0x14d,a5
}
    80004e26:	6422                	ld	s0,8(sp)
    80004e28:	0141                	addi	sp,sp,16
    80004e2a:	8082                	ret

0000000080004e2c <start>:
{
    80004e2c:	1141                	addi	sp,sp,-16
    80004e2e:	e406                	sd	ra,8(sp)
    80004e30:	e022                	sd	s0,0(sp)
    80004e32:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004e34:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004e38:	7779                	lui	a4,0xffffe
    80004e3a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd86f>
    80004e3e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004e40:	6705                	lui	a4,0x1
    80004e42:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004e46:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004e48:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004e4c:	ffffb797          	auipc	a5,0xffffb
    80004e50:	60878793          	addi	a5,a5,1544 # 80000454 <main>
    80004e54:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004e58:	4781                	li	a5,0
    80004e5a:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004e5e:	67c1                	lui	a5,0x10
    80004e60:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004e62:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004e66:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004e6a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004e6e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004e72:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004e76:	57fd                	li	a5,-1
    80004e78:	83a9                	srli	a5,a5,0xa
    80004e7a:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004e7e:	47bd                	li	a5,15
    80004e80:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004e84:	f65ff0ef          	jal	ra,80004de8 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004e88:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004e8c:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004e8e:	823e                	mv	tp,a5
  asm volatile("mret");
    80004e90:	30200073          	mret
}
    80004e94:	60a2                	ld	ra,8(sp)
    80004e96:	6402                	ld	s0,0(sp)
    80004e98:	0141                	addi	sp,sp,16
    80004e9a:	8082                	ret

0000000080004e9c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004e9c:	715d                	addi	sp,sp,-80
    80004e9e:	e486                	sd	ra,72(sp)
    80004ea0:	e0a2                	sd	s0,64(sp)
    80004ea2:	fc26                	sd	s1,56(sp)
    80004ea4:	f84a                	sd	s2,48(sp)
    80004ea6:	f44e                	sd	s3,40(sp)
    80004ea8:	f052                	sd	s4,32(sp)
    80004eaa:	ec56                	sd	s5,24(sp)
    80004eac:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004eae:	04c05363          	blez	a2,80004ef4 <consolewrite+0x58>
    80004eb2:	8a2a                	mv	s4,a0
    80004eb4:	84ae                	mv	s1,a1
    80004eb6:	89b2                	mv	s3,a2
    80004eb8:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004eba:	5afd                	li	s5,-1
    80004ebc:	4685                	li	a3,1
    80004ebe:	8626                	mv	a2,s1
    80004ec0:	85d2                	mv	a1,s4
    80004ec2:	fbf40513          	addi	a0,s0,-65
    80004ec6:	a4bfc0ef          	jal	ra,80001910 <either_copyin>
    80004eca:	01550b63          	beq	a0,s5,80004ee0 <consolewrite+0x44>
      break;
    uartputc(c);
    80004ece:	fbf44503          	lbu	a0,-65(s0)
    80004ed2:	7da000ef          	jal	ra,800056ac <uartputc>
  for(i = 0; i < n; i++){
    80004ed6:	2905                	addiw	s2,s2,1
    80004ed8:	0485                	addi	s1,s1,1
    80004eda:	ff2991e3          	bne	s3,s2,80004ebc <consolewrite+0x20>
    80004ede:	894e                	mv	s2,s3
  }

  return i;
}
    80004ee0:	854a                	mv	a0,s2
    80004ee2:	60a6                	ld	ra,72(sp)
    80004ee4:	6406                	ld	s0,64(sp)
    80004ee6:	74e2                	ld	s1,56(sp)
    80004ee8:	7942                	ld	s2,48(sp)
    80004eea:	79a2                	ld	s3,40(sp)
    80004eec:	7a02                	ld	s4,32(sp)
    80004eee:	6ae2                	ld	s5,24(sp)
    80004ef0:	6161                	addi	sp,sp,80
    80004ef2:	8082                	ret
  for(i = 0; i < n; i++){
    80004ef4:	4901                	li	s2,0
    80004ef6:	b7ed                	j	80004ee0 <consolewrite+0x44>

0000000080004ef8 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004ef8:	7159                	addi	sp,sp,-112
    80004efa:	f486                	sd	ra,104(sp)
    80004efc:	f0a2                	sd	s0,96(sp)
    80004efe:	eca6                	sd	s1,88(sp)
    80004f00:	e8ca                	sd	s2,80(sp)
    80004f02:	e4ce                	sd	s3,72(sp)
    80004f04:	e0d2                	sd	s4,64(sp)
    80004f06:	fc56                	sd	s5,56(sp)
    80004f08:	f85a                	sd	s6,48(sp)
    80004f0a:	f45e                	sd	s7,40(sp)
    80004f0c:	f062                	sd	s8,32(sp)
    80004f0e:	ec66                	sd	s9,24(sp)
    80004f10:	e86a                	sd	s10,16(sp)
    80004f12:	1880                	addi	s0,sp,112
    80004f14:	8aaa                	mv	s5,a0
    80004f16:	8a2e                	mv	s4,a1
    80004f18:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004f1a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004f1e:	0001c517          	auipc	a0,0x1c
    80004f22:	f7250513          	addi	a0,a0,-142 # 80020e90 <cons>
    80004f26:	10d000ef          	jal	ra,80005832 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004f2a:	0001c497          	auipc	s1,0x1c
    80004f2e:	f6648493          	addi	s1,s1,-154 # 80020e90 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004f32:	0001c917          	auipc	s2,0x1c
    80004f36:	ff690913          	addi	s2,s2,-10 # 80020f28 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80004f3a:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004f3c:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80004f3e:	4ca9                	li	s9,10
  while(n > 0){
    80004f40:	07305363          	blez	s3,80004fa6 <consoleread+0xae>
    while(cons.r == cons.w){
    80004f44:	0984a783          	lw	a5,152(s1)
    80004f48:	09c4a703          	lw	a4,156(s1)
    80004f4c:	02f71163          	bne	a4,a5,80004f6e <consoleread+0x76>
      if(killed(myproc())){
    80004f50:	84efc0ef          	jal	ra,80000f9e <myproc>
    80004f54:	84ffc0ef          	jal	ra,800017a2 <killed>
    80004f58:	e125                	bnez	a0,80004fb8 <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    80004f5a:	85a6                	mv	a1,s1
    80004f5c:	854a                	mv	a0,s2
    80004f5e:	e0cfc0ef          	jal	ra,8000156a <sleep>
    while(cons.r == cons.w){
    80004f62:	0984a783          	lw	a5,152(s1)
    80004f66:	09c4a703          	lw	a4,156(s1)
    80004f6a:	fef703e3          	beq	a4,a5,80004f50 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004f6e:	0017871b          	addiw	a4,a5,1
    80004f72:	08e4ac23          	sw	a4,152(s1)
    80004f76:	07f7f713          	andi	a4,a5,127
    80004f7a:	9726                	add	a4,a4,s1
    80004f7c:	01874703          	lbu	a4,24(a4)
    80004f80:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80004f84:	057d0f63          	beq	s10,s7,80004fe2 <consoleread+0xea>
    cbuf = c;
    80004f88:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004f8c:	4685                	li	a3,1
    80004f8e:	f9f40613          	addi	a2,s0,-97
    80004f92:	85d2                	mv	a1,s4
    80004f94:	8556                	mv	a0,s5
    80004f96:	931fc0ef          	jal	ra,800018c6 <either_copyout>
    80004f9a:	01850663          	beq	a0,s8,80004fa6 <consoleread+0xae>
    dst++;
    80004f9e:	0a05                	addi	s4,s4,1
    --n;
    80004fa0:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80004fa2:	f99d1fe3          	bne	s10,s9,80004f40 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80004fa6:	0001c517          	auipc	a0,0x1c
    80004faa:	eea50513          	addi	a0,a0,-278 # 80020e90 <cons>
    80004fae:	11d000ef          	jal	ra,800058ca <release>

  return target - n;
    80004fb2:	413b053b          	subw	a0,s6,s3
    80004fb6:	a801                	j	80004fc6 <consoleread+0xce>
        release(&cons.lock);
    80004fb8:	0001c517          	auipc	a0,0x1c
    80004fbc:	ed850513          	addi	a0,a0,-296 # 80020e90 <cons>
    80004fc0:	10b000ef          	jal	ra,800058ca <release>
        return -1;
    80004fc4:	557d                	li	a0,-1
}
    80004fc6:	70a6                	ld	ra,104(sp)
    80004fc8:	7406                	ld	s0,96(sp)
    80004fca:	64e6                	ld	s1,88(sp)
    80004fcc:	6946                	ld	s2,80(sp)
    80004fce:	69a6                	ld	s3,72(sp)
    80004fd0:	6a06                	ld	s4,64(sp)
    80004fd2:	7ae2                	ld	s5,56(sp)
    80004fd4:	7b42                	ld	s6,48(sp)
    80004fd6:	7ba2                	ld	s7,40(sp)
    80004fd8:	7c02                	ld	s8,32(sp)
    80004fda:	6ce2                	ld	s9,24(sp)
    80004fdc:	6d42                	ld	s10,16(sp)
    80004fde:	6165                	addi	sp,sp,112
    80004fe0:	8082                	ret
      if(n < target){
    80004fe2:	0009871b          	sext.w	a4,s3
    80004fe6:	fd6770e3          	bgeu	a4,s6,80004fa6 <consoleread+0xae>
        cons.r--;
    80004fea:	0001c717          	auipc	a4,0x1c
    80004fee:	f2f72f23          	sw	a5,-194(a4) # 80020f28 <cons+0x98>
    80004ff2:	bf55                	j	80004fa6 <consoleread+0xae>

0000000080004ff4 <consputc>:
{
    80004ff4:	1141                	addi	sp,sp,-16
    80004ff6:	e406                	sd	ra,8(sp)
    80004ff8:	e022                	sd	s0,0(sp)
    80004ffa:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80004ffc:	10000793          	li	a5,256
    80005000:	00f50863          	beq	a0,a5,80005010 <consputc+0x1c>
    uartputc_sync(c);
    80005004:	5d2000ef          	jal	ra,800055d6 <uartputc_sync>
}
    80005008:	60a2                	ld	ra,8(sp)
    8000500a:	6402                	ld	s0,0(sp)
    8000500c:	0141                	addi	sp,sp,16
    8000500e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005010:	4521                	li	a0,8
    80005012:	5c4000ef          	jal	ra,800055d6 <uartputc_sync>
    80005016:	02000513          	li	a0,32
    8000501a:	5bc000ef          	jal	ra,800055d6 <uartputc_sync>
    8000501e:	4521                	li	a0,8
    80005020:	5b6000ef          	jal	ra,800055d6 <uartputc_sync>
    80005024:	b7d5                	j	80005008 <consputc+0x14>

0000000080005026 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005026:	1101                	addi	sp,sp,-32
    80005028:	ec06                	sd	ra,24(sp)
    8000502a:	e822                	sd	s0,16(sp)
    8000502c:	e426                	sd	s1,8(sp)
    8000502e:	e04a                	sd	s2,0(sp)
    80005030:	1000                	addi	s0,sp,32
    80005032:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005034:	0001c517          	auipc	a0,0x1c
    80005038:	e5c50513          	addi	a0,a0,-420 # 80020e90 <cons>
    8000503c:	7f6000ef          	jal	ra,80005832 <acquire>

  switch(c){
    80005040:	47d5                	li	a5,21
    80005042:	0af48063          	beq	s1,a5,800050e2 <consoleintr+0xbc>
    80005046:	0297c663          	blt	a5,s1,80005072 <consoleintr+0x4c>
    8000504a:	47a1                	li	a5,8
    8000504c:	0cf48f63          	beq	s1,a5,8000512a <consoleintr+0x104>
    80005050:	47c1                	li	a5,16
    80005052:	10f49063          	bne	s1,a5,80005152 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    80005056:	905fc0ef          	jal	ra,8000195a <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    8000505a:	0001c517          	auipc	a0,0x1c
    8000505e:	e3650513          	addi	a0,a0,-458 # 80020e90 <cons>
    80005062:	069000ef          	jal	ra,800058ca <release>
}
    80005066:	60e2                	ld	ra,24(sp)
    80005068:	6442                	ld	s0,16(sp)
    8000506a:	64a2                	ld	s1,8(sp)
    8000506c:	6902                	ld	s2,0(sp)
    8000506e:	6105                	addi	sp,sp,32
    80005070:	8082                	ret
  switch(c){
    80005072:	07f00793          	li	a5,127
    80005076:	0af48a63          	beq	s1,a5,8000512a <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000507a:	0001c717          	auipc	a4,0x1c
    8000507e:	e1670713          	addi	a4,a4,-490 # 80020e90 <cons>
    80005082:	0a072783          	lw	a5,160(a4)
    80005086:	09872703          	lw	a4,152(a4)
    8000508a:	9f99                	subw	a5,a5,a4
    8000508c:	07f00713          	li	a4,127
    80005090:	fcf765e3          	bltu	a4,a5,8000505a <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    80005094:	47b5                	li	a5,13
    80005096:	0cf48163          	beq	s1,a5,80005158 <consoleintr+0x132>
      consputc(c);
    8000509a:	8526                	mv	a0,s1
    8000509c:	f59ff0ef          	jal	ra,80004ff4 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800050a0:	0001c797          	auipc	a5,0x1c
    800050a4:	df078793          	addi	a5,a5,-528 # 80020e90 <cons>
    800050a8:	0a07a683          	lw	a3,160(a5)
    800050ac:	0016871b          	addiw	a4,a3,1
    800050b0:	0007061b          	sext.w	a2,a4
    800050b4:	0ae7a023          	sw	a4,160(a5)
    800050b8:	07f6f693          	andi	a3,a3,127
    800050bc:	97b6                	add	a5,a5,a3
    800050be:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    800050c2:	47a9                	li	a5,10
    800050c4:	0af48f63          	beq	s1,a5,80005182 <consoleintr+0x15c>
    800050c8:	4791                	li	a5,4
    800050ca:	0af48c63          	beq	s1,a5,80005182 <consoleintr+0x15c>
    800050ce:	0001c797          	auipc	a5,0x1c
    800050d2:	e5a7a783          	lw	a5,-422(a5) # 80020f28 <cons+0x98>
    800050d6:	9f1d                	subw	a4,a4,a5
    800050d8:	08000793          	li	a5,128
    800050dc:	f6f71fe3          	bne	a4,a5,8000505a <consoleintr+0x34>
    800050e0:	a04d                	j	80005182 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    800050e2:	0001c717          	auipc	a4,0x1c
    800050e6:	dae70713          	addi	a4,a4,-594 # 80020e90 <cons>
    800050ea:	0a072783          	lw	a5,160(a4)
    800050ee:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800050f2:	0001c497          	auipc	s1,0x1c
    800050f6:	d9e48493          	addi	s1,s1,-610 # 80020e90 <cons>
    while(cons.e != cons.w &&
    800050fa:	4929                	li	s2,10
    800050fc:	f4f70fe3          	beq	a4,a5,8000505a <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005100:	37fd                	addiw	a5,a5,-1
    80005102:	07f7f713          	andi	a4,a5,127
    80005106:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005108:	01874703          	lbu	a4,24(a4)
    8000510c:	f52707e3          	beq	a4,s2,8000505a <consoleintr+0x34>
      cons.e--;
    80005110:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005114:	10000513          	li	a0,256
    80005118:	eddff0ef          	jal	ra,80004ff4 <consputc>
    while(cons.e != cons.w &&
    8000511c:	0a04a783          	lw	a5,160(s1)
    80005120:	09c4a703          	lw	a4,156(s1)
    80005124:	fcf71ee3          	bne	a4,a5,80005100 <consoleintr+0xda>
    80005128:	bf0d                	j	8000505a <consoleintr+0x34>
    if(cons.e != cons.w){
    8000512a:	0001c717          	auipc	a4,0x1c
    8000512e:	d6670713          	addi	a4,a4,-666 # 80020e90 <cons>
    80005132:	0a072783          	lw	a5,160(a4)
    80005136:	09c72703          	lw	a4,156(a4)
    8000513a:	f2f700e3          	beq	a4,a5,8000505a <consoleintr+0x34>
      cons.e--;
    8000513e:	37fd                	addiw	a5,a5,-1
    80005140:	0001c717          	auipc	a4,0x1c
    80005144:	def72823          	sw	a5,-528(a4) # 80020f30 <cons+0xa0>
      consputc(BACKSPACE);
    80005148:	10000513          	li	a0,256
    8000514c:	ea9ff0ef          	jal	ra,80004ff4 <consputc>
    80005150:	b729                	j	8000505a <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005152:	f00484e3          	beqz	s1,8000505a <consoleintr+0x34>
    80005156:	b715                	j	8000507a <consoleintr+0x54>
      consputc(c);
    80005158:	4529                	li	a0,10
    8000515a:	e9bff0ef          	jal	ra,80004ff4 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000515e:	0001c797          	auipc	a5,0x1c
    80005162:	d3278793          	addi	a5,a5,-718 # 80020e90 <cons>
    80005166:	0a07a703          	lw	a4,160(a5)
    8000516a:	0017069b          	addiw	a3,a4,1
    8000516e:	0006861b          	sext.w	a2,a3
    80005172:	0ad7a023          	sw	a3,160(a5)
    80005176:	07f77713          	andi	a4,a4,127
    8000517a:	97ba                	add	a5,a5,a4
    8000517c:	4729                	li	a4,10
    8000517e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005182:	0001c797          	auipc	a5,0x1c
    80005186:	dac7a523          	sw	a2,-598(a5) # 80020f2c <cons+0x9c>
        wakeup(&cons.r);
    8000518a:	0001c517          	auipc	a0,0x1c
    8000518e:	d9e50513          	addi	a0,a0,-610 # 80020f28 <cons+0x98>
    80005192:	c24fc0ef          	jal	ra,800015b6 <wakeup>
    80005196:	b5d1                	j	8000505a <consoleintr+0x34>

0000000080005198 <consoleinit>:

void
consoleinit(void)
{
    80005198:	1141                	addi	sp,sp,-16
    8000519a:	e406                	sd	ra,8(sp)
    8000519c:	e022                	sd	s0,0(sp)
    8000519e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800051a0:	00002597          	auipc	a1,0x2
    800051a4:	7a058593          	addi	a1,a1,1952 # 80007940 <syscalls+0x458>
    800051a8:	0001c517          	auipc	a0,0x1c
    800051ac:	ce850513          	addi	a0,a0,-792 # 80020e90 <cons>
    800051b0:	602000ef          	jal	ra,800057b2 <initlock>

  uartinit();
    800051b4:	3d6000ef          	jal	ra,8000558a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800051b8:	00013797          	auipc	a5,0x13
    800051bc:	b4078793          	addi	a5,a5,-1216 # 80017cf8 <devsw>
    800051c0:	00000717          	auipc	a4,0x0
    800051c4:	d3870713          	addi	a4,a4,-712 # 80004ef8 <consoleread>
    800051c8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800051ca:	00000717          	auipc	a4,0x0
    800051ce:	cd270713          	addi	a4,a4,-814 # 80004e9c <consolewrite>
    800051d2:	ef98                	sd	a4,24(a5)
}
    800051d4:	60a2                	ld	ra,8(sp)
    800051d6:	6402                	ld	s0,0(sp)
    800051d8:	0141                	addi	sp,sp,16
    800051da:	8082                	ret

00000000800051dc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    800051dc:	7179                	addi	sp,sp,-48
    800051de:	f406                	sd	ra,40(sp)
    800051e0:	f022                	sd	s0,32(sp)
    800051e2:	ec26                	sd	s1,24(sp)
    800051e4:	e84a                	sd	s2,16(sp)
    800051e6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    800051e8:	c219                	beqz	a2,800051ee <printint+0x12>
    800051ea:	06054e63          	bltz	a0,80005266 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    800051ee:	4881                	li	a7,0
    800051f0:	fd040693          	addi	a3,s0,-48

  i = 0;
    800051f4:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    800051f6:	00002617          	auipc	a2,0x2
    800051fa:	77260613          	addi	a2,a2,1906 # 80007968 <digits>
    800051fe:	883e                	mv	a6,a5
    80005200:	2785                	addiw	a5,a5,1
    80005202:	02b57733          	remu	a4,a0,a1
    80005206:	9732                	add	a4,a4,a2
    80005208:	00074703          	lbu	a4,0(a4)
    8000520c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80005210:	872a                	mv	a4,a0
    80005212:	02b55533          	divu	a0,a0,a1
    80005216:	0685                	addi	a3,a3,1
    80005218:	feb773e3          	bgeu	a4,a1,800051fe <printint+0x22>

  if(sign)
    8000521c:	00088a63          	beqz	a7,80005230 <printint+0x54>
    buf[i++] = '-';
    80005220:	1781                	addi	a5,a5,-32
    80005222:	97a2                	add	a5,a5,s0
    80005224:	02d00713          	li	a4,45
    80005228:	fee78823          	sb	a4,-16(a5)
    8000522c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005230:	02f05563          	blez	a5,8000525a <printint+0x7e>
    80005234:	fd040713          	addi	a4,s0,-48
    80005238:	00f704b3          	add	s1,a4,a5
    8000523c:	fff70913          	addi	s2,a4,-1
    80005240:	993e                	add	s2,s2,a5
    80005242:	37fd                	addiw	a5,a5,-1
    80005244:	1782                	slli	a5,a5,0x20
    80005246:	9381                	srli	a5,a5,0x20
    80005248:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000524c:	fff4c503          	lbu	a0,-1(s1)
    80005250:	da5ff0ef          	jal	ra,80004ff4 <consputc>
  while(--i >= 0)
    80005254:	14fd                	addi	s1,s1,-1
    80005256:	ff249be3          	bne	s1,s2,8000524c <printint+0x70>
}
    8000525a:	70a2                	ld	ra,40(sp)
    8000525c:	7402                	ld	s0,32(sp)
    8000525e:	64e2                	ld	s1,24(sp)
    80005260:	6942                	ld	s2,16(sp)
    80005262:	6145                	addi	sp,sp,48
    80005264:	8082                	ret
    x = -xx;
    80005266:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000526a:	4885                	li	a7,1
    x = -xx;
    8000526c:	b751                	j	800051f0 <printint+0x14>

000000008000526e <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000526e:	7155                	addi	sp,sp,-208
    80005270:	e506                	sd	ra,136(sp)
    80005272:	e122                	sd	s0,128(sp)
    80005274:	fca6                	sd	s1,120(sp)
    80005276:	f8ca                	sd	s2,112(sp)
    80005278:	f4ce                	sd	s3,104(sp)
    8000527a:	f0d2                	sd	s4,96(sp)
    8000527c:	ecd6                	sd	s5,88(sp)
    8000527e:	e8da                	sd	s6,80(sp)
    80005280:	e4de                	sd	s7,72(sp)
    80005282:	e0e2                	sd	s8,64(sp)
    80005284:	fc66                	sd	s9,56(sp)
    80005286:	f86a                	sd	s10,48(sp)
    80005288:	f46e                	sd	s11,40(sp)
    8000528a:	0900                	addi	s0,sp,144
    8000528c:	8a2a                	mv	s4,a0
    8000528e:	e40c                	sd	a1,8(s0)
    80005290:	e810                	sd	a2,16(s0)
    80005292:	ec14                	sd	a3,24(s0)
    80005294:	f018                	sd	a4,32(s0)
    80005296:	f41c                	sd	a5,40(s0)
    80005298:	03043823          	sd	a6,48(s0)
    8000529c:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800052a0:	0001c797          	auipc	a5,0x1c
    800052a4:	cb07a783          	lw	a5,-848(a5) # 80020f50 <pr+0x18>
    800052a8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800052ac:	eb9d                	bnez	a5,800052e2 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800052ae:	00840793          	addi	a5,s0,8
    800052b2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800052b6:	00054503          	lbu	a0,0(a0)
    800052ba:	24050463          	beqz	a0,80005502 <printf+0x294>
    800052be:	4981                	li	s3,0
    if(cx != '%'){
    800052c0:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800052c4:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800052c8:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    800052cc:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    800052d0:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    800052d4:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800052d8:	00002b97          	auipc	s7,0x2
    800052dc:	690b8b93          	addi	s7,s7,1680 # 80007968 <digits>
    800052e0:	a081                	j	80005320 <printf+0xb2>
    acquire(&pr.lock);
    800052e2:	0001c517          	auipc	a0,0x1c
    800052e6:	c5650513          	addi	a0,a0,-938 # 80020f38 <pr>
    800052ea:	548000ef          	jal	ra,80005832 <acquire>
  va_start(ap, fmt);
    800052ee:	00840793          	addi	a5,s0,8
    800052f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800052f6:	000a4503          	lbu	a0,0(s4)
    800052fa:	f171                	bnez	a0,800052be <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    800052fc:	0001c517          	auipc	a0,0x1c
    80005300:	c3c50513          	addi	a0,a0,-964 # 80020f38 <pr>
    80005304:	5c6000ef          	jal	ra,800058ca <release>
    80005308:	aaed                	j	80005502 <printf+0x294>
      consputc(cx);
    8000530a:	cebff0ef          	jal	ra,80004ff4 <consputc>
      continue;
    8000530e:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005310:	0014899b          	addiw	s3,s1,1
    80005314:	013a07b3          	add	a5,s4,s3
    80005318:	0007c503          	lbu	a0,0(a5)
    8000531c:	1c050f63          	beqz	a0,800054fa <printf+0x28c>
    if(cx != '%'){
    80005320:	ff5515e3          	bne	a0,s5,8000530a <printf+0x9c>
    i++;
    80005324:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005328:	009a07b3          	add	a5,s4,s1
    8000532c:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005330:	1c090563          	beqz	s2,800054fa <printf+0x28c>
    80005334:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005338:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000533a:	c789                	beqz	a5,80005344 <printf+0xd6>
    8000533c:	009a0733          	add	a4,s4,s1
    80005340:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005344:	03690463          	beq	s2,s6,8000536c <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80005348:	03890e63          	beq	s2,s8,80005384 <printf+0x116>
    } else if(c0 == 'u'){
    8000534c:	0b990d63          	beq	s2,s9,80005406 <printf+0x198>
    } else if(c0 == 'x'){
    80005350:	11a90363          	beq	s2,s10,80005456 <printf+0x1e8>
    } else if(c0 == 'p'){
    80005354:	13b90b63          	beq	s2,s11,8000548a <printf+0x21c>
    } else if(c0 == 's'){
    80005358:	07300793          	li	a5,115
    8000535c:	16f90363          	beq	s2,a5,800054c2 <printf+0x254>
    } else if(c0 == '%'){
    80005360:	03591c63          	bne	s2,s5,80005398 <printf+0x12a>
      consputc('%');
    80005364:	8556                	mv	a0,s5
    80005366:	c8fff0ef          	jal	ra,80004ff4 <consputc>
    8000536a:	b75d                	j	80005310 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    8000536c:	f8843783          	ld	a5,-120(s0)
    80005370:	00878713          	addi	a4,a5,8
    80005374:	f8e43423          	sd	a4,-120(s0)
    80005378:	4605                	li	a2,1
    8000537a:	45a9                	li	a1,10
    8000537c:	4388                	lw	a0,0(a5)
    8000537e:	e5fff0ef          	jal	ra,800051dc <printint>
    80005382:	b779                	j	80005310 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    80005384:	03678163          	beq	a5,s6,800053a6 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005388:	03878d63          	beq	a5,s8,800053c2 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    8000538c:	09978963          	beq	a5,s9,8000541e <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005390:	03878b63          	beq	a5,s8,800053c6 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    80005394:	0da78d63          	beq	a5,s10,8000546e <printf+0x200>
      consputc('%');
    80005398:	8556                	mv	a0,s5
    8000539a:	c5bff0ef          	jal	ra,80004ff4 <consputc>
      consputc(c0);
    8000539e:	854a                	mv	a0,s2
    800053a0:	c55ff0ef          	jal	ra,80004ff4 <consputc>
    800053a4:	b7b5                	j	80005310 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800053a6:	f8843783          	ld	a5,-120(s0)
    800053aa:	00878713          	addi	a4,a5,8
    800053ae:	f8e43423          	sd	a4,-120(s0)
    800053b2:	4605                	li	a2,1
    800053b4:	45a9                	li	a1,10
    800053b6:	6388                	ld	a0,0(a5)
    800053b8:	e25ff0ef          	jal	ra,800051dc <printint>
      i += 1;
    800053bc:	0029849b          	addiw	s1,s3,2
    800053c0:	bf81                	j	80005310 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800053c2:	03668463          	beq	a3,s6,800053ea <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800053c6:	07968a63          	beq	a3,s9,8000543a <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800053ca:	fda697e3          	bne	a3,s10,80005398 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    800053ce:	f8843783          	ld	a5,-120(s0)
    800053d2:	00878713          	addi	a4,a5,8
    800053d6:	f8e43423          	sd	a4,-120(s0)
    800053da:	4601                	li	a2,0
    800053dc:	45c1                	li	a1,16
    800053de:	6388                	ld	a0,0(a5)
    800053e0:	dfdff0ef          	jal	ra,800051dc <printint>
      i += 2;
    800053e4:	0039849b          	addiw	s1,s3,3
    800053e8:	b725                	j	80005310 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800053ea:	f8843783          	ld	a5,-120(s0)
    800053ee:	00878713          	addi	a4,a5,8
    800053f2:	f8e43423          	sd	a4,-120(s0)
    800053f6:	4605                	li	a2,1
    800053f8:	45a9                	li	a1,10
    800053fa:	6388                	ld	a0,0(a5)
    800053fc:	de1ff0ef          	jal	ra,800051dc <printint>
      i += 2;
    80005400:	0039849b          	addiw	s1,s3,3
    80005404:	b731                	j	80005310 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80005406:	f8843783          	ld	a5,-120(s0)
    8000540a:	00878713          	addi	a4,a5,8
    8000540e:	f8e43423          	sd	a4,-120(s0)
    80005412:	4601                	li	a2,0
    80005414:	45a9                	li	a1,10
    80005416:	4388                	lw	a0,0(a5)
    80005418:	dc5ff0ef          	jal	ra,800051dc <printint>
    8000541c:	bdd5                	j	80005310 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000541e:	f8843783          	ld	a5,-120(s0)
    80005422:	00878713          	addi	a4,a5,8
    80005426:	f8e43423          	sd	a4,-120(s0)
    8000542a:	4601                	li	a2,0
    8000542c:	45a9                	li	a1,10
    8000542e:	6388                	ld	a0,0(a5)
    80005430:	dadff0ef          	jal	ra,800051dc <printint>
      i += 1;
    80005434:	0029849b          	addiw	s1,s3,2
    80005438:	bde1                	j	80005310 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000543a:	f8843783          	ld	a5,-120(s0)
    8000543e:	00878713          	addi	a4,a5,8
    80005442:	f8e43423          	sd	a4,-120(s0)
    80005446:	4601                	li	a2,0
    80005448:	45a9                	li	a1,10
    8000544a:	6388                	ld	a0,0(a5)
    8000544c:	d91ff0ef          	jal	ra,800051dc <printint>
      i += 2;
    80005450:	0039849b          	addiw	s1,s3,3
    80005454:	bd75                	j	80005310 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    80005456:	f8843783          	ld	a5,-120(s0)
    8000545a:	00878713          	addi	a4,a5,8
    8000545e:	f8e43423          	sd	a4,-120(s0)
    80005462:	4601                	li	a2,0
    80005464:	45c1                	li	a1,16
    80005466:	4388                	lw	a0,0(a5)
    80005468:	d75ff0ef          	jal	ra,800051dc <printint>
    8000546c:	b555                	j	80005310 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    8000546e:	f8843783          	ld	a5,-120(s0)
    80005472:	00878713          	addi	a4,a5,8
    80005476:	f8e43423          	sd	a4,-120(s0)
    8000547a:	4601                	li	a2,0
    8000547c:	45c1                	li	a1,16
    8000547e:	6388                	ld	a0,0(a5)
    80005480:	d5dff0ef          	jal	ra,800051dc <printint>
      i += 1;
    80005484:	0029849b          	addiw	s1,s3,2
    80005488:	b561                	j	80005310 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    8000548a:	f8843783          	ld	a5,-120(s0)
    8000548e:	00878713          	addi	a4,a5,8
    80005492:	f8e43423          	sd	a4,-120(s0)
    80005496:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000549a:	03000513          	li	a0,48
    8000549e:	b57ff0ef          	jal	ra,80004ff4 <consputc>
  consputc('x');
    800054a2:	856a                	mv	a0,s10
    800054a4:	b51ff0ef          	jal	ra,80004ff4 <consputc>
    800054a8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800054aa:	03c9d793          	srli	a5,s3,0x3c
    800054ae:	97de                	add	a5,a5,s7
    800054b0:	0007c503          	lbu	a0,0(a5)
    800054b4:	b41ff0ef          	jal	ra,80004ff4 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800054b8:	0992                	slli	s3,s3,0x4
    800054ba:	397d                	addiw	s2,s2,-1
    800054bc:	fe0917e3          	bnez	s2,800054aa <printf+0x23c>
    800054c0:	bd81                	j	80005310 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    800054c2:	f8843783          	ld	a5,-120(s0)
    800054c6:	00878713          	addi	a4,a5,8
    800054ca:	f8e43423          	sd	a4,-120(s0)
    800054ce:	0007b903          	ld	s2,0(a5)
    800054d2:	00090d63          	beqz	s2,800054ec <printf+0x27e>
      for(; *s; s++)
    800054d6:	00094503          	lbu	a0,0(s2)
    800054da:	e2050be3          	beqz	a0,80005310 <printf+0xa2>
        consputc(*s);
    800054de:	b17ff0ef          	jal	ra,80004ff4 <consputc>
      for(; *s; s++)
    800054e2:	0905                	addi	s2,s2,1
    800054e4:	00094503          	lbu	a0,0(s2)
    800054e8:	f97d                	bnez	a0,800054de <printf+0x270>
    800054ea:	b51d                	j	80005310 <printf+0xa2>
        s = "(null)";
    800054ec:	00002917          	auipc	s2,0x2
    800054f0:	45c90913          	addi	s2,s2,1116 # 80007948 <syscalls+0x460>
      for(; *s; s++)
    800054f4:	02800513          	li	a0,40
    800054f8:	b7dd                	j	800054de <printf+0x270>
  if(locking)
    800054fa:	f7843783          	ld	a5,-136(s0)
    800054fe:	de079fe3          	bnez	a5,800052fc <printf+0x8e>

  return 0;
}
    80005502:	4501                	li	a0,0
    80005504:	60aa                	ld	ra,136(sp)
    80005506:	640a                	ld	s0,128(sp)
    80005508:	74e6                	ld	s1,120(sp)
    8000550a:	7946                	ld	s2,112(sp)
    8000550c:	79a6                	ld	s3,104(sp)
    8000550e:	7a06                	ld	s4,96(sp)
    80005510:	6ae6                	ld	s5,88(sp)
    80005512:	6b46                	ld	s6,80(sp)
    80005514:	6ba6                	ld	s7,72(sp)
    80005516:	6c06                	ld	s8,64(sp)
    80005518:	7ce2                	ld	s9,56(sp)
    8000551a:	7d42                	ld	s10,48(sp)
    8000551c:	7da2                	ld	s11,40(sp)
    8000551e:	6169                	addi	sp,sp,208
    80005520:	8082                	ret

0000000080005522 <panic>:

void
panic(char *s)
{
    80005522:	1101                	addi	sp,sp,-32
    80005524:	ec06                	sd	ra,24(sp)
    80005526:	e822                	sd	s0,16(sp)
    80005528:	e426                	sd	s1,8(sp)
    8000552a:	1000                	addi	s0,sp,32
    8000552c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000552e:	0001c797          	auipc	a5,0x1c
    80005532:	a207a123          	sw	zero,-1502(a5) # 80020f50 <pr+0x18>
  printf("panic: ");
    80005536:	00002517          	auipc	a0,0x2
    8000553a:	41a50513          	addi	a0,a0,1050 # 80007950 <syscalls+0x468>
    8000553e:	d31ff0ef          	jal	ra,8000526e <printf>
  printf("%s\n", s);
    80005542:	85a6                	mv	a1,s1
    80005544:	00002517          	auipc	a0,0x2
    80005548:	41450513          	addi	a0,a0,1044 # 80007958 <syscalls+0x470>
    8000554c:	d23ff0ef          	jal	ra,8000526e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005550:	4785                	li	a5,1
    80005552:	00002717          	auipc	a4,0x2
    80005556:	4ef72d23          	sw	a5,1274(a4) # 80007a4c <panicked>
  for(;;)
    8000555a:	a001                	j	8000555a <panic+0x38>

000000008000555c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000555c:	1101                	addi	sp,sp,-32
    8000555e:	ec06                	sd	ra,24(sp)
    80005560:	e822                	sd	s0,16(sp)
    80005562:	e426                	sd	s1,8(sp)
    80005564:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005566:	0001c497          	auipc	s1,0x1c
    8000556a:	9d248493          	addi	s1,s1,-1582 # 80020f38 <pr>
    8000556e:	00002597          	auipc	a1,0x2
    80005572:	3f258593          	addi	a1,a1,1010 # 80007960 <syscalls+0x478>
    80005576:	8526                	mv	a0,s1
    80005578:	23a000ef          	jal	ra,800057b2 <initlock>
  pr.locking = 1;
    8000557c:	4785                	li	a5,1
    8000557e:	cc9c                	sw	a5,24(s1)
}
    80005580:	60e2                	ld	ra,24(sp)
    80005582:	6442                	ld	s0,16(sp)
    80005584:	64a2                	ld	s1,8(sp)
    80005586:	6105                	addi	sp,sp,32
    80005588:	8082                	ret

000000008000558a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000558a:	1141                	addi	sp,sp,-16
    8000558c:	e406                	sd	ra,8(sp)
    8000558e:	e022                	sd	s0,0(sp)
    80005590:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005592:	100007b7          	lui	a5,0x10000
    80005596:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000559a:	f8000713          	li	a4,-128
    8000559e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800055a2:	470d                	li	a4,3
    800055a4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800055a8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800055ac:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800055b0:	469d                	li	a3,7
    800055b2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800055b6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800055ba:	00002597          	auipc	a1,0x2
    800055be:	3c658593          	addi	a1,a1,966 # 80007980 <digits+0x18>
    800055c2:	0001c517          	auipc	a0,0x1c
    800055c6:	99650513          	addi	a0,a0,-1642 # 80020f58 <uart_tx_lock>
    800055ca:	1e8000ef          	jal	ra,800057b2 <initlock>
}
    800055ce:	60a2                	ld	ra,8(sp)
    800055d0:	6402                	ld	s0,0(sp)
    800055d2:	0141                	addi	sp,sp,16
    800055d4:	8082                	ret

00000000800055d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800055d6:	1101                	addi	sp,sp,-32
    800055d8:	ec06                	sd	ra,24(sp)
    800055da:	e822                	sd	s0,16(sp)
    800055dc:	e426                	sd	s1,8(sp)
    800055de:	1000                	addi	s0,sp,32
    800055e0:	84aa                	mv	s1,a0
  push_off();
    800055e2:	210000ef          	jal	ra,800057f2 <push_off>

  if(panicked){
    800055e6:	00002797          	auipc	a5,0x2
    800055ea:	4667a783          	lw	a5,1126(a5) # 80007a4c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800055ee:	10000737          	lui	a4,0x10000
  if(panicked){
    800055f2:	c391                	beqz	a5,800055f6 <uartputc_sync+0x20>
    for(;;)
    800055f4:	a001                	j	800055f4 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800055f6:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800055fa:	0207f793          	andi	a5,a5,32
    800055fe:	dfe5                	beqz	a5,800055f6 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80005600:	0ff4f513          	zext.b	a0,s1
    80005604:	100007b7          	lui	a5,0x10000
    80005608:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000560c:	26a000ef          	jal	ra,80005876 <pop_off>
}
    80005610:	60e2                	ld	ra,24(sp)
    80005612:	6442                	ld	s0,16(sp)
    80005614:	64a2                	ld	s1,8(sp)
    80005616:	6105                	addi	sp,sp,32
    80005618:	8082                	ret

000000008000561a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000561a:	00002797          	auipc	a5,0x2
    8000561e:	4367b783          	ld	a5,1078(a5) # 80007a50 <uart_tx_r>
    80005622:	00002717          	auipc	a4,0x2
    80005626:	43673703          	ld	a4,1078(a4) # 80007a58 <uart_tx_w>
    8000562a:	06f70c63          	beq	a4,a5,800056a2 <uartstart+0x88>
{
    8000562e:	7139                	addi	sp,sp,-64
    80005630:	fc06                	sd	ra,56(sp)
    80005632:	f822                	sd	s0,48(sp)
    80005634:	f426                	sd	s1,40(sp)
    80005636:	f04a                	sd	s2,32(sp)
    80005638:	ec4e                	sd	s3,24(sp)
    8000563a:	e852                	sd	s4,16(sp)
    8000563c:	e456                	sd	s5,8(sp)
    8000563e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }

    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005640:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }

    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005644:	0001ca17          	auipc	s4,0x1c
    80005648:	914a0a13          	addi	s4,s4,-1772 # 80020f58 <uart_tx_lock>
    uart_tx_r += 1;
    8000564c:	00002497          	auipc	s1,0x2
    80005650:	40448493          	addi	s1,s1,1028 # 80007a50 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80005654:	00002997          	auipc	s3,0x2
    80005658:	40498993          	addi	s3,s3,1028 # 80007a58 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000565c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80005660:	02077713          	andi	a4,a4,32
    80005664:	c715                	beqz	a4,80005690 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005666:	01f7f713          	andi	a4,a5,31
    8000566a:	9752                	add	a4,a4,s4
    8000566c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80005670:	0785                	addi	a5,a5,1
    80005672:	e09c                	sd	a5,0(s1)

    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80005674:	8526                	mv	a0,s1
    80005676:	f41fb0ef          	jal	ra,800015b6 <wakeup>

    WriteReg(THR, c);
    8000567a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000567e:	609c                	ld	a5,0(s1)
    80005680:	0009b703          	ld	a4,0(s3)
    80005684:	fcf71ce3          	bne	a4,a5,8000565c <uartstart+0x42>
      ReadReg(ISR);
    80005688:	100007b7          	lui	a5,0x10000
    8000568c:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80005690:	70e2                	ld	ra,56(sp)
    80005692:	7442                	ld	s0,48(sp)
    80005694:	74a2                	ld	s1,40(sp)
    80005696:	7902                	ld	s2,32(sp)
    80005698:	69e2                	ld	s3,24(sp)
    8000569a:	6a42                	ld	s4,16(sp)
    8000569c:	6aa2                	ld	s5,8(sp)
    8000569e:	6121                	addi	sp,sp,64
    800056a0:	8082                	ret
      ReadReg(ISR);
    800056a2:	100007b7          	lui	a5,0x10000
    800056a6:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    800056aa:	8082                	ret

00000000800056ac <uartputc>:
{
    800056ac:	7179                	addi	sp,sp,-48
    800056ae:	f406                	sd	ra,40(sp)
    800056b0:	f022                	sd	s0,32(sp)
    800056b2:	ec26                	sd	s1,24(sp)
    800056b4:	e84a                	sd	s2,16(sp)
    800056b6:	e44e                	sd	s3,8(sp)
    800056b8:	e052                	sd	s4,0(sp)
    800056ba:	1800                	addi	s0,sp,48
    800056bc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800056be:	0001c517          	auipc	a0,0x1c
    800056c2:	89a50513          	addi	a0,a0,-1894 # 80020f58 <uart_tx_lock>
    800056c6:	16c000ef          	jal	ra,80005832 <acquire>
  if(panicked){
    800056ca:	00002797          	auipc	a5,0x2
    800056ce:	3827a783          	lw	a5,898(a5) # 80007a4c <panicked>
    800056d2:	efbd                	bnez	a5,80005750 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800056d4:	00002717          	auipc	a4,0x2
    800056d8:	38473703          	ld	a4,900(a4) # 80007a58 <uart_tx_w>
    800056dc:	00002797          	auipc	a5,0x2
    800056e0:	3747b783          	ld	a5,884(a5) # 80007a50 <uart_tx_r>
    800056e4:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800056e8:	0001c997          	auipc	s3,0x1c
    800056ec:	87098993          	addi	s3,s3,-1936 # 80020f58 <uart_tx_lock>
    800056f0:	00002497          	auipc	s1,0x2
    800056f4:	36048493          	addi	s1,s1,864 # 80007a50 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800056f8:	00002917          	auipc	s2,0x2
    800056fc:	36090913          	addi	s2,s2,864 # 80007a58 <uart_tx_w>
    80005700:	00e79d63          	bne	a5,a4,8000571a <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005704:	85ce                	mv	a1,s3
    80005706:	8526                	mv	a0,s1
    80005708:	e63fb0ef          	jal	ra,8000156a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000570c:	00093703          	ld	a4,0(s2)
    80005710:	609c                	ld	a5,0(s1)
    80005712:	02078793          	addi	a5,a5,32
    80005716:	fee787e3          	beq	a5,a4,80005704 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000571a:	0001c497          	auipc	s1,0x1c
    8000571e:	83e48493          	addi	s1,s1,-1986 # 80020f58 <uart_tx_lock>
    80005722:	01f77793          	andi	a5,a4,31
    80005726:	97a6                	add	a5,a5,s1
    80005728:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    8000572c:	0705                	addi	a4,a4,1
    8000572e:	00002797          	auipc	a5,0x2
    80005732:	32e7b523          	sd	a4,810(a5) # 80007a58 <uart_tx_w>
  uartstart();
    80005736:	ee5ff0ef          	jal	ra,8000561a <uartstart>
  release(&uart_tx_lock);
    8000573a:	8526                	mv	a0,s1
    8000573c:	18e000ef          	jal	ra,800058ca <release>
}
    80005740:	70a2                	ld	ra,40(sp)
    80005742:	7402                	ld	s0,32(sp)
    80005744:	64e2                	ld	s1,24(sp)
    80005746:	6942                	ld	s2,16(sp)
    80005748:	69a2                	ld	s3,8(sp)
    8000574a:	6a02                	ld	s4,0(sp)
    8000574c:	6145                	addi	sp,sp,48
    8000574e:	8082                	ret
    for(;;)
    80005750:	a001                	j	80005750 <uartputc+0xa4>

0000000080005752 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005752:	1141                	addi	sp,sp,-16
    80005754:	e422                	sd	s0,8(sp)
    80005756:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80005758:	100007b7          	lui	a5,0x10000
    8000575c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80005760:	8b85                	andi	a5,a5,1
    80005762:	cb81                	beqz	a5,80005772 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80005764:	100007b7          	lui	a5,0x10000
    80005768:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000576c:	6422                	ld	s0,8(sp)
    8000576e:	0141                	addi	sp,sp,16
    80005770:	8082                	ret
    return -1;
    80005772:	557d                	li	a0,-1
    80005774:	bfe5                	j	8000576c <uartgetc+0x1a>

0000000080005776 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005776:	1101                	addi	sp,sp,-32
    80005778:	ec06                	sd	ra,24(sp)
    8000577a:	e822                	sd	s0,16(sp)
    8000577c:	e426                	sd	s1,8(sp)
    8000577e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80005780:	54fd                	li	s1,-1
    80005782:	a019                	j	80005788 <uartintr+0x12>
      break;
    consoleintr(c);
    80005784:	8a3ff0ef          	jal	ra,80005026 <consoleintr>
    int c = uartgetc();
    80005788:	fcbff0ef          	jal	ra,80005752 <uartgetc>
    if(c == -1)
    8000578c:	fe951ce3          	bne	a0,s1,80005784 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80005790:	0001b497          	auipc	s1,0x1b
    80005794:	7c848493          	addi	s1,s1,1992 # 80020f58 <uart_tx_lock>
    80005798:	8526                	mv	a0,s1
    8000579a:	098000ef          	jal	ra,80005832 <acquire>
  uartstart();
    8000579e:	e7dff0ef          	jal	ra,8000561a <uartstart>
  release(&uart_tx_lock);
    800057a2:	8526                	mv	a0,s1
    800057a4:	126000ef          	jal	ra,800058ca <release>
}
    800057a8:	60e2                	ld	ra,24(sp)
    800057aa:	6442                	ld	s0,16(sp)
    800057ac:	64a2                	ld	s1,8(sp)
    800057ae:	6105                	addi	sp,sp,32
    800057b0:	8082                	ret

00000000800057b2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800057b2:	1141                	addi	sp,sp,-16
    800057b4:	e422                	sd	s0,8(sp)
    800057b6:	0800                	addi	s0,sp,16
  lk->name = name;
    800057b8:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800057ba:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800057be:	00053823          	sd	zero,16(a0)
}
    800057c2:	6422                	ld	s0,8(sp)
    800057c4:	0141                	addi	sp,sp,16
    800057c6:	8082                	ret

00000000800057c8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800057c8:	411c                	lw	a5,0(a0)
    800057ca:	e399                	bnez	a5,800057d0 <holding+0x8>
    800057cc:	4501                	li	a0,0
  return r;
}
    800057ce:	8082                	ret
{
    800057d0:	1101                	addi	sp,sp,-32
    800057d2:	ec06                	sd	ra,24(sp)
    800057d4:	e822                	sd	s0,16(sp)
    800057d6:	e426                	sd	s1,8(sp)
    800057d8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800057da:	6904                	ld	s1,16(a0)
    800057dc:	fa6fb0ef          	jal	ra,80000f82 <mycpu>
    800057e0:	40a48533          	sub	a0,s1,a0
    800057e4:	00153513          	seqz	a0,a0
}
    800057e8:	60e2                	ld	ra,24(sp)
    800057ea:	6442                	ld	s0,16(sp)
    800057ec:	64a2                	ld	s1,8(sp)
    800057ee:	6105                	addi	sp,sp,32
    800057f0:	8082                	ret

00000000800057f2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800057f2:	1101                	addi	sp,sp,-32
    800057f4:	ec06                	sd	ra,24(sp)
    800057f6:	e822                	sd	s0,16(sp)
    800057f8:	e426                	sd	s1,8(sp)
    800057fa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800057fc:	100024f3          	csrr	s1,sstatus
    80005800:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005804:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005806:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    8000580a:	f78fb0ef          	jal	ra,80000f82 <mycpu>
    8000580e:	5d3c                	lw	a5,120(a0)
    80005810:	cb99                	beqz	a5,80005826 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005812:	f70fb0ef          	jal	ra,80000f82 <mycpu>
    80005816:	5d3c                	lw	a5,120(a0)
    80005818:	2785                	addiw	a5,a5,1
    8000581a:	dd3c                	sw	a5,120(a0)
}
    8000581c:	60e2                	ld	ra,24(sp)
    8000581e:	6442                	ld	s0,16(sp)
    80005820:	64a2                	ld	s1,8(sp)
    80005822:	6105                	addi	sp,sp,32
    80005824:	8082                	ret
    mycpu()->intena = old;
    80005826:	f5cfb0ef          	jal	ra,80000f82 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    8000582a:	8085                	srli	s1,s1,0x1
    8000582c:	8885                	andi	s1,s1,1
    8000582e:	dd64                	sw	s1,124(a0)
    80005830:	b7cd                	j	80005812 <push_off+0x20>

0000000080005832 <acquire>:
{
    80005832:	1101                	addi	sp,sp,-32
    80005834:	ec06                	sd	ra,24(sp)
    80005836:	e822                	sd	s0,16(sp)
    80005838:	e426                	sd	s1,8(sp)
    8000583a:	1000                	addi	s0,sp,32
    8000583c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    8000583e:	fb5ff0ef          	jal	ra,800057f2 <push_off>
  if(holding(lk))
    80005842:	8526                	mv	a0,s1
    80005844:	f85ff0ef          	jal	ra,800057c8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005848:	4705                	li	a4,1
  if(holding(lk))
    8000584a:	e105                	bnez	a0,8000586a <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000584c:	87ba                	mv	a5,a4
    8000584e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005852:	2781                	sext.w	a5,a5
    80005854:	ffe5                	bnez	a5,8000584c <acquire+0x1a>
  __sync_synchronize();
    80005856:	0ff0000f          	fence
  lk->cpu = mycpu();
    8000585a:	f28fb0ef          	jal	ra,80000f82 <mycpu>
    8000585e:	e888                	sd	a0,16(s1)
}
    80005860:	60e2                	ld	ra,24(sp)
    80005862:	6442                	ld	s0,16(sp)
    80005864:	64a2                	ld	s1,8(sp)
    80005866:	6105                	addi	sp,sp,32
    80005868:	8082                	ret
    panic("acquire");
    8000586a:	00002517          	auipc	a0,0x2
    8000586e:	11e50513          	addi	a0,a0,286 # 80007988 <digits+0x20>
    80005872:	cb1ff0ef          	jal	ra,80005522 <panic>

0000000080005876 <pop_off>:

void
pop_off(void)
{
    80005876:	1141                	addi	sp,sp,-16
    80005878:	e406                	sd	ra,8(sp)
    8000587a:	e022                	sd	s0,0(sp)
    8000587c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000587e:	f04fb0ef          	jal	ra,80000f82 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005882:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005886:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005888:	e78d                	bnez	a5,800058b2 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    8000588a:	5d3c                	lw	a5,120(a0)
    8000588c:	02f05963          	blez	a5,800058be <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005890:	37fd                	addiw	a5,a5,-1
    80005892:	0007871b          	sext.w	a4,a5
    80005896:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005898:	eb09                	bnez	a4,800058aa <pop_off+0x34>
    8000589a:	5d7c                	lw	a5,124(a0)
    8000589c:	c799                	beqz	a5,800058aa <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000589e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800058a2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800058a6:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800058aa:	60a2                	ld	ra,8(sp)
    800058ac:	6402                	ld	s0,0(sp)
    800058ae:	0141                	addi	sp,sp,16
    800058b0:	8082                	ret
    panic("pop_off - interruptible");
    800058b2:	00002517          	auipc	a0,0x2
    800058b6:	0de50513          	addi	a0,a0,222 # 80007990 <digits+0x28>
    800058ba:	c69ff0ef          	jal	ra,80005522 <panic>
    panic("pop_off");
    800058be:	00002517          	auipc	a0,0x2
    800058c2:	0ea50513          	addi	a0,a0,234 # 800079a8 <digits+0x40>
    800058c6:	c5dff0ef          	jal	ra,80005522 <panic>

00000000800058ca <release>:
{
    800058ca:	1101                	addi	sp,sp,-32
    800058cc:	ec06                	sd	ra,24(sp)
    800058ce:	e822                	sd	s0,16(sp)
    800058d0:	e426                	sd	s1,8(sp)
    800058d2:	1000                	addi	s0,sp,32
    800058d4:	84aa                	mv	s1,a0
  if(!holding(lk))
    800058d6:	ef3ff0ef          	jal	ra,800057c8 <holding>
    800058da:	c105                	beqz	a0,800058fa <release+0x30>
  lk->cpu = 0;
    800058dc:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800058e0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800058e4:	0f50000f          	fence	iorw,ow
    800058e8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800058ec:	f8bff0ef          	jal	ra,80005876 <pop_off>
}
    800058f0:	60e2                	ld	ra,24(sp)
    800058f2:	6442                	ld	s0,16(sp)
    800058f4:	64a2                	ld	s1,8(sp)
    800058f6:	6105                	addi	sp,sp,32
    800058f8:	8082                	ret
    panic("release");
    800058fa:	00002517          	auipc	a0,0x2
    800058fe:	0b650513          	addi	a0,a0,182 # 800079b0 <digits+0x48>
    80005902:	c21ff0ef          	jal	ra,80005522 <panic>
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
