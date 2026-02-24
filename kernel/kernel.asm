
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	98013103          	ld	sp,-1664(sp) # 80007980 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	4b7040ef          	jal	ra,80004ccc <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	e7a9                	bnez	a5,80000076 <kfree+0x5a>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00021797          	auipc	a5,0x21
    80000034:	cd078793          	addi	a5,a5,-816 # 80020d00 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	106000ef          	jal	ra,8000014e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000004c:	00008917          	auipc	s2,0x8
    80000050:	98490913          	addi	s2,s2,-1660 # 800079d0 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	67c050ef          	jal	ra,800056d2 <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	704050ef          	jal	ra,8000576a <release>
}
    8000006a:	60e2                	ld	ra,24(sp)
    8000006c:	6442                	ld	s0,16(sp)
    8000006e:	64a2                	ld	s1,8(sp)
    80000070:	6902                	ld	s2,0(sp)
    80000072:	6105                	addi	sp,sp,32
    80000074:	8082                	ret
    panic("kfree");
    80000076:	00007517          	auipc	a0,0x7
    8000007a:	f9a50513          	addi	a0,a0,-102 # 80007010 <etext+0x10>
    8000007e:	344050ef          	jal	ra,800053c2 <panic>

0000000080000082 <freerange>:
{
    80000082:	7179                	addi	sp,sp,-48
    80000084:	f406                	sd	ra,40(sp)
    80000086:	f022                	sd	s0,32(sp)
    80000088:	ec26                	sd	s1,24(sp)
    8000008a:	e84a                	sd	s2,16(sp)
    8000008c:	e44e                	sd	s3,8(sp)
    8000008e:	e052                	sd	s4,0(sp)
    80000090:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000092:	6785                	lui	a5,0x1
    80000094:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000098:	00e504b3          	add	s1,a0,a4
    8000009c:	777d                	lui	a4,0xfffff
    8000009e:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000a0:	94be                	add	s1,s1,a5
    800000a2:	0095ec63          	bltu	a1,s1,800000ba <freerange+0x38>
    800000a6:	892e                	mv	s2,a1
    kfree(p);
    800000a8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000aa:	6985                	lui	s3,0x1
    kfree(p);
    800000ac:	01448533          	add	a0,s1,s4
    800000b0:	f6dff0ef          	jal	ra,8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000b4:	94ce                	add	s1,s1,s3
    800000b6:	fe997be3          	bgeu	s2,s1,800000ac <freerange+0x2a>
}
    800000ba:	70a2                	ld	ra,40(sp)
    800000bc:	7402                	ld	s0,32(sp)
    800000be:	64e2                	ld	s1,24(sp)
    800000c0:	6942                	ld	s2,16(sp)
    800000c2:	69a2                	ld	s3,8(sp)
    800000c4:	6a02                	ld	s4,0(sp)
    800000c6:	6145                	addi	sp,sp,48
    800000c8:	8082                	ret

00000000800000ca <kinit>:
{
    800000ca:	1141                	addi	sp,sp,-16
    800000cc:	e406                	sd	ra,8(sp)
    800000ce:	e022                	sd	s0,0(sp)
    800000d0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000d2:	00007597          	auipc	a1,0x7
    800000d6:	f4658593          	addi	a1,a1,-186 # 80007018 <etext+0x18>
    800000da:	00008517          	auipc	a0,0x8
    800000de:	8f650513          	addi	a0,a0,-1802 # 800079d0 <kmem>
    800000e2:	570050ef          	jal	ra,80005652 <initlock>
  freerange(end, (void*)PHYSTOP);
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	00021517          	auipc	a0,0x21
    800000ee:	c1650513          	addi	a0,a0,-1002 # 80020d00 <end>
    800000f2:	f91ff0ef          	jal	ra,80000082 <freerange>
}
    800000f6:	60a2                	ld	ra,8(sp)
    800000f8:	6402                	ld	s0,0(sp)
    800000fa:	0141                	addi	sp,sp,16
    800000fc:	8082                	ret

00000000800000fe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800000fe:	1101                	addi	sp,sp,-32
    80000100:	ec06                	sd	ra,24(sp)
    80000102:	e822                	sd	s0,16(sp)
    80000104:	e426                	sd	s1,8(sp)
    80000106:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000108:	00008497          	auipc	s1,0x8
    8000010c:	8c848493          	addi	s1,s1,-1848 # 800079d0 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	5c0050ef          	jal	ra,800056d2 <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if (r) {
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	00008517          	auipc	a0,0x8
    80000120:	8b450513          	addi	a0,a0,-1868 # 800079d0 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  }
  release(&kmem.lock);
    80000126:	644050ef          	jal	ra,8000576a <release>

  if (r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000012a:	6605                	lui	a2,0x1
    8000012c:	4595                	li	a1,5
    8000012e:	8526                	mv	a0,s1
    80000130:	01e000ef          	jal	ra,8000014e <memset>
  }
  return (void*)r;
}
    80000134:	8526                	mv	a0,s1
    80000136:	60e2                	ld	ra,24(sp)
    80000138:	6442                	ld	s0,16(sp)
    8000013a:	64a2                	ld	s1,8(sp)
    8000013c:	6105                	addi	sp,sp,32
    8000013e:	8082                	ret
  release(&kmem.lock);
    80000140:	00008517          	auipc	a0,0x8
    80000144:	89050513          	addi	a0,a0,-1904 # 800079d0 <kmem>
    80000148:	622050ef          	jal	ra,8000576a <release>
  if (r) {
    8000014c:	b7e5                	j	80000134 <kalloc+0x36>

000000008000014e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000014e:	1141                	addi	sp,sp,-16
    80000150:	e422                	sd	s0,8(sp)
    80000152:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000154:	ca19                	beqz	a2,8000016a <memset+0x1c>
    80000156:	87aa                	mv	a5,a0
    80000158:	1602                	slli	a2,a2,0x20
    8000015a:	9201                	srli	a2,a2,0x20
    8000015c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000160:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000164:	0785                	addi	a5,a5,1
    80000166:	fee79de3          	bne	a5,a4,80000160 <memset+0x12>
  }
  return dst;
}
    8000016a:	6422                	ld	s0,8(sp)
    8000016c:	0141                	addi	sp,sp,16
    8000016e:	8082                	ret

0000000080000170 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000170:	1141                	addi	sp,sp,-16
    80000172:	e422                	sd	s0,8(sp)
    80000174:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000176:	ca05                	beqz	a2,800001a6 <memcmp+0x36>
    80000178:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    8000017c:	1682                	slli	a3,a3,0x20
    8000017e:	9281                	srli	a3,a3,0x20
    80000180:	0685                	addi	a3,a3,1
    80000182:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000184:	00054783          	lbu	a5,0(a0)
    80000188:	0005c703          	lbu	a4,0(a1)
    8000018c:	00e79863          	bne	a5,a4,8000019c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000190:	0505                	addi	a0,a0,1
    80000192:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000194:	fed518e3          	bne	a0,a3,80000184 <memcmp+0x14>
  }

  return 0;
    80000198:	4501                	li	a0,0
    8000019a:	a019                	j	800001a0 <memcmp+0x30>
      return *s1 - *s2;
    8000019c:	40e7853b          	subw	a0,a5,a4
}
    800001a0:	6422                	ld	s0,8(sp)
    800001a2:	0141                	addi	sp,sp,16
    800001a4:	8082                	ret
  return 0;
    800001a6:	4501                	li	a0,0
    800001a8:	bfe5                	j	800001a0 <memcmp+0x30>

00000000800001aa <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001aa:	1141                	addi	sp,sp,-16
    800001ac:	e422                	sd	s0,8(sp)
    800001ae:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001b0:	c205                	beqz	a2,800001d0 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001b2:	02a5e263          	bltu	a1,a0,800001d6 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001b6:	1602                	slli	a2,a2,0x20
    800001b8:	9201                	srli	a2,a2,0x20
    800001ba:	00c587b3          	add	a5,a1,a2
{
    800001be:	872a                	mv	a4,a0
      *d++ = *s++;
    800001c0:	0585                	addi	a1,a1,1
    800001c2:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde301>
    800001c4:	fff5c683          	lbu	a3,-1(a1)
    800001c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800001cc:	fef59ae3          	bne	a1,a5,800001c0 <memmove+0x16>

  return dst;
}
    800001d0:	6422                	ld	s0,8(sp)
    800001d2:	0141                	addi	sp,sp,16
    800001d4:	8082                	ret
  if(s < d && s + n > d){
    800001d6:	02061693          	slli	a3,a2,0x20
    800001da:	9281                	srli	a3,a3,0x20
    800001dc:	00d58733          	add	a4,a1,a3
    800001e0:	fce57be3          	bgeu	a0,a4,800001b6 <memmove+0xc>
    d += n;
    800001e4:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800001e6:	fff6079b          	addiw	a5,a2,-1
    800001ea:	1782                	slli	a5,a5,0x20
    800001ec:	9381                	srli	a5,a5,0x20
    800001ee:	fff7c793          	not	a5,a5
    800001f2:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800001f4:	177d                	addi	a4,a4,-1
    800001f6:	16fd                	addi	a3,a3,-1
    800001f8:	00074603          	lbu	a2,0(a4)
    800001fc:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000200:	fee79ae3          	bne	a5,a4,800001f4 <memmove+0x4a>
    80000204:	b7f1                	j	800001d0 <memmove+0x26>

0000000080000206 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000206:	1141                	addi	sp,sp,-16
    80000208:	e406                	sd	ra,8(sp)
    8000020a:	e022                	sd	s0,0(sp)
    8000020c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000020e:	f9dff0ef          	jal	ra,800001aa <memmove>
}
    80000212:	60a2                	ld	ra,8(sp)
    80000214:	6402                	ld	s0,0(sp)
    80000216:	0141                	addi	sp,sp,16
    80000218:	8082                	ret

000000008000021a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000021a:	1141                	addi	sp,sp,-16
    8000021c:	e422                	sd	s0,8(sp)
    8000021e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000220:	ce11                	beqz	a2,8000023c <strncmp+0x22>
    80000222:	00054783          	lbu	a5,0(a0)
    80000226:	cf89                	beqz	a5,80000240 <strncmp+0x26>
    80000228:	0005c703          	lbu	a4,0(a1)
    8000022c:	00f71a63          	bne	a4,a5,80000240 <strncmp+0x26>
    n--, p++, q++;
    80000230:	367d                	addiw	a2,a2,-1
    80000232:	0505                	addi	a0,a0,1
    80000234:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000236:	f675                	bnez	a2,80000222 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000238:	4501                	li	a0,0
    8000023a:	a809                	j	8000024c <strncmp+0x32>
    8000023c:	4501                	li	a0,0
    8000023e:	a039                	j	8000024c <strncmp+0x32>
  if(n == 0)
    80000240:	ca09                	beqz	a2,80000252 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000242:	00054503          	lbu	a0,0(a0)
    80000246:	0005c783          	lbu	a5,0(a1)
    8000024a:	9d1d                	subw	a0,a0,a5
}
    8000024c:	6422                	ld	s0,8(sp)
    8000024e:	0141                	addi	sp,sp,16
    80000250:	8082                	ret
    return 0;
    80000252:	4501                	li	a0,0
    80000254:	bfe5                	j	8000024c <strncmp+0x32>

0000000080000256 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000256:	1141                	addi	sp,sp,-16
    80000258:	e422                	sd	s0,8(sp)
    8000025a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000025c:	872a                	mv	a4,a0
    8000025e:	8832                	mv	a6,a2
    80000260:	367d                	addiw	a2,a2,-1
    80000262:	01005963          	blez	a6,80000274 <strncpy+0x1e>
    80000266:	0705                	addi	a4,a4,1
    80000268:	0005c783          	lbu	a5,0(a1)
    8000026c:	fef70fa3          	sb	a5,-1(a4)
    80000270:	0585                	addi	a1,a1,1
    80000272:	f7f5                	bnez	a5,8000025e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000274:	86ba                	mv	a3,a4
    80000276:	00c05c63          	blez	a2,8000028e <strncpy+0x38>
    *s++ = 0;
    8000027a:	0685                	addi	a3,a3,1
    8000027c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000280:	40d707bb          	subw	a5,a4,a3
    80000284:	37fd                	addiw	a5,a5,-1
    80000286:	010787bb          	addw	a5,a5,a6
    8000028a:	fef048e3          	bgtz	a5,8000027a <strncpy+0x24>
  return os;
}
    8000028e:	6422                	ld	s0,8(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret

0000000080000294 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e422                	sd	s0,8(sp)
    80000298:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000029a:	02c05363          	blez	a2,800002c0 <safestrcpy+0x2c>
    8000029e:	fff6069b          	addiw	a3,a2,-1
    800002a2:	1682                	slli	a3,a3,0x20
    800002a4:	9281                	srli	a3,a3,0x20
    800002a6:	96ae                	add	a3,a3,a1
    800002a8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002aa:	00d58963          	beq	a1,a3,800002bc <safestrcpy+0x28>
    800002ae:	0585                	addi	a1,a1,1
    800002b0:	0785                	addi	a5,a5,1
    800002b2:	fff5c703          	lbu	a4,-1(a1)
    800002b6:	fee78fa3          	sb	a4,-1(a5)
    800002ba:	fb65                	bnez	a4,800002aa <safestrcpy+0x16>
    ;
  *s = 0;
    800002bc:	00078023          	sb	zero,0(a5)
  return os;
}
    800002c0:	6422                	ld	s0,8(sp)
    800002c2:	0141                	addi	sp,sp,16
    800002c4:	8082                	ret

00000000800002c6 <strlen>:

int
strlen(const char *s)
{
    800002c6:	1141                	addi	sp,sp,-16
    800002c8:	e422                	sd	s0,8(sp)
    800002ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800002cc:	00054783          	lbu	a5,0(a0)
    800002d0:	cf91                	beqz	a5,800002ec <strlen+0x26>
    800002d2:	0505                	addi	a0,a0,1
    800002d4:	87aa                	mv	a5,a0
    800002d6:	4685                	li	a3,1
    800002d8:	9e89                	subw	a3,a3,a0
    800002da:	00f6853b          	addw	a0,a3,a5
    800002de:	0785                	addi	a5,a5,1
    800002e0:	fff7c703          	lbu	a4,-1(a5)
    800002e4:	fb7d                	bnez	a4,800002da <strlen+0x14>
    ;
  return n;
}
    800002e6:	6422                	ld	s0,8(sp)
    800002e8:	0141                	addi	sp,sp,16
    800002ea:	8082                	ret
  for(n = 0; s[n]; n++)
    800002ec:	4501                	li	a0,0
    800002ee:	bfe5                	j	800002e6 <strlen+0x20>

00000000800002f0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800002f0:	1141                	addi	sp,sp,-16
    800002f2:	e406                	sd	ra,8(sp)
    800002f4:	e022                	sd	s0,0(sp)
    800002f6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800002f8:	311000ef          	jal	ra,80000e08 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800002fc:	00007717          	auipc	a4,0x7
    80000300:	6a470713          	addi	a4,a4,1700 # 800079a0 <started>
  if(cpuid() == 0){
    80000304:	c51d                	beqz	a0,80000332 <main+0x42>
    while(started == 0)
    80000306:	431c                	lw	a5,0(a4)
    80000308:	2781                	sext.w	a5,a5
    8000030a:	dff5                	beqz	a5,80000306 <main+0x16>
      ;
    __sync_synchronize();
    8000030c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000310:	2f9000ef          	jal	ra,80000e08 <cpuid>
    80000314:	85aa                	mv	a1,a0
    80000316:	00007517          	auipc	a0,0x7
    8000031a:	d2250513          	addi	a0,a0,-734 # 80007038 <etext+0x38>
    8000031e:	5f1040ef          	jal	ra,8000510e <printf>
    kvminithart();    // turn on paging
    80000322:	080000ef          	jal	ra,800003a2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000326:	5fc010ef          	jal	ra,80001922 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000032a:	3fa040ef          	jal	ra,80004724 <plicinithart>
  }

  scheduler();
    8000032e:	739000ef          	jal	ra,80001266 <scheduler>
    consoleinit();
    80000332:	507040ef          	jal	ra,80005038 <consoleinit>
    printfinit();
    80000336:	0c6050ef          	jal	ra,800053fc <printfinit>
    printf("\n");
    8000033a:	00007517          	auipc	a0,0x7
    8000033e:	d0e50513          	addi	a0,a0,-754 # 80007048 <etext+0x48>
    80000342:	5cd040ef          	jal	ra,8000510e <printf>
    printf("xv6 kernel is booting\n");
    80000346:	00007517          	auipc	a0,0x7
    8000034a:	cda50513          	addi	a0,a0,-806 # 80007020 <etext+0x20>
    8000034e:	5c1040ef          	jal	ra,8000510e <printf>
    printf("\n");
    80000352:	00007517          	auipc	a0,0x7
    80000356:	cf650513          	addi	a0,a0,-778 # 80007048 <etext+0x48>
    8000035a:	5b5040ef          	jal	ra,8000510e <printf>
    kinit();         // physical page allocator
    8000035e:	d6dff0ef          	jal	ra,800000ca <kinit>
    kvminit();       // create kernel page table
    80000362:	2d4000ef          	jal	ra,80000636 <kvminit>
    kvminithart();   // turn on paging
    80000366:	03c000ef          	jal	ra,800003a2 <kvminithart>
    procinit();      // process table
    8000036a:	1f7000ef          	jal	ra,80000d60 <procinit>
    trapinit();      // trap vectors
    8000036e:	590010ef          	jal	ra,800018fe <trapinit>
    trapinithart();  // install kernel trap vector
    80000372:	5b0010ef          	jal	ra,80001922 <trapinithart>
    plicinit();      // set up interrupt controller
    80000376:	398040ef          	jal	ra,8000470e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000037a:	3aa040ef          	jal	ra,80004724 <plicinithart>
    binit();         // buffer cache
    8000037e:	423010ef          	jal	ra,80001fa0 <binit>
    iinit();         // inode table
    80000382:	1fe020ef          	jal	ra,80002580 <iinit>
    fileinit();      // file table
    80000386:	7a1020ef          	jal	ra,80003326 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000038a:	48a040ef          	jal	ra,80004814 <virtio_disk_init>
    userinit();      // first user process
    8000038e:	50f000ef          	jal	ra,8000109c <userinit>
    __sync_synchronize();
    80000392:	0ff0000f          	fence
    started = 1;
    80000396:	4785                	li	a5,1
    80000398:	00007717          	auipc	a4,0x7
    8000039c:	60f72423          	sw	a5,1544(a4) # 800079a0 <started>
    800003a0:	b779                	j	8000032e <main+0x3e>

00000000800003a2 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800003a2:	1141                	addi	sp,sp,-16
    800003a4:	e422                	sd	s0,8(sp)
    800003a6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800003a8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800003ac:	00007797          	auipc	a5,0x7
    800003b0:	5fc7b783          	ld	a5,1532(a5) # 800079a8 <kernel_pagetable>
    800003b4:	83b1                	srli	a5,a5,0xc
    800003b6:	577d                	li	a4,-1
    800003b8:	177e                	slli	a4,a4,0x3f
    800003ba:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800003bc:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800003c0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800003c4:	6422                	ld	s0,8(sp)
    800003c6:	0141                	addi	sp,sp,16
    800003c8:	8082                	ret

00000000800003ca <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800003ca:	7139                	addi	sp,sp,-64
    800003cc:	fc06                	sd	ra,56(sp)
    800003ce:	f822                	sd	s0,48(sp)
    800003d0:	f426                	sd	s1,40(sp)
    800003d2:	f04a                	sd	s2,32(sp)
    800003d4:	ec4e                	sd	s3,24(sp)
    800003d6:	e852                	sd	s4,16(sp)
    800003d8:	e456                	sd	s5,8(sp)
    800003da:	e05a                	sd	s6,0(sp)
    800003dc:	0080                	addi	s0,sp,64
    800003de:	892a                	mv	s2,a0
    800003e0:	89ae                	mv	s3,a1
    800003e2:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800003e4:	57fd                	li	a5,-1
    800003e6:	83e9                	srli	a5,a5,0x1a
    800003e8:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800003ea:	4b31                	li	s6,12
  if(va >= MAXVA)
    800003ec:	02b7fb63          	bgeu	a5,a1,80000422 <walk+0x58>
    panic("walk");
    800003f0:	00007517          	auipc	a0,0x7
    800003f4:	c6050513          	addi	a0,a0,-928 # 80007050 <etext+0x50>
    800003f8:	7cb040ef          	jal	ra,800053c2 <panic>
      if(PTE_LEAF(*pte)) {
        return pte;
      }
#endif
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800003fc:	060a8563          	beqz	s5,80000466 <walk+0x9c>
    80000400:	cffff0ef          	jal	ra,800000fe <kalloc>
    80000404:	892a                	mv	s2,a0
    80000406:	c135                	beqz	a0,8000046a <walk+0xa0>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000408:	6605                	lui	a2,0x1
    8000040a:	4581                	li	a1,0
    8000040c:	d43ff0ef          	jal	ra,8000014e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000410:	00c95793          	srli	a5,s2,0xc
    80000414:	07aa                	slli	a5,a5,0xa
    80000416:	0017e793          	ori	a5,a5,1
    8000041a:	e09c                	sd	a5,0(s1)
  for(int level = 2; level > 0; level--) {
    8000041c:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde2f7>
    8000041e:	036a0263          	beq	s4,s6,80000442 <walk+0x78>
    pte_t *pte = &pagetable[PX(level, va)];
    80000422:	0149d4b3          	srl	s1,s3,s4
    80000426:	1ff4f493          	andi	s1,s1,511
    8000042a:	048e                	slli	s1,s1,0x3
    8000042c:	94ca                	add	s1,s1,s2
    if(*pte & PTE_V) {
    8000042e:	609c                	ld	a5,0(s1)
    80000430:	0017f713          	andi	a4,a5,1
    80000434:	d761                	beqz	a4,800003fc <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000436:	00a7d913          	srli	s2,a5,0xa
    8000043a:	0932                	slli	s2,s2,0xc
      if(PTE_LEAF(*pte)) {
    8000043c:	8bb9                	andi	a5,a5,14
    8000043e:	dff9                	beqz	a5,8000041c <walk+0x52>
    80000440:	a801                	j	80000450 <walk+0x86>
    }
  }
  return &pagetable[PX(0, va)];
    80000442:	00c9d993          	srli	s3,s3,0xc
    80000446:	1ff9f993          	andi	s3,s3,511
    8000044a:	098e                	slli	s3,s3,0x3
    8000044c:	013904b3          	add	s1,s2,s3
}
    80000450:	8526                	mv	a0,s1
    80000452:	70e2                	ld	ra,56(sp)
    80000454:	7442                	ld	s0,48(sp)
    80000456:	74a2                	ld	s1,40(sp)
    80000458:	7902                	ld	s2,32(sp)
    8000045a:	69e2                	ld	s3,24(sp)
    8000045c:	6a42                	ld	s4,16(sp)
    8000045e:	6aa2                	ld	s5,8(sp)
    80000460:	6b02                	ld	s6,0(sp)
    80000462:	6121                	addi	sp,sp,64
    80000464:	8082                	ret
        return 0;
    80000466:	4481                	li	s1,0
    80000468:	b7e5                	j	80000450 <walk+0x86>
    8000046a:	84aa                	mv	s1,a0
    8000046c:	b7d5                	j	80000450 <walk+0x86>

000000008000046e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000046e:	57fd                	li	a5,-1
    80000470:	83e9                	srli	a5,a5,0x1a
    80000472:	00b7f463          	bgeu	a5,a1,8000047a <walkaddr+0xc>
    return 0;
    80000476:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000478:	8082                	ret
{
    8000047a:	1141                	addi	sp,sp,-16
    8000047c:	e406                	sd	ra,8(sp)
    8000047e:	e022                	sd	s0,0(sp)
    80000480:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000482:	4601                	li	a2,0
    80000484:	f47ff0ef          	jal	ra,800003ca <walk>
  if(pte == 0)
    80000488:	c105                	beqz	a0,800004a8 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    8000048a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000048c:	0117f693          	andi	a3,a5,17
    80000490:	4745                	li	a4,17
    return 0;
    80000492:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000494:	00e68663          	beq	a3,a4,800004a0 <walkaddr+0x32>
}
    80000498:	60a2                	ld	ra,8(sp)
    8000049a:	6402                	ld	s0,0(sp)
    8000049c:	0141                	addi	sp,sp,16
    8000049e:	8082                	ret
  pa = PTE2PA(*pte);
    800004a0:	83a9                	srli	a5,a5,0xa
    800004a2:	00c79513          	slli	a0,a5,0xc
  return pa;
    800004a6:	bfcd                	j	80000498 <walkaddr+0x2a>
    return 0;
    800004a8:	4501                	li	a0,0
    800004aa:	b7fd                	j	80000498 <walkaddr+0x2a>

00000000800004ac <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800004ac:	715d                	addi	sp,sp,-80
    800004ae:	e486                	sd	ra,72(sp)
    800004b0:	e0a2                	sd	s0,64(sp)
    800004b2:	fc26                	sd	s1,56(sp)
    800004b4:	f84a                	sd	s2,48(sp)
    800004b6:	f44e                	sd	s3,40(sp)
    800004b8:	f052                	sd	s4,32(sp)
    800004ba:	ec56                	sd	s5,24(sp)
    800004bc:	e85a                	sd	s6,16(sp)
    800004be:	e45e                	sd	s7,8(sp)
    800004c0:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800004c2:	03459793          	slli	a5,a1,0x34
    800004c6:	e7a9                	bnez	a5,80000510 <mappages+0x64>
    800004c8:	8aaa                	mv	s5,a0
    800004ca:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800004cc:	03461793          	slli	a5,a2,0x34
    800004d0:	e7b1                	bnez	a5,8000051c <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800004d2:	ca39                	beqz	a2,80000528 <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    800004d4:	77fd                	lui	a5,0xfffff
    800004d6:	963e                	add	a2,a2,a5
    800004d8:	00b609b3          	add	s3,a2,a1
  a = va;
    800004dc:	892e                	mv	s2,a1
    800004de:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800004e2:	6b85                	lui	s7,0x1
    800004e4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800004e8:	4605                	li	a2,1
    800004ea:	85ca                	mv	a1,s2
    800004ec:	8556                	mv	a0,s5
    800004ee:	eddff0ef          	jal	ra,800003ca <walk>
    800004f2:	c539                	beqz	a0,80000540 <mappages+0x94>
    if(*pte & PTE_V)
    800004f4:	611c                	ld	a5,0(a0)
    800004f6:	8b85                	andi	a5,a5,1
    800004f8:	ef95                	bnez	a5,80000534 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800004fa:	80b1                	srli	s1,s1,0xc
    800004fc:	04aa                	slli	s1,s1,0xa
    800004fe:	0164e4b3          	or	s1,s1,s6
    80000502:	0014e493          	ori	s1,s1,1
    80000506:	e104                	sd	s1,0(a0)
    if(a == last)
    80000508:	05390863          	beq	s2,s3,80000558 <mappages+0xac>
    a += PGSIZE;
    8000050c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000050e:	bfd9                	j	800004e4 <mappages+0x38>
    panic("mappages: va not aligned");
    80000510:	00007517          	auipc	a0,0x7
    80000514:	b4850513          	addi	a0,a0,-1208 # 80007058 <etext+0x58>
    80000518:	6ab040ef          	jal	ra,800053c2 <panic>
    panic("mappages: size not aligned");
    8000051c:	00007517          	auipc	a0,0x7
    80000520:	b5c50513          	addi	a0,a0,-1188 # 80007078 <etext+0x78>
    80000524:	69f040ef          	jal	ra,800053c2 <panic>
    panic("mappages: size");
    80000528:	00007517          	auipc	a0,0x7
    8000052c:	b7050513          	addi	a0,a0,-1168 # 80007098 <etext+0x98>
    80000530:	693040ef          	jal	ra,800053c2 <panic>
      panic("mappages: remap");
    80000534:	00007517          	auipc	a0,0x7
    80000538:	b7450513          	addi	a0,a0,-1164 # 800070a8 <etext+0xa8>
    8000053c:	687040ef          	jal	ra,800053c2 <panic>
      return -1;
    80000540:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000542:	60a6                	ld	ra,72(sp)
    80000544:	6406                	ld	s0,64(sp)
    80000546:	74e2                	ld	s1,56(sp)
    80000548:	7942                	ld	s2,48(sp)
    8000054a:	79a2                	ld	s3,40(sp)
    8000054c:	7a02                	ld	s4,32(sp)
    8000054e:	6ae2                	ld	s5,24(sp)
    80000550:	6b42                	ld	s6,16(sp)
    80000552:	6ba2                	ld	s7,8(sp)
    80000554:	6161                	addi	sp,sp,80
    80000556:	8082                	ret
  return 0;
    80000558:	4501                	li	a0,0
    8000055a:	b7e5                	j	80000542 <mappages+0x96>

000000008000055c <kvmmap>:
{
    8000055c:	1141                	addi	sp,sp,-16
    8000055e:	e406                	sd	ra,8(sp)
    80000560:	e022                	sd	s0,0(sp)
    80000562:	0800                	addi	s0,sp,16
    80000564:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000566:	86b2                	mv	a3,a2
    80000568:	863e                	mv	a2,a5
    8000056a:	f43ff0ef          	jal	ra,800004ac <mappages>
    8000056e:	e509                	bnez	a0,80000578 <kvmmap+0x1c>
}
    80000570:	60a2                	ld	ra,8(sp)
    80000572:	6402                	ld	s0,0(sp)
    80000574:	0141                	addi	sp,sp,16
    80000576:	8082                	ret
    panic("kvmmap");
    80000578:	00007517          	auipc	a0,0x7
    8000057c:	b4050513          	addi	a0,a0,-1216 # 800070b8 <etext+0xb8>
    80000580:	643040ef          	jal	ra,800053c2 <panic>

0000000080000584 <kvmmake>:
{
    80000584:	1101                	addi	sp,sp,-32
    80000586:	ec06                	sd	ra,24(sp)
    80000588:	e822                	sd	s0,16(sp)
    8000058a:	e426                	sd	s1,8(sp)
    8000058c:	e04a                	sd	s2,0(sp)
    8000058e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000590:	b6fff0ef          	jal	ra,800000fe <kalloc>
    80000594:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000596:	6605                	lui	a2,0x1
    80000598:	4581                	li	a1,0
    8000059a:	bb5ff0ef          	jal	ra,8000014e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000059e:	4719                	li	a4,6
    800005a0:	6685                	lui	a3,0x1
    800005a2:	10000637          	lui	a2,0x10000
    800005a6:	100005b7          	lui	a1,0x10000
    800005aa:	8526                	mv	a0,s1
    800005ac:	fb1ff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800005b0:	4719                	li	a4,6
    800005b2:	6685                	lui	a3,0x1
    800005b4:	10001637          	lui	a2,0x10001
    800005b8:	100015b7          	lui	a1,0x10001
    800005bc:	8526                	mv	a0,s1
    800005be:	f9fff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800005c2:	4719                	li	a4,6
    800005c4:	040006b7          	lui	a3,0x4000
    800005c8:	0c000637          	lui	a2,0xc000
    800005cc:	0c0005b7          	lui	a1,0xc000
    800005d0:	8526                	mv	a0,s1
    800005d2:	f8bff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800005d6:	00007917          	auipc	s2,0x7
    800005da:	a2a90913          	addi	s2,s2,-1494 # 80007000 <etext>
    800005de:	4729                	li	a4,10
    800005e0:	80007697          	auipc	a3,0x80007
    800005e4:	a2068693          	addi	a3,a3,-1504 # 7000 <_entry-0x7fff9000>
    800005e8:	4605                	li	a2,1
    800005ea:	067e                	slli	a2,a2,0x1f
    800005ec:	85b2                	mv	a1,a2
    800005ee:	8526                	mv	a0,s1
    800005f0:	f6dff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800005f4:	4719                	li	a4,6
    800005f6:	46c5                	li	a3,17
    800005f8:	06ee                	slli	a3,a3,0x1b
    800005fa:	412686b3          	sub	a3,a3,s2
    800005fe:	864a                	mv	a2,s2
    80000600:	85ca                	mv	a1,s2
    80000602:	8526                	mv	a0,s1
    80000604:	f59ff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80000608:	4729                	li	a4,10
    8000060a:	6685                	lui	a3,0x1
    8000060c:	00006617          	auipc	a2,0x6
    80000610:	9f460613          	addi	a2,a2,-1548 # 80006000 <_trampoline>
    80000614:	040005b7          	lui	a1,0x4000
    80000618:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000061a:	05b2                	slli	a1,a1,0xc
    8000061c:	8526                	mv	a0,s1
    8000061e:	f3fff0ef          	jal	ra,8000055c <kvmmap>
  proc_mapstacks(kpgtbl);
    80000622:	8526                	mv	a0,s1
    80000624:	6b2000ef          	jal	ra,80000cd6 <proc_mapstacks>
}
    80000628:	8526                	mv	a0,s1
    8000062a:	60e2                	ld	ra,24(sp)
    8000062c:	6442                	ld	s0,16(sp)
    8000062e:	64a2                	ld	s1,8(sp)
    80000630:	6902                	ld	s2,0(sp)
    80000632:	6105                	addi	sp,sp,32
    80000634:	8082                	ret

0000000080000636 <kvminit>:
{
    80000636:	1141                	addi	sp,sp,-16
    80000638:	e406                	sd	ra,8(sp)
    8000063a:	e022                	sd	s0,0(sp)
    8000063c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000063e:	f47ff0ef          	jal	ra,80000584 <kvmmake>
    80000642:	00007797          	auipc	a5,0x7
    80000646:	36a7b323          	sd	a0,870(a5) # 800079a8 <kernel_pagetable>
}
    8000064a:	60a2                	ld	ra,8(sp)
    8000064c:	6402                	ld	s0,0(sp)
    8000064e:	0141                	addi	sp,sp,16
    80000650:	8082                	ret

0000000080000652 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000652:	715d                	addi	sp,sp,-80
    80000654:	e486                	sd	ra,72(sp)
    80000656:	e0a2                	sd	s0,64(sp)
    80000658:	fc26                	sd	s1,56(sp)
    8000065a:	f84a                	sd	s2,48(sp)
    8000065c:	f44e                	sd	s3,40(sp)
    8000065e:	f052                	sd	s4,32(sp)
    80000660:	ec56                	sd	s5,24(sp)
    80000662:	e85a                	sd	s6,16(sp)
    80000664:	e45e                	sd	s7,8(sp)
    80000666:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;
  int sz;

  if((va % PGSIZE) != 0)
    80000668:	03459793          	slli	a5,a1,0x34
    8000066c:	e795                	bnez	a5,80000698 <uvmunmap+0x46>
    8000066e:	8a2a                	mv	s4,a0
    80000670:	892e                	mv	s2,a1
    80000672:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += sz){
    80000674:	0632                	slli	a2,a2,0xc
    80000676:	00b609b3          	add	s3,a2,a1
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0) {
      printf("va=%ld pte=%ld\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if(PTE_FLAGS(*pte) == PTE_V)
    8000067a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += sz){
    8000067c:	6b05                	lui	s6,0x1
    8000067e:	0735e163          	bltu	a1,s3,800006e0 <uvmunmap+0x8e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80000682:	60a6                	ld	ra,72(sp)
    80000684:	6406                	ld	s0,64(sp)
    80000686:	74e2                	ld	s1,56(sp)
    80000688:	7942                	ld	s2,48(sp)
    8000068a:	79a2                	ld	s3,40(sp)
    8000068c:	7a02                	ld	s4,32(sp)
    8000068e:	6ae2                	ld	s5,24(sp)
    80000690:	6b42                	ld	s6,16(sp)
    80000692:	6ba2                	ld	s7,8(sp)
    80000694:	6161                	addi	sp,sp,80
    80000696:	8082                	ret
    panic("uvmunmap: not aligned");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a2850513          	addi	a0,a0,-1496 # 800070c0 <etext+0xc0>
    800006a0:	523040ef          	jal	ra,800053c2 <panic>
      panic("uvmunmap: walk");
    800006a4:	00007517          	auipc	a0,0x7
    800006a8:	a3450513          	addi	a0,a0,-1484 # 800070d8 <etext+0xd8>
    800006ac:	517040ef          	jal	ra,800053c2 <panic>
      printf("va=%ld pte=%ld\n", a, *pte);
    800006b0:	85ca                	mv	a1,s2
    800006b2:	00007517          	auipc	a0,0x7
    800006b6:	a3650513          	addi	a0,a0,-1482 # 800070e8 <etext+0xe8>
    800006ba:	255040ef          	jal	ra,8000510e <printf>
      panic("uvmunmap: not mapped");
    800006be:	00007517          	auipc	a0,0x7
    800006c2:	a3a50513          	addi	a0,a0,-1478 # 800070f8 <etext+0xf8>
    800006c6:	4fd040ef          	jal	ra,800053c2 <panic>
      panic("uvmunmap: not a leaf");
    800006ca:	00007517          	auipc	a0,0x7
    800006ce:	a4650513          	addi	a0,a0,-1466 # 80007110 <etext+0x110>
    800006d2:	4f1040ef          	jal	ra,800053c2 <panic>
    *pte = 0;
    800006d6:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += sz){
    800006da:	995a                	add	s2,s2,s6
    800006dc:	fb3973e3          	bgeu	s2,s3,80000682 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800006e0:	4601                	li	a2,0
    800006e2:	85ca                	mv	a1,s2
    800006e4:	8552                	mv	a0,s4
    800006e6:	ce5ff0ef          	jal	ra,800003ca <walk>
    800006ea:	84aa                	mv	s1,a0
    800006ec:	dd45                	beqz	a0,800006a4 <uvmunmap+0x52>
    if((*pte & PTE_V) == 0) {
    800006ee:	6110                	ld	a2,0(a0)
    800006f0:	00167793          	andi	a5,a2,1
    800006f4:	dfd5                	beqz	a5,800006b0 <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    800006f6:	3ff67793          	andi	a5,a2,1023
    800006fa:	fd7788e3          	beq	a5,s7,800006ca <uvmunmap+0x78>
    if(do_free){
    800006fe:	fc0a8ce3          	beqz	s5,800006d6 <uvmunmap+0x84>
      uint64 pa = PTE2PA(*pte);
    80000702:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    80000704:	00c61513          	slli	a0,a2,0xc
    80000708:	915ff0ef          	jal	ra,8000001c <kfree>
    8000070c:	b7e9                	j	800006d6 <uvmunmap+0x84>

000000008000070e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000070e:	1101                	addi	sp,sp,-32
    80000710:	ec06                	sd	ra,24(sp)
    80000712:	e822                	sd	s0,16(sp)
    80000714:	e426                	sd	s1,8(sp)
    80000716:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000718:	9e7ff0ef          	jal	ra,800000fe <kalloc>
    8000071c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000071e:	c509                	beqz	a0,80000728 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000720:	6605                	lui	a2,0x1
    80000722:	4581                	li	a1,0
    80000724:	a2bff0ef          	jal	ra,8000014e <memset>
  return pagetable;
}
    80000728:	8526                	mv	a0,s1
    8000072a:	60e2                	ld	ra,24(sp)
    8000072c:	6442                	ld	s0,16(sp)
    8000072e:	64a2                	ld	s1,8(sp)
    80000730:	6105                	addi	sp,sp,32
    80000732:	8082                	ret

0000000080000734 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000734:	7179                	addi	sp,sp,-48
    80000736:	f406                	sd	ra,40(sp)
    80000738:	f022                	sd	s0,32(sp)
    8000073a:	ec26                	sd	s1,24(sp)
    8000073c:	e84a                	sd	s2,16(sp)
    8000073e:	e44e                	sd	s3,8(sp)
    80000740:	e052                	sd	s4,0(sp)
    80000742:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000744:	6785                	lui	a5,0x1
    80000746:	04f67063          	bgeu	a2,a5,80000786 <uvmfirst+0x52>
    8000074a:	8a2a                	mv	s4,a0
    8000074c:	89ae                	mv	s3,a1
    8000074e:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80000750:	9afff0ef          	jal	ra,800000fe <kalloc>
    80000754:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000756:	6605                	lui	a2,0x1
    80000758:	4581                	li	a1,0
    8000075a:	9f5ff0ef          	jal	ra,8000014e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000075e:	4779                	li	a4,30
    80000760:	86ca                	mv	a3,s2
    80000762:	6605                	lui	a2,0x1
    80000764:	4581                	li	a1,0
    80000766:	8552                	mv	a0,s4
    80000768:	d45ff0ef          	jal	ra,800004ac <mappages>
  memmove(mem, src, sz);
    8000076c:	8626                	mv	a2,s1
    8000076e:	85ce                	mv	a1,s3
    80000770:	854a                	mv	a0,s2
    80000772:	a39ff0ef          	jal	ra,800001aa <memmove>
}
    80000776:	70a2                	ld	ra,40(sp)
    80000778:	7402                	ld	s0,32(sp)
    8000077a:	64e2                	ld	s1,24(sp)
    8000077c:	6942                	ld	s2,16(sp)
    8000077e:	69a2                	ld	s3,8(sp)
    80000780:	6a02                	ld	s4,0(sp)
    80000782:	6145                	addi	sp,sp,48
    80000784:	8082                	ret
    panic("uvmfirst: more than a page");
    80000786:	00007517          	auipc	a0,0x7
    8000078a:	9a250513          	addi	a0,a0,-1630 # 80007128 <etext+0x128>
    8000078e:	435040ef          	jal	ra,800053c2 <panic>

0000000080000792 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000792:	1101                	addi	sp,sp,-32
    80000794:	ec06                	sd	ra,24(sp)
    80000796:	e822                	sd	s0,16(sp)
    80000798:	e426                	sd	s1,8(sp)
    8000079a:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000079c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000079e:	00b67d63          	bgeu	a2,a1,800007b8 <uvmdealloc+0x26>
    800007a2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800007a4:	6785                	lui	a5,0x1
    800007a6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800007a8:	00f60733          	add	a4,a2,a5
    800007ac:	76fd                	lui	a3,0xfffff
    800007ae:	8f75                	and	a4,a4,a3
    800007b0:	97ae                	add	a5,a5,a1
    800007b2:	8ff5                	and	a5,a5,a3
    800007b4:	00f76863          	bltu	a4,a5,800007c4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800007b8:	8526                	mv	a0,s1
    800007ba:	60e2                	ld	ra,24(sp)
    800007bc:	6442                	ld	s0,16(sp)
    800007be:	64a2                	ld	s1,8(sp)
    800007c0:	6105                	addi	sp,sp,32
    800007c2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800007c4:	8f99                	sub	a5,a5,a4
    800007c6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800007c8:	4685                	li	a3,1
    800007ca:	0007861b          	sext.w	a2,a5
    800007ce:	85ba                	mv	a1,a4
    800007d0:	e83ff0ef          	jal	ra,80000652 <uvmunmap>
    800007d4:	b7d5                	j	800007b8 <uvmdealloc+0x26>

00000000800007d6 <uvmalloc>:
  if(newsz < oldsz)
    800007d6:	08b66963          	bltu	a2,a1,80000868 <uvmalloc+0x92>
{
    800007da:	7139                	addi	sp,sp,-64
    800007dc:	fc06                	sd	ra,56(sp)
    800007de:	f822                	sd	s0,48(sp)
    800007e0:	f426                	sd	s1,40(sp)
    800007e2:	f04a                	sd	s2,32(sp)
    800007e4:	ec4e                	sd	s3,24(sp)
    800007e6:	e852                	sd	s4,16(sp)
    800007e8:	e456                	sd	s5,8(sp)
    800007ea:	e05a                	sd	s6,0(sp)
    800007ec:	0080                	addi	s0,sp,64
    800007ee:	8aaa                	mv	s5,a0
    800007f0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800007f2:	6785                	lui	a5,0x1
    800007f4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800007f6:	95be                	add	a1,a1,a5
    800007f8:	77fd                	lui	a5,0xfffff
    800007fa:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += sz){
    800007fe:	06c9f763          	bgeu	s3,a2,8000086c <uvmalloc+0x96>
    80000802:	894e                	mv	s2,s3
    if(mappages(pagetable, a, sz, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000804:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80000808:	8f7ff0ef          	jal	ra,800000fe <kalloc>
    8000080c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000080e:	c11d                	beqz	a0,80000834 <uvmalloc+0x5e>
    memset(mem, 0, sz);
    80000810:	6605                	lui	a2,0x1
    80000812:	4581                	li	a1,0
    80000814:	93bff0ef          	jal	ra,8000014e <memset>
    if(mappages(pagetable, a, sz, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000818:	875a                	mv	a4,s6
    8000081a:	86a6                	mv	a3,s1
    8000081c:	6605                	lui	a2,0x1
    8000081e:	85ca                	mv	a1,s2
    80000820:	8556                	mv	a0,s5
    80000822:	c8bff0ef          	jal	ra,800004ac <mappages>
    80000826:	e51d                	bnez	a0,80000854 <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += sz){
    80000828:	6785                	lui	a5,0x1
    8000082a:	993e                	add	s2,s2,a5
    8000082c:	fd496ee3          	bltu	s2,s4,80000808 <uvmalloc+0x32>
  return newsz;
    80000830:	8552                	mv	a0,s4
    80000832:	a039                	j	80000840 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    80000834:	864e                	mv	a2,s3
    80000836:	85ca                	mv	a1,s2
    80000838:	8556                	mv	a0,s5
    8000083a:	f59ff0ef          	jal	ra,80000792 <uvmdealloc>
      return 0;
    8000083e:	4501                	li	a0,0
}
    80000840:	70e2                	ld	ra,56(sp)
    80000842:	7442                	ld	s0,48(sp)
    80000844:	74a2                	ld	s1,40(sp)
    80000846:	7902                	ld	s2,32(sp)
    80000848:	69e2                	ld	s3,24(sp)
    8000084a:	6a42                	ld	s4,16(sp)
    8000084c:	6aa2                	ld	s5,8(sp)
    8000084e:	6b02                	ld	s6,0(sp)
    80000850:	6121                	addi	sp,sp,64
    80000852:	8082                	ret
      kfree(mem);
    80000854:	8526                	mv	a0,s1
    80000856:	fc6ff0ef          	jal	ra,8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000085a:	864e                	mv	a2,s3
    8000085c:	85ca                	mv	a1,s2
    8000085e:	8556                	mv	a0,s5
    80000860:	f33ff0ef          	jal	ra,80000792 <uvmdealloc>
      return 0;
    80000864:	4501                	li	a0,0
    80000866:	bfe9                	j	80000840 <uvmalloc+0x6a>
    return oldsz;
    80000868:	852e                	mv	a0,a1
}
    8000086a:	8082                	ret
  return newsz;
    8000086c:	8532                	mv	a0,a2
    8000086e:	bfc9                	j	80000840 <uvmalloc+0x6a>

0000000080000870 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80000870:	7179                	addi	sp,sp,-48
    80000872:	f406                	sd	ra,40(sp)
    80000874:	f022                	sd	s0,32(sp)
    80000876:	ec26                	sd	s1,24(sp)
    80000878:	e84a                	sd	s2,16(sp)
    8000087a:	e44e                	sd	s3,8(sp)
    8000087c:	e052                	sd	s4,0(sp)
    8000087e:	1800                	addi	s0,sp,48
    80000880:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000882:	84aa                	mv	s1,a0
    80000884:	6905                	lui	s2,0x1
    80000886:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000888:	4985                	li	s3,1
    8000088a:	a819                	j	800008a0 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000088c:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000088e:	00c79513          	slli	a0,a5,0xc
    80000892:	fdfff0ef          	jal	ra,80000870 <freewalk>
      pagetable[i] = 0;
    80000896:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000089a:	04a1                	addi	s1,s1,8
    8000089c:	01248f63          	beq	s1,s2,800008ba <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800008a0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800008a2:	00f7f713          	andi	a4,a5,15
    800008a6:	ff3703e3          	beq	a4,s3,8000088c <freewalk+0x1c>
    } else if(pte & PTE_V){
    800008aa:	8b85                	andi	a5,a5,1
    800008ac:	d7fd                	beqz	a5,8000089a <freewalk+0x2a>
      panic("freewalk: leaf");
    800008ae:	00007517          	auipc	a0,0x7
    800008b2:	89a50513          	addi	a0,a0,-1894 # 80007148 <etext+0x148>
    800008b6:	30d040ef          	jal	ra,800053c2 <panic>
    }
  }
  kfree((void*)pagetable);
    800008ba:	8552                	mv	a0,s4
    800008bc:	f60ff0ef          	jal	ra,8000001c <kfree>
}
    800008c0:	70a2                	ld	ra,40(sp)
    800008c2:	7402                	ld	s0,32(sp)
    800008c4:	64e2                	ld	s1,24(sp)
    800008c6:	6942                	ld	s2,16(sp)
    800008c8:	69a2                	ld	s3,8(sp)
    800008ca:	6a02                	ld	s4,0(sp)
    800008cc:	6145                	addi	sp,sp,48
    800008ce:	8082                	ret

00000000800008d0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800008d0:	1101                	addi	sp,sp,-32
    800008d2:	ec06                	sd	ra,24(sp)
    800008d4:	e822                	sd	s0,16(sp)
    800008d6:	e426                	sd	s1,8(sp)
    800008d8:	1000                	addi	s0,sp,32
    800008da:	84aa                	mv	s1,a0
  if(sz > 0)
    800008dc:	e989                	bnez	a1,800008ee <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800008de:	8526                	mv	a0,s1
    800008e0:	f91ff0ef          	jal	ra,80000870 <freewalk>
}
    800008e4:	60e2                	ld	ra,24(sp)
    800008e6:	6442                	ld	s0,16(sp)
    800008e8:	64a2                	ld	s1,8(sp)
    800008ea:	6105                	addi	sp,sp,32
    800008ec:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800008ee:	6785                	lui	a5,0x1
    800008f0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800008f2:	95be                	add	a1,a1,a5
    800008f4:	4685                	li	a3,1
    800008f6:	00c5d613          	srli	a2,a1,0xc
    800008fa:	4581                	li	a1,0
    800008fc:	d57ff0ef          	jal	ra,80000652 <uvmunmap>
    80000900:	bff9                	j	800008de <uvmfree+0xe>

0000000080000902 <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;
  int szinc;

  for(i = 0; i < sz; i += szinc){
    80000902:	c65d                	beqz	a2,800009b0 <uvmcopy+0xae>
{
    80000904:	715d                	addi	sp,sp,-80
    80000906:	e486                	sd	ra,72(sp)
    80000908:	e0a2                	sd	s0,64(sp)
    8000090a:	fc26                	sd	s1,56(sp)
    8000090c:	f84a                	sd	s2,48(sp)
    8000090e:	f44e                	sd	s3,40(sp)
    80000910:	f052                	sd	s4,32(sp)
    80000912:	ec56                	sd	s5,24(sp)
    80000914:	e85a                	sd	s6,16(sp)
    80000916:	e45e                	sd	s7,8(sp)
    80000918:	0880                	addi	s0,sp,80
    8000091a:	8b2a                	mv	s6,a0
    8000091c:	8aae                	mv	s5,a1
    8000091e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += szinc){
    80000920:	4981                	li	s3,0
    szinc = PGSIZE;
    if((pte = walk(old, i, 0)) == 0)
    80000922:	4601                	li	a2,0
    80000924:	85ce                	mv	a1,s3
    80000926:	855a                	mv	a0,s6
    80000928:	aa3ff0ef          	jal	ra,800003ca <walk>
    8000092c:	c121                	beqz	a0,8000096c <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000092e:	6118                	ld	a4,0(a0)
    80000930:	00177793          	andi	a5,a4,1
    80000934:	c3b1                	beqz	a5,80000978 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000936:	00a75593          	srli	a1,a4,0xa
    8000093a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000093e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80000942:	fbcff0ef          	jal	ra,800000fe <kalloc>
    80000946:	892a                	mv	s2,a0
    80000948:	c129                	beqz	a0,8000098a <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000094a:	6605                	lui	a2,0x1
    8000094c:	85de                	mv	a1,s7
    8000094e:	85dff0ef          	jal	ra,800001aa <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000952:	8726                	mv	a4,s1
    80000954:	86ca                	mv	a3,s2
    80000956:	6605                	lui	a2,0x1
    80000958:	85ce                	mv	a1,s3
    8000095a:	8556                	mv	a0,s5
    8000095c:	b51ff0ef          	jal	ra,800004ac <mappages>
    80000960:	e115                	bnez	a0,80000984 <uvmcopy+0x82>
  for(i = 0; i < sz; i += szinc){
    80000962:	6785                	lui	a5,0x1
    80000964:	99be                	add	s3,s3,a5
    80000966:	fb49eee3          	bltu	s3,s4,80000922 <uvmcopy+0x20>
    8000096a:	a805                	j	8000099a <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    8000096c:	00006517          	auipc	a0,0x6
    80000970:	7ec50513          	addi	a0,a0,2028 # 80007158 <etext+0x158>
    80000974:	24f040ef          	jal	ra,800053c2 <panic>
      panic("uvmcopy: page not present");
    80000978:	00007517          	auipc	a0,0x7
    8000097c:	80050513          	addi	a0,a0,-2048 # 80007178 <etext+0x178>
    80000980:	243040ef          	jal	ra,800053c2 <panic>
      kfree(mem);
    80000984:	854a                	mv	a0,s2
    80000986:	e96ff0ef          	jal	ra,8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000098a:	4685                	li	a3,1
    8000098c:	00c9d613          	srli	a2,s3,0xc
    80000990:	4581                	li	a1,0
    80000992:	8556                	mv	a0,s5
    80000994:	cbfff0ef          	jal	ra,80000652 <uvmunmap>
  return -1;
    80000998:	557d                	li	a0,-1
}
    8000099a:	60a6                	ld	ra,72(sp)
    8000099c:	6406                	ld	s0,64(sp)
    8000099e:	74e2                	ld	s1,56(sp)
    800009a0:	7942                	ld	s2,48(sp)
    800009a2:	79a2                	ld	s3,40(sp)
    800009a4:	7a02                	ld	s4,32(sp)
    800009a6:	6ae2                	ld	s5,24(sp)
    800009a8:	6b42                	ld	s6,16(sp)
    800009aa:	6ba2                	ld	s7,8(sp)
    800009ac:	6161                	addi	sp,sp,80
    800009ae:	8082                	ret
  return 0;
    800009b0:	4501                	li	a0,0
}
    800009b2:	8082                	ret

00000000800009b4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800009b4:	1141                	addi	sp,sp,-16
    800009b6:	e406                	sd	ra,8(sp)
    800009b8:	e022                	sd	s0,0(sp)
    800009ba:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800009bc:	4601                	li	a2,0
    800009be:	a0dff0ef          	jal	ra,800003ca <walk>
  if(pte == 0)
    800009c2:	c901                	beqz	a0,800009d2 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800009c4:	611c                	ld	a5,0(a0)
    800009c6:	9bbd                	andi	a5,a5,-17
    800009c8:	e11c                	sd	a5,0(a0)
}
    800009ca:	60a2                	ld	ra,8(sp)
    800009cc:	6402                	ld	s0,0(sp)
    800009ce:	0141                	addi	sp,sp,16
    800009d0:	8082                	ret
    panic("uvmclear");
    800009d2:	00006517          	auipc	a0,0x6
    800009d6:	7c650513          	addi	a0,a0,1990 # 80007198 <etext+0x198>
    800009da:	1e9040ef          	jal	ra,800053c2 <panic>

00000000800009de <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800009de:	c6c1                	beqz	a3,80000a66 <copyout+0x88>
{
    800009e0:	711d                	addi	sp,sp,-96
    800009e2:	ec86                	sd	ra,88(sp)
    800009e4:	e8a2                	sd	s0,80(sp)
    800009e6:	e4a6                	sd	s1,72(sp)
    800009e8:	e0ca                	sd	s2,64(sp)
    800009ea:	fc4e                	sd	s3,56(sp)
    800009ec:	f852                	sd	s4,48(sp)
    800009ee:	f456                	sd	s5,40(sp)
    800009f0:	f05a                	sd	s6,32(sp)
    800009f2:	ec5e                	sd	s7,24(sp)
    800009f4:	e862                	sd	s8,16(sp)
    800009f6:	e466                	sd	s9,8(sp)
    800009f8:	1080                	addi	s0,sp,96
    800009fa:	8b2a                	mv	s6,a0
    800009fc:	8a2e                	mv	s4,a1
    800009fe:	8ab2                	mv	s5,a2
    80000a00:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000a02:	74fd                	lui	s1,0xfffff
    80000a04:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000a06:	57fd                	li	a5,-1
    80000a08:	83e9                	srli	a5,a5,0x1a
    80000a0a:	0697e063          	bltu	a5,s1,80000a6a <copyout+0x8c>
    80000a0e:	6c05                	lui	s8,0x1
    80000a10:	8bbe                	mv	s7,a5
    80000a12:	a015                	j	80000a36 <copyout+0x58>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000a14:	409a04b3          	sub	s1,s4,s1
    80000a18:	0009061b          	sext.w	a2,s2
    80000a1c:	85d6                	mv	a1,s5
    80000a1e:	9526                	add	a0,a0,s1
    80000a20:	f8aff0ef          	jal	ra,800001aa <memmove>

    len -= n;
    80000a24:	412989b3          	sub	s3,s3,s2
    src += n;
    80000a28:	9aca                	add	s5,s5,s2
  while(len > 0){
    80000a2a:	02098c63          	beqz	s3,80000a62 <copyout+0x84>
    if (va0 >= MAXVA)
    80000a2e:	059be063          	bltu	s7,s9,80000a6e <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80000a32:	84e6                	mv	s1,s9
    dstva = va0 + PGSIZE;
    80000a34:	8a66                	mv	s4,s9
    if((pte = walk(pagetable, va0, 0)) == 0) {
    80000a36:	4601                	li	a2,0
    80000a38:	85a6                	mv	a1,s1
    80000a3a:	855a                	mv	a0,s6
    80000a3c:	98fff0ef          	jal	ra,800003ca <walk>
    80000a40:	c90d                	beqz	a0,80000a72 <copyout+0x94>
    if((*pte & PTE_W) == 0)
    80000a42:	611c                	ld	a5,0(a0)
    80000a44:	8b91                	andi	a5,a5,4
    80000a46:	c7a1                	beqz	a5,80000a8e <copyout+0xb0>
    pa0 = walkaddr(pagetable, va0);
    80000a48:	85a6                	mv	a1,s1
    80000a4a:	855a                	mv	a0,s6
    80000a4c:	a23ff0ef          	jal	ra,8000046e <walkaddr>
    if(pa0 == 0)
    80000a50:	c129                	beqz	a0,80000a92 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80000a52:	01848cb3          	add	s9,s1,s8
    80000a56:	414c8933          	sub	s2,s9,s4
    80000a5a:	fb29fde3          	bgeu	s3,s2,80000a14 <copyout+0x36>
    80000a5e:	894e                	mv	s2,s3
    80000a60:	bf55                	j	80000a14 <copyout+0x36>
  }
  return 0;
    80000a62:	4501                	li	a0,0
    80000a64:	a801                	j	80000a74 <copyout+0x96>
    80000a66:	4501                	li	a0,0
}
    80000a68:	8082                	ret
      return -1;
    80000a6a:	557d                	li	a0,-1
    80000a6c:	a021                	j	80000a74 <copyout+0x96>
    80000a6e:	557d                	li	a0,-1
    80000a70:	a011                	j	80000a74 <copyout+0x96>
      return -1;
    80000a72:	557d                	li	a0,-1
}
    80000a74:	60e6                	ld	ra,88(sp)
    80000a76:	6446                	ld	s0,80(sp)
    80000a78:	64a6                	ld	s1,72(sp)
    80000a7a:	6906                	ld	s2,64(sp)
    80000a7c:	79e2                	ld	s3,56(sp)
    80000a7e:	7a42                	ld	s4,48(sp)
    80000a80:	7aa2                	ld	s5,40(sp)
    80000a82:	7b02                	ld	s6,32(sp)
    80000a84:	6be2                	ld	s7,24(sp)
    80000a86:	6c42                	ld	s8,16(sp)
    80000a88:	6ca2                	ld	s9,8(sp)
    80000a8a:	6125                	addi	sp,sp,96
    80000a8c:	8082                	ret
      return -1;
    80000a8e:	557d                	li	a0,-1
    80000a90:	b7d5                	j	80000a74 <copyout+0x96>
      return -1;
    80000a92:	557d                	li	a0,-1
    80000a94:	b7c5                	j	80000a74 <copyout+0x96>

0000000080000a96 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000a96:	c6a5                	beqz	a3,80000afe <copyin+0x68>
{
    80000a98:	715d                	addi	sp,sp,-80
    80000a9a:	e486                	sd	ra,72(sp)
    80000a9c:	e0a2                	sd	s0,64(sp)
    80000a9e:	fc26                	sd	s1,56(sp)
    80000aa0:	f84a                	sd	s2,48(sp)
    80000aa2:	f44e                	sd	s3,40(sp)
    80000aa4:	f052                	sd	s4,32(sp)
    80000aa6:	ec56                	sd	s5,24(sp)
    80000aa8:	e85a                	sd	s6,16(sp)
    80000aaa:	e45e                	sd	s7,8(sp)
    80000aac:	e062                	sd	s8,0(sp)
    80000aae:	0880                	addi	s0,sp,80
    80000ab0:	8b2a                	mv	s6,a0
    80000ab2:	8a2e                	mv	s4,a1
    80000ab4:	8c32                	mv	s8,a2
    80000ab6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000ab8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000aba:	6a85                	lui	s5,0x1
    80000abc:	a00d                	j	80000ade <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000abe:	018505b3          	add	a1,a0,s8
    80000ac2:	0004861b          	sext.w	a2,s1
    80000ac6:	412585b3          	sub	a1,a1,s2
    80000aca:	8552                	mv	a0,s4
    80000acc:	edeff0ef          	jal	ra,800001aa <memmove>

    len -= n;
    80000ad0:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000ad4:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000ad6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000ada:	02098063          	beqz	s3,80000afa <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000ade:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000ae2:	85ca                	mv	a1,s2
    80000ae4:	855a                	mv	a0,s6
    80000ae6:	989ff0ef          	jal	ra,8000046e <walkaddr>
    if(pa0 == 0)
    80000aea:	cd01                	beqz	a0,80000b02 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000aec:	418904b3          	sub	s1,s2,s8
    80000af0:	94d6                	add	s1,s1,s5
    80000af2:	fc99f6e3          	bgeu	s3,s1,80000abe <copyin+0x28>
    80000af6:	84ce                	mv	s1,s3
    80000af8:	b7d9                	j	80000abe <copyin+0x28>
  }
  return 0;
    80000afa:	4501                	li	a0,0
    80000afc:	a021                	j	80000b04 <copyin+0x6e>
    80000afe:	4501                	li	a0,0
}
    80000b00:	8082                	ret
      return -1;
    80000b02:	557d                	li	a0,-1
}
    80000b04:	60a6                	ld	ra,72(sp)
    80000b06:	6406                	ld	s0,64(sp)
    80000b08:	74e2                	ld	s1,56(sp)
    80000b0a:	7942                	ld	s2,48(sp)
    80000b0c:	79a2                	ld	s3,40(sp)
    80000b0e:	7a02                	ld	s4,32(sp)
    80000b10:	6ae2                	ld	s5,24(sp)
    80000b12:	6b42                	ld	s6,16(sp)
    80000b14:	6ba2                	ld	s7,8(sp)
    80000b16:	6c02                	ld	s8,0(sp)
    80000b18:	6161                	addi	sp,sp,80
    80000b1a:	8082                	ret

0000000080000b1c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000b1c:	c2cd                	beqz	a3,80000bbe <copyinstr+0xa2>
{
    80000b1e:	715d                	addi	sp,sp,-80
    80000b20:	e486                	sd	ra,72(sp)
    80000b22:	e0a2                	sd	s0,64(sp)
    80000b24:	fc26                	sd	s1,56(sp)
    80000b26:	f84a                	sd	s2,48(sp)
    80000b28:	f44e                	sd	s3,40(sp)
    80000b2a:	f052                	sd	s4,32(sp)
    80000b2c:	ec56                	sd	s5,24(sp)
    80000b2e:	e85a                	sd	s6,16(sp)
    80000b30:	e45e                	sd	s7,8(sp)
    80000b32:	0880                	addi	s0,sp,80
    80000b34:	8a2a                	mv	s4,a0
    80000b36:	8b2e                	mv	s6,a1
    80000b38:	8bb2                	mv	s7,a2
    80000b3a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000b3c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000b3e:	6985                	lui	s3,0x1
    80000b40:	a02d                	j	80000b6a <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000b42:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000b46:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000b48:	37fd                	addiw	a5,a5,-1
    80000b4a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000b4e:	60a6                	ld	ra,72(sp)
    80000b50:	6406                	ld	s0,64(sp)
    80000b52:	74e2                	ld	s1,56(sp)
    80000b54:	7942                	ld	s2,48(sp)
    80000b56:	79a2                	ld	s3,40(sp)
    80000b58:	7a02                	ld	s4,32(sp)
    80000b5a:	6ae2                	ld	s5,24(sp)
    80000b5c:	6b42                	ld	s6,16(sp)
    80000b5e:	6ba2                	ld	s7,8(sp)
    80000b60:	6161                	addi	sp,sp,80
    80000b62:	8082                	ret
    srcva = va0 + PGSIZE;
    80000b64:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000b68:	c4b9                	beqz	s1,80000bb6 <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80000b6a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000b6e:	85ca                	mv	a1,s2
    80000b70:	8552                	mv	a0,s4
    80000b72:	8fdff0ef          	jal	ra,8000046e <walkaddr>
    if(pa0 == 0)
    80000b76:	c131                	beqz	a0,80000bba <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80000b78:	417906b3          	sub	a3,s2,s7
    80000b7c:	96ce                	add	a3,a3,s3
    80000b7e:	00d4f363          	bgeu	s1,a3,80000b84 <copyinstr+0x68>
    80000b82:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000b84:	955e                	add	a0,a0,s7
    80000b86:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000b8a:	dee9                	beqz	a3,80000b64 <copyinstr+0x48>
    80000b8c:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000b8e:	41650633          	sub	a2,a0,s6
    80000b92:	fff48593          	addi	a1,s1,-1 # ffffffffffffefff <end+0xffffffff7ffde2ff>
    80000b96:	95da                	add	a1,a1,s6
    while(n > 0){
    80000b98:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80000b9a:	00f60733          	add	a4,a2,a5
    80000b9e:	00074703          	lbu	a4,0(a4)
    80000ba2:	d345                	beqz	a4,80000b42 <copyinstr+0x26>
        *dst = *p;
    80000ba4:	00e78023          	sb	a4,0(a5)
      --max;
    80000ba8:	40f584b3          	sub	s1,a1,a5
      dst++;
    80000bac:	0785                	addi	a5,a5,1
    while(n > 0){
    80000bae:	fed796e3          	bne	a5,a3,80000b9a <copyinstr+0x7e>
      dst++;
    80000bb2:	8b3e                	mv	s6,a5
    80000bb4:	bf45                	j	80000b64 <copyinstr+0x48>
    80000bb6:	4781                	li	a5,0
    80000bb8:	bf41                	j	80000b48 <copyinstr+0x2c>
      return -1;
    80000bba:	557d                	li	a0,-1
    80000bbc:	bf49                	j	80000b4e <copyinstr+0x32>
  int got_null = 0;
    80000bbe:	4781                	li	a5,0
  if(got_null){
    80000bc0:	37fd                	addiw	a5,a5,-1
    80000bc2:	0007851b          	sext.w	a0,a5
}
    80000bc6:	8082                	ret

0000000080000bc8 <vmprint_recurse>:
  vmprint_recurse(pagetable, 0); //start the recursion with depth 0
}
#endif

void
vmprint_recurse(pagetable_t pagetable, int depth) { //seperate function so we can keep track of depth using a parameter
    80000bc8:	7119                	addi	sp,sp,-128
    80000bca:	fc86                	sd	ra,120(sp)
    80000bcc:	f8a2                	sd	s0,112(sp)
    80000bce:	f4a6                	sd	s1,104(sp)
    80000bd0:	f0ca                	sd	s2,96(sp)
    80000bd2:	ecce                	sd	s3,88(sp)
    80000bd4:	e8d2                	sd	s4,80(sp)
    80000bd6:	e4d6                	sd	s5,72(sp)
    80000bd8:	e0da                	sd	s6,64(sp)
    80000bda:	fc5e                	sd	s7,56(sp)
    80000bdc:	f862                	sd	s8,48(sp)
    80000bde:	f466                	sd	s9,40(sp)
    80000be0:	f06a                	sd	s10,32(sp)
    80000be2:	ec6e                	sd	s11,24(sp)
    80000be4:	0100                	addi	s0,sp,128
    80000be6:	8aae                	mv	s5,a1
      continue;
    }

    //PXSHIFT macro does exactly what we need to reconstruct VA, just in the opposite
    //direction of depth so we inverse it using 2 - depth
    uint64 va = (uint64)i << PXSHIFT(2 - depth);
    80000be8:	4789                	li	a5,2
    80000bea:	9f8d                	subw	a5,a5,a1
    80000bec:	00379c9b          	slliw	s9,a5,0x3
    80000bf0:	00fc8cbb          	addw	s9,s9,a5
    80000bf4:	2cb1                	addiw	s9,s9,12
    80000bf6:	8a2a                	mv	s4,a0
    80000bf8:	4901                	li	s2,0

    if ((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0) { //recursive case - non leaf
    80000bfa:	4c05                	li	s8,1
      uint64 child_pa = PTE2PA(pte); //get child pa to convert to a pagetable
      vmprint_recurse((pagetable_t)child_pa, depth + 1);
    } else { //base case - time to print
      printf(" ");
    80000bfc:	00006d97          	auipc	s11,0x6
    80000c00:	5acd8d93          	addi	s11,s11,1452 # 800071a8 <etext+0x1a8>
      for (int j = 0; j < depth; j++) {
        printf(".. ");
      }
      //we already have the VA and the PTE bits, and we can use the PTE2PA macro to get the pa
      printf("..%p: pte %p pa %p\n", (void*)va, (void*)pte, (void*)PTE2PA(pte));
    80000c04:	00006d17          	auipc	s10,0x6
    80000c08:	5b4d0d13          	addi	s10,s10,1460 # 800071b8 <etext+0x1b8>
        printf(".. ");
    80000c0c:	00006b17          	auipc	s6,0x6
    80000c10:	5a4b0b13          	addi	s6,s6,1444 # 800071b0 <etext+0x1b0>
      vmprint_recurse((pagetable_t)child_pa, depth + 1);
    80000c14:	0015879b          	addiw	a5,a1,1
    80000c18:	f8f43423          	sd	a5,-120(s0)
  for (int i = 0; i < 512; i++) { //there are 2^9 = 512 ptes in a page table
    80000c1c:	20000b93          	li	s7,512
    80000c20:	a815                	j	80000c54 <vmprint_recurse+0x8c>
      printf(" ");
    80000c22:	856e                	mv	a0,s11
    80000c24:	4ea040ef          	jal	ra,8000510e <printf>
      for (int j = 0; j < depth; j++) {
    80000c28:	01505963          	blez	s5,80000c3a <vmprint_recurse+0x72>
    80000c2c:	4481                	li	s1,0
        printf(".. ");
    80000c2e:	855a                	mv	a0,s6
    80000c30:	4de040ef          	jal	ra,8000510e <printf>
      for (int j = 0; j < depth; j++) {
    80000c34:	2485                	addiw	s1,s1,1
    80000c36:	fe9a9ce3          	bne	s5,s1,80000c2e <vmprint_recurse+0x66>
      printf("..%p: pte %p pa %p\n", (void*)va, (void*)pte, (void*)PTE2PA(pte));
    80000c3a:	00a9d693          	srli	a3,s3,0xa
    80000c3e:	06b2                	slli	a3,a3,0xc
    80000c40:	864e                	mv	a2,s3
    80000c42:	019915b3          	sll	a1,s2,s9
    80000c46:	856a                	mv	a0,s10
    80000c48:	4c6040ef          	jal	ra,8000510e <printf>
  for (int i = 0; i < 512; i++) { //there are 2^9 = 512 ptes in a page table
    80000c4c:	0905                	addi	s2,s2,1 # 1001 <_entry-0x7fffefff>
    80000c4e:	0a21                	addi	s4,s4,8
    80000c50:	03790363          	beq	s2,s7,80000c76 <vmprint_recurse+0xae>
    pte_t pte = pagetable[i]; //store pte from page table
    80000c54:	000a3983          	ld	s3,0(s4)
    if (!(pte & PTE_V)) { //skip the pte if it's not valid per lab spec
    80000c58:	0019f793          	andi	a5,s3,1
    80000c5c:	dbe5                	beqz	a5,80000c4c <vmprint_recurse+0x84>
    if ((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0) { //recursive case - non leaf
    80000c5e:	00f9f793          	andi	a5,s3,15
    80000c62:	fd8790e3          	bne	a5,s8,80000c22 <vmprint_recurse+0x5a>
      uint64 child_pa = PTE2PA(pte); //get child pa to convert to a pagetable
    80000c66:	00a9d513          	srli	a0,s3,0xa
      vmprint_recurse((pagetable_t)child_pa, depth + 1);
    80000c6a:	f8843583          	ld	a1,-120(s0)
    80000c6e:	0532                	slli	a0,a0,0xc
    80000c70:	f59ff0ef          	jal	ra,80000bc8 <vmprint_recurse>
    80000c74:	bfe1                	j	80000c4c <vmprint_recurse+0x84>


    }
  }
}
    80000c76:	70e6                	ld	ra,120(sp)
    80000c78:	7446                	ld	s0,112(sp)
    80000c7a:	74a6                	ld	s1,104(sp)
    80000c7c:	7906                	ld	s2,96(sp)
    80000c7e:	69e6                	ld	s3,88(sp)
    80000c80:	6a46                	ld	s4,80(sp)
    80000c82:	6aa6                	ld	s5,72(sp)
    80000c84:	6b06                	ld	s6,64(sp)
    80000c86:	7be2                	ld	s7,56(sp)
    80000c88:	7c42                	ld	s8,48(sp)
    80000c8a:	7ca2                	ld	s9,40(sp)
    80000c8c:	7d02                	ld	s10,32(sp)
    80000c8e:	6de2                	ld	s11,24(sp)
    80000c90:	6109                	addi	sp,sp,128
    80000c92:	8082                	ret

0000000080000c94 <vmprint>:
vmprint(pagetable_t pagetable) {
    80000c94:	1101                	addi	sp,sp,-32
    80000c96:	ec06                	sd	ra,24(sp)
    80000c98:	e822                	sd	s0,16(sp)
    80000c9a:	e426                	sd	s1,8(sp)
    80000c9c:	1000                	addi	s0,sp,32
    80000c9e:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80000ca0:	85aa                	mv	a1,a0
    80000ca2:	00006517          	auipc	a0,0x6
    80000ca6:	52e50513          	addi	a0,a0,1326 # 800071d0 <etext+0x1d0>
    80000caa:	464040ef          	jal	ra,8000510e <printf>
  vmprint_recurse(pagetable, 0); //start the recursion with depth 0
    80000cae:	4581                	li	a1,0
    80000cb0:	8526                	mv	a0,s1
    80000cb2:	f17ff0ef          	jal	ra,80000bc8 <vmprint_recurse>
}
    80000cb6:	60e2                	ld	ra,24(sp)
    80000cb8:	6442                	ld	s0,16(sp)
    80000cba:	64a2                	ld	s1,8(sp)
    80000cbc:	6105                	addi	sp,sp,32
    80000cbe:	8082                	ret

0000000080000cc0 <pgpte>:



#ifdef LAB_PGTBL
pte_t*
pgpte(pagetable_t pagetable, uint64 va) {
    80000cc0:	1141                	addi	sp,sp,-16
    80000cc2:	e406                	sd	ra,8(sp)
    80000cc4:	e022                	sd	s0,0(sp)
    80000cc6:	0800                	addi	s0,sp,16
  return walk(pagetable, va, 0);
    80000cc8:	4601                	li	a2,0
    80000cca:	f00ff0ef          	jal	ra,800003ca <walk>
}
    80000cce:	60a2                	ld	ra,8(sp)
    80000cd0:	6402                	ld	s0,0(sp)
    80000cd2:	0141                	addi	sp,sp,16
    80000cd4:	8082                	ret

0000000080000cd6 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000cd6:	7139                	addi	sp,sp,-64
    80000cd8:	fc06                	sd	ra,56(sp)
    80000cda:	f822                	sd	s0,48(sp)
    80000cdc:	f426                	sd	s1,40(sp)
    80000cde:	f04a                	sd	s2,32(sp)
    80000ce0:	ec4e                	sd	s3,24(sp)
    80000ce2:	e852                	sd	s4,16(sp)
    80000ce4:	e456                	sd	s5,8(sp)
    80000ce6:	e05a                	sd	s6,0(sp)
    80000ce8:	0080                	addi	s0,sp,64
    80000cea:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80000cec:	00007497          	auipc	s1,0x7
    80000cf0:	13448493          	addi	s1,s1,308 # 80007e20 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000cf4:	8b26                	mv	s6,s1
    80000cf6:	00006a97          	auipc	s5,0x6
    80000cfa:	30aa8a93          	addi	s5,s5,778 # 80007000 <etext>
    80000cfe:	04000937          	lui	s2,0x4000
    80000d02:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000d04:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d06:	0000da17          	auipc	s4,0xd
    80000d0a:	b1aa0a13          	addi	s4,s4,-1254 # 8000d820 <tickslock>
    char *pa = kalloc();
    80000d0e:	bf0ff0ef          	jal	ra,800000fe <kalloc>
    80000d12:	862a                	mv	a2,a0
    if(pa == 0)
    80000d14:	c121                	beqz	a0,80000d54 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80000d16:	416485b3          	sub	a1,s1,s6
    80000d1a:	858d                	srai	a1,a1,0x3
    80000d1c:	000ab783          	ld	a5,0(s5)
    80000d20:	02f585b3          	mul	a1,a1,a5
    80000d24:	2585                	addiw	a1,a1,1
    80000d26:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000d2a:	4719                	li	a4,6
    80000d2c:	6685                	lui	a3,0x1
    80000d2e:	40b905b3          	sub	a1,s2,a1
    80000d32:	854e                	mv	a0,s3
    80000d34:	829ff0ef          	jal	ra,8000055c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d38:	16848493          	addi	s1,s1,360
    80000d3c:	fd4499e3          	bne	s1,s4,80000d0e <proc_mapstacks+0x38>
  }
}
    80000d40:	70e2                	ld	ra,56(sp)
    80000d42:	7442                	ld	s0,48(sp)
    80000d44:	74a2                	ld	s1,40(sp)
    80000d46:	7902                	ld	s2,32(sp)
    80000d48:	69e2                	ld	s3,24(sp)
    80000d4a:	6a42                	ld	s4,16(sp)
    80000d4c:	6aa2                	ld	s5,8(sp)
    80000d4e:	6b02                	ld	s6,0(sp)
    80000d50:	6121                	addi	sp,sp,64
    80000d52:	8082                	ret
      panic("kalloc");
    80000d54:	00006517          	auipc	a0,0x6
    80000d58:	48c50513          	addi	a0,a0,1164 # 800071e0 <etext+0x1e0>
    80000d5c:	666040ef          	jal	ra,800053c2 <panic>

0000000080000d60 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000d60:	7139                	addi	sp,sp,-64
    80000d62:	fc06                	sd	ra,56(sp)
    80000d64:	f822                	sd	s0,48(sp)
    80000d66:	f426                	sd	s1,40(sp)
    80000d68:	f04a                	sd	s2,32(sp)
    80000d6a:	ec4e                	sd	s3,24(sp)
    80000d6c:	e852                	sd	s4,16(sp)
    80000d6e:	e456                	sd	s5,8(sp)
    80000d70:	e05a                	sd	s6,0(sp)
    80000d72:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80000d74:	00006597          	auipc	a1,0x6
    80000d78:	47458593          	addi	a1,a1,1140 # 800071e8 <etext+0x1e8>
    80000d7c:	00007517          	auipc	a0,0x7
    80000d80:	c7450513          	addi	a0,a0,-908 # 800079f0 <pid_lock>
    80000d84:	0cf040ef          	jal	ra,80005652 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000d88:	00006597          	auipc	a1,0x6
    80000d8c:	46858593          	addi	a1,a1,1128 # 800071f0 <etext+0x1f0>
    80000d90:	00007517          	auipc	a0,0x7
    80000d94:	c7850513          	addi	a0,a0,-904 # 80007a08 <wait_lock>
    80000d98:	0bb040ef          	jal	ra,80005652 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d9c:	00007497          	auipc	s1,0x7
    80000da0:	08448493          	addi	s1,s1,132 # 80007e20 <proc>
      initlock(&p->lock, "proc");
    80000da4:	00006b17          	auipc	s6,0x6
    80000da8:	45cb0b13          	addi	s6,s6,1116 # 80007200 <etext+0x200>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000dac:	8aa6                	mv	s5,s1
    80000dae:	00006a17          	auipc	s4,0x6
    80000db2:	252a0a13          	addi	s4,s4,594 # 80007000 <etext>
    80000db6:	04000937          	lui	s2,0x4000
    80000dba:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000dbc:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dbe:	0000d997          	auipc	s3,0xd
    80000dc2:	a6298993          	addi	s3,s3,-1438 # 8000d820 <tickslock>
      initlock(&p->lock, "proc");
    80000dc6:	85da                	mv	a1,s6
    80000dc8:	8526                	mv	a0,s1
    80000dca:	089040ef          	jal	ra,80005652 <initlock>
      p->state = UNUSED;
    80000dce:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000dd2:	415487b3          	sub	a5,s1,s5
    80000dd6:	878d                	srai	a5,a5,0x3
    80000dd8:	000a3703          	ld	a4,0(s4)
    80000ddc:	02e787b3          	mul	a5,a5,a4
    80000de0:	2785                	addiw	a5,a5,1
    80000de2:	00d7979b          	slliw	a5,a5,0xd
    80000de6:	40f907b3          	sub	a5,s2,a5
    80000dea:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dec:	16848493          	addi	s1,s1,360
    80000df0:	fd349be3          	bne	s1,s3,80000dc6 <procinit+0x66>
  }
}
    80000df4:	70e2                	ld	ra,56(sp)
    80000df6:	7442                	ld	s0,48(sp)
    80000df8:	74a2                	ld	s1,40(sp)
    80000dfa:	7902                	ld	s2,32(sp)
    80000dfc:	69e2                	ld	s3,24(sp)
    80000dfe:	6a42                	ld	s4,16(sp)
    80000e00:	6aa2                	ld	s5,8(sp)
    80000e02:	6b02                	ld	s6,0(sp)
    80000e04:	6121                	addi	sp,sp,64
    80000e06:	8082                	ret

0000000080000e08 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000e08:	1141                	addi	sp,sp,-16
    80000e0a:	e422                	sd	s0,8(sp)
    80000e0c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e0e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000e10:	2501                	sext.w	a0,a0
    80000e12:	6422                	ld	s0,8(sp)
    80000e14:	0141                	addi	sp,sp,16
    80000e16:	8082                	ret

0000000080000e18 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000e18:	1141                	addi	sp,sp,-16
    80000e1a:	e422                	sd	s0,8(sp)
    80000e1c:	0800                	addi	s0,sp,16
    80000e1e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000e20:	2781                	sext.w	a5,a5
    80000e22:	079e                	slli	a5,a5,0x7
  return c;
}
    80000e24:	00007517          	auipc	a0,0x7
    80000e28:	bfc50513          	addi	a0,a0,-1028 # 80007a20 <cpus>
    80000e2c:	953e                	add	a0,a0,a5
    80000e2e:	6422                	ld	s0,8(sp)
    80000e30:	0141                	addi	sp,sp,16
    80000e32:	8082                	ret

0000000080000e34 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000e34:	1101                	addi	sp,sp,-32
    80000e36:	ec06                	sd	ra,24(sp)
    80000e38:	e822                	sd	s0,16(sp)
    80000e3a:	e426                	sd	s1,8(sp)
    80000e3c:	1000                	addi	s0,sp,32
  push_off();
    80000e3e:	055040ef          	jal	ra,80005692 <push_off>
    80000e42:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000e44:	2781                	sext.w	a5,a5
    80000e46:	079e                	slli	a5,a5,0x7
    80000e48:	00007717          	auipc	a4,0x7
    80000e4c:	ba870713          	addi	a4,a4,-1112 # 800079f0 <pid_lock>
    80000e50:	97ba                	add	a5,a5,a4
    80000e52:	7b84                	ld	s1,48(a5)
  pop_off();
    80000e54:	0c3040ef          	jal	ra,80005716 <pop_off>
  return p;
}
    80000e58:	8526                	mv	a0,s1
    80000e5a:	60e2                	ld	ra,24(sp)
    80000e5c:	6442                	ld	s0,16(sp)
    80000e5e:	64a2                	ld	s1,8(sp)
    80000e60:	6105                	addi	sp,sp,32
    80000e62:	8082                	ret

0000000080000e64 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000e64:	1141                	addi	sp,sp,-16
    80000e66:	e406                	sd	ra,8(sp)
    80000e68:	e022                	sd	s0,0(sp)
    80000e6a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000e6c:	fc9ff0ef          	jal	ra,80000e34 <myproc>
    80000e70:	0fb040ef          	jal	ra,8000576a <release>

  if (first) {
    80000e74:	00007797          	auipc	a5,0x7
    80000e78:	abc7a783          	lw	a5,-1348(a5) # 80007930 <first.1>
    80000e7c:	e799                	bnez	a5,80000e8a <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000e7e:	2bd000ef          	jal	ra,8000193a <usertrapret>
}
    80000e82:	60a2                	ld	ra,8(sp)
    80000e84:	6402                	ld	s0,0(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret
    fsinit(ROOTDEV);
    80000e8a:	4505                	li	a0,1
    80000e8c:	688010ef          	jal	ra,80002514 <fsinit>
    first = 0;
    80000e90:	00007797          	auipc	a5,0x7
    80000e94:	aa07a023          	sw	zero,-1376(a5) # 80007930 <first.1>
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    80000e9c:	b7cd                	j	80000e7e <forkret+0x1a>

0000000080000e9e <allocpid>:
{
    80000e9e:	1101                	addi	sp,sp,-32
    80000ea0:	ec06                	sd	ra,24(sp)
    80000ea2:	e822                	sd	s0,16(sp)
    80000ea4:	e426                	sd	s1,8(sp)
    80000ea6:	e04a                	sd	s2,0(sp)
    80000ea8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000eaa:	00007917          	auipc	s2,0x7
    80000eae:	b4690913          	addi	s2,s2,-1210 # 800079f0 <pid_lock>
    80000eb2:	854a                	mv	a0,s2
    80000eb4:	01f040ef          	jal	ra,800056d2 <acquire>
  pid = nextpid;
    80000eb8:	00007797          	auipc	a5,0x7
    80000ebc:	a7c78793          	addi	a5,a5,-1412 # 80007934 <nextpid>
    80000ec0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000ec2:	0014871b          	addiw	a4,s1,1
    80000ec6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000ec8:	854a                	mv	a0,s2
    80000eca:	0a1040ef          	jal	ra,8000576a <release>
}
    80000ece:	8526                	mv	a0,s1
    80000ed0:	60e2                	ld	ra,24(sp)
    80000ed2:	6442                	ld	s0,16(sp)
    80000ed4:	64a2                	ld	s1,8(sp)
    80000ed6:	6902                	ld	s2,0(sp)
    80000ed8:	6105                	addi	sp,sp,32
    80000eda:	8082                	ret

0000000080000edc <proc_pagetable>:
{
    80000edc:	1101                	addi	sp,sp,-32
    80000ede:	ec06                	sd	ra,24(sp)
    80000ee0:	e822                	sd	s0,16(sp)
    80000ee2:	e426                	sd	s1,8(sp)
    80000ee4:	e04a                	sd	s2,0(sp)
    80000ee6:	1000                	addi	s0,sp,32
    80000ee8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000eea:	825ff0ef          	jal	ra,8000070e <uvmcreate>
    80000eee:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000ef0:	cd05                	beqz	a0,80000f28 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000ef2:	4729                	li	a4,10
    80000ef4:	00005697          	auipc	a3,0x5
    80000ef8:	10c68693          	addi	a3,a3,268 # 80006000 <_trampoline>
    80000efc:	6605                	lui	a2,0x1
    80000efe:	040005b7          	lui	a1,0x4000
    80000f02:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f04:	05b2                	slli	a1,a1,0xc
    80000f06:	da6ff0ef          	jal	ra,800004ac <mappages>
    80000f0a:	02054663          	bltz	a0,80000f36 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000f0e:	4719                	li	a4,6
    80000f10:	05893683          	ld	a3,88(s2)
    80000f14:	6605                	lui	a2,0x1
    80000f16:	020005b7          	lui	a1,0x2000
    80000f1a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000f1c:	05b6                	slli	a1,a1,0xd
    80000f1e:	8526                	mv	a0,s1
    80000f20:	d8cff0ef          	jal	ra,800004ac <mappages>
    80000f24:	00054f63          	bltz	a0,80000f42 <proc_pagetable+0x66>
}
    80000f28:	8526                	mv	a0,s1
    80000f2a:	60e2                	ld	ra,24(sp)
    80000f2c:	6442                	ld	s0,16(sp)
    80000f2e:	64a2                	ld	s1,8(sp)
    80000f30:	6902                	ld	s2,0(sp)
    80000f32:	6105                	addi	sp,sp,32
    80000f34:	8082                	ret
    uvmfree(pagetable, 0);
    80000f36:	4581                	li	a1,0
    80000f38:	8526                	mv	a0,s1
    80000f3a:	997ff0ef          	jal	ra,800008d0 <uvmfree>
    return 0;
    80000f3e:	4481                	li	s1,0
    80000f40:	b7e5                	j	80000f28 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f42:	4681                	li	a3,0
    80000f44:	4605                	li	a2,1
    80000f46:	040005b7          	lui	a1,0x4000
    80000f4a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f4c:	05b2                	slli	a1,a1,0xc
    80000f4e:	8526                	mv	a0,s1
    80000f50:	f02ff0ef          	jal	ra,80000652 <uvmunmap>
    uvmfree(pagetable, 0);
    80000f54:	4581                	li	a1,0
    80000f56:	8526                	mv	a0,s1
    80000f58:	979ff0ef          	jal	ra,800008d0 <uvmfree>
    return 0;
    80000f5c:	4481                	li	s1,0
    80000f5e:	b7e9                	j	80000f28 <proc_pagetable+0x4c>

0000000080000f60 <proc_freepagetable>:
{
    80000f60:	1101                	addi	sp,sp,-32
    80000f62:	ec06                	sd	ra,24(sp)
    80000f64:	e822                	sd	s0,16(sp)
    80000f66:	e426                	sd	s1,8(sp)
    80000f68:	e04a                	sd	s2,0(sp)
    80000f6a:	1000                	addi	s0,sp,32
    80000f6c:	84aa                	mv	s1,a0
    80000f6e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f70:	4681                	li	a3,0
    80000f72:	4605                	li	a2,1
    80000f74:	040005b7          	lui	a1,0x4000
    80000f78:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f7a:	05b2                	slli	a1,a1,0xc
    80000f7c:	ed6ff0ef          	jal	ra,80000652 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000f80:	4681                	li	a3,0
    80000f82:	4605                	li	a2,1
    80000f84:	020005b7          	lui	a1,0x2000
    80000f88:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000f8a:	05b6                	slli	a1,a1,0xd
    80000f8c:	8526                	mv	a0,s1
    80000f8e:	ec4ff0ef          	jal	ra,80000652 <uvmunmap>
  uvmfree(pagetable, sz);
    80000f92:	85ca                	mv	a1,s2
    80000f94:	8526                	mv	a0,s1
    80000f96:	93bff0ef          	jal	ra,800008d0 <uvmfree>
}
    80000f9a:	60e2                	ld	ra,24(sp)
    80000f9c:	6442                	ld	s0,16(sp)
    80000f9e:	64a2                	ld	s1,8(sp)
    80000fa0:	6902                	ld	s2,0(sp)
    80000fa2:	6105                	addi	sp,sp,32
    80000fa4:	8082                	ret

0000000080000fa6 <freeproc>:
{
    80000fa6:	1101                	addi	sp,sp,-32
    80000fa8:	ec06                	sd	ra,24(sp)
    80000faa:	e822                	sd	s0,16(sp)
    80000fac:	e426                	sd	s1,8(sp)
    80000fae:	1000                	addi	s0,sp,32
    80000fb0:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000fb2:	6d28                	ld	a0,88(a0)
    80000fb4:	c119                	beqz	a0,80000fba <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000fb6:	866ff0ef          	jal	ra,8000001c <kfree>
  p->trapframe = 0;
    80000fba:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80000fbe:	68a8                	ld	a0,80(s1)
    80000fc0:	c501                	beqz	a0,80000fc8 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80000fc2:	64ac                	ld	a1,72(s1)
    80000fc4:	f9dff0ef          	jal	ra,80000f60 <proc_freepagetable>
  p->pagetable = 0;
    80000fc8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80000fcc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000fd0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000fd4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000fd8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000fdc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000fe0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000fe4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000fe8:	0004ac23          	sw	zero,24(s1)
}
    80000fec:	60e2                	ld	ra,24(sp)
    80000fee:	6442                	ld	s0,16(sp)
    80000ff0:	64a2                	ld	s1,8(sp)
    80000ff2:	6105                	addi	sp,sp,32
    80000ff4:	8082                	ret

0000000080000ff6 <allocproc>:
{
    80000ff6:	1101                	addi	sp,sp,-32
    80000ff8:	ec06                	sd	ra,24(sp)
    80000ffa:	e822                	sd	s0,16(sp)
    80000ffc:	e426                	sd	s1,8(sp)
    80000ffe:	e04a                	sd	s2,0(sp)
    80001000:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001002:	00007497          	auipc	s1,0x7
    80001006:	e1e48493          	addi	s1,s1,-482 # 80007e20 <proc>
    8000100a:	0000d917          	auipc	s2,0xd
    8000100e:	81690913          	addi	s2,s2,-2026 # 8000d820 <tickslock>
    acquire(&p->lock);
    80001012:	8526                	mv	a0,s1
    80001014:	6be040ef          	jal	ra,800056d2 <acquire>
    if(p->state == UNUSED) {
    80001018:	4c9c                	lw	a5,24(s1)
    8000101a:	cb91                	beqz	a5,8000102e <allocproc+0x38>
      release(&p->lock);
    8000101c:	8526                	mv	a0,s1
    8000101e:	74c040ef          	jal	ra,8000576a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001022:	16848493          	addi	s1,s1,360
    80001026:	ff2496e3          	bne	s1,s2,80001012 <allocproc+0x1c>
  return 0;
    8000102a:	4481                	li	s1,0
    8000102c:	a089                	j	8000106e <allocproc+0x78>
  p->pid = allocpid();
    8000102e:	e71ff0ef          	jal	ra,80000e9e <allocpid>
    80001032:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001034:	4785                	li	a5,1
    80001036:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001038:	8c6ff0ef          	jal	ra,800000fe <kalloc>
    8000103c:	892a                	mv	s2,a0
    8000103e:	eca8                	sd	a0,88(s1)
    80001040:	cd15                	beqz	a0,8000107c <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001042:	8526                	mv	a0,s1
    80001044:	e99ff0ef          	jal	ra,80000edc <proc_pagetable>
    80001048:	892a                	mv	s2,a0
    8000104a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    8000104c:	c121                	beqz	a0,8000108c <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    8000104e:	07000613          	li	a2,112
    80001052:	4581                	li	a1,0
    80001054:	06048513          	addi	a0,s1,96
    80001058:	8f6ff0ef          	jal	ra,8000014e <memset>
  p->context.ra = (uint64)forkret;
    8000105c:	00000797          	auipc	a5,0x0
    80001060:	e0878793          	addi	a5,a5,-504 # 80000e64 <forkret>
    80001064:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001066:	60bc                	ld	a5,64(s1)
    80001068:	6705                	lui	a4,0x1
    8000106a:	97ba                	add	a5,a5,a4
    8000106c:	f4bc                	sd	a5,104(s1)
}
    8000106e:	8526                	mv	a0,s1
    80001070:	60e2                	ld	ra,24(sp)
    80001072:	6442                	ld	s0,16(sp)
    80001074:	64a2                	ld	s1,8(sp)
    80001076:	6902                	ld	s2,0(sp)
    80001078:	6105                	addi	sp,sp,32
    8000107a:	8082                	ret
    freeproc(p);
    8000107c:	8526                	mv	a0,s1
    8000107e:	f29ff0ef          	jal	ra,80000fa6 <freeproc>
    release(&p->lock);
    80001082:	8526                	mv	a0,s1
    80001084:	6e6040ef          	jal	ra,8000576a <release>
    return 0;
    80001088:	84ca                	mv	s1,s2
    8000108a:	b7d5                	j	8000106e <allocproc+0x78>
    freeproc(p);
    8000108c:	8526                	mv	a0,s1
    8000108e:	f19ff0ef          	jal	ra,80000fa6 <freeproc>
    release(&p->lock);
    80001092:	8526                	mv	a0,s1
    80001094:	6d6040ef          	jal	ra,8000576a <release>
    return 0;
    80001098:	84ca                	mv	s1,s2
    8000109a:	bfd1                	j	8000106e <allocproc+0x78>

000000008000109c <userinit>:
{
    8000109c:	1101                	addi	sp,sp,-32
    8000109e:	ec06                	sd	ra,24(sp)
    800010a0:	e822                	sd	s0,16(sp)
    800010a2:	e426                	sd	s1,8(sp)
    800010a4:	1000                	addi	s0,sp,32
  p = allocproc();
    800010a6:	f51ff0ef          	jal	ra,80000ff6 <allocproc>
    800010aa:	84aa                	mv	s1,a0
  initproc = p;
    800010ac:	00007797          	auipc	a5,0x7
    800010b0:	90a7b223          	sd	a0,-1788(a5) # 800079b0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800010b4:	03400613          	li	a2,52
    800010b8:	00007597          	auipc	a1,0x7
    800010bc:	88858593          	addi	a1,a1,-1912 # 80007940 <initcode>
    800010c0:	6928                	ld	a0,80(a0)
    800010c2:	e72ff0ef          	jal	ra,80000734 <uvmfirst>
  p->sz = PGSIZE;
    800010c6:	6785                	lui	a5,0x1
    800010c8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800010ca:	6cb8                	ld	a4,88(s1)
    800010cc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800010d0:	6cb8                	ld	a4,88(s1)
    800010d2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800010d4:	4641                	li	a2,16
    800010d6:	00006597          	auipc	a1,0x6
    800010da:	13258593          	addi	a1,a1,306 # 80007208 <etext+0x208>
    800010de:	15848513          	addi	a0,s1,344
    800010e2:	9b2ff0ef          	jal	ra,80000294 <safestrcpy>
  p->cwd = namei("/");
    800010e6:	00006517          	auipc	a0,0x6
    800010ea:	13250513          	addi	a0,a0,306 # 80007218 <etext+0x218>
    800010ee:	50d010ef          	jal	ra,80002dfa <namei>
    800010f2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800010f6:	478d                	li	a5,3
    800010f8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800010fa:	8526                	mv	a0,s1
    800010fc:	66e040ef          	jal	ra,8000576a <release>
}
    80001100:	60e2                	ld	ra,24(sp)
    80001102:	6442                	ld	s0,16(sp)
    80001104:	64a2                	ld	s1,8(sp)
    80001106:	6105                	addi	sp,sp,32
    80001108:	8082                	ret

000000008000110a <growproc>:
{
    8000110a:	1101                	addi	sp,sp,-32
    8000110c:	ec06                	sd	ra,24(sp)
    8000110e:	e822                	sd	s0,16(sp)
    80001110:	e426                	sd	s1,8(sp)
    80001112:	e04a                	sd	s2,0(sp)
    80001114:	1000                	addi	s0,sp,32
    80001116:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001118:	d1dff0ef          	jal	ra,80000e34 <myproc>
    8000111c:	84aa                	mv	s1,a0
  sz = p->sz;
    8000111e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001120:	01204c63          	bgtz	s2,80001138 <growproc+0x2e>
  } else if(n < 0){
    80001124:	02094463          	bltz	s2,8000114c <growproc+0x42>
  p->sz = sz;
    80001128:	e4ac                	sd	a1,72(s1)
  return 0;
    8000112a:	4501                	li	a0,0
}
    8000112c:	60e2                	ld	ra,24(sp)
    8000112e:	6442                	ld	s0,16(sp)
    80001130:	64a2                	ld	s1,8(sp)
    80001132:	6902                	ld	s2,0(sp)
    80001134:	6105                	addi	sp,sp,32
    80001136:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001138:	4691                	li	a3,4
    8000113a:	00b90633          	add	a2,s2,a1
    8000113e:	6928                	ld	a0,80(a0)
    80001140:	e96ff0ef          	jal	ra,800007d6 <uvmalloc>
    80001144:	85aa                	mv	a1,a0
    80001146:	f16d                	bnez	a0,80001128 <growproc+0x1e>
      return -1;
    80001148:	557d                	li	a0,-1
    8000114a:	b7cd                	j	8000112c <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000114c:	00b90633          	add	a2,s2,a1
    80001150:	6928                	ld	a0,80(a0)
    80001152:	e40ff0ef          	jal	ra,80000792 <uvmdealloc>
    80001156:	85aa                	mv	a1,a0
    80001158:	bfc1                	j	80001128 <growproc+0x1e>

000000008000115a <fork>:
{
    8000115a:	7139                	addi	sp,sp,-64
    8000115c:	fc06                	sd	ra,56(sp)
    8000115e:	f822                	sd	s0,48(sp)
    80001160:	f426                	sd	s1,40(sp)
    80001162:	f04a                	sd	s2,32(sp)
    80001164:	ec4e                	sd	s3,24(sp)
    80001166:	e852                	sd	s4,16(sp)
    80001168:	e456                	sd	s5,8(sp)
    8000116a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000116c:	cc9ff0ef          	jal	ra,80000e34 <myproc>
    80001170:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001172:	e85ff0ef          	jal	ra,80000ff6 <allocproc>
    80001176:	0e050663          	beqz	a0,80001262 <fork+0x108>
    8000117a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000117c:	048ab603          	ld	a2,72(s5)
    80001180:	692c                	ld	a1,80(a0)
    80001182:	050ab503          	ld	a0,80(s5)
    80001186:	f7cff0ef          	jal	ra,80000902 <uvmcopy>
    8000118a:	04054863          	bltz	a0,800011da <fork+0x80>
  np->sz = p->sz;
    8000118e:	048ab783          	ld	a5,72(s5)
    80001192:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001196:	058ab683          	ld	a3,88(s5)
    8000119a:	87b6                	mv	a5,a3
    8000119c:	058a3703          	ld	a4,88(s4)
    800011a0:	12068693          	addi	a3,a3,288
    800011a4:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800011a8:	6788                	ld	a0,8(a5)
    800011aa:	6b8c                	ld	a1,16(a5)
    800011ac:	6f90                	ld	a2,24(a5)
    800011ae:	01073023          	sd	a6,0(a4)
    800011b2:	e708                	sd	a0,8(a4)
    800011b4:	eb0c                	sd	a1,16(a4)
    800011b6:	ef10                	sd	a2,24(a4)
    800011b8:	02078793          	addi	a5,a5,32
    800011bc:	02070713          	addi	a4,a4,32
    800011c0:	fed792e3          	bne	a5,a3,800011a4 <fork+0x4a>
  np->trapframe->a0 = 0;
    800011c4:	058a3783          	ld	a5,88(s4)
    800011c8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800011cc:	0d0a8493          	addi	s1,s5,208
    800011d0:	0d0a0913          	addi	s2,s4,208
    800011d4:	150a8993          	addi	s3,s5,336
    800011d8:	a829                	j	800011f2 <fork+0x98>
    freeproc(np);
    800011da:	8552                	mv	a0,s4
    800011dc:	dcbff0ef          	jal	ra,80000fa6 <freeproc>
    release(&np->lock);
    800011e0:	8552                	mv	a0,s4
    800011e2:	588040ef          	jal	ra,8000576a <release>
    return -1;
    800011e6:	597d                	li	s2,-1
    800011e8:	a09d                	j	8000124e <fork+0xf4>
  for(i = 0; i < NOFILE; i++)
    800011ea:	04a1                	addi	s1,s1,8
    800011ec:	0921                	addi	s2,s2,8
    800011ee:	01348963          	beq	s1,s3,80001200 <fork+0xa6>
    if(p->ofile[i])
    800011f2:	6088                	ld	a0,0(s1)
    800011f4:	d97d                	beqz	a0,800011ea <fork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    800011f6:	1b2020ef          	jal	ra,800033a8 <filedup>
    800011fa:	00a93023          	sd	a0,0(s2)
    800011fe:	b7f5                	j	800011ea <fork+0x90>
  np->cwd = idup(p->cwd);
    80001200:	150ab503          	ld	a0,336(s5)
    80001204:	508010ef          	jal	ra,8000270c <idup>
    80001208:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000120c:	4641                	li	a2,16
    8000120e:	158a8593          	addi	a1,s5,344
    80001212:	158a0513          	addi	a0,s4,344
    80001216:	87eff0ef          	jal	ra,80000294 <safestrcpy>
  pid = np->pid;
    8000121a:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    8000121e:	8552                	mv	a0,s4
    80001220:	54a040ef          	jal	ra,8000576a <release>
  acquire(&wait_lock);
    80001224:	00006497          	auipc	s1,0x6
    80001228:	7e448493          	addi	s1,s1,2020 # 80007a08 <wait_lock>
    8000122c:	8526                	mv	a0,s1
    8000122e:	4a4040ef          	jal	ra,800056d2 <acquire>
  np->parent = p;
    80001232:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001236:	8526                	mv	a0,s1
    80001238:	532040ef          	jal	ra,8000576a <release>
  acquire(&np->lock);
    8000123c:	8552                	mv	a0,s4
    8000123e:	494040ef          	jal	ra,800056d2 <acquire>
  np->state = RUNNABLE;
    80001242:	478d                	li	a5,3
    80001244:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001248:	8552                	mv	a0,s4
    8000124a:	520040ef          	jal	ra,8000576a <release>
}
    8000124e:	854a                	mv	a0,s2
    80001250:	70e2                	ld	ra,56(sp)
    80001252:	7442                	ld	s0,48(sp)
    80001254:	74a2                	ld	s1,40(sp)
    80001256:	7902                	ld	s2,32(sp)
    80001258:	69e2                	ld	s3,24(sp)
    8000125a:	6a42                	ld	s4,16(sp)
    8000125c:	6aa2                	ld	s5,8(sp)
    8000125e:	6121                	addi	sp,sp,64
    80001260:	8082                	ret
    return -1;
    80001262:	597d                	li	s2,-1
    80001264:	b7ed                	j	8000124e <fork+0xf4>

0000000080001266 <scheduler>:
{
    80001266:	715d                	addi	sp,sp,-80
    80001268:	e486                	sd	ra,72(sp)
    8000126a:	e0a2                	sd	s0,64(sp)
    8000126c:	fc26                	sd	s1,56(sp)
    8000126e:	f84a                	sd	s2,48(sp)
    80001270:	f44e                	sd	s3,40(sp)
    80001272:	f052                	sd	s4,32(sp)
    80001274:	ec56                	sd	s5,24(sp)
    80001276:	e85a                	sd	s6,16(sp)
    80001278:	e45e                	sd	s7,8(sp)
    8000127a:	e062                	sd	s8,0(sp)
    8000127c:	0880                	addi	s0,sp,80
    8000127e:	8792                	mv	a5,tp
  int id = r_tp();
    80001280:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001282:	00779b13          	slli	s6,a5,0x7
    80001286:	00006717          	auipc	a4,0x6
    8000128a:	76a70713          	addi	a4,a4,1898 # 800079f0 <pid_lock>
    8000128e:	975a                	add	a4,a4,s6
    80001290:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001294:	00006717          	auipc	a4,0x6
    80001298:	79470713          	addi	a4,a4,1940 # 80007a28 <cpus+0x8>
    8000129c:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000129e:	4c11                	li	s8,4
        c->proc = p;
    800012a0:	079e                	slli	a5,a5,0x7
    800012a2:	00006a17          	auipc	s4,0x6
    800012a6:	74ea0a13          	addi	s4,s4,1870 # 800079f0 <pid_lock>
    800012aa:	9a3e                	add	s4,s4,a5
        found = 1;
    800012ac:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800012ae:	0000c997          	auipc	s3,0xc
    800012b2:	57298993          	addi	s3,s3,1394 # 8000d820 <tickslock>
    800012b6:	a0a9                	j	80001300 <scheduler+0x9a>
      release(&p->lock);
    800012b8:	8526                	mv	a0,s1
    800012ba:	4b0040ef          	jal	ra,8000576a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800012be:	16848493          	addi	s1,s1,360
    800012c2:	03348563          	beq	s1,s3,800012ec <scheduler+0x86>
      acquire(&p->lock);
    800012c6:	8526                	mv	a0,s1
    800012c8:	40a040ef          	jal	ra,800056d2 <acquire>
      if(p->state == RUNNABLE) {
    800012cc:	4c9c                	lw	a5,24(s1)
    800012ce:	ff2795e3          	bne	a5,s2,800012b8 <scheduler+0x52>
        p->state = RUNNING;
    800012d2:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    800012d6:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800012da:	06048593          	addi	a1,s1,96
    800012de:	855a                	mv	a0,s6
    800012e0:	5b4000ef          	jal	ra,80001894 <swtch>
        c->proc = 0;
    800012e4:	020a3823          	sd	zero,48(s4)
        found = 1;
    800012e8:	8ade                	mv	s5,s7
    800012ea:	b7f9                	j	800012b8 <scheduler+0x52>
    if(found == 0) {
    800012ec:	000a9a63          	bnez	s5,80001300 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012f0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800012f4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012f8:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800012fc:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001300:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001304:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001308:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000130c:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000130e:	00007497          	auipc	s1,0x7
    80001312:	b1248493          	addi	s1,s1,-1262 # 80007e20 <proc>
      if(p->state == RUNNABLE) {
    80001316:	490d                	li	s2,3
    80001318:	b77d                	j	800012c6 <scheduler+0x60>

000000008000131a <sched>:
{
    8000131a:	7179                	addi	sp,sp,-48
    8000131c:	f406                	sd	ra,40(sp)
    8000131e:	f022                	sd	s0,32(sp)
    80001320:	ec26                	sd	s1,24(sp)
    80001322:	e84a                	sd	s2,16(sp)
    80001324:	e44e                	sd	s3,8(sp)
    80001326:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001328:	b0dff0ef          	jal	ra,80000e34 <myproc>
    8000132c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000132e:	33a040ef          	jal	ra,80005668 <holding>
    80001332:	c92d                	beqz	a0,800013a4 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001334:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001336:	2781                	sext.w	a5,a5
    80001338:	079e                	slli	a5,a5,0x7
    8000133a:	00006717          	auipc	a4,0x6
    8000133e:	6b670713          	addi	a4,a4,1718 # 800079f0 <pid_lock>
    80001342:	97ba                	add	a5,a5,a4
    80001344:	0a87a703          	lw	a4,168(a5)
    80001348:	4785                	li	a5,1
    8000134a:	06f71363          	bne	a4,a5,800013b0 <sched+0x96>
  if(p->state == RUNNING)
    8000134e:	4c98                	lw	a4,24(s1)
    80001350:	4791                	li	a5,4
    80001352:	06f70563          	beq	a4,a5,800013bc <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001356:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000135a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000135c:	e7b5                	bnez	a5,800013c8 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000135e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001360:	00006917          	auipc	s2,0x6
    80001364:	69090913          	addi	s2,s2,1680 # 800079f0 <pid_lock>
    80001368:	2781                	sext.w	a5,a5
    8000136a:	079e                	slli	a5,a5,0x7
    8000136c:	97ca                	add	a5,a5,s2
    8000136e:	0ac7a983          	lw	s3,172(a5)
    80001372:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001374:	2781                	sext.w	a5,a5
    80001376:	079e                	slli	a5,a5,0x7
    80001378:	00006597          	auipc	a1,0x6
    8000137c:	6b058593          	addi	a1,a1,1712 # 80007a28 <cpus+0x8>
    80001380:	95be                	add	a1,a1,a5
    80001382:	06048513          	addi	a0,s1,96
    80001386:	50e000ef          	jal	ra,80001894 <swtch>
    8000138a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000138c:	2781                	sext.w	a5,a5
    8000138e:	079e                	slli	a5,a5,0x7
    80001390:	993e                	add	s2,s2,a5
    80001392:	0b392623          	sw	s3,172(s2)
}
    80001396:	70a2                	ld	ra,40(sp)
    80001398:	7402                	ld	s0,32(sp)
    8000139a:	64e2                	ld	s1,24(sp)
    8000139c:	6942                	ld	s2,16(sp)
    8000139e:	69a2                	ld	s3,8(sp)
    800013a0:	6145                	addi	sp,sp,48
    800013a2:	8082                	ret
    panic("sched p->lock");
    800013a4:	00006517          	auipc	a0,0x6
    800013a8:	e7c50513          	addi	a0,a0,-388 # 80007220 <etext+0x220>
    800013ac:	016040ef          	jal	ra,800053c2 <panic>
    panic("sched locks");
    800013b0:	00006517          	auipc	a0,0x6
    800013b4:	e8050513          	addi	a0,a0,-384 # 80007230 <etext+0x230>
    800013b8:	00a040ef          	jal	ra,800053c2 <panic>
    panic("sched running");
    800013bc:	00006517          	auipc	a0,0x6
    800013c0:	e8450513          	addi	a0,a0,-380 # 80007240 <etext+0x240>
    800013c4:	7ff030ef          	jal	ra,800053c2 <panic>
    panic("sched interruptible");
    800013c8:	00006517          	auipc	a0,0x6
    800013cc:	e8850513          	addi	a0,a0,-376 # 80007250 <etext+0x250>
    800013d0:	7f3030ef          	jal	ra,800053c2 <panic>

00000000800013d4 <yield>:
{
    800013d4:	1101                	addi	sp,sp,-32
    800013d6:	ec06                	sd	ra,24(sp)
    800013d8:	e822                	sd	s0,16(sp)
    800013da:	e426                	sd	s1,8(sp)
    800013dc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800013de:	a57ff0ef          	jal	ra,80000e34 <myproc>
    800013e2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800013e4:	2ee040ef          	jal	ra,800056d2 <acquire>
  p->state = RUNNABLE;
    800013e8:	478d                	li	a5,3
    800013ea:	cc9c                	sw	a5,24(s1)
  sched();
    800013ec:	f2fff0ef          	jal	ra,8000131a <sched>
  release(&p->lock);
    800013f0:	8526                	mv	a0,s1
    800013f2:	378040ef          	jal	ra,8000576a <release>
}
    800013f6:	60e2                	ld	ra,24(sp)
    800013f8:	6442                	ld	s0,16(sp)
    800013fa:	64a2                	ld	s1,8(sp)
    800013fc:	6105                	addi	sp,sp,32
    800013fe:	8082                	ret

0000000080001400 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001400:	7179                	addi	sp,sp,-48
    80001402:	f406                	sd	ra,40(sp)
    80001404:	f022                	sd	s0,32(sp)
    80001406:	ec26                	sd	s1,24(sp)
    80001408:	e84a                	sd	s2,16(sp)
    8000140a:	e44e                	sd	s3,8(sp)
    8000140c:	1800                	addi	s0,sp,48
    8000140e:	89aa                	mv	s3,a0
    80001410:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001412:	a23ff0ef          	jal	ra,80000e34 <myproc>
    80001416:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001418:	2ba040ef          	jal	ra,800056d2 <acquire>
  release(lk);
    8000141c:	854a                	mv	a0,s2
    8000141e:	34c040ef          	jal	ra,8000576a <release>

  // Go to sleep.
  p->chan = chan;
    80001422:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001426:	4789                	li	a5,2
    80001428:	cc9c                	sw	a5,24(s1)

  sched();
    8000142a:	ef1ff0ef          	jal	ra,8000131a <sched>

  // Tidy up.
  p->chan = 0;
    8000142e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001432:	8526                	mv	a0,s1
    80001434:	336040ef          	jal	ra,8000576a <release>
  acquire(lk);
    80001438:	854a                	mv	a0,s2
    8000143a:	298040ef          	jal	ra,800056d2 <acquire>
}
    8000143e:	70a2                	ld	ra,40(sp)
    80001440:	7402                	ld	s0,32(sp)
    80001442:	64e2                	ld	s1,24(sp)
    80001444:	6942                	ld	s2,16(sp)
    80001446:	69a2                	ld	s3,8(sp)
    80001448:	6145                	addi	sp,sp,48
    8000144a:	8082                	ret

000000008000144c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000144c:	7139                	addi	sp,sp,-64
    8000144e:	fc06                	sd	ra,56(sp)
    80001450:	f822                	sd	s0,48(sp)
    80001452:	f426                	sd	s1,40(sp)
    80001454:	f04a                	sd	s2,32(sp)
    80001456:	ec4e                	sd	s3,24(sp)
    80001458:	e852                	sd	s4,16(sp)
    8000145a:	e456                	sd	s5,8(sp)
    8000145c:	0080                	addi	s0,sp,64
    8000145e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001460:	00007497          	auipc	s1,0x7
    80001464:	9c048493          	addi	s1,s1,-1600 # 80007e20 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001468:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000146a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000146c:	0000c917          	auipc	s2,0xc
    80001470:	3b490913          	addi	s2,s2,948 # 8000d820 <tickslock>
    80001474:	a801                	j	80001484 <wakeup+0x38>
      }
      release(&p->lock);
    80001476:	8526                	mv	a0,s1
    80001478:	2f2040ef          	jal	ra,8000576a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000147c:	16848493          	addi	s1,s1,360
    80001480:	03248263          	beq	s1,s2,800014a4 <wakeup+0x58>
    if(p != myproc()){
    80001484:	9b1ff0ef          	jal	ra,80000e34 <myproc>
    80001488:	fea48ae3          	beq	s1,a0,8000147c <wakeup+0x30>
      acquire(&p->lock);
    8000148c:	8526                	mv	a0,s1
    8000148e:	244040ef          	jal	ra,800056d2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001492:	4c9c                	lw	a5,24(s1)
    80001494:	ff3791e3          	bne	a5,s3,80001476 <wakeup+0x2a>
    80001498:	709c                	ld	a5,32(s1)
    8000149a:	fd479ee3          	bne	a5,s4,80001476 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000149e:	0154ac23          	sw	s5,24(s1)
    800014a2:	bfd1                	j	80001476 <wakeup+0x2a>
    }
  }
}
    800014a4:	70e2                	ld	ra,56(sp)
    800014a6:	7442                	ld	s0,48(sp)
    800014a8:	74a2                	ld	s1,40(sp)
    800014aa:	7902                	ld	s2,32(sp)
    800014ac:	69e2                	ld	s3,24(sp)
    800014ae:	6a42                	ld	s4,16(sp)
    800014b0:	6aa2                	ld	s5,8(sp)
    800014b2:	6121                	addi	sp,sp,64
    800014b4:	8082                	ret

00000000800014b6 <reparent>:
{
    800014b6:	7179                	addi	sp,sp,-48
    800014b8:	f406                	sd	ra,40(sp)
    800014ba:	f022                	sd	s0,32(sp)
    800014bc:	ec26                	sd	s1,24(sp)
    800014be:	e84a                	sd	s2,16(sp)
    800014c0:	e44e                	sd	s3,8(sp)
    800014c2:	e052                	sd	s4,0(sp)
    800014c4:	1800                	addi	s0,sp,48
    800014c6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800014c8:	00007497          	auipc	s1,0x7
    800014cc:	95848493          	addi	s1,s1,-1704 # 80007e20 <proc>
      pp->parent = initproc;
    800014d0:	00006a17          	auipc	s4,0x6
    800014d4:	4e0a0a13          	addi	s4,s4,1248 # 800079b0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800014d8:	0000c997          	auipc	s3,0xc
    800014dc:	34898993          	addi	s3,s3,840 # 8000d820 <tickslock>
    800014e0:	a029                	j	800014ea <reparent+0x34>
    800014e2:	16848493          	addi	s1,s1,360
    800014e6:	01348b63          	beq	s1,s3,800014fc <reparent+0x46>
    if(pp->parent == p){
    800014ea:	7c9c                	ld	a5,56(s1)
    800014ec:	ff279be3          	bne	a5,s2,800014e2 <reparent+0x2c>
      pp->parent = initproc;
    800014f0:	000a3503          	ld	a0,0(s4)
    800014f4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800014f6:	f57ff0ef          	jal	ra,8000144c <wakeup>
    800014fa:	b7e5                	j	800014e2 <reparent+0x2c>
}
    800014fc:	70a2                	ld	ra,40(sp)
    800014fe:	7402                	ld	s0,32(sp)
    80001500:	64e2                	ld	s1,24(sp)
    80001502:	6942                	ld	s2,16(sp)
    80001504:	69a2                	ld	s3,8(sp)
    80001506:	6a02                	ld	s4,0(sp)
    80001508:	6145                	addi	sp,sp,48
    8000150a:	8082                	ret

000000008000150c <exit>:
{
    8000150c:	7179                	addi	sp,sp,-48
    8000150e:	f406                	sd	ra,40(sp)
    80001510:	f022                	sd	s0,32(sp)
    80001512:	ec26                	sd	s1,24(sp)
    80001514:	e84a                	sd	s2,16(sp)
    80001516:	e44e                	sd	s3,8(sp)
    80001518:	e052                	sd	s4,0(sp)
    8000151a:	1800                	addi	s0,sp,48
    8000151c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000151e:	917ff0ef          	jal	ra,80000e34 <myproc>
    80001522:	89aa                	mv	s3,a0
  if(p == initproc)
    80001524:	00006797          	auipc	a5,0x6
    80001528:	48c7b783          	ld	a5,1164(a5) # 800079b0 <initproc>
    8000152c:	0d050493          	addi	s1,a0,208
    80001530:	15050913          	addi	s2,a0,336
    80001534:	00a79f63          	bne	a5,a0,80001552 <exit+0x46>
    panic("init exiting");
    80001538:	00006517          	auipc	a0,0x6
    8000153c:	d3050513          	addi	a0,a0,-720 # 80007268 <etext+0x268>
    80001540:	683030ef          	jal	ra,800053c2 <panic>
      fileclose(f);
    80001544:	6ab010ef          	jal	ra,800033ee <fileclose>
      p->ofile[fd] = 0;
    80001548:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000154c:	04a1                	addi	s1,s1,8
    8000154e:	01248563          	beq	s1,s2,80001558 <exit+0x4c>
    if(p->ofile[fd]){
    80001552:	6088                	ld	a0,0(s1)
    80001554:	f965                	bnez	a0,80001544 <exit+0x38>
    80001556:	bfdd                	j	8000154c <exit+0x40>
  begin_op();
    80001558:	27f010ef          	jal	ra,80002fd6 <begin_op>
  iput(p->cwd);
    8000155c:	1509b503          	ld	a0,336(s3)
    80001560:	360010ef          	jal	ra,800028c0 <iput>
  end_op();
    80001564:	2e1010ef          	jal	ra,80003044 <end_op>
  p->cwd = 0;
    80001568:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000156c:	00006497          	auipc	s1,0x6
    80001570:	49c48493          	addi	s1,s1,1180 # 80007a08 <wait_lock>
    80001574:	8526                	mv	a0,s1
    80001576:	15c040ef          	jal	ra,800056d2 <acquire>
  reparent(p);
    8000157a:	854e                	mv	a0,s3
    8000157c:	f3bff0ef          	jal	ra,800014b6 <reparent>
  wakeup(p->parent);
    80001580:	0389b503          	ld	a0,56(s3)
    80001584:	ec9ff0ef          	jal	ra,8000144c <wakeup>
  acquire(&p->lock);
    80001588:	854e                	mv	a0,s3
    8000158a:	148040ef          	jal	ra,800056d2 <acquire>
  p->xstate = status;
    8000158e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001592:	4795                	li	a5,5
    80001594:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001598:	8526                	mv	a0,s1
    8000159a:	1d0040ef          	jal	ra,8000576a <release>
  sched();
    8000159e:	d7dff0ef          	jal	ra,8000131a <sched>
  panic("zombie exit");
    800015a2:	00006517          	auipc	a0,0x6
    800015a6:	cd650513          	addi	a0,a0,-810 # 80007278 <etext+0x278>
    800015aa:	619030ef          	jal	ra,800053c2 <panic>

00000000800015ae <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800015ae:	7179                	addi	sp,sp,-48
    800015b0:	f406                	sd	ra,40(sp)
    800015b2:	f022                	sd	s0,32(sp)
    800015b4:	ec26                	sd	s1,24(sp)
    800015b6:	e84a                	sd	s2,16(sp)
    800015b8:	e44e                	sd	s3,8(sp)
    800015ba:	1800                	addi	s0,sp,48
    800015bc:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800015be:	00007497          	auipc	s1,0x7
    800015c2:	86248493          	addi	s1,s1,-1950 # 80007e20 <proc>
    800015c6:	0000c997          	auipc	s3,0xc
    800015ca:	25a98993          	addi	s3,s3,602 # 8000d820 <tickslock>
    acquire(&p->lock);
    800015ce:	8526                	mv	a0,s1
    800015d0:	102040ef          	jal	ra,800056d2 <acquire>
    if(p->pid == pid){
    800015d4:	589c                	lw	a5,48(s1)
    800015d6:	01278b63          	beq	a5,s2,800015ec <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800015da:	8526                	mv	a0,s1
    800015dc:	18e040ef          	jal	ra,8000576a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800015e0:	16848493          	addi	s1,s1,360
    800015e4:	ff3495e3          	bne	s1,s3,800015ce <kill+0x20>
  }
  return -1;
    800015e8:	557d                	li	a0,-1
    800015ea:	a819                	j	80001600 <kill+0x52>
      p->killed = 1;
    800015ec:	4785                	li	a5,1
    800015ee:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800015f0:	4c98                	lw	a4,24(s1)
    800015f2:	4789                	li	a5,2
    800015f4:	00f70d63          	beq	a4,a5,8000160e <kill+0x60>
      release(&p->lock);
    800015f8:	8526                	mv	a0,s1
    800015fa:	170040ef          	jal	ra,8000576a <release>
      return 0;
    800015fe:	4501                	li	a0,0
}
    80001600:	70a2                	ld	ra,40(sp)
    80001602:	7402                	ld	s0,32(sp)
    80001604:	64e2                	ld	s1,24(sp)
    80001606:	6942                	ld	s2,16(sp)
    80001608:	69a2                	ld	s3,8(sp)
    8000160a:	6145                	addi	sp,sp,48
    8000160c:	8082                	ret
        p->state = RUNNABLE;
    8000160e:	478d                	li	a5,3
    80001610:	cc9c                	sw	a5,24(s1)
    80001612:	b7dd                	j	800015f8 <kill+0x4a>

0000000080001614 <setkilled>:

void
setkilled(struct proc *p)
{
    80001614:	1101                	addi	sp,sp,-32
    80001616:	ec06                	sd	ra,24(sp)
    80001618:	e822                	sd	s0,16(sp)
    8000161a:	e426                	sd	s1,8(sp)
    8000161c:	1000                	addi	s0,sp,32
    8000161e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001620:	0b2040ef          	jal	ra,800056d2 <acquire>
  p->killed = 1;
    80001624:	4785                	li	a5,1
    80001626:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001628:	8526                	mv	a0,s1
    8000162a:	140040ef          	jal	ra,8000576a <release>
}
    8000162e:	60e2                	ld	ra,24(sp)
    80001630:	6442                	ld	s0,16(sp)
    80001632:	64a2                	ld	s1,8(sp)
    80001634:	6105                	addi	sp,sp,32
    80001636:	8082                	ret

0000000080001638 <killed>:

int
killed(struct proc *p)
{
    80001638:	1101                	addi	sp,sp,-32
    8000163a:	ec06                	sd	ra,24(sp)
    8000163c:	e822                	sd	s0,16(sp)
    8000163e:	e426                	sd	s1,8(sp)
    80001640:	e04a                	sd	s2,0(sp)
    80001642:	1000                	addi	s0,sp,32
    80001644:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80001646:	08c040ef          	jal	ra,800056d2 <acquire>
  k = p->killed;
    8000164a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000164e:	8526                	mv	a0,s1
    80001650:	11a040ef          	jal	ra,8000576a <release>
  return k;
}
    80001654:	854a                	mv	a0,s2
    80001656:	60e2                	ld	ra,24(sp)
    80001658:	6442                	ld	s0,16(sp)
    8000165a:	64a2                	ld	s1,8(sp)
    8000165c:	6902                	ld	s2,0(sp)
    8000165e:	6105                	addi	sp,sp,32
    80001660:	8082                	ret

0000000080001662 <wait>:
{
    80001662:	715d                	addi	sp,sp,-80
    80001664:	e486                	sd	ra,72(sp)
    80001666:	e0a2                	sd	s0,64(sp)
    80001668:	fc26                	sd	s1,56(sp)
    8000166a:	f84a                	sd	s2,48(sp)
    8000166c:	f44e                	sd	s3,40(sp)
    8000166e:	f052                	sd	s4,32(sp)
    80001670:	ec56                	sd	s5,24(sp)
    80001672:	e85a                	sd	s6,16(sp)
    80001674:	e45e                	sd	s7,8(sp)
    80001676:	e062                	sd	s8,0(sp)
    80001678:	0880                	addi	s0,sp,80
    8000167a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000167c:	fb8ff0ef          	jal	ra,80000e34 <myproc>
    80001680:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001682:	00006517          	auipc	a0,0x6
    80001686:	38650513          	addi	a0,a0,902 # 80007a08 <wait_lock>
    8000168a:	048040ef          	jal	ra,800056d2 <acquire>
    havekids = 0;
    8000168e:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001690:	4a15                	li	s4,5
        havekids = 1;
    80001692:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001694:	0000c997          	auipc	s3,0xc
    80001698:	18c98993          	addi	s3,s3,396 # 8000d820 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000169c:	00006c17          	auipc	s8,0x6
    800016a0:	36cc0c13          	addi	s8,s8,876 # 80007a08 <wait_lock>
    havekids = 0;
    800016a4:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016a6:	00006497          	auipc	s1,0x6
    800016aa:	77a48493          	addi	s1,s1,1914 # 80007e20 <proc>
    800016ae:	a899                	j	80001704 <wait+0xa2>
          pid = pp->pid;
    800016b0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800016b4:	000b0c63          	beqz	s6,800016cc <wait+0x6a>
    800016b8:	4691                	li	a3,4
    800016ba:	02c48613          	addi	a2,s1,44
    800016be:	85da                	mv	a1,s6
    800016c0:	05093503          	ld	a0,80(s2)
    800016c4:	b1aff0ef          	jal	ra,800009de <copyout>
    800016c8:	00054f63          	bltz	a0,800016e6 <wait+0x84>
          freeproc(pp);
    800016cc:	8526                	mv	a0,s1
    800016ce:	8d9ff0ef          	jal	ra,80000fa6 <freeproc>
          release(&pp->lock);
    800016d2:	8526                	mv	a0,s1
    800016d4:	096040ef          	jal	ra,8000576a <release>
          release(&wait_lock);
    800016d8:	00006517          	auipc	a0,0x6
    800016dc:	33050513          	addi	a0,a0,816 # 80007a08 <wait_lock>
    800016e0:	08a040ef          	jal	ra,8000576a <release>
          return pid;
    800016e4:	a891                	j	80001738 <wait+0xd6>
            release(&pp->lock);
    800016e6:	8526                	mv	a0,s1
    800016e8:	082040ef          	jal	ra,8000576a <release>
            release(&wait_lock);
    800016ec:	00006517          	auipc	a0,0x6
    800016f0:	31c50513          	addi	a0,a0,796 # 80007a08 <wait_lock>
    800016f4:	076040ef          	jal	ra,8000576a <release>
            return -1;
    800016f8:	59fd                	li	s3,-1
    800016fa:	a83d                	j	80001738 <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016fc:	16848493          	addi	s1,s1,360
    80001700:	03348063          	beq	s1,s3,80001720 <wait+0xbe>
      if(pp->parent == p){
    80001704:	7c9c                	ld	a5,56(s1)
    80001706:	ff279be3          	bne	a5,s2,800016fc <wait+0x9a>
        acquire(&pp->lock);
    8000170a:	8526                	mv	a0,s1
    8000170c:	7c7030ef          	jal	ra,800056d2 <acquire>
        if(pp->state == ZOMBIE){
    80001710:	4c9c                	lw	a5,24(s1)
    80001712:	f9478fe3          	beq	a5,s4,800016b0 <wait+0x4e>
        release(&pp->lock);
    80001716:	8526                	mv	a0,s1
    80001718:	052040ef          	jal	ra,8000576a <release>
        havekids = 1;
    8000171c:	8756                	mv	a4,s5
    8000171e:	bff9                	j	800016fc <wait+0x9a>
    if(!havekids || killed(p)){
    80001720:	c709                	beqz	a4,8000172a <wait+0xc8>
    80001722:	854a                	mv	a0,s2
    80001724:	f15ff0ef          	jal	ra,80001638 <killed>
    80001728:	c50d                	beqz	a0,80001752 <wait+0xf0>
      release(&wait_lock);
    8000172a:	00006517          	auipc	a0,0x6
    8000172e:	2de50513          	addi	a0,a0,734 # 80007a08 <wait_lock>
    80001732:	038040ef          	jal	ra,8000576a <release>
      return -1;
    80001736:	59fd                	li	s3,-1
}
    80001738:	854e                	mv	a0,s3
    8000173a:	60a6                	ld	ra,72(sp)
    8000173c:	6406                	ld	s0,64(sp)
    8000173e:	74e2                	ld	s1,56(sp)
    80001740:	7942                	ld	s2,48(sp)
    80001742:	79a2                	ld	s3,40(sp)
    80001744:	7a02                	ld	s4,32(sp)
    80001746:	6ae2                	ld	s5,24(sp)
    80001748:	6b42                	ld	s6,16(sp)
    8000174a:	6ba2                	ld	s7,8(sp)
    8000174c:	6c02                	ld	s8,0(sp)
    8000174e:	6161                	addi	sp,sp,80
    80001750:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001752:	85e2                	mv	a1,s8
    80001754:	854a                	mv	a0,s2
    80001756:	cabff0ef          	jal	ra,80001400 <sleep>
    havekids = 0;
    8000175a:	b7a9                	j	800016a4 <wait+0x42>

000000008000175c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000175c:	7179                	addi	sp,sp,-48
    8000175e:	f406                	sd	ra,40(sp)
    80001760:	f022                	sd	s0,32(sp)
    80001762:	ec26                	sd	s1,24(sp)
    80001764:	e84a                	sd	s2,16(sp)
    80001766:	e44e                	sd	s3,8(sp)
    80001768:	e052                	sd	s4,0(sp)
    8000176a:	1800                	addi	s0,sp,48
    8000176c:	84aa                	mv	s1,a0
    8000176e:	892e                	mv	s2,a1
    80001770:	89b2                	mv	s3,a2
    80001772:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001774:	ec0ff0ef          	jal	ra,80000e34 <myproc>
  if(user_dst){
    80001778:	cc99                	beqz	s1,80001796 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000177a:	86d2                	mv	a3,s4
    8000177c:	864e                	mv	a2,s3
    8000177e:	85ca                	mv	a1,s2
    80001780:	6928                	ld	a0,80(a0)
    80001782:	a5cff0ef          	jal	ra,800009de <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001786:	70a2                	ld	ra,40(sp)
    80001788:	7402                	ld	s0,32(sp)
    8000178a:	64e2                	ld	s1,24(sp)
    8000178c:	6942                	ld	s2,16(sp)
    8000178e:	69a2                	ld	s3,8(sp)
    80001790:	6a02                	ld	s4,0(sp)
    80001792:	6145                	addi	sp,sp,48
    80001794:	8082                	ret
    memmove((char *)dst, src, len);
    80001796:	000a061b          	sext.w	a2,s4
    8000179a:	85ce                	mv	a1,s3
    8000179c:	854a                	mv	a0,s2
    8000179e:	a0dfe0ef          	jal	ra,800001aa <memmove>
    return 0;
    800017a2:	8526                	mv	a0,s1
    800017a4:	b7cd                	j	80001786 <either_copyout+0x2a>

00000000800017a6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800017a6:	7179                	addi	sp,sp,-48
    800017a8:	f406                	sd	ra,40(sp)
    800017aa:	f022                	sd	s0,32(sp)
    800017ac:	ec26                	sd	s1,24(sp)
    800017ae:	e84a                	sd	s2,16(sp)
    800017b0:	e44e                	sd	s3,8(sp)
    800017b2:	e052                	sd	s4,0(sp)
    800017b4:	1800                	addi	s0,sp,48
    800017b6:	892a                	mv	s2,a0
    800017b8:	84ae                	mv	s1,a1
    800017ba:	89b2                	mv	s3,a2
    800017bc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800017be:	e76ff0ef          	jal	ra,80000e34 <myproc>
  if(user_src){
    800017c2:	cc99                	beqz	s1,800017e0 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800017c4:	86d2                	mv	a3,s4
    800017c6:	864e                	mv	a2,s3
    800017c8:	85ca                	mv	a1,s2
    800017ca:	6928                	ld	a0,80(a0)
    800017cc:	acaff0ef          	jal	ra,80000a96 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800017d0:	70a2                	ld	ra,40(sp)
    800017d2:	7402                	ld	s0,32(sp)
    800017d4:	64e2                	ld	s1,24(sp)
    800017d6:	6942                	ld	s2,16(sp)
    800017d8:	69a2                	ld	s3,8(sp)
    800017da:	6a02                	ld	s4,0(sp)
    800017dc:	6145                	addi	sp,sp,48
    800017de:	8082                	ret
    memmove(dst, (char*)src, len);
    800017e0:	000a061b          	sext.w	a2,s4
    800017e4:	85ce                	mv	a1,s3
    800017e6:	854a                	mv	a0,s2
    800017e8:	9c3fe0ef          	jal	ra,800001aa <memmove>
    return 0;
    800017ec:	8526                	mv	a0,s1
    800017ee:	b7cd                	j	800017d0 <either_copyin+0x2a>

00000000800017f0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800017f0:	715d                	addi	sp,sp,-80
    800017f2:	e486                	sd	ra,72(sp)
    800017f4:	e0a2                	sd	s0,64(sp)
    800017f6:	fc26                	sd	s1,56(sp)
    800017f8:	f84a                	sd	s2,48(sp)
    800017fa:	f44e                	sd	s3,40(sp)
    800017fc:	f052                	sd	s4,32(sp)
    800017fe:	ec56                	sd	s5,24(sp)
    80001800:	e85a                	sd	s6,16(sp)
    80001802:	e45e                	sd	s7,8(sp)
    80001804:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001806:	00006517          	auipc	a0,0x6
    8000180a:	84250513          	addi	a0,a0,-1982 # 80007048 <etext+0x48>
    8000180e:	101030ef          	jal	ra,8000510e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001812:	00006497          	auipc	s1,0x6
    80001816:	76648493          	addi	s1,s1,1894 # 80007f78 <proc+0x158>
    8000181a:	0000c917          	auipc	s2,0xc
    8000181e:	15e90913          	addi	s2,s2,350 # 8000d978 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001822:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001824:	00006997          	auipc	s3,0x6
    80001828:	a6498993          	addi	s3,s3,-1436 # 80007288 <etext+0x288>
    printf("%d %s %s", p->pid, state, p->name);
    8000182c:	00006a97          	auipc	s5,0x6
    80001830:	a64a8a93          	addi	s5,s5,-1436 # 80007290 <etext+0x290>
    printf("\n");
    80001834:	00006a17          	auipc	s4,0x6
    80001838:	814a0a13          	addi	s4,s4,-2028 # 80007048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000183c:	00006b97          	auipc	s7,0x6
    80001840:	a94b8b93          	addi	s7,s7,-1388 # 800072d0 <states.0>
    80001844:	a829                	j	8000185e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001846:	ed86a583          	lw	a1,-296(a3)
    8000184a:	8556                	mv	a0,s5
    8000184c:	0c3030ef          	jal	ra,8000510e <printf>
    printf("\n");
    80001850:	8552                	mv	a0,s4
    80001852:	0bd030ef          	jal	ra,8000510e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001856:	16848493          	addi	s1,s1,360
    8000185a:	03248263          	beq	s1,s2,8000187e <procdump+0x8e>
    if(p->state == UNUSED)
    8000185e:	86a6                	mv	a3,s1
    80001860:	ec04a783          	lw	a5,-320(s1)
    80001864:	dbed                	beqz	a5,80001856 <procdump+0x66>
      state = "???";
    80001866:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001868:	fcfb6fe3          	bltu	s6,a5,80001846 <procdump+0x56>
    8000186c:	02079713          	slli	a4,a5,0x20
    80001870:	01d75793          	srli	a5,a4,0x1d
    80001874:	97de                	add	a5,a5,s7
    80001876:	6390                	ld	a2,0(a5)
    80001878:	f679                	bnez	a2,80001846 <procdump+0x56>
      state = "???";
    8000187a:	864e                	mv	a2,s3
    8000187c:	b7e9                	j	80001846 <procdump+0x56>
  }
}
    8000187e:	60a6                	ld	ra,72(sp)
    80001880:	6406                	ld	s0,64(sp)
    80001882:	74e2                	ld	s1,56(sp)
    80001884:	7942                	ld	s2,48(sp)
    80001886:	79a2                	ld	s3,40(sp)
    80001888:	7a02                	ld	s4,32(sp)
    8000188a:	6ae2                	ld	s5,24(sp)
    8000188c:	6b42                	ld	s6,16(sp)
    8000188e:	6ba2                	ld	s7,8(sp)
    80001890:	6161                	addi	sp,sp,80
    80001892:	8082                	ret

0000000080001894 <swtch>:
    80001894:	00153023          	sd	ra,0(a0)
    80001898:	00253423          	sd	sp,8(a0)
    8000189c:	e900                	sd	s0,16(a0)
    8000189e:	ed04                	sd	s1,24(a0)
    800018a0:	03253023          	sd	s2,32(a0)
    800018a4:	03353423          	sd	s3,40(a0)
    800018a8:	03453823          	sd	s4,48(a0)
    800018ac:	03553c23          	sd	s5,56(a0)
    800018b0:	05653023          	sd	s6,64(a0)
    800018b4:	05753423          	sd	s7,72(a0)
    800018b8:	05853823          	sd	s8,80(a0)
    800018bc:	05953c23          	sd	s9,88(a0)
    800018c0:	07a53023          	sd	s10,96(a0)
    800018c4:	07b53423          	sd	s11,104(a0)
    800018c8:	0005b083          	ld	ra,0(a1)
    800018cc:	0085b103          	ld	sp,8(a1)
    800018d0:	6980                	ld	s0,16(a1)
    800018d2:	6d84                	ld	s1,24(a1)
    800018d4:	0205b903          	ld	s2,32(a1)
    800018d8:	0285b983          	ld	s3,40(a1)
    800018dc:	0305ba03          	ld	s4,48(a1)
    800018e0:	0385ba83          	ld	s5,56(a1)
    800018e4:	0405bb03          	ld	s6,64(a1)
    800018e8:	0485bb83          	ld	s7,72(a1)
    800018ec:	0505bc03          	ld	s8,80(a1)
    800018f0:	0585bc83          	ld	s9,88(a1)
    800018f4:	0605bd03          	ld	s10,96(a1)
    800018f8:	0685bd83          	ld	s11,104(a1)
    800018fc:	8082                	ret

00000000800018fe <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800018fe:	1141                	addi	sp,sp,-16
    80001900:	e406                	sd	ra,8(sp)
    80001902:	e022                	sd	s0,0(sp)
    80001904:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001906:	00006597          	auipc	a1,0x6
    8000190a:	9fa58593          	addi	a1,a1,-1542 # 80007300 <states.0+0x30>
    8000190e:	0000c517          	auipc	a0,0xc
    80001912:	f1250513          	addi	a0,a0,-238 # 8000d820 <tickslock>
    80001916:	53d030ef          	jal	ra,80005652 <initlock>
}
    8000191a:	60a2                	ld	ra,8(sp)
    8000191c:	6402                	ld	s0,0(sp)
    8000191e:	0141                	addi	sp,sp,16
    80001920:	8082                	ret

0000000080001922 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001922:	1141                	addi	sp,sp,-16
    80001924:	e422                	sd	s0,8(sp)
    80001926:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001928:	00003797          	auipc	a5,0x3
    8000192c:	d8878793          	addi	a5,a5,-632 # 800046b0 <kernelvec>
    80001930:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001934:	6422                	ld	s0,8(sp)
    80001936:	0141                	addi	sp,sp,16
    80001938:	8082                	ret

000000008000193a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000193a:	1141                	addi	sp,sp,-16
    8000193c:	e406                	sd	ra,8(sp)
    8000193e:	e022                	sd	s0,0(sp)
    80001940:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001942:	cf2ff0ef          	jal	ra,80000e34 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001946:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000194a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000194c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001950:	00004697          	auipc	a3,0x4
    80001954:	6b068693          	addi	a3,a3,1712 # 80006000 <_trampoline>
    80001958:	00004717          	auipc	a4,0x4
    8000195c:	6a870713          	addi	a4,a4,1704 # 80006000 <_trampoline>
    80001960:	8f15                	sub	a4,a4,a3
    80001962:	040007b7          	lui	a5,0x4000
    80001966:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001968:	07b2                	slli	a5,a5,0xc
    8000196a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000196c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001970:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001972:	18002673          	csrr	a2,satp
    80001976:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001978:	6d30                	ld	a2,88(a0)
    8000197a:	6138                	ld	a4,64(a0)
    8000197c:	6585                	lui	a1,0x1
    8000197e:	972e                	add	a4,a4,a1
    80001980:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001982:	6d38                	ld	a4,88(a0)
    80001984:	00000617          	auipc	a2,0x0
    80001988:	10c60613          	addi	a2,a2,268 # 80001a90 <usertrap>
    8000198c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000198e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001990:	8612                	mv	a2,tp
    80001992:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001994:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001998:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000199c:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800019a0:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800019a4:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800019a6:	6f18                	ld	a4,24(a4)
    800019a8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800019ac:	6928                	ld	a0,80(a0)
    800019ae:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019b0:	00004717          	auipc	a4,0x4
    800019b4:	6ec70713          	addi	a4,a4,1772 # 8000609c <userret>
    800019b8:	8f15                	sub	a4,a4,a3
    800019ba:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019bc:	577d                	li	a4,-1
    800019be:	177e                	slli	a4,a4,0x3f
    800019c0:	8d59                	or	a0,a0,a4
    800019c2:	9782                	jalr	a5
}
    800019c4:	60a2                	ld	ra,8(sp)
    800019c6:	6402                	ld	s0,0(sp)
    800019c8:	0141                	addi	sp,sp,16
    800019ca:	8082                	ret

00000000800019cc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800019cc:	1101                	addi	sp,sp,-32
    800019ce:	ec06                	sd	ra,24(sp)
    800019d0:	e822                	sd	s0,16(sp)
    800019d2:	e426                	sd	s1,8(sp)
    800019d4:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800019d6:	c32ff0ef          	jal	ra,80000e08 <cpuid>
    800019da:	cd19                	beqz	a0,800019f8 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800019dc:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800019e0:	000f4737          	lui	a4,0xf4
    800019e4:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800019e8:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800019ea:	14d79073          	csrw	0x14d,a5
}
    800019ee:	60e2                	ld	ra,24(sp)
    800019f0:	6442                	ld	s0,16(sp)
    800019f2:	64a2                	ld	s1,8(sp)
    800019f4:	6105                	addi	sp,sp,32
    800019f6:	8082                	ret
    acquire(&tickslock);
    800019f8:	0000c497          	auipc	s1,0xc
    800019fc:	e2848493          	addi	s1,s1,-472 # 8000d820 <tickslock>
    80001a00:	8526                	mv	a0,s1
    80001a02:	4d1030ef          	jal	ra,800056d2 <acquire>
    ticks++;
    80001a06:	00006517          	auipc	a0,0x6
    80001a0a:	fb250513          	addi	a0,a0,-78 # 800079b8 <ticks>
    80001a0e:	411c                	lw	a5,0(a0)
    80001a10:	2785                	addiw	a5,a5,1
    80001a12:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001a14:	a39ff0ef          	jal	ra,8000144c <wakeup>
    release(&tickslock);
    80001a18:	8526                	mv	a0,s1
    80001a1a:	551030ef          	jal	ra,8000576a <release>
    80001a1e:	bf7d                	j	800019dc <clockintr+0x10>

0000000080001a20 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001a20:	1101                	addi	sp,sp,-32
    80001a22:	ec06                	sd	ra,24(sp)
    80001a24:	e822                	sd	s0,16(sp)
    80001a26:	e426                	sd	s1,8(sp)
    80001a28:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a2a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001a2e:	57fd                	li	a5,-1
    80001a30:	17fe                	slli	a5,a5,0x3f
    80001a32:	07a5                	addi	a5,a5,9
    80001a34:	00f70d63          	beq	a4,a5,80001a4e <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001a38:	57fd                	li	a5,-1
    80001a3a:	17fe                	slli	a5,a5,0x3f
    80001a3c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001a3e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001a40:	04f70463          	beq	a4,a5,80001a88 <devintr+0x68>
  }
}
    80001a44:	60e2                	ld	ra,24(sp)
    80001a46:	6442                	ld	s0,16(sp)
    80001a48:	64a2                	ld	s1,8(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret
    int irq = plic_claim();
    80001a4e:	50b020ef          	jal	ra,80004758 <plic_claim>
    80001a52:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001a54:	47a9                	li	a5,10
    80001a56:	02f50363          	beq	a0,a5,80001a7c <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001a5a:	4785                	li	a5,1
    80001a5c:	02f50363          	beq	a0,a5,80001a82 <devintr+0x62>
    return 1;
    80001a60:	4505                	li	a0,1
    } else if(irq){
    80001a62:	d0ed                	beqz	s1,80001a44 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001a64:	85a6                	mv	a1,s1
    80001a66:	00006517          	auipc	a0,0x6
    80001a6a:	8a250513          	addi	a0,a0,-1886 # 80007308 <states.0+0x38>
    80001a6e:	6a0030ef          	jal	ra,8000510e <printf>
      plic_complete(irq);
    80001a72:	8526                	mv	a0,s1
    80001a74:	505020ef          	jal	ra,80004778 <plic_complete>
    return 1;
    80001a78:	4505                	li	a0,1
    80001a7a:	b7e9                	j	80001a44 <devintr+0x24>
      uartintr();
    80001a7c:	39b030ef          	jal	ra,80005616 <uartintr>
    80001a80:	bfcd                	j	80001a72 <devintr+0x52>
      virtio_disk_intr();
    80001a82:	162030ef          	jal	ra,80004be4 <virtio_disk_intr>
    80001a86:	b7f5                	j	80001a72 <devintr+0x52>
    clockintr();
    80001a88:	f45ff0ef          	jal	ra,800019cc <clockintr>
    return 2;
    80001a8c:	4509                	li	a0,2
    80001a8e:	bf5d                	j	80001a44 <devintr+0x24>

0000000080001a90 <usertrap>:
{
    80001a90:	1101                	addi	sp,sp,-32
    80001a92:	ec06                	sd	ra,24(sp)
    80001a94:	e822                	sd	s0,16(sp)
    80001a96:	e426                	sd	s1,8(sp)
    80001a98:	e04a                	sd	s2,0(sp)
    80001a9a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a9c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001aa0:	1007f793          	andi	a5,a5,256
    80001aa4:	ef85                	bnez	a5,80001adc <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001aa6:	00003797          	auipc	a5,0x3
    80001aaa:	c0a78793          	addi	a5,a5,-1014 # 800046b0 <kernelvec>
    80001aae:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001ab2:	b82ff0ef          	jal	ra,80000e34 <myproc>
    80001ab6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001ab8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001aba:	14102773          	csrr	a4,sepc
    80001abe:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ac0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001ac4:	47a1                	li	a5,8
    80001ac6:	02f70163          	beq	a4,a5,80001ae8 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001aca:	f57ff0ef          	jal	ra,80001a20 <devintr>
    80001ace:	892a                	mv	s2,a0
    80001ad0:	c135                	beqz	a0,80001b34 <usertrap+0xa4>
  if(killed(p))
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	b65ff0ef          	jal	ra,80001638 <killed>
    80001ad8:	cd1d                	beqz	a0,80001b16 <usertrap+0x86>
    80001ada:	a81d                	j	80001b10 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001adc:	00006517          	auipc	a0,0x6
    80001ae0:	84c50513          	addi	a0,a0,-1972 # 80007328 <states.0+0x58>
    80001ae4:	0df030ef          	jal	ra,800053c2 <panic>
    if(killed(p))
    80001ae8:	b51ff0ef          	jal	ra,80001638 <killed>
    80001aec:	e121                	bnez	a0,80001b2c <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001aee:	6cb8                	ld	a4,88(s1)
    80001af0:	6f1c                	ld	a5,24(a4)
    80001af2:	0791                	addi	a5,a5,4
    80001af4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001af6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001afa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001afe:	10079073          	csrw	sstatus,a5
    syscall();
    80001b02:	248000ef          	jal	ra,80001d4a <syscall>
  if(killed(p))
    80001b06:	8526                	mv	a0,s1
    80001b08:	b31ff0ef          	jal	ra,80001638 <killed>
    80001b0c:	c901                	beqz	a0,80001b1c <usertrap+0x8c>
    80001b0e:	4901                	li	s2,0
    exit(-1);
    80001b10:	557d                	li	a0,-1
    80001b12:	9fbff0ef          	jal	ra,8000150c <exit>
  if(which_dev == 2)
    80001b16:	4789                	li	a5,2
    80001b18:	04f90563          	beq	s2,a5,80001b62 <usertrap+0xd2>
  usertrapret();
    80001b1c:	e1fff0ef          	jal	ra,8000193a <usertrapret>
}
    80001b20:	60e2                	ld	ra,24(sp)
    80001b22:	6442                	ld	s0,16(sp)
    80001b24:	64a2                	ld	s1,8(sp)
    80001b26:	6902                	ld	s2,0(sp)
    80001b28:	6105                	addi	sp,sp,32
    80001b2a:	8082                	ret
      exit(-1);
    80001b2c:	557d                	li	a0,-1
    80001b2e:	9dfff0ef          	jal	ra,8000150c <exit>
    80001b32:	bf75                	j	80001aee <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b34:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001b38:	5890                	lw	a2,48(s1)
    80001b3a:	00006517          	auipc	a0,0x6
    80001b3e:	80e50513          	addi	a0,a0,-2034 # 80007348 <states.0+0x78>
    80001b42:	5cc030ef          	jal	ra,8000510e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b46:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b4a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001b4e:	00006517          	auipc	a0,0x6
    80001b52:	82a50513          	addi	a0,a0,-2006 # 80007378 <states.0+0xa8>
    80001b56:	5b8030ef          	jal	ra,8000510e <printf>
    setkilled(p);
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	ab9ff0ef          	jal	ra,80001614 <setkilled>
    80001b60:	b75d                	j	80001b06 <usertrap+0x76>
    yield();
    80001b62:	873ff0ef          	jal	ra,800013d4 <yield>
    80001b66:	bf5d                	j	80001b1c <usertrap+0x8c>

0000000080001b68 <kerneltrap>:
{
    80001b68:	7179                	addi	sp,sp,-48
    80001b6a:	f406                	sd	ra,40(sp)
    80001b6c:	f022                	sd	s0,32(sp)
    80001b6e:	ec26                	sd	s1,24(sp)
    80001b70:	e84a                	sd	s2,16(sp)
    80001b72:	e44e                	sd	s3,8(sp)
    80001b74:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b76:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b7a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b7e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001b82:	1004f793          	andi	a5,s1,256
    80001b86:	c795                	beqz	a5,80001bb2 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b88:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001b8c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001b8e:	eb85                	bnez	a5,80001bbe <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001b90:	e91ff0ef          	jal	ra,80001a20 <devintr>
    80001b94:	c91d                	beqz	a0,80001bca <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001b96:	4789                	li	a5,2
    80001b98:	04f50a63          	beq	a0,a5,80001bec <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b9c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ba0:	10049073          	csrw	sstatus,s1
}
    80001ba4:	70a2                	ld	ra,40(sp)
    80001ba6:	7402                	ld	s0,32(sp)
    80001ba8:	64e2                	ld	s1,24(sp)
    80001baa:	6942                	ld	s2,16(sp)
    80001bac:	69a2                	ld	s3,8(sp)
    80001bae:	6145                	addi	sp,sp,48
    80001bb0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001bb2:	00005517          	auipc	a0,0x5
    80001bb6:	7ee50513          	addi	a0,a0,2030 # 800073a0 <states.0+0xd0>
    80001bba:	009030ef          	jal	ra,800053c2 <panic>
    panic("kerneltrap: interrupts enabled");
    80001bbe:	00006517          	auipc	a0,0x6
    80001bc2:	80a50513          	addi	a0,a0,-2038 # 800073c8 <states.0+0xf8>
    80001bc6:	7fc030ef          	jal	ra,800053c2 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bca:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bce:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001bd2:	85ce                	mv	a1,s3
    80001bd4:	00006517          	auipc	a0,0x6
    80001bd8:	81450513          	addi	a0,a0,-2028 # 800073e8 <states.0+0x118>
    80001bdc:	532030ef          	jal	ra,8000510e <printf>
    panic("kerneltrap");
    80001be0:	00006517          	auipc	a0,0x6
    80001be4:	83050513          	addi	a0,a0,-2000 # 80007410 <states.0+0x140>
    80001be8:	7da030ef          	jal	ra,800053c2 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001bec:	a48ff0ef          	jal	ra,80000e34 <myproc>
    80001bf0:	d555                	beqz	a0,80001b9c <kerneltrap+0x34>
    yield();
    80001bf2:	fe2ff0ef          	jal	ra,800013d4 <yield>
    80001bf6:	b75d                	j	80001b9c <kerneltrap+0x34>

0000000080001bf8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001bf8:	1101                	addi	sp,sp,-32
    80001bfa:	ec06                	sd	ra,24(sp)
    80001bfc:	e822                	sd	s0,16(sp)
    80001bfe:	e426                	sd	s1,8(sp)
    80001c00:	1000                	addi	s0,sp,32
    80001c02:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c04:	a30ff0ef          	jal	ra,80000e34 <myproc>
  switch (n) {
    80001c08:	4795                	li	a5,5
    80001c0a:	0497e163          	bltu	a5,s1,80001c4c <argraw+0x54>
    80001c0e:	048a                	slli	s1,s1,0x2
    80001c10:	00006717          	auipc	a4,0x6
    80001c14:	83870713          	addi	a4,a4,-1992 # 80007448 <states.0+0x178>
    80001c18:	94ba                	add	s1,s1,a4
    80001c1a:	409c                	lw	a5,0(s1)
    80001c1c:	97ba                	add	a5,a5,a4
    80001c1e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001c20:	6d3c                	ld	a5,88(a0)
    80001c22:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001c24:	60e2                	ld	ra,24(sp)
    80001c26:	6442                	ld	s0,16(sp)
    80001c28:	64a2                	ld	s1,8(sp)
    80001c2a:	6105                	addi	sp,sp,32
    80001c2c:	8082                	ret
    return p->trapframe->a1;
    80001c2e:	6d3c                	ld	a5,88(a0)
    80001c30:	7fa8                	ld	a0,120(a5)
    80001c32:	bfcd                	j	80001c24 <argraw+0x2c>
    return p->trapframe->a2;
    80001c34:	6d3c                	ld	a5,88(a0)
    80001c36:	63c8                	ld	a0,128(a5)
    80001c38:	b7f5                	j	80001c24 <argraw+0x2c>
    return p->trapframe->a3;
    80001c3a:	6d3c                	ld	a5,88(a0)
    80001c3c:	67c8                	ld	a0,136(a5)
    80001c3e:	b7dd                	j	80001c24 <argraw+0x2c>
    return p->trapframe->a4;
    80001c40:	6d3c                	ld	a5,88(a0)
    80001c42:	6bc8                	ld	a0,144(a5)
    80001c44:	b7c5                	j	80001c24 <argraw+0x2c>
    return p->trapframe->a5;
    80001c46:	6d3c                	ld	a5,88(a0)
    80001c48:	6fc8                	ld	a0,152(a5)
    80001c4a:	bfe9                	j	80001c24 <argraw+0x2c>
  panic("argraw");
    80001c4c:	00005517          	auipc	a0,0x5
    80001c50:	7d450513          	addi	a0,a0,2004 # 80007420 <states.0+0x150>
    80001c54:	76e030ef          	jal	ra,800053c2 <panic>

0000000080001c58 <fetchaddr>:
{
    80001c58:	1101                	addi	sp,sp,-32
    80001c5a:	ec06                	sd	ra,24(sp)
    80001c5c:	e822                	sd	s0,16(sp)
    80001c5e:	e426                	sd	s1,8(sp)
    80001c60:	e04a                	sd	s2,0(sp)
    80001c62:	1000                	addi	s0,sp,32
    80001c64:	84aa                	mv	s1,a0
    80001c66:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001c68:	9ccff0ef          	jal	ra,80000e34 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001c6c:	653c                	ld	a5,72(a0)
    80001c6e:	02f4f663          	bgeu	s1,a5,80001c9a <fetchaddr+0x42>
    80001c72:	00848713          	addi	a4,s1,8
    80001c76:	02e7e463          	bltu	a5,a4,80001c9e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001c7a:	46a1                	li	a3,8
    80001c7c:	8626                	mv	a2,s1
    80001c7e:	85ca                	mv	a1,s2
    80001c80:	6928                	ld	a0,80(a0)
    80001c82:	e15fe0ef          	jal	ra,80000a96 <copyin>
    80001c86:	00a03533          	snez	a0,a0
    80001c8a:	40a00533          	neg	a0,a0
}
    80001c8e:	60e2                	ld	ra,24(sp)
    80001c90:	6442                	ld	s0,16(sp)
    80001c92:	64a2                	ld	s1,8(sp)
    80001c94:	6902                	ld	s2,0(sp)
    80001c96:	6105                	addi	sp,sp,32
    80001c98:	8082                	ret
    return -1;
    80001c9a:	557d                	li	a0,-1
    80001c9c:	bfcd                	j	80001c8e <fetchaddr+0x36>
    80001c9e:	557d                	li	a0,-1
    80001ca0:	b7fd                	j	80001c8e <fetchaddr+0x36>

0000000080001ca2 <fetchstr>:
{
    80001ca2:	7179                	addi	sp,sp,-48
    80001ca4:	f406                	sd	ra,40(sp)
    80001ca6:	f022                	sd	s0,32(sp)
    80001ca8:	ec26                	sd	s1,24(sp)
    80001caa:	e84a                	sd	s2,16(sp)
    80001cac:	e44e                	sd	s3,8(sp)
    80001cae:	1800                	addi	s0,sp,48
    80001cb0:	892a                	mv	s2,a0
    80001cb2:	84ae                	mv	s1,a1
    80001cb4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001cb6:	97eff0ef          	jal	ra,80000e34 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001cba:	86ce                	mv	a3,s3
    80001cbc:	864a                	mv	a2,s2
    80001cbe:	85a6                	mv	a1,s1
    80001cc0:	6928                	ld	a0,80(a0)
    80001cc2:	e5bfe0ef          	jal	ra,80000b1c <copyinstr>
    80001cc6:	00054c63          	bltz	a0,80001cde <fetchstr+0x3c>
  return strlen(buf);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	dfafe0ef          	jal	ra,800002c6 <strlen>
}
    80001cd0:	70a2                	ld	ra,40(sp)
    80001cd2:	7402                	ld	s0,32(sp)
    80001cd4:	64e2                	ld	s1,24(sp)
    80001cd6:	6942                	ld	s2,16(sp)
    80001cd8:	69a2                	ld	s3,8(sp)
    80001cda:	6145                	addi	sp,sp,48
    80001cdc:	8082                	ret
    return -1;
    80001cde:	557d                	li	a0,-1
    80001ce0:	bfc5                	j	80001cd0 <fetchstr+0x2e>

0000000080001ce2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001ce2:	1101                	addi	sp,sp,-32
    80001ce4:	ec06                	sd	ra,24(sp)
    80001ce6:	e822                	sd	s0,16(sp)
    80001ce8:	e426                	sd	s1,8(sp)
    80001cea:	1000                	addi	s0,sp,32
    80001cec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001cee:	f0bff0ef          	jal	ra,80001bf8 <argraw>
    80001cf2:	c088                	sw	a0,0(s1)
}
    80001cf4:	60e2                	ld	ra,24(sp)
    80001cf6:	6442                	ld	s0,16(sp)
    80001cf8:	64a2                	ld	s1,8(sp)
    80001cfa:	6105                	addi	sp,sp,32
    80001cfc:	8082                	ret

0000000080001cfe <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001cfe:	1101                	addi	sp,sp,-32
    80001d00:	ec06                	sd	ra,24(sp)
    80001d02:	e822                	sd	s0,16(sp)
    80001d04:	e426                	sd	s1,8(sp)
    80001d06:	1000                	addi	s0,sp,32
    80001d08:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001d0a:	eefff0ef          	jal	ra,80001bf8 <argraw>
    80001d0e:	e088                	sd	a0,0(s1)
}
    80001d10:	60e2                	ld	ra,24(sp)
    80001d12:	6442                	ld	s0,16(sp)
    80001d14:	64a2                	ld	s1,8(sp)
    80001d16:	6105                	addi	sp,sp,32
    80001d18:	8082                	ret

0000000080001d1a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001d1a:	7179                	addi	sp,sp,-48
    80001d1c:	f406                	sd	ra,40(sp)
    80001d1e:	f022                	sd	s0,32(sp)
    80001d20:	ec26                	sd	s1,24(sp)
    80001d22:	e84a                	sd	s2,16(sp)
    80001d24:	1800                	addi	s0,sp,48
    80001d26:	84ae                	mv	s1,a1
    80001d28:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001d2a:	fd840593          	addi	a1,s0,-40
    80001d2e:	fd1ff0ef          	jal	ra,80001cfe <argaddr>
  return fetchstr(addr, buf, max);
    80001d32:	864a                	mv	a2,s2
    80001d34:	85a6                	mv	a1,s1
    80001d36:	fd843503          	ld	a0,-40(s0)
    80001d3a:	f69ff0ef          	jal	ra,80001ca2 <fetchstr>
}
    80001d3e:	70a2                	ld	ra,40(sp)
    80001d40:	7402                	ld	s0,32(sp)
    80001d42:	64e2                	ld	s1,24(sp)
    80001d44:	6942                	ld	s2,16(sp)
    80001d46:	6145                	addi	sp,sp,48
    80001d48:	8082                	ret

0000000080001d4a <syscall>:
#endif
};

void
syscall(void)
{
    80001d4a:	1101                	addi	sp,sp,-32
    80001d4c:	ec06                	sd	ra,24(sp)
    80001d4e:	e822                	sd	s0,16(sp)
    80001d50:	e426                	sd	s1,8(sp)
    80001d52:	e04a                	sd	s2,0(sp)
    80001d54:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001d56:	8deff0ef          	jal	ra,80000e34 <myproc>
    80001d5a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001d5c:	05853903          	ld	s2,88(a0)
    80001d60:	0a893783          	ld	a5,168(s2)
    80001d64:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001d68:	37fd                	addiw	a5,a5,-1
    80001d6a:	02100713          	li	a4,33
    80001d6e:	00f76f63          	bltu	a4,a5,80001d8c <syscall+0x42>
    80001d72:	00369713          	slli	a4,a3,0x3
    80001d76:	00005797          	auipc	a5,0x5
    80001d7a:	6ea78793          	addi	a5,a5,1770 # 80007460 <syscalls>
    80001d7e:	97ba                	add	a5,a5,a4
    80001d80:	639c                	ld	a5,0(a5)
    80001d82:	c789                	beqz	a5,80001d8c <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001d84:	9782                	jalr	a5
    80001d86:	06a93823          	sd	a0,112(s2)
    80001d8a:	a829                	j	80001da4 <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001d8c:	15848613          	addi	a2,s1,344
    80001d90:	588c                	lw	a1,48(s1)
    80001d92:	00005517          	auipc	a0,0x5
    80001d96:	69650513          	addi	a0,a0,1686 # 80007428 <states.0+0x158>
    80001d9a:	374030ef          	jal	ra,8000510e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001d9e:	6cbc                	ld	a5,88(s1)
    80001da0:	577d                	li	a4,-1
    80001da2:	fbb8                	sd	a4,112(a5)
  }
}
    80001da4:	60e2                	ld	ra,24(sp)
    80001da6:	6442                	ld	s0,16(sp)
    80001da8:	64a2                	ld	s1,8(sp)
    80001daa:	6902                	ld	s2,0(sp)
    80001dac:	6105                	addi	sp,sp,32
    80001dae:	8082                	ret

0000000080001db0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001db0:	1101                	addi	sp,sp,-32
    80001db2:	ec06                	sd	ra,24(sp)
    80001db4:	e822                	sd	s0,16(sp)
    80001db6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001db8:	fec40593          	addi	a1,s0,-20
    80001dbc:	4501                	li	a0,0
    80001dbe:	f25ff0ef          	jal	ra,80001ce2 <argint>
  exit(n);
    80001dc2:	fec42503          	lw	a0,-20(s0)
    80001dc6:	f46ff0ef          	jal	ra,8000150c <exit>
  return 0;  // not reached
}
    80001dca:	4501                	li	a0,0
    80001dcc:	60e2                	ld	ra,24(sp)
    80001dce:	6442                	ld	s0,16(sp)
    80001dd0:	6105                	addi	sp,sp,32
    80001dd2:	8082                	ret

0000000080001dd4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001dd4:	1141                	addi	sp,sp,-16
    80001dd6:	e406                	sd	ra,8(sp)
    80001dd8:	e022                	sd	s0,0(sp)
    80001dda:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001ddc:	858ff0ef          	jal	ra,80000e34 <myproc>
}
    80001de0:	5908                	lw	a0,48(a0)
    80001de2:	60a2                	ld	ra,8(sp)
    80001de4:	6402                	ld	s0,0(sp)
    80001de6:	0141                	addi	sp,sp,16
    80001de8:	8082                	ret

0000000080001dea <sys_fork>:

uint64
sys_fork(void)
{
    80001dea:	1141                	addi	sp,sp,-16
    80001dec:	e406                	sd	ra,8(sp)
    80001dee:	e022                	sd	s0,0(sp)
    80001df0:	0800                	addi	s0,sp,16
  return fork();
    80001df2:	b68ff0ef          	jal	ra,8000115a <fork>
}
    80001df6:	60a2                	ld	ra,8(sp)
    80001df8:	6402                	ld	s0,0(sp)
    80001dfa:	0141                	addi	sp,sp,16
    80001dfc:	8082                	ret

0000000080001dfe <sys_wait>:

uint64
sys_wait(void)
{
    80001dfe:	1101                	addi	sp,sp,-32
    80001e00:	ec06                	sd	ra,24(sp)
    80001e02:	e822                	sd	s0,16(sp)
    80001e04:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001e06:	fe840593          	addi	a1,s0,-24
    80001e0a:	4501                	li	a0,0
    80001e0c:	ef3ff0ef          	jal	ra,80001cfe <argaddr>
  return wait(p);
    80001e10:	fe843503          	ld	a0,-24(s0)
    80001e14:	84fff0ef          	jal	ra,80001662 <wait>
}
    80001e18:	60e2                	ld	ra,24(sp)
    80001e1a:	6442                	ld	s0,16(sp)
    80001e1c:	6105                	addi	sp,sp,32
    80001e1e:	8082                	ret

0000000080001e20 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001e20:	7179                	addi	sp,sp,-48
    80001e22:	f406                	sd	ra,40(sp)
    80001e24:	f022                	sd	s0,32(sp)
    80001e26:	ec26                	sd	s1,24(sp)
    80001e28:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001e2a:	fdc40593          	addi	a1,s0,-36
    80001e2e:	4501                	li	a0,0
    80001e30:	eb3ff0ef          	jal	ra,80001ce2 <argint>
  addr = myproc()->sz;
    80001e34:	800ff0ef          	jal	ra,80000e34 <myproc>
    80001e38:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001e3a:	fdc42503          	lw	a0,-36(s0)
    80001e3e:	accff0ef          	jal	ra,8000110a <growproc>
    80001e42:	00054863          	bltz	a0,80001e52 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001e46:	8526                	mv	a0,s1
    80001e48:	70a2                	ld	ra,40(sp)
    80001e4a:	7402                	ld	s0,32(sp)
    80001e4c:	64e2                	ld	s1,24(sp)
    80001e4e:	6145                	addi	sp,sp,48
    80001e50:	8082                	ret
    return -1;
    80001e52:	54fd                	li	s1,-1
    80001e54:	bfcd                	j	80001e46 <sys_sbrk+0x26>

0000000080001e56 <sys_sleep>:

uint64
sys_sleep(void)
{
    80001e56:	7139                	addi	sp,sp,-64
    80001e58:	fc06                	sd	ra,56(sp)
    80001e5a:	f822                	sd	s0,48(sp)
    80001e5c:	f426                	sd	s1,40(sp)
    80001e5e:	f04a                	sd	s2,32(sp)
    80001e60:	ec4e                	sd	s3,24(sp)
    80001e62:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001e64:	fcc40593          	addi	a1,s0,-52
    80001e68:	4501                	li	a0,0
    80001e6a:	e79ff0ef          	jal	ra,80001ce2 <argint>
  if(n < 0)
    80001e6e:	fcc42783          	lw	a5,-52(s0)
    80001e72:	0607c563          	bltz	a5,80001edc <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001e76:	0000c517          	auipc	a0,0xc
    80001e7a:	9aa50513          	addi	a0,a0,-1622 # 8000d820 <tickslock>
    80001e7e:	055030ef          	jal	ra,800056d2 <acquire>
  ticks0 = ticks;
    80001e82:	00006917          	auipc	s2,0x6
    80001e86:	b3692903          	lw	s2,-1226(s2) # 800079b8 <ticks>
  while(ticks - ticks0 < n){
    80001e8a:	fcc42783          	lw	a5,-52(s0)
    80001e8e:	cb8d                	beqz	a5,80001ec0 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001e90:	0000c997          	auipc	s3,0xc
    80001e94:	99098993          	addi	s3,s3,-1648 # 8000d820 <tickslock>
    80001e98:	00006497          	auipc	s1,0x6
    80001e9c:	b2048493          	addi	s1,s1,-1248 # 800079b8 <ticks>
    if(killed(myproc())){
    80001ea0:	f95fe0ef          	jal	ra,80000e34 <myproc>
    80001ea4:	f94ff0ef          	jal	ra,80001638 <killed>
    80001ea8:	ed0d                	bnez	a0,80001ee2 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001eaa:	85ce                	mv	a1,s3
    80001eac:	8526                	mv	a0,s1
    80001eae:	d52ff0ef          	jal	ra,80001400 <sleep>
  while(ticks - ticks0 < n){
    80001eb2:	409c                	lw	a5,0(s1)
    80001eb4:	412787bb          	subw	a5,a5,s2
    80001eb8:	fcc42703          	lw	a4,-52(s0)
    80001ebc:	fee7e2e3          	bltu	a5,a4,80001ea0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80001ec0:	0000c517          	auipc	a0,0xc
    80001ec4:	96050513          	addi	a0,a0,-1696 # 8000d820 <tickslock>
    80001ec8:	0a3030ef          	jal	ra,8000576a <release>
  return 0;
    80001ecc:	4501                	li	a0,0
}
    80001ece:	70e2                	ld	ra,56(sp)
    80001ed0:	7442                	ld	s0,48(sp)
    80001ed2:	74a2                	ld	s1,40(sp)
    80001ed4:	7902                	ld	s2,32(sp)
    80001ed6:	69e2                	ld	s3,24(sp)
    80001ed8:	6121                	addi	sp,sp,64
    80001eda:	8082                	ret
    n = 0;
    80001edc:	fc042623          	sw	zero,-52(s0)
    80001ee0:	bf59                	j	80001e76 <sys_sleep+0x20>
      release(&tickslock);
    80001ee2:	0000c517          	auipc	a0,0xc
    80001ee6:	93e50513          	addi	a0,a0,-1730 # 8000d820 <tickslock>
    80001eea:	081030ef          	jal	ra,8000576a <release>
      return -1;
    80001eee:	557d                	li	a0,-1
    80001ef0:	bff9                	j	80001ece <sys_sleep+0x78>

0000000080001ef2 <sys_pgpte>:


#ifdef LAB_PGTBL
int
sys_pgpte(void)
{
    80001ef2:	7179                	addi	sp,sp,-48
    80001ef4:	f406                	sd	ra,40(sp)
    80001ef6:	f022                	sd	s0,32(sp)
    80001ef8:	ec26                	sd	s1,24(sp)
    80001efa:	1800                	addi	s0,sp,48
  uint64 va;
  struct proc *p;

  p = myproc();
    80001efc:	f39fe0ef          	jal	ra,80000e34 <myproc>
    80001f00:	84aa                	mv	s1,a0
  argaddr(0, &va);
    80001f02:	fd840593          	addi	a1,s0,-40
    80001f06:	4501                	li	a0,0
    80001f08:	df7ff0ef          	jal	ra,80001cfe <argaddr>
  pte_t *pte = pgpte(p->pagetable, va);
    80001f0c:	fd843583          	ld	a1,-40(s0)
    80001f10:	68a8                	ld	a0,80(s1)
    80001f12:	daffe0ef          	jal	ra,80000cc0 <pgpte>
    80001f16:	87aa                	mv	a5,a0
  if(pte != 0) {
      return (uint64) *pte;
  }
  return 0;
    80001f18:	4501                	li	a0,0
  if(pte != 0) {
    80001f1a:	c391                	beqz	a5,80001f1e <sys_pgpte+0x2c>
      return (uint64) *pte;
    80001f1c:	4388                	lw	a0,0(a5)
}
    80001f1e:	70a2                	ld	ra,40(sp)
    80001f20:	7402                	ld	s0,32(sp)
    80001f22:	64e2                	ld	s1,24(sp)
    80001f24:	6145                	addi	sp,sp,48
    80001f26:	8082                	ret

0000000080001f28 <sys_kpgtbl>:
#endif

#ifdef LAB_PGTBL
int
sys_kpgtbl(void)
{
    80001f28:	1141                	addi	sp,sp,-16
    80001f2a:	e406                	sd	ra,8(sp)
    80001f2c:	e022                	sd	s0,0(sp)
    80001f2e:	0800                	addi	s0,sp,16
  struct proc *p;

  p = myproc();
    80001f30:	f05fe0ef          	jal	ra,80000e34 <myproc>
  vmprint(p->pagetable);
    80001f34:	6928                	ld	a0,80(a0)
    80001f36:	d5ffe0ef          	jal	ra,80000c94 <vmprint>
  return 0;
}
    80001f3a:	4501                	li	a0,0
    80001f3c:	60a2                	ld	ra,8(sp)
    80001f3e:	6402                	ld	s0,0(sp)
    80001f40:	0141                	addi	sp,sp,16
    80001f42:	8082                	ret

0000000080001f44 <sys_kill>:
#endif


uint64
sys_kill(void)
{
    80001f44:	1101                	addi	sp,sp,-32
    80001f46:	ec06                	sd	ra,24(sp)
    80001f48:	e822                	sd	s0,16(sp)
    80001f4a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001f4c:	fec40593          	addi	a1,s0,-20
    80001f50:	4501                	li	a0,0
    80001f52:	d91ff0ef          	jal	ra,80001ce2 <argint>
  return kill(pid);
    80001f56:	fec42503          	lw	a0,-20(s0)
    80001f5a:	e54ff0ef          	jal	ra,800015ae <kill>
}
    80001f5e:	60e2                	ld	ra,24(sp)
    80001f60:	6442                	ld	s0,16(sp)
    80001f62:	6105                	addi	sp,sp,32
    80001f64:	8082                	ret

0000000080001f66 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001f66:	1101                	addi	sp,sp,-32
    80001f68:	ec06                	sd	ra,24(sp)
    80001f6a:	e822                	sd	s0,16(sp)
    80001f6c:	e426                	sd	s1,8(sp)
    80001f6e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001f70:	0000c517          	auipc	a0,0xc
    80001f74:	8b050513          	addi	a0,a0,-1872 # 8000d820 <tickslock>
    80001f78:	75a030ef          	jal	ra,800056d2 <acquire>
  xticks = ticks;
    80001f7c:	00006497          	auipc	s1,0x6
    80001f80:	a3c4a483          	lw	s1,-1476(s1) # 800079b8 <ticks>
  release(&tickslock);
    80001f84:	0000c517          	auipc	a0,0xc
    80001f88:	89c50513          	addi	a0,a0,-1892 # 8000d820 <tickslock>
    80001f8c:	7de030ef          	jal	ra,8000576a <release>
  return xticks;
}
    80001f90:	02049513          	slli	a0,s1,0x20
    80001f94:	9101                	srli	a0,a0,0x20
    80001f96:	60e2                	ld	ra,24(sp)
    80001f98:	6442                	ld	s0,16(sp)
    80001f9a:	64a2                	ld	s1,8(sp)
    80001f9c:	6105                	addi	sp,sp,32
    80001f9e:	8082                	ret

0000000080001fa0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80001fa0:	7179                	addi	sp,sp,-48
    80001fa2:	f406                	sd	ra,40(sp)
    80001fa4:	f022                	sd	s0,32(sp)
    80001fa6:	ec26                	sd	s1,24(sp)
    80001fa8:	e84a                	sd	s2,16(sp)
    80001faa:	e44e                	sd	s3,8(sp)
    80001fac:	e052                	sd	s4,0(sp)
    80001fae:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80001fb0:	00005597          	auipc	a1,0x5
    80001fb4:	5c858593          	addi	a1,a1,1480 # 80007578 <syscalls+0x118>
    80001fb8:	0000c517          	auipc	a0,0xc
    80001fbc:	88050513          	addi	a0,a0,-1920 # 8000d838 <bcache>
    80001fc0:	692030ef          	jal	ra,80005652 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80001fc4:	00014797          	auipc	a5,0x14
    80001fc8:	87478793          	addi	a5,a5,-1932 # 80015838 <bcache+0x8000>
    80001fcc:	00014717          	auipc	a4,0x14
    80001fd0:	ad470713          	addi	a4,a4,-1324 # 80015aa0 <bcache+0x8268>
    80001fd4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80001fd8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001fdc:	0000c497          	auipc	s1,0xc
    80001fe0:	87448493          	addi	s1,s1,-1932 # 8000d850 <bcache+0x18>
    b->next = bcache.head.next;
    80001fe4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80001fe6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80001fe8:	00005a17          	auipc	s4,0x5
    80001fec:	598a0a13          	addi	s4,s4,1432 # 80007580 <syscalls+0x120>
    b->next = bcache.head.next;
    80001ff0:	2b893783          	ld	a5,696(s2)
    80001ff4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80001ff6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80001ffa:	85d2                	mv	a1,s4
    80001ffc:	01048513          	addi	a0,s1,16
    80002000:	228010ef          	jal	ra,80003228 <initsleeplock>
    bcache.head.next->prev = b;
    80002004:	2b893783          	ld	a5,696(s2)
    80002008:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000200a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000200e:	45848493          	addi	s1,s1,1112
    80002012:	fd349fe3          	bne	s1,s3,80001ff0 <binit+0x50>
  }
}
    80002016:	70a2                	ld	ra,40(sp)
    80002018:	7402                	ld	s0,32(sp)
    8000201a:	64e2                	ld	s1,24(sp)
    8000201c:	6942                	ld	s2,16(sp)
    8000201e:	69a2                	ld	s3,8(sp)
    80002020:	6a02                	ld	s4,0(sp)
    80002022:	6145                	addi	sp,sp,48
    80002024:	8082                	ret

0000000080002026 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002026:	7179                	addi	sp,sp,-48
    80002028:	f406                	sd	ra,40(sp)
    8000202a:	f022                	sd	s0,32(sp)
    8000202c:	ec26                	sd	s1,24(sp)
    8000202e:	e84a                	sd	s2,16(sp)
    80002030:	e44e                	sd	s3,8(sp)
    80002032:	1800                	addi	s0,sp,48
    80002034:	892a                	mv	s2,a0
    80002036:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002038:	0000c517          	auipc	a0,0xc
    8000203c:	80050513          	addi	a0,a0,-2048 # 8000d838 <bcache>
    80002040:	692030ef          	jal	ra,800056d2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002044:	00014497          	auipc	s1,0x14
    80002048:	aac4b483          	ld	s1,-1364(s1) # 80015af0 <bcache+0x82b8>
    8000204c:	00014797          	auipc	a5,0x14
    80002050:	a5478793          	addi	a5,a5,-1452 # 80015aa0 <bcache+0x8268>
    80002054:	02f48b63          	beq	s1,a5,8000208a <bread+0x64>
    80002058:	873e                	mv	a4,a5
    8000205a:	a021                	j	80002062 <bread+0x3c>
    8000205c:	68a4                	ld	s1,80(s1)
    8000205e:	02e48663          	beq	s1,a4,8000208a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002062:	449c                	lw	a5,8(s1)
    80002064:	ff279ce3          	bne	a5,s2,8000205c <bread+0x36>
    80002068:	44dc                	lw	a5,12(s1)
    8000206a:	ff3799e3          	bne	a5,s3,8000205c <bread+0x36>
      b->refcnt++;
    8000206e:	40bc                	lw	a5,64(s1)
    80002070:	2785                	addiw	a5,a5,1
    80002072:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002074:	0000b517          	auipc	a0,0xb
    80002078:	7c450513          	addi	a0,a0,1988 # 8000d838 <bcache>
    8000207c:	6ee030ef          	jal	ra,8000576a <release>
      acquiresleep(&b->lock);
    80002080:	01048513          	addi	a0,s1,16
    80002084:	1da010ef          	jal	ra,8000325e <acquiresleep>
      return b;
    80002088:	a889                	j	800020da <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000208a:	00014497          	auipc	s1,0x14
    8000208e:	a5e4b483          	ld	s1,-1442(s1) # 80015ae8 <bcache+0x82b0>
    80002092:	00014797          	auipc	a5,0x14
    80002096:	a0e78793          	addi	a5,a5,-1522 # 80015aa0 <bcache+0x8268>
    8000209a:	00f48863          	beq	s1,a5,800020aa <bread+0x84>
    8000209e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800020a0:	40bc                	lw	a5,64(s1)
    800020a2:	cb91                	beqz	a5,800020b6 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800020a4:	64a4                	ld	s1,72(s1)
    800020a6:	fee49de3          	bne	s1,a4,800020a0 <bread+0x7a>
  panic("bget: no buffers");
    800020aa:	00005517          	auipc	a0,0x5
    800020ae:	4de50513          	addi	a0,a0,1246 # 80007588 <syscalls+0x128>
    800020b2:	310030ef          	jal	ra,800053c2 <panic>
      b->dev = dev;
    800020b6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800020ba:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800020be:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800020c2:	4785                	li	a5,1
    800020c4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800020c6:	0000b517          	auipc	a0,0xb
    800020ca:	77250513          	addi	a0,a0,1906 # 8000d838 <bcache>
    800020ce:	69c030ef          	jal	ra,8000576a <release>
      acquiresleep(&b->lock);
    800020d2:	01048513          	addi	a0,s1,16
    800020d6:	188010ef          	jal	ra,8000325e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800020da:	409c                	lw	a5,0(s1)
    800020dc:	cb89                	beqz	a5,800020ee <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800020de:	8526                	mv	a0,s1
    800020e0:	70a2                	ld	ra,40(sp)
    800020e2:	7402                	ld	s0,32(sp)
    800020e4:	64e2                	ld	s1,24(sp)
    800020e6:	6942                	ld	s2,16(sp)
    800020e8:	69a2                	ld	s3,8(sp)
    800020ea:	6145                	addi	sp,sp,48
    800020ec:	8082                	ret
    virtio_disk_rw(b, 0);
    800020ee:	4581                	li	a1,0
    800020f0:	8526                	mv	a0,s1
    800020f2:	0d9020ef          	jal	ra,800049ca <virtio_disk_rw>
    b->valid = 1;
    800020f6:	4785                	li	a5,1
    800020f8:	c09c                	sw	a5,0(s1)
  return b;
    800020fa:	b7d5                	j	800020de <bread+0xb8>

00000000800020fc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800020fc:	1101                	addi	sp,sp,-32
    800020fe:	ec06                	sd	ra,24(sp)
    80002100:	e822                	sd	s0,16(sp)
    80002102:	e426                	sd	s1,8(sp)
    80002104:	1000                	addi	s0,sp,32
    80002106:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002108:	0541                	addi	a0,a0,16
    8000210a:	1d2010ef          	jal	ra,800032dc <holdingsleep>
    8000210e:	c911                	beqz	a0,80002122 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002110:	4585                	li	a1,1
    80002112:	8526                	mv	a0,s1
    80002114:	0b7020ef          	jal	ra,800049ca <virtio_disk_rw>
}
    80002118:	60e2                	ld	ra,24(sp)
    8000211a:	6442                	ld	s0,16(sp)
    8000211c:	64a2                	ld	s1,8(sp)
    8000211e:	6105                	addi	sp,sp,32
    80002120:	8082                	ret
    panic("bwrite");
    80002122:	00005517          	auipc	a0,0x5
    80002126:	47e50513          	addi	a0,a0,1150 # 800075a0 <syscalls+0x140>
    8000212a:	298030ef          	jal	ra,800053c2 <panic>

000000008000212e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000212e:	1101                	addi	sp,sp,-32
    80002130:	ec06                	sd	ra,24(sp)
    80002132:	e822                	sd	s0,16(sp)
    80002134:	e426                	sd	s1,8(sp)
    80002136:	e04a                	sd	s2,0(sp)
    80002138:	1000                	addi	s0,sp,32
    8000213a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000213c:	01050913          	addi	s2,a0,16
    80002140:	854a                	mv	a0,s2
    80002142:	19a010ef          	jal	ra,800032dc <holdingsleep>
    80002146:	c13d                	beqz	a0,800021ac <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002148:	854a                	mv	a0,s2
    8000214a:	15a010ef          	jal	ra,800032a4 <releasesleep>

  acquire(&bcache.lock);
    8000214e:	0000b517          	auipc	a0,0xb
    80002152:	6ea50513          	addi	a0,a0,1770 # 8000d838 <bcache>
    80002156:	57c030ef          	jal	ra,800056d2 <acquire>
  b->refcnt--;
    8000215a:	40bc                	lw	a5,64(s1)
    8000215c:	37fd                	addiw	a5,a5,-1
    8000215e:	0007871b          	sext.w	a4,a5
    80002162:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002164:	eb05                	bnez	a4,80002194 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002166:	68bc                	ld	a5,80(s1)
    80002168:	64b8                	ld	a4,72(s1)
    8000216a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000216c:	64bc                	ld	a5,72(s1)
    8000216e:	68b8                	ld	a4,80(s1)
    80002170:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002172:	00013797          	auipc	a5,0x13
    80002176:	6c678793          	addi	a5,a5,1734 # 80015838 <bcache+0x8000>
    8000217a:	2b87b703          	ld	a4,696(a5)
    8000217e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002180:	00014717          	auipc	a4,0x14
    80002184:	92070713          	addi	a4,a4,-1760 # 80015aa0 <bcache+0x8268>
    80002188:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000218a:	2b87b703          	ld	a4,696(a5)
    8000218e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002190:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002194:	0000b517          	auipc	a0,0xb
    80002198:	6a450513          	addi	a0,a0,1700 # 8000d838 <bcache>
    8000219c:	5ce030ef          	jal	ra,8000576a <release>
}
    800021a0:	60e2                	ld	ra,24(sp)
    800021a2:	6442                	ld	s0,16(sp)
    800021a4:	64a2                	ld	s1,8(sp)
    800021a6:	6902                	ld	s2,0(sp)
    800021a8:	6105                	addi	sp,sp,32
    800021aa:	8082                	ret
    panic("brelse");
    800021ac:	00005517          	auipc	a0,0x5
    800021b0:	3fc50513          	addi	a0,a0,1020 # 800075a8 <syscalls+0x148>
    800021b4:	20e030ef          	jal	ra,800053c2 <panic>

00000000800021b8 <bpin>:

void
bpin(struct buf *b) {
    800021b8:	1101                	addi	sp,sp,-32
    800021ba:	ec06                	sd	ra,24(sp)
    800021bc:	e822                	sd	s0,16(sp)
    800021be:	e426                	sd	s1,8(sp)
    800021c0:	1000                	addi	s0,sp,32
    800021c2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800021c4:	0000b517          	auipc	a0,0xb
    800021c8:	67450513          	addi	a0,a0,1652 # 8000d838 <bcache>
    800021cc:	506030ef          	jal	ra,800056d2 <acquire>
  b->refcnt++;
    800021d0:	40bc                	lw	a5,64(s1)
    800021d2:	2785                	addiw	a5,a5,1
    800021d4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800021d6:	0000b517          	auipc	a0,0xb
    800021da:	66250513          	addi	a0,a0,1634 # 8000d838 <bcache>
    800021de:	58c030ef          	jal	ra,8000576a <release>
}
    800021e2:	60e2                	ld	ra,24(sp)
    800021e4:	6442                	ld	s0,16(sp)
    800021e6:	64a2                	ld	s1,8(sp)
    800021e8:	6105                	addi	sp,sp,32
    800021ea:	8082                	ret

00000000800021ec <bunpin>:

void
bunpin(struct buf *b) {
    800021ec:	1101                	addi	sp,sp,-32
    800021ee:	ec06                	sd	ra,24(sp)
    800021f0:	e822                	sd	s0,16(sp)
    800021f2:	e426                	sd	s1,8(sp)
    800021f4:	1000                	addi	s0,sp,32
    800021f6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800021f8:	0000b517          	auipc	a0,0xb
    800021fc:	64050513          	addi	a0,a0,1600 # 8000d838 <bcache>
    80002200:	4d2030ef          	jal	ra,800056d2 <acquire>
  b->refcnt--;
    80002204:	40bc                	lw	a5,64(s1)
    80002206:	37fd                	addiw	a5,a5,-1
    80002208:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000220a:	0000b517          	auipc	a0,0xb
    8000220e:	62e50513          	addi	a0,a0,1582 # 8000d838 <bcache>
    80002212:	558030ef          	jal	ra,8000576a <release>
}
    80002216:	60e2                	ld	ra,24(sp)
    80002218:	6442                	ld	s0,16(sp)
    8000221a:	64a2                	ld	s1,8(sp)
    8000221c:	6105                	addi	sp,sp,32
    8000221e:	8082                	ret

0000000080002220 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002220:	1101                	addi	sp,sp,-32
    80002222:	ec06                	sd	ra,24(sp)
    80002224:	e822                	sd	s0,16(sp)
    80002226:	e426                	sd	s1,8(sp)
    80002228:	e04a                	sd	s2,0(sp)
    8000222a:	1000                	addi	s0,sp,32
    8000222c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000222e:	00d5d59b          	srliw	a1,a1,0xd
    80002232:	00014797          	auipc	a5,0x14
    80002236:	ce27a783          	lw	a5,-798(a5) # 80015f14 <sb+0x1c>
    8000223a:	9dbd                	addw	a1,a1,a5
    8000223c:	debff0ef          	jal	ra,80002026 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002240:	0074f713          	andi	a4,s1,7
    80002244:	4785                	li	a5,1
    80002246:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000224a:	14ce                	slli	s1,s1,0x33
    8000224c:	90d9                	srli	s1,s1,0x36
    8000224e:	00950733          	add	a4,a0,s1
    80002252:	05874703          	lbu	a4,88(a4)
    80002256:	00e7f6b3          	and	a3,a5,a4
    8000225a:	c29d                	beqz	a3,80002280 <bfree+0x60>
    8000225c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000225e:	94aa                	add	s1,s1,a0
    80002260:	fff7c793          	not	a5,a5
    80002264:	8f7d                	and	a4,a4,a5
    80002266:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000226a:	6ef000ef          	jal	ra,80003158 <log_write>
  brelse(bp);
    8000226e:	854a                	mv	a0,s2
    80002270:	ebfff0ef          	jal	ra,8000212e <brelse>
}
    80002274:	60e2                	ld	ra,24(sp)
    80002276:	6442                	ld	s0,16(sp)
    80002278:	64a2                	ld	s1,8(sp)
    8000227a:	6902                	ld	s2,0(sp)
    8000227c:	6105                	addi	sp,sp,32
    8000227e:	8082                	ret
    panic("freeing free block");
    80002280:	00005517          	auipc	a0,0x5
    80002284:	33050513          	addi	a0,a0,816 # 800075b0 <syscalls+0x150>
    80002288:	13a030ef          	jal	ra,800053c2 <panic>

000000008000228c <balloc>:
{
    8000228c:	711d                	addi	sp,sp,-96
    8000228e:	ec86                	sd	ra,88(sp)
    80002290:	e8a2                	sd	s0,80(sp)
    80002292:	e4a6                	sd	s1,72(sp)
    80002294:	e0ca                	sd	s2,64(sp)
    80002296:	fc4e                	sd	s3,56(sp)
    80002298:	f852                	sd	s4,48(sp)
    8000229a:	f456                	sd	s5,40(sp)
    8000229c:	f05a                	sd	s6,32(sp)
    8000229e:	ec5e                	sd	s7,24(sp)
    800022a0:	e862                	sd	s8,16(sp)
    800022a2:	e466                	sd	s9,8(sp)
    800022a4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800022a6:	00014797          	auipc	a5,0x14
    800022aa:	c567a783          	lw	a5,-938(a5) # 80015efc <sb+0x4>
    800022ae:	cff1                	beqz	a5,8000238a <balloc+0xfe>
    800022b0:	8baa                	mv	s7,a0
    800022b2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800022b4:	00014b17          	auipc	s6,0x14
    800022b8:	c44b0b13          	addi	s6,s6,-956 # 80015ef8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022bc:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800022be:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022c0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800022c2:	6c89                	lui	s9,0x2
    800022c4:	a0b5                	j	80002330 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    800022c6:	97ca                	add	a5,a5,s2
    800022c8:	8e55                	or	a2,a2,a3
    800022ca:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800022ce:	854a                	mv	a0,s2
    800022d0:	689000ef          	jal	ra,80003158 <log_write>
        brelse(bp);
    800022d4:	854a                	mv	a0,s2
    800022d6:	e59ff0ef          	jal	ra,8000212e <brelse>
  bp = bread(dev, bno);
    800022da:	85a6                	mv	a1,s1
    800022dc:	855e                	mv	a0,s7
    800022de:	d49ff0ef          	jal	ra,80002026 <bread>
    800022e2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800022e4:	40000613          	li	a2,1024
    800022e8:	4581                	li	a1,0
    800022ea:	05850513          	addi	a0,a0,88
    800022ee:	e61fd0ef          	jal	ra,8000014e <memset>
  log_write(bp);
    800022f2:	854a                	mv	a0,s2
    800022f4:	665000ef          	jal	ra,80003158 <log_write>
  brelse(bp);
    800022f8:	854a                	mv	a0,s2
    800022fa:	e35ff0ef          	jal	ra,8000212e <brelse>
}
    800022fe:	8526                	mv	a0,s1
    80002300:	60e6                	ld	ra,88(sp)
    80002302:	6446                	ld	s0,80(sp)
    80002304:	64a6                	ld	s1,72(sp)
    80002306:	6906                	ld	s2,64(sp)
    80002308:	79e2                	ld	s3,56(sp)
    8000230a:	7a42                	ld	s4,48(sp)
    8000230c:	7aa2                	ld	s5,40(sp)
    8000230e:	7b02                	ld	s6,32(sp)
    80002310:	6be2                	ld	s7,24(sp)
    80002312:	6c42                	ld	s8,16(sp)
    80002314:	6ca2                	ld	s9,8(sp)
    80002316:	6125                	addi	sp,sp,96
    80002318:	8082                	ret
    brelse(bp);
    8000231a:	854a                	mv	a0,s2
    8000231c:	e13ff0ef          	jal	ra,8000212e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002320:	015c87bb          	addw	a5,s9,s5
    80002324:	00078a9b          	sext.w	s5,a5
    80002328:	004b2703          	lw	a4,4(s6)
    8000232c:	04eaff63          	bgeu	s5,a4,8000238a <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80002330:	41fad79b          	sraiw	a5,s5,0x1f
    80002334:	0137d79b          	srliw	a5,a5,0x13
    80002338:	015787bb          	addw	a5,a5,s5
    8000233c:	40d7d79b          	sraiw	a5,a5,0xd
    80002340:	01cb2583          	lw	a1,28(s6)
    80002344:	9dbd                	addw	a1,a1,a5
    80002346:	855e                	mv	a0,s7
    80002348:	cdfff0ef          	jal	ra,80002026 <bread>
    8000234c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000234e:	004b2503          	lw	a0,4(s6)
    80002352:	000a849b          	sext.w	s1,s5
    80002356:	8762                	mv	a4,s8
    80002358:	fca4f1e3          	bgeu	s1,a0,8000231a <balloc+0x8e>
      m = 1 << (bi % 8);
    8000235c:	00777693          	andi	a3,a4,7
    80002360:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002364:	41f7579b          	sraiw	a5,a4,0x1f
    80002368:	01d7d79b          	srliw	a5,a5,0x1d
    8000236c:	9fb9                	addw	a5,a5,a4
    8000236e:	4037d79b          	sraiw	a5,a5,0x3
    80002372:	00f90633          	add	a2,s2,a5
    80002376:	05864603          	lbu	a2,88(a2)
    8000237a:	00c6f5b3          	and	a1,a3,a2
    8000237e:	d5a1                	beqz	a1,800022c6 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002380:	2705                	addiw	a4,a4,1
    80002382:	2485                	addiw	s1,s1,1
    80002384:	fd471ae3          	bne	a4,s4,80002358 <balloc+0xcc>
    80002388:	bf49                	j	8000231a <balloc+0x8e>
  printf("balloc: out of blocks\n");
    8000238a:	00005517          	auipc	a0,0x5
    8000238e:	23e50513          	addi	a0,a0,574 # 800075c8 <syscalls+0x168>
    80002392:	57d020ef          	jal	ra,8000510e <printf>
  return 0;
    80002396:	4481                	li	s1,0
    80002398:	b79d                	j	800022fe <balloc+0x72>

000000008000239a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000239a:	7179                	addi	sp,sp,-48
    8000239c:	f406                	sd	ra,40(sp)
    8000239e:	f022                	sd	s0,32(sp)
    800023a0:	ec26                	sd	s1,24(sp)
    800023a2:	e84a                	sd	s2,16(sp)
    800023a4:	e44e                	sd	s3,8(sp)
    800023a6:	e052                	sd	s4,0(sp)
    800023a8:	1800                	addi	s0,sp,48
    800023aa:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800023ac:	47ad                	li	a5,11
    800023ae:	02b7e663          	bltu	a5,a1,800023da <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    800023b2:	02059793          	slli	a5,a1,0x20
    800023b6:	01e7d593          	srli	a1,a5,0x1e
    800023ba:	00b504b3          	add	s1,a0,a1
    800023be:	0504a903          	lw	s2,80(s1)
    800023c2:	06091663          	bnez	s2,8000242e <bmap+0x94>
      addr = balloc(ip->dev);
    800023c6:	4108                	lw	a0,0(a0)
    800023c8:	ec5ff0ef          	jal	ra,8000228c <balloc>
    800023cc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800023d0:	04090f63          	beqz	s2,8000242e <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    800023d4:	0524a823          	sw	s2,80(s1)
    800023d8:	a899                	j	8000242e <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    800023da:	ff45849b          	addiw	s1,a1,-12
    800023de:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800023e2:	0ff00793          	li	a5,255
    800023e6:	06e7eb63          	bltu	a5,a4,8000245c <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800023ea:	08052903          	lw	s2,128(a0)
    800023ee:	00091b63          	bnez	s2,80002404 <bmap+0x6a>
      addr = balloc(ip->dev);
    800023f2:	4108                	lw	a0,0(a0)
    800023f4:	e99ff0ef          	jal	ra,8000228c <balloc>
    800023f8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800023fc:	02090963          	beqz	s2,8000242e <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002400:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002404:	85ca                	mv	a1,s2
    80002406:	0009a503          	lw	a0,0(s3)
    8000240a:	c1dff0ef          	jal	ra,80002026 <bread>
    8000240e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002410:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002414:	02049713          	slli	a4,s1,0x20
    80002418:	01e75593          	srli	a1,a4,0x1e
    8000241c:	00b784b3          	add	s1,a5,a1
    80002420:	0004a903          	lw	s2,0(s1)
    80002424:	00090e63          	beqz	s2,80002440 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002428:	8552                	mv	a0,s4
    8000242a:	d05ff0ef          	jal	ra,8000212e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000242e:	854a                	mv	a0,s2
    80002430:	70a2                	ld	ra,40(sp)
    80002432:	7402                	ld	s0,32(sp)
    80002434:	64e2                	ld	s1,24(sp)
    80002436:	6942                	ld	s2,16(sp)
    80002438:	69a2                	ld	s3,8(sp)
    8000243a:	6a02                	ld	s4,0(sp)
    8000243c:	6145                	addi	sp,sp,48
    8000243e:	8082                	ret
      addr = balloc(ip->dev);
    80002440:	0009a503          	lw	a0,0(s3)
    80002444:	e49ff0ef          	jal	ra,8000228c <balloc>
    80002448:	0005091b          	sext.w	s2,a0
      if(addr){
    8000244c:	fc090ee3          	beqz	s2,80002428 <bmap+0x8e>
        a[bn] = addr;
    80002450:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002454:	8552                	mv	a0,s4
    80002456:	503000ef          	jal	ra,80003158 <log_write>
    8000245a:	b7f9                	j	80002428 <bmap+0x8e>
  panic("bmap: out of range");
    8000245c:	00005517          	auipc	a0,0x5
    80002460:	18450513          	addi	a0,a0,388 # 800075e0 <syscalls+0x180>
    80002464:	75f020ef          	jal	ra,800053c2 <panic>

0000000080002468 <iget>:
{
    80002468:	7179                	addi	sp,sp,-48
    8000246a:	f406                	sd	ra,40(sp)
    8000246c:	f022                	sd	s0,32(sp)
    8000246e:	ec26                	sd	s1,24(sp)
    80002470:	e84a                	sd	s2,16(sp)
    80002472:	e44e                	sd	s3,8(sp)
    80002474:	e052                	sd	s4,0(sp)
    80002476:	1800                	addi	s0,sp,48
    80002478:	89aa                	mv	s3,a0
    8000247a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000247c:	00014517          	auipc	a0,0x14
    80002480:	a9c50513          	addi	a0,a0,-1380 # 80015f18 <itable>
    80002484:	24e030ef          	jal	ra,800056d2 <acquire>
  empty = 0;
    80002488:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000248a:	00014497          	auipc	s1,0x14
    8000248e:	aa648493          	addi	s1,s1,-1370 # 80015f30 <itable+0x18>
    80002492:	00015697          	auipc	a3,0x15
    80002496:	52e68693          	addi	a3,a3,1326 # 800179c0 <log>
    8000249a:	a039                	j	800024a8 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000249c:	02090963          	beqz	s2,800024ce <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800024a0:	08848493          	addi	s1,s1,136
    800024a4:	02d48863          	beq	s1,a3,800024d4 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800024a8:	449c                	lw	a5,8(s1)
    800024aa:	fef059e3          	blez	a5,8000249c <iget+0x34>
    800024ae:	4098                	lw	a4,0(s1)
    800024b0:	ff3716e3          	bne	a4,s3,8000249c <iget+0x34>
    800024b4:	40d8                	lw	a4,4(s1)
    800024b6:	ff4713e3          	bne	a4,s4,8000249c <iget+0x34>
      ip->ref++;
    800024ba:	2785                	addiw	a5,a5,1
    800024bc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800024be:	00014517          	auipc	a0,0x14
    800024c2:	a5a50513          	addi	a0,a0,-1446 # 80015f18 <itable>
    800024c6:	2a4030ef          	jal	ra,8000576a <release>
      return ip;
    800024ca:	8926                	mv	s2,s1
    800024cc:	a02d                	j	800024f6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800024ce:	fbe9                	bnez	a5,800024a0 <iget+0x38>
    800024d0:	8926                	mv	s2,s1
    800024d2:	b7f9                	j	800024a0 <iget+0x38>
  if(empty == 0)
    800024d4:	02090a63          	beqz	s2,80002508 <iget+0xa0>
  ip->dev = dev;
    800024d8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800024dc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800024e0:	4785                	li	a5,1
    800024e2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800024e6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800024ea:	00014517          	auipc	a0,0x14
    800024ee:	a2e50513          	addi	a0,a0,-1490 # 80015f18 <itable>
    800024f2:	278030ef          	jal	ra,8000576a <release>
}
    800024f6:	854a                	mv	a0,s2
    800024f8:	70a2                	ld	ra,40(sp)
    800024fa:	7402                	ld	s0,32(sp)
    800024fc:	64e2                	ld	s1,24(sp)
    800024fe:	6942                	ld	s2,16(sp)
    80002500:	69a2                	ld	s3,8(sp)
    80002502:	6a02                	ld	s4,0(sp)
    80002504:	6145                	addi	sp,sp,48
    80002506:	8082                	ret
    panic("iget: no inodes");
    80002508:	00005517          	auipc	a0,0x5
    8000250c:	0f050513          	addi	a0,a0,240 # 800075f8 <syscalls+0x198>
    80002510:	6b3020ef          	jal	ra,800053c2 <panic>

0000000080002514 <fsinit>:
fsinit(int dev) {
    80002514:	7179                	addi	sp,sp,-48
    80002516:	f406                	sd	ra,40(sp)
    80002518:	f022                	sd	s0,32(sp)
    8000251a:	ec26                	sd	s1,24(sp)
    8000251c:	e84a                	sd	s2,16(sp)
    8000251e:	e44e                	sd	s3,8(sp)
    80002520:	1800                	addi	s0,sp,48
    80002522:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002524:	4585                	li	a1,1
    80002526:	b01ff0ef          	jal	ra,80002026 <bread>
    8000252a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000252c:	00014997          	auipc	s3,0x14
    80002530:	9cc98993          	addi	s3,s3,-1588 # 80015ef8 <sb>
    80002534:	02000613          	li	a2,32
    80002538:	05850593          	addi	a1,a0,88
    8000253c:	854e                	mv	a0,s3
    8000253e:	c6dfd0ef          	jal	ra,800001aa <memmove>
  brelse(bp);
    80002542:	8526                	mv	a0,s1
    80002544:	bebff0ef          	jal	ra,8000212e <brelse>
  if(sb.magic != FSMAGIC)
    80002548:	0009a703          	lw	a4,0(s3)
    8000254c:	102037b7          	lui	a5,0x10203
    80002550:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002554:	02f71063          	bne	a4,a5,80002574 <fsinit+0x60>
  initlog(dev, &sb);
    80002558:	00014597          	auipc	a1,0x14
    8000255c:	9a058593          	addi	a1,a1,-1632 # 80015ef8 <sb>
    80002560:	854a                	mv	a0,s2
    80002562:	1e3000ef          	jal	ra,80002f44 <initlog>
}
    80002566:	70a2                	ld	ra,40(sp)
    80002568:	7402                	ld	s0,32(sp)
    8000256a:	64e2                	ld	s1,24(sp)
    8000256c:	6942                	ld	s2,16(sp)
    8000256e:	69a2                	ld	s3,8(sp)
    80002570:	6145                	addi	sp,sp,48
    80002572:	8082                	ret
    panic("invalid file system");
    80002574:	00005517          	auipc	a0,0x5
    80002578:	09450513          	addi	a0,a0,148 # 80007608 <syscalls+0x1a8>
    8000257c:	647020ef          	jal	ra,800053c2 <panic>

0000000080002580 <iinit>:
{
    80002580:	7179                	addi	sp,sp,-48
    80002582:	f406                	sd	ra,40(sp)
    80002584:	f022                	sd	s0,32(sp)
    80002586:	ec26                	sd	s1,24(sp)
    80002588:	e84a                	sd	s2,16(sp)
    8000258a:	e44e                	sd	s3,8(sp)
    8000258c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000258e:	00005597          	auipc	a1,0x5
    80002592:	09258593          	addi	a1,a1,146 # 80007620 <syscalls+0x1c0>
    80002596:	00014517          	auipc	a0,0x14
    8000259a:	98250513          	addi	a0,a0,-1662 # 80015f18 <itable>
    8000259e:	0b4030ef          	jal	ra,80005652 <initlock>
  for(i = 0; i < NINODE; i++) {
    800025a2:	00014497          	auipc	s1,0x14
    800025a6:	99e48493          	addi	s1,s1,-1634 # 80015f40 <itable+0x28>
    800025aa:	00015997          	auipc	s3,0x15
    800025ae:	42698993          	addi	s3,s3,1062 # 800179d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800025b2:	00005917          	auipc	s2,0x5
    800025b6:	07690913          	addi	s2,s2,118 # 80007628 <syscalls+0x1c8>
    800025ba:	85ca                	mv	a1,s2
    800025bc:	8526                	mv	a0,s1
    800025be:	46b000ef          	jal	ra,80003228 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800025c2:	08848493          	addi	s1,s1,136
    800025c6:	ff349ae3          	bne	s1,s3,800025ba <iinit+0x3a>
}
    800025ca:	70a2                	ld	ra,40(sp)
    800025cc:	7402                	ld	s0,32(sp)
    800025ce:	64e2                	ld	s1,24(sp)
    800025d0:	6942                	ld	s2,16(sp)
    800025d2:	69a2                	ld	s3,8(sp)
    800025d4:	6145                	addi	sp,sp,48
    800025d6:	8082                	ret

00000000800025d8 <ialloc>:
{
    800025d8:	715d                	addi	sp,sp,-80
    800025da:	e486                	sd	ra,72(sp)
    800025dc:	e0a2                	sd	s0,64(sp)
    800025de:	fc26                	sd	s1,56(sp)
    800025e0:	f84a                	sd	s2,48(sp)
    800025e2:	f44e                	sd	s3,40(sp)
    800025e4:	f052                	sd	s4,32(sp)
    800025e6:	ec56                	sd	s5,24(sp)
    800025e8:	e85a                	sd	s6,16(sp)
    800025ea:	e45e                	sd	s7,8(sp)
    800025ec:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800025ee:	00014717          	auipc	a4,0x14
    800025f2:	91672703          	lw	a4,-1770(a4) # 80015f04 <sb+0xc>
    800025f6:	4785                	li	a5,1
    800025f8:	04e7f663          	bgeu	a5,a4,80002644 <ialloc+0x6c>
    800025fc:	8aaa                	mv	s5,a0
    800025fe:	8bae                	mv	s7,a1
    80002600:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002602:	00014a17          	auipc	s4,0x14
    80002606:	8f6a0a13          	addi	s4,s4,-1802 # 80015ef8 <sb>
    8000260a:	00048b1b          	sext.w	s6,s1
    8000260e:	0044d593          	srli	a1,s1,0x4
    80002612:	018a2783          	lw	a5,24(s4)
    80002616:	9dbd                	addw	a1,a1,a5
    80002618:	8556                	mv	a0,s5
    8000261a:	a0dff0ef          	jal	ra,80002026 <bread>
    8000261e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002620:	05850993          	addi	s3,a0,88
    80002624:	00f4f793          	andi	a5,s1,15
    80002628:	079a                	slli	a5,a5,0x6
    8000262a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000262c:	00099783          	lh	a5,0(s3)
    80002630:	cf85                	beqz	a5,80002668 <ialloc+0x90>
    brelse(bp);
    80002632:	afdff0ef          	jal	ra,8000212e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002636:	0485                	addi	s1,s1,1
    80002638:	00ca2703          	lw	a4,12(s4)
    8000263c:	0004879b          	sext.w	a5,s1
    80002640:	fce7e5e3          	bltu	a5,a4,8000260a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002644:	00005517          	auipc	a0,0x5
    80002648:	fec50513          	addi	a0,a0,-20 # 80007630 <syscalls+0x1d0>
    8000264c:	2c3020ef          	jal	ra,8000510e <printf>
  return 0;
    80002650:	4501                	li	a0,0
}
    80002652:	60a6                	ld	ra,72(sp)
    80002654:	6406                	ld	s0,64(sp)
    80002656:	74e2                	ld	s1,56(sp)
    80002658:	7942                	ld	s2,48(sp)
    8000265a:	79a2                	ld	s3,40(sp)
    8000265c:	7a02                	ld	s4,32(sp)
    8000265e:	6ae2                	ld	s5,24(sp)
    80002660:	6b42                	ld	s6,16(sp)
    80002662:	6ba2                	ld	s7,8(sp)
    80002664:	6161                	addi	sp,sp,80
    80002666:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002668:	04000613          	li	a2,64
    8000266c:	4581                	li	a1,0
    8000266e:	854e                	mv	a0,s3
    80002670:	adffd0ef          	jal	ra,8000014e <memset>
      dip->type = type;
    80002674:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002678:	854a                	mv	a0,s2
    8000267a:	2df000ef          	jal	ra,80003158 <log_write>
      brelse(bp);
    8000267e:	854a                	mv	a0,s2
    80002680:	aafff0ef          	jal	ra,8000212e <brelse>
      return iget(dev, inum);
    80002684:	85da                	mv	a1,s6
    80002686:	8556                	mv	a0,s5
    80002688:	de1ff0ef          	jal	ra,80002468 <iget>
    8000268c:	b7d9                	j	80002652 <ialloc+0x7a>

000000008000268e <iupdate>:
{
    8000268e:	1101                	addi	sp,sp,-32
    80002690:	ec06                	sd	ra,24(sp)
    80002692:	e822                	sd	s0,16(sp)
    80002694:	e426                	sd	s1,8(sp)
    80002696:	e04a                	sd	s2,0(sp)
    80002698:	1000                	addi	s0,sp,32
    8000269a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000269c:	415c                	lw	a5,4(a0)
    8000269e:	0047d79b          	srliw	a5,a5,0x4
    800026a2:	00014597          	auipc	a1,0x14
    800026a6:	86e5a583          	lw	a1,-1938(a1) # 80015f10 <sb+0x18>
    800026aa:	9dbd                	addw	a1,a1,a5
    800026ac:	4108                	lw	a0,0(a0)
    800026ae:	979ff0ef          	jal	ra,80002026 <bread>
    800026b2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800026b4:	05850793          	addi	a5,a0,88
    800026b8:	40d8                	lw	a4,4(s1)
    800026ba:	8b3d                	andi	a4,a4,15
    800026bc:	071a                	slli	a4,a4,0x6
    800026be:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800026c0:	04449703          	lh	a4,68(s1)
    800026c4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800026c8:	04649703          	lh	a4,70(s1)
    800026cc:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800026d0:	04849703          	lh	a4,72(s1)
    800026d4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800026d8:	04a49703          	lh	a4,74(s1)
    800026dc:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800026e0:	44f8                	lw	a4,76(s1)
    800026e2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800026e4:	03400613          	li	a2,52
    800026e8:	05048593          	addi	a1,s1,80
    800026ec:	00c78513          	addi	a0,a5,12
    800026f0:	abbfd0ef          	jal	ra,800001aa <memmove>
  log_write(bp);
    800026f4:	854a                	mv	a0,s2
    800026f6:	263000ef          	jal	ra,80003158 <log_write>
  brelse(bp);
    800026fa:	854a                	mv	a0,s2
    800026fc:	a33ff0ef          	jal	ra,8000212e <brelse>
}
    80002700:	60e2                	ld	ra,24(sp)
    80002702:	6442                	ld	s0,16(sp)
    80002704:	64a2                	ld	s1,8(sp)
    80002706:	6902                	ld	s2,0(sp)
    80002708:	6105                	addi	sp,sp,32
    8000270a:	8082                	ret

000000008000270c <idup>:
{
    8000270c:	1101                	addi	sp,sp,-32
    8000270e:	ec06                	sd	ra,24(sp)
    80002710:	e822                	sd	s0,16(sp)
    80002712:	e426                	sd	s1,8(sp)
    80002714:	1000                	addi	s0,sp,32
    80002716:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002718:	00014517          	auipc	a0,0x14
    8000271c:	80050513          	addi	a0,a0,-2048 # 80015f18 <itable>
    80002720:	7b3020ef          	jal	ra,800056d2 <acquire>
  ip->ref++;
    80002724:	449c                	lw	a5,8(s1)
    80002726:	2785                	addiw	a5,a5,1
    80002728:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000272a:	00013517          	auipc	a0,0x13
    8000272e:	7ee50513          	addi	a0,a0,2030 # 80015f18 <itable>
    80002732:	038030ef          	jal	ra,8000576a <release>
}
    80002736:	8526                	mv	a0,s1
    80002738:	60e2                	ld	ra,24(sp)
    8000273a:	6442                	ld	s0,16(sp)
    8000273c:	64a2                	ld	s1,8(sp)
    8000273e:	6105                	addi	sp,sp,32
    80002740:	8082                	ret

0000000080002742 <ilock>:
{
    80002742:	1101                	addi	sp,sp,-32
    80002744:	ec06                	sd	ra,24(sp)
    80002746:	e822                	sd	s0,16(sp)
    80002748:	e426                	sd	s1,8(sp)
    8000274a:	e04a                	sd	s2,0(sp)
    8000274c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000274e:	c105                	beqz	a0,8000276e <ilock+0x2c>
    80002750:	84aa                	mv	s1,a0
    80002752:	451c                	lw	a5,8(a0)
    80002754:	00f05d63          	blez	a5,8000276e <ilock+0x2c>
  acquiresleep(&ip->lock);
    80002758:	0541                	addi	a0,a0,16
    8000275a:	305000ef          	jal	ra,8000325e <acquiresleep>
  if(ip->valid == 0){
    8000275e:	40bc                	lw	a5,64(s1)
    80002760:	cf89                	beqz	a5,8000277a <ilock+0x38>
}
    80002762:	60e2                	ld	ra,24(sp)
    80002764:	6442                	ld	s0,16(sp)
    80002766:	64a2                	ld	s1,8(sp)
    80002768:	6902                	ld	s2,0(sp)
    8000276a:	6105                	addi	sp,sp,32
    8000276c:	8082                	ret
    panic("ilock");
    8000276e:	00005517          	auipc	a0,0x5
    80002772:	eda50513          	addi	a0,a0,-294 # 80007648 <syscalls+0x1e8>
    80002776:	44d020ef          	jal	ra,800053c2 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000277a:	40dc                	lw	a5,4(s1)
    8000277c:	0047d79b          	srliw	a5,a5,0x4
    80002780:	00013597          	auipc	a1,0x13
    80002784:	7905a583          	lw	a1,1936(a1) # 80015f10 <sb+0x18>
    80002788:	9dbd                	addw	a1,a1,a5
    8000278a:	4088                	lw	a0,0(s1)
    8000278c:	89bff0ef          	jal	ra,80002026 <bread>
    80002790:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002792:	05850593          	addi	a1,a0,88
    80002796:	40dc                	lw	a5,4(s1)
    80002798:	8bbd                	andi	a5,a5,15
    8000279a:	079a                	slli	a5,a5,0x6
    8000279c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000279e:	00059783          	lh	a5,0(a1)
    800027a2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800027a6:	00259783          	lh	a5,2(a1)
    800027aa:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800027ae:	00459783          	lh	a5,4(a1)
    800027b2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800027b6:	00659783          	lh	a5,6(a1)
    800027ba:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800027be:	459c                	lw	a5,8(a1)
    800027c0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800027c2:	03400613          	li	a2,52
    800027c6:	05b1                	addi	a1,a1,12
    800027c8:	05048513          	addi	a0,s1,80
    800027cc:	9dffd0ef          	jal	ra,800001aa <memmove>
    brelse(bp);
    800027d0:	854a                	mv	a0,s2
    800027d2:	95dff0ef          	jal	ra,8000212e <brelse>
    ip->valid = 1;
    800027d6:	4785                	li	a5,1
    800027d8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800027da:	04449783          	lh	a5,68(s1)
    800027de:	f3d1                	bnez	a5,80002762 <ilock+0x20>
      panic("ilock: no type");
    800027e0:	00005517          	auipc	a0,0x5
    800027e4:	e7050513          	addi	a0,a0,-400 # 80007650 <syscalls+0x1f0>
    800027e8:	3db020ef          	jal	ra,800053c2 <panic>

00000000800027ec <iunlock>:
{
    800027ec:	1101                	addi	sp,sp,-32
    800027ee:	ec06                	sd	ra,24(sp)
    800027f0:	e822                	sd	s0,16(sp)
    800027f2:	e426                	sd	s1,8(sp)
    800027f4:	e04a                	sd	s2,0(sp)
    800027f6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800027f8:	c505                	beqz	a0,80002820 <iunlock+0x34>
    800027fa:	84aa                	mv	s1,a0
    800027fc:	01050913          	addi	s2,a0,16
    80002800:	854a                	mv	a0,s2
    80002802:	2db000ef          	jal	ra,800032dc <holdingsleep>
    80002806:	cd09                	beqz	a0,80002820 <iunlock+0x34>
    80002808:	449c                	lw	a5,8(s1)
    8000280a:	00f05b63          	blez	a5,80002820 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000280e:	854a                	mv	a0,s2
    80002810:	295000ef          	jal	ra,800032a4 <releasesleep>
}
    80002814:	60e2                	ld	ra,24(sp)
    80002816:	6442                	ld	s0,16(sp)
    80002818:	64a2                	ld	s1,8(sp)
    8000281a:	6902                	ld	s2,0(sp)
    8000281c:	6105                	addi	sp,sp,32
    8000281e:	8082                	ret
    panic("iunlock");
    80002820:	00005517          	auipc	a0,0x5
    80002824:	e4050513          	addi	a0,a0,-448 # 80007660 <syscalls+0x200>
    80002828:	39b020ef          	jal	ra,800053c2 <panic>

000000008000282c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000282c:	7179                	addi	sp,sp,-48
    8000282e:	f406                	sd	ra,40(sp)
    80002830:	f022                	sd	s0,32(sp)
    80002832:	ec26                	sd	s1,24(sp)
    80002834:	e84a                	sd	s2,16(sp)
    80002836:	e44e                	sd	s3,8(sp)
    80002838:	e052                	sd	s4,0(sp)
    8000283a:	1800                	addi	s0,sp,48
    8000283c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000283e:	05050493          	addi	s1,a0,80
    80002842:	08050913          	addi	s2,a0,128
    80002846:	a021                	j	8000284e <itrunc+0x22>
    80002848:	0491                	addi	s1,s1,4
    8000284a:	01248b63          	beq	s1,s2,80002860 <itrunc+0x34>
    if(ip->addrs[i]){
    8000284e:	408c                	lw	a1,0(s1)
    80002850:	dde5                	beqz	a1,80002848 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002852:	0009a503          	lw	a0,0(s3)
    80002856:	9cbff0ef          	jal	ra,80002220 <bfree>
      ip->addrs[i] = 0;
    8000285a:	0004a023          	sw	zero,0(s1)
    8000285e:	b7ed                	j	80002848 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002860:	0809a583          	lw	a1,128(s3)
    80002864:	ed91                	bnez	a1,80002880 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002866:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000286a:	854e                	mv	a0,s3
    8000286c:	e23ff0ef          	jal	ra,8000268e <iupdate>
}
    80002870:	70a2                	ld	ra,40(sp)
    80002872:	7402                	ld	s0,32(sp)
    80002874:	64e2                	ld	s1,24(sp)
    80002876:	6942                	ld	s2,16(sp)
    80002878:	69a2                	ld	s3,8(sp)
    8000287a:	6a02                	ld	s4,0(sp)
    8000287c:	6145                	addi	sp,sp,48
    8000287e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002880:	0009a503          	lw	a0,0(s3)
    80002884:	fa2ff0ef          	jal	ra,80002026 <bread>
    80002888:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000288a:	05850493          	addi	s1,a0,88
    8000288e:	45850913          	addi	s2,a0,1112
    80002892:	a021                	j	8000289a <itrunc+0x6e>
    80002894:	0491                	addi	s1,s1,4
    80002896:	01248963          	beq	s1,s2,800028a8 <itrunc+0x7c>
      if(a[j])
    8000289a:	408c                	lw	a1,0(s1)
    8000289c:	dde5                	beqz	a1,80002894 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    8000289e:	0009a503          	lw	a0,0(s3)
    800028a2:	97fff0ef          	jal	ra,80002220 <bfree>
    800028a6:	b7fd                	j	80002894 <itrunc+0x68>
    brelse(bp);
    800028a8:	8552                	mv	a0,s4
    800028aa:	885ff0ef          	jal	ra,8000212e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800028ae:	0809a583          	lw	a1,128(s3)
    800028b2:	0009a503          	lw	a0,0(s3)
    800028b6:	96bff0ef          	jal	ra,80002220 <bfree>
    ip->addrs[NDIRECT] = 0;
    800028ba:	0809a023          	sw	zero,128(s3)
    800028be:	b765                	j	80002866 <itrunc+0x3a>

00000000800028c0 <iput>:
{
    800028c0:	1101                	addi	sp,sp,-32
    800028c2:	ec06                	sd	ra,24(sp)
    800028c4:	e822                	sd	s0,16(sp)
    800028c6:	e426                	sd	s1,8(sp)
    800028c8:	e04a                	sd	s2,0(sp)
    800028ca:	1000                	addi	s0,sp,32
    800028cc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800028ce:	00013517          	auipc	a0,0x13
    800028d2:	64a50513          	addi	a0,a0,1610 # 80015f18 <itable>
    800028d6:	5fd020ef          	jal	ra,800056d2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800028da:	4498                	lw	a4,8(s1)
    800028dc:	4785                	li	a5,1
    800028de:	02f70163          	beq	a4,a5,80002900 <iput+0x40>
  ip->ref--;
    800028e2:	449c                	lw	a5,8(s1)
    800028e4:	37fd                	addiw	a5,a5,-1
    800028e6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800028e8:	00013517          	auipc	a0,0x13
    800028ec:	63050513          	addi	a0,a0,1584 # 80015f18 <itable>
    800028f0:	67b020ef          	jal	ra,8000576a <release>
}
    800028f4:	60e2                	ld	ra,24(sp)
    800028f6:	6442                	ld	s0,16(sp)
    800028f8:	64a2                	ld	s1,8(sp)
    800028fa:	6902                	ld	s2,0(sp)
    800028fc:	6105                	addi	sp,sp,32
    800028fe:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002900:	40bc                	lw	a5,64(s1)
    80002902:	d3e5                	beqz	a5,800028e2 <iput+0x22>
    80002904:	04a49783          	lh	a5,74(s1)
    80002908:	ffe9                	bnez	a5,800028e2 <iput+0x22>
    acquiresleep(&ip->lock);
    8000290a:	01048913          	addi	s2,s1,16
    8000290e:	854a                	mv	a0,s2
    80002910:	14f000ef          	jal	ra,8000325e <acquiresleep>
    release(&itable.lock);
    80002914:	00013517          	auipc	a0,0x13
    80002918:	60450513          	addi	a0,a0,1540 # 80015f18 <itable>
    8000291c:	64f020ef          	jal	ra,8000576a <release>
    itrunc(ip);
    80002920:	8526                	mv	a0,s1
    80002922:	f0bff0ef          	jal	ra,8000282c <itrunc>
    ip->type = 0;
    80002926:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000292a:	8526                	mv	a0,s1
    8000292c:	d63ff0ef          	jal	ra,8000268e <iupdate>
    ip->valid = 0;
    80002930:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002934:	854a                	mv	a0,s2
    80002936:	16f000ef          	jal	ra,800032a4 <releasesleep>
    acquire(&itable.lock);
    8000293a:	00013517          	auipc	a0,0x13
    8000293e:	5de50513          	addi	a0,a0,1502 # 80015f18 <itable>
    80002942:	591020ef          	jal	ra,800056d2 <acquire>
    80002946:	bf71                	j	800028e2 <iput+0x22>

0000000080002948 <iunlockput>:
{
    80002948:	1101                	addi	sp,sp,-32
    8000294a:	ec06                	sd	ra,24(sp)
    8000294c:	e822                	sd	s0,16(sp)
    8000294e:	e426                	sd	s1,8(sp)
    80002950:	1000                	addi	s0,sp,32
    80002952:	84aa                	mv	s1,a0
  iunlock(ip);
    80002954:	e99ff0ef          	jal	ra,800027ec <iunlock>
  iput(ip);
    80002958:	8526                	mv	a0,s1
    8000295a:	f67ff0ef          	jal	ra,800028c0 <iput>
}
    8000295e:	60e2                	ld	ra,24(sp)
    80002960:	6442                	ld	s0,16(sp)
    80002962:	64a2                	ld	s1,8(sp)
    80002964:	6105                	addi	sp,sp,32
    80002966:	8082                	ret

0000000080002968 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002968:	1141                	addi	sp,sp,-16
    8000296a:	e422                	sd	s0,8(sp)
    8000296c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000296e:	411c                	lw	a5,0(a0)
    80002970:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002972:	415c                	lw	a5,4(a0)
    80002974:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002976:	04451783          	lh	a5,68(a0)
    8000297a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000297e:	04a51783          	lh	a5,74(a0)
    80002982:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002986:	04c56783          	lwu	a5,76(a0)
    8000298a:	e99c                	sd	a5,16(a1)
}
    8000298c:	6422                	ld	s0,8(sp)
    8000298e:	0141                	addi	sp,sp,16
    80002990:	8082                	ret

0000000080002992 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002992:	457c                	lw	a5,76(a0)
    80002994:	0cd7ef63          	bltu	a5,a3,80002a72 <readi+0xe0>
{
    80002998:	7159                	addi	sp,sp,-112
    8000299a:	f486                	sd	ra,104(sp)
    8000299c:	f0a2                	sd	s0,96(sp)
    8000299e:	eca6                	sd	s1,88(sp)
    800029a0:	e8ca                	sd	s2,80(sp)
    800029a2:	e4ce                	sd	s3,72(sp)
    800029a4:	e0d2                	sd	s4,64(sp)
    800029a6:	fc56                	sd	s5,56(sp)
    800029a8:	f85a                	sd	s6,48(sp)
    800029aa:	f45e                	sd	s7,40(sp)
    800029ac:	f062                	sd	s8,32(sp)
    800029ae:	ec66                	sd	s9,24(sp)
    800029b0:	e86a                	sd	s10,16(sp)
    800029b2:	e46e                	sd	s11,8(sp)
    800029b4:	1880                	addi	s0,sp,112
    800029b6:	8b2a                	mv	s6,a0
    800029b8:	8bae                	mv	s7,a1
    800029ba:	8a32                	mv	s4,a2
    800029bc:	84b6                	mv	s1,a3
    800029be:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800029c0:	9f35                	addw	a4,a4,a3
    return 0;
    800029c2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800029c4:	08d76663          	bltu	a4,a3,80002a50 <readi+0xbe>
  if(off + n > ip->size)
    800029c8:	00e7f463          	bgeu	a5,a4,800029d0 <readi+0x3e>
    n = ip->size - off;
    800029cc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800029d0:	080a8f63          	beqz	s5,80002a6e <readi+0xdc>
    800029d4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800029d6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800029da:	5c7d                	li	s8,-1
    800029dc:	a80d                	j	80002a0e <readi+0x7c>
    800029de:	020d1d93          	slli	s11,s10,0x20
    800029e2:	020ddd93          	srli	s11,s11,0x20
    800029e6:	05890613          	addi	a2,s2,88
    800029ea:	86ee                	mv	a3,s11
    800029ec:	963a                	add	a2,a2,a4
    800029ee:	85d2                	mv	a1,s4
    800029f0:	855e                	mv	a0,s7
    800029f2:	d6bfe0ef          	jal	ra,8000175c <either_copyout>
    800029f6:	05850763          	beq	a0,s8,80002a44 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800029fa:	854a                	mv	a0,s2
    800029fc:	f32ff0ef          	jal	ra,8000212e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a00:	013d09bb          	addw	s3,s10,s3
    80002a04:	009d04bb          	addw	s1,s10,s1
    80002a08:	9a6e                	add	s4,s4,s11
    80002a0a:	0559f163          	bgeu	s3,s5,80002a4c <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80002a0e:	00a4d59b          	srliw	a1,s1,0xa
    80002a12:	855a                	mv	a0,s6
    80002a14:	987ff0ef          	jal	ra,8000239a <bmap>
    80002a18:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002a1c:	c985                	beqz	a1,80002a4c <readi+0xba>
    bp = bread(ip->dev, addr);
    80002a1e:	000b2503          	lw	a0,0(s6)
    80002a22:	e04ff0ef          	jal	ra,80002026 <bread>
    80002a26:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a28:	3ff4f713          	andi	a4,s1,1023
    80002a2c:	40ec87bb          	subw	a5,s9,a4
    80002a30:	413a86bb          	subw	a3,s5,s3
    80002a34:	8d3e                	mv	s10,a5
    80002a36:	2781                	sext.w	a5,a5
    80002a38:	0006861b          	sext.w	a2,a3
    80002a3c:	faf671e3          	bgeu	a2,a5,800029de <readi+0x4c>
    80002a40:	8d36                	mv	s10,a3
    80002a42:	bf71                	j	800029de <readi+0x4c>
      brelse(bp);
    80002a44:	854a                	mv	a0,s2
    80002a46:	ee8ff0ef          	jal	ra,8000212e <brelse>
      tot = -1;
    80002a4a:	59fd                	li	s3,-1
  }
  return tot;
    80002a4c:	0009851b          	sext.w	a0,s3
}
    80002a50:	70a6                	ld	ra,104(sp)
    80002a52:	7406                	ld	s0,96(sp)
    80002a54:	64e6                	ld	s1,88(sp)
    80002a56:	6946                	ld	s2,80(sp)
    80002a58:	69a6                	ld	s3,72(sp)
    80002a5a:	6a06                	ld	s4,64(sp)
    80002a5c:	7ae2                	ld	s5,56(sp)
    80002a5e:	7b42                	ld	s6,48(sp)
    80002a60:	7ba2                	ld	s7,40(sp)
    80002a62:	7c02                	ld	s8,32(sp)
    80002a64:	6ce2                	ld	s9,24(sp)
    80002a66:	6d42                	ld	s10,16(sp)
    80002a68:	6da2                	ld	s11,8(sp)
    80002a6a:	6165                	addi	sp,sp,112
    80002a6c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a6e:	89d6                	mv	s3,s5
    80002a70:	bff1                	j	80002a4c <readi+0xba>
    return 0;
    80002a72:	4501                	li	a0,0
}
    80002a74:	8082                	ret

0000000080002a76 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002a76:	457c                	lw	a5,76(a0)
    80002a78:	0ed7ea63          	bltu	a5,a3,80002b6c <writei+0xf6>
{
    80002a7c:	7159                	addi	sp,sp,-112
    80002a7e:	f486                	sd	ra,104(sp)
    80002a80:	f0a2                	sd	s0,96(sp)
    80002a82:	eca6                	sd	s1,88(sp)
    80002a84:	e8ca                	sd	s2,80(sp)
    80002a86:	e4ce                	sd	s3,72(sp)
    80002a88:	e0d2                	sd	s4,64(sp)
    80002a8a:	fc56                	sd	s5,56(sp)
    80002a8c:	f85a                	sd	s6,48(sp)
    80002a8e:	f45e                	sd	s7,40(sp)
    80002a90:	f062                	sd	s8,32(sp)
    80002a92:	ec66                	sd	s9,24(sp)
    80002a94:	e86a                	sd	s10,16(sp)
    80002a96:	e46e                	sd	s11,8(sp)
    80002a98:	1880                	addi	s0,sp,112
    80002a9a:	8aaa                	mv	s5,a0
    80002a9c:	8bae                	mv	s7,a1
    80002a9e:	8a32                	mv	s4,a2
    80002aa0:	8936                	mv	s2,a3
    80002aa2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002aa4:	00e687bb          	addw	a5,a3,a4
    80002aa8:	0cd7e463          	bltu	a5,a3,80002b70 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002aac:	00043737          	lui	a4,0x43
    80002ab0:	0cf76263          	bltu	a4,a5,80002b74 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002ab4:	0a0b0a63          	beqz	s6,80002b68 <writei+0xf2>
    80002ab8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002aba:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002abe:	5c7d                	li	s8,-1
    80002ac0:	a825                	j	80002af8 <writei+0x82>
    80002ac2:	020d1d93          	slli	s11,s10,0x20
    80002ac6:	020ddd93          	srli	s11,s11,0x20
    80002aca:	05848513          	addi	a0,s1,88
    80002ace:	86ee                	mv	a3,s11
    80002ad0:	8652                	mv	a2,s4
    80002ad2:	85de                	mv	a1,s7
    80002ad4:	953a                	add	a0,a0,a4
    80002ad6:	cd1fe0ef          	jal	ra,800017a6 <either_copyin>
    80002ada:	05850a63          	beq	a0,s8,80002b2e <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002ade:	8526                	mv	a0,s1
    80002ae0:	678000ef          	jal	ra,80003158 <log_write>
    brelse(bp);
    80002ae4:	8526                	mv	a0,s1
    80002ae6:	e48ff0ef          	jal	ra,8000212e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002aea:	013d09bb          	addw	s3,s10,s3
    80002aee:	012d093b          	addw	s2,s10,s2
    80002af2:	9a6e                	add	s4,s4,s11
    80002af4:	0569f063          	bgeu	s3,s6,80002b34 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002af8:	00a9559b          	srliw	a1,s2,0xa
    80002afc:	8556                	mv	a0,s5
    80002afe:	89dff0ef          	jal	ra,8000239a <bmap>
    80002b02:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002b06:	c59d                	beqz	a1,80002b34 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002b08:	000aa503          	lw	a0,0(s5)
    80002b0c:	d1aff0ef          	jal	ra,80002026 <bread>
    80002b10:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b12:	3ff97713          	andi	a4,s2,1023
    80002b16:	40ec87bb          	subw	a5,s9,a4
    80002b1a:	413b06bb          	subw	a3,s6,s3
    80002b1e:	8d3e                	mv	s10,a5
    80002b20:	2781                	sext.w	a5,a5
    80002b22:	0006861b          	sext.w	a2,a3
    80002b26:	f8f67ee3          	bgeu	a2,a5,80002ac2 <writei+0x4c>
    80002b2a:	8d36                	mv	s10,a3
    80002b2c:	bf59                	j	80002ac2 <writei+0x4c>
      brelse(bp);
    80002b2e:	8526                	mv	a0,s1
    80002b30:	dfeff0ef          	jal	ra,8000212e <brelse>
  }

  if(off > ip->size)
    80002b34:	04caa783          	lw	a5,76(s5)
    80002b38:	0127f463          	bgeu	a5,s2,80002b40 <writei+0xca>
    ip->size = off;
    80002b3c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002b40:	8556                	mv	a0,s5
    80002b42:	b4dff0ef          	jal	ra,8000268e <iupdate>

  return tot;
    80002b46:	0009851b          	sext.w	a0,s3
}
    80002b4a:	70a6                	ld	ra,104(sp)
    80002b4c:	7406                	ld	s0,96(sp)
    80002b4e:	64e6                	ld	s1,88(sp)
    80002b50:	6946                	ld	s2,80(sp)
    80002b52:	69a6                	ld	s3,72(sp)
    80002b54:	6a06                	ld	s4,64(sp)
    80002b56:	7ae2                	ld	s5,56(sp)
    80002b58:	7b42                	ld	s6,48(sp)
    80002b5a:	7ba2                	ld	s7,40(sp)
    80002b5c:	7c02                	ld	s8,32(sp)
    80002b5e:	6ce2                	ld	s9,24(sp)
    80002b60:	6d42                	ld	s10,16(sp)
    80002b62:	6da2                	ld	s11,8(sp)
    80002b64:	6165                	addi	sp,sp,112
    80002b66:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b68:	89da                	mv	s3,s6
    80002b6a:	bfd9                	j	80002b40 <writei+0xca>
    return -1;
    80002b6c:	557d                	li	a0,-1
}
    80002b6e:	8082                	ret
    return -1;
    80002b70:	557d                	li	a0,-1
    80002b72:	bfe1                	j	80002b4a <writei+0xd4>
    return -1;
    80002b74:	557d                	li	a0,-1
    80002b76:	bfd1                	j	80002b4a <writei+0xd4>

0000000080002b78 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002b78:	1141                	addi	sp,sp,-16
    80002b7a:	e406                	sd	ra,8(sp)
    80002b7c:	e022                	sd	s0,0(sp)
    80002b7e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002b80:	4639                	li	a2,14
    80002b82:	e98fd0ef          	jal	ra,8000021a <strncmp>
}
    80002b86:	60a2                	ld	ra,8(sp)
    80002b88:	6402                	ld	s0,0(sp)
    80002b8a:	0141                	addi	sp,sp,16
    80002b8c:	8082                	ret

0000000080002b8e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002b8e:	7139                	addi	sp,sp,-64
    80002b90:	fc06                	sd	ra,56(sp)
    80002b92:	f822                	sd	s0,48(sp)
    80002b94:	f426                	sd	s1,40(sp)
    80002b96:	f04a                	sd	s2,32(sp)
    80002b98:	ec4e                	sd	s3,24(sp)
    80002b9a:	e852                	sd	s4,16(sp)
    80002b9c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002b9e:	04451703          	lh	a4,68(a0)
    80002ba2:	4785                	li	a5,1
    80002ba4:	00f71a63          	bne	a4,a5,80002bb8 <dirlookup+0x2a>
    80002ba8:	892a                	mv	s2,a0
    80002baa:	89ae                	mv	s3,a1
    80002bac:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002bae:	457c                	lw	a5,76(a0)
    80002bb0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002bb2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002bb4:	e39d                	bnez	a5,80002bda <dirlookup+0x4c>
    80002bb6:	a095                	j	80002c1a <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002bb8:	00005517          	auipc	a0,0x5
    80002bbc:	ab050513          	addi	a0,a0,-1360 # 80007668 <syscalls+0x208>
    80002bc0:	003020ef          	jal	ra,800053c2 <panic>
      panic("dirlookup read");
    80002bc4:	00005517          	auipc	a0,0x5
    80002bc8:	abc50513          	addi	a0,a0,-1348 # 80007680 <syscalls+0x220>
    80002bcc:	7f6020ef          	jal	ra,800053c2 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002bd0:	24c1                	addiw	s1,s1,16
    80002bd2:	04c92783          	lw	a5,76(s2)
    80002bd6:	04f4f163          	bgeu	s1,a5,80002c18 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002bda:	4741                	li	a4,16
    80002bdc:	86a6                	mv	a3,s1
    80002bde:	fc040613          	addi	a2,s0,-64
    80002be2:	4581                	li	a1,0
    80002be4:	854a                	mv	a0,s2
    80002be6:	dadff0ef          	jal	ra,80002992 <readi>
    80002bea:	47c1                	li	a5,16
    80002bec:	fcf51ce3          	bne	a0,a5,80002bc4 <dirlookup+0x36>
    if(de.inum == 0)
    80002bf0:	fc045783          	lhu	a5,-64(s0)
    80002bf4:	dff1                	beqz	a5,80002bd0 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002bf6:	fc240593          	addi	a1,s0,-62
    80002bfa:	854e                	mv	a0,s3
    80002bfc:	f7dff0ef          	jal	ra,80002b78 <namecmp>
    80002c00:	f961                	bnez	a0,80002bd0 <dirlookup+0x42>
      if(poff)
    80002c02:	000a0463          	beqz	s4,80002c0a <dirlookup+0x7c>
        *poff = off;
    80002c06:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002c0a:	fc045583          	lhu	a1,-64(s0)
    80002c0e:	00092503          	lw	a0,0(s2)
    80002c12:	857ff0ef          	jal	ra,80002468 <iget>
    80002c16:	a011                	j	80002c1a <dirlookup+0x8c>
  return 0;
    80002c18:	4501                	li	a0,0
}
    80002c1a:	70e2                	ld	ra,56(sp)
    80002c1c:	7442                	ld	s0,48(sp)
    80002c1e:	74a2                	ld	s1,40(sp)
    80002c20:	7902                	ld	s2,32(sp)
    80002c22:	69e2                	ld	s3,24(sp)
    80002c24:	6a42                	ld	s4,16(sp)
    80002c26:	6121                	addi	sp,sp,64
    80002c28:	8082                	ret

0000000080002c2a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002c2a:	711d                	addi	sp,sp,-96
    80002c2c:	ec86                	sd	ra,88(sp)
    80002c2e:	e8a2                	sd	s0,80(sp)
    80002c30:	e4a6                	sd	s1,72(sp)
    80002c32:	e0ca                	sd	s2,64(sp)
    80002c34:	fc4e                	sd	s3,56(sp)
    80002c36:	f852                	sd	s4,48(sp)
    80002c38:	f456                	sd	s5,40(sp)
    80002c3a:	f05a                	sd	s6,32(sp)
    80002c3c:	ec5e                	sd	s7,24(sp)
    80002c3e:	e862                	sd	s8,16(sp)
    80002c40:	e466                	sd	s9,8(sp)
    80002c42:	e06a                	sd	s10,0(sp)
    80002c44:	1080                	addi	s0,sp,96
    80002c46:	84aa                	mv	s1,a0
    80002c48:	8b2e                	mv	s6,a1
    80002c4a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002c4c:	00054703          	lbu	a4,0(a0)
    80002c50:	02f00793          	li	a5,47
    80002c54:	00f70f63          	beq	a4,a5,80002c72 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002c58:	9dcfe0ef          	jal	ra,80000e34 <myproc>
    80002c5c:	15053503          	ld	a0,336(a0)
    80002c60:	aadff0ef          	jal	ra,8000270c <idup>
    80002c64:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002c66:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002c6a:	4cb5                	li	s9,13
  len = path - s;
    80002c6c:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002c6e:	4c05                	li	s8,1
    80002c70:	a879                	j	80002d0e <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80002c72:	4585                	li	a1,1
    80002c74:	4505                	li	a0,1
    80002c76:	ff2ff0ef          	jal	ra,80002468 <iget>
    80002c7a:	8a2a                	mv	s4,a0
    80002c7c:	b7ed                	j	80002c66 <namex+0x3c>
      iunlockput(ip);
    80002c7e:	8552                	mv	a0,s4
    80002c80:	cc9ff0ef          	jal	ra,80002948 <iunlockput>
      return 0;
    80002c84:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002c86:	8552                	mv	a0,s4
    80002c88:	60e6                	ld	ra,88(sp)
    80002c8a:	6446                	ld	s0,80(sp)
    80002c8c:	64a6                	ld	s1,72(sp)
    80002c8e:	6906                	ld	s2,64(sp)
    80002c90:	79e2                	ld	s3,56(sp)
    80002c92:	7a42                	ld	s4,48(sp)
    80002c94:	7aa2                	ld	s5,40(sp)
    80002c96:	7b02                	ld	s6,32(sp)
    80002c98:	6be2                	ld	s7,24(sp)
    80002c9a:	6c42                	ld	s8,16(sp)
    80002c9c:	6ca2                	ld	s9,8(sp)
    80002c9e:	6d02                	ld	s10,0(sp)
    80002ca0:	6125                	addi	sp,sp,96
    80002ca2:	8082                	ret
      iunlock(ip);
    80002ca4:	8552                	mv	a0,s4
    80002ca6:	b47ff0ef          	jal	ra,800027ec <iunlock>
      return ip;
    80002caa:	bff1                	j	80002c86 <namex+0x5c>
      iunlockput(ip);
    80002cac:	8552                	mv	a0,s4
    80002cae:	c9bff0ef          	jal	ra,80002948 <iunlockput>
      return 0;
    80002cb2:	8a4e                	mv	s4,s3
    80002cb4:	bfc9                	j	80002c86 <namex+0x5c>
  len = path - s;
    80002cb6:	40998633          	sub	a2,s3,s1
    80002cba:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80002cbe:	09acd063          	bge	s9,s10,80002d3e <namex+0x114>
    memmove(name, s, DIRSIZ);
    80002cc2:	4639                	li	a2,14
    80002cc4:	85a6                	mv	a1,s1
    80002cc6:	8556                	mv	a0,s5
    80002cc8:	ce2fd0ef          	jal	ra,800001aa <memmove>
    80002ccc:	84ce                	mv	s1,s3
  while(*path == '/')
    80002cce:	0004c783          	lbu	a5,0(s1)
    80002cd2:	01279763          	bne	a5,s2,80002ce0 <namex+0xb6>
    path++;
    80002cd6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002cd8:	0004c783          	lbu	a5,0(s1)
    80002cdc:	ff278de3          	beq	a5,s2,80002cd6 <namex+0xac>
    ilock(ip);
    80002ce0:	8552                	mv	a0,s4
    80002ce2:	a61ff0ef          	jal	ra,80002742 <ilock>
    if(ip->type != T_DIR){
    80002ce6:	044a1783          	lh	a5,68(s4)
    80002cea:	f9879ae3          	bne	a5,s8,80002c7e <namex+0x54>
    if(nameiparent && *path == '\0'){
    80002cee:	000b0563          	beqz	s6,80002cf8 <namex+0xce>
    80002cf2:	0004c783          	lbu	a5,0(s1)
    80002cf6:	d7dd                	beqz	a5,80002ca4 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002cf8:	865e                	mv	a2,s7
    80002cfa:	85d6                	mv	a1,s5
    80002cfc:	8552                	mv	a0,s4
    80002cfe:	e91ff0ef          	jal	ra,80002b8e <dirlookup>
    80002d02:	89aa                	mv	s3,a0
    80002d04:	d545                	beqz	a0,80002cac <namex+0x82>
    iunlockput(ip);
    80002d06:	8552                	mv	a0,s4
    80002d08:	c41ff0ef          	jal	ra,80002948 <iunlockput>
    ip = next;
    80002d0c:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002d0e:	0004c783          	lbu	a5,0(s1)
    80002d12:	01279763          	bne	a5,s2,80002d20 <namex+0xf6>
    path++;
    80002d16:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002d18:	0004c783          	lbu	a5,0(s1)
    80002d1c:	ff278de3          	beq	a5,s2,80002d16 <namex+0xec>
  if(*path == 0)
    80002d20:	cb8d                	beqz	a5,80002d52 <namex+0x128>
  while(*path != '/' && *path != 0)
    80002d22:	0004c783          	lbu	a5,0(s1)
    80002d26:	89a6                	mv	s3,s1
  len = path - s;
    80002d28:	8d5e                	mv	s10,s7
    80002d2a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80002d2c:	01278963          	beq	a5,s2,80002d3e <namex+0x114>
    80002d30:	d3d9                	beqz	a5,80002cb6 <namex+0x8c>
    path++;
    80002d32:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002d34:	0009c783          	lbu	a5,0(s3)
    80002d38:	ff279ce3          	bne	a5,s2,80002d30 <namex+0x106>
    80002d3c:	bfad                	j	80002cb6 <namex+0x8c>
    memmove(name, s, len);
    80002d3e:	2601                	sext.w	a2,a2
    80002d40:	85a6                	mv	a1,s1
    80002d42:	8556                	mv	a0,s5
    80002d44:	c66fd0ef          	jal	ra,800001aa <memmove>
    name[len] = 0;
    80002d48:	9d56                	add	s10,s10,s5
    80002d4a:	000d0023          	sb	zero,0(s10)
    80002d4e:	84ce                	mv	s1,s3
    80002d50:	bfbd                	j	80002cce <namex+0xa4>
  if(nameiparent){
    80002d52:	f20b0ae3          	beqz	s6,80002c86 <namex+0x5c>
    iput(ip);
    80002d56:	8552                	mv	a0,s4
    80002d58:	b69ff0ef          	jal	ra,800028c0 <iput>
    return 0;
    80002d5c:	4a01                	li	s4,0
    80002d5e:	b725                	j	80002c86 <namex+0x5c>

0000000080002d60 <dirlink>:
{
    80002d60:	7139                	addi	sp,sp,-64
    80002d62:	fc06                	sd	ra,56(sp)
    80002d64:	f822                	sd	s0,48(sp)
    80002d66:	f426                	sd	s1,40(sp)
    80002d68:	f04a                	sd	s2,32(sp)
    80002d6a:	ec4e                	sd	s3,24(sp)
    80002d6c:	e852                	sd	s4,16(sp)
    80002d6e:	0080                	addi	s0,sp,64
    80002d70:	892a                	mv	s2,a0
    80002d72:	8a2e                	mv	s4,a1
    80002d74:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002d76:	4601                	li	a2,0
    80002d78:	e17ff0ef          	jal	ra,80002b8e <dirlookup>
    80002d7c:	e52d                	bnez	a0,80002de6 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d7e:	04c92483          	lw	s1,76(s2)
    80002d82:	c48d                	beqz	s1,80002dac <dirlink+0x4c>
    80002d84:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d86:	4741                	li	a4,16
    80002d88:	86a6                	mv	a3,s1
    80002d8a:	fc040613          	addi	a2,s0,-64
    80002d8e:	4581                	li	a1,0
    80002d90:	854a                	mv	a0,s2
    80002d92:	c01ff0ef          	jal	ra,80002992 <readi>
    80002d96:	47c1                	li	a5,16
    80002d98:	04f51b63          	bne	a0,a5,80002dee <dirlink+0x8e>
    if(de.inum == 0)
    80002d9c:	fc045783          	lhu	a5,-64(s0)
    80002da0:	c791                	beqz	a5,80002dac <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002da2:	24c1                	addiw	s1,s1,16
    80002da4:	04c92783          	lw	a5,76(s2)
    80002da8:	fcf4efe3          	bltu	s1,a5,80002d86 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002dac:	4639                	li	a2,14
    80002dae:	85d2                	mv	a1,s4
    80002db0:	fc240513          	addi	a0,s0,-62
    80002db4:	ca2fd0ef          	jal	ra,80000256 <strncpy>
  de.inum = inum;
    80002db8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002dbc:	4741                	li	a4,16
    80002dbe:	86a6                	mv	a3,s1
    80002dc0:	fc040613          	addi	a2,s0,-64
    80002dc4:	4581                	li	a1,0
    80002dc6:	854a                	mv	a0,s2
    80002dc8:	cafff0ef          	jal	ra,80002a76 <writei>
    80002dcc:	1541                	addi	a0,a0,-16
    80002dce:	00a03533          	snez	a0,a0
    80002dd2:	40a00533          	neg	a0,a0
}
    80002dd6:	70e2                	ld	ra,56(sp)
    80002dd8:	7442                	ld	s0,48(sp)
    80002dda:	74a2                	ld	s1,40(sp)
    80002ddc:	7902                	ld	s2,32(sp)
    80002dde:	69e2                	ld	s3,24(sp)
    80002de0:	6a42                	ld	s4,16(sp)
    80002de2:	6121                	addi	sp,sp,64
    80002de4:	8082                	ret
    iput(ip);
    80002de6:	adbff0ef          	jal	ra,800028c0 <iput>
    return -1;
    80002dea:	557d                	li	a0,-1
    80002dec:	b7ed                	j	80002dd6 <dirlink+0x76>
      panic("dirlink read");
    80002dee:	00005517          	auipc	a0,0x5
    80002df2:	8a250513          	addi	a0,a0,-1886 # 80007690 <syscalls+0x230>
    80002df6:	5cc020ef          	jal	ra,800053c2 <panic>

0000000080002dfa <namei>:

struct inode*
namei(char *path)
{
    80002dfa:	1101                	addi	sp,sp,-32
    80002dfc:	ec06                	sd	ra,24(sp)
    80002dfe:	e822                	sd	s0,16(sp)
    80002e00:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002e02:	fe040613          	addi	a2,s0,-32
    80002e06:	4581                	li	a1,0
    80002e08:	e23ff0ef          	jal	ra,80002c2a <namex>
}
    80002e0c:	60e2                	ld	ra,24(sp)
    80002e0e:	6442                	ld	s0,16(sp)
    80002e10:	6105                	addi	sp,sp,32
    80002e12:	8082                	ret

0000000080002e14 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002e14:	1141                	addi	sp,sp,-16
    80002e16:	e406                	sd	ra,8(sp)
    80002e18:	e022                	sd	s0,0(sp)
    80002e1a:	0800                	addi	s0,sp,16
    80002e1c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002e1e:	4585                	li	a1,1
    80002e20:	e0bff0ef          	jal	ra,80002c2a <namex>
}
    80002e24:	60a2                	ld	ra,8(sp)
    80002e26:	6402                	ld	s0,0(sp)
    80002e28:	0141                	addi	sp,sp,16
    80002e2a:	8082                	ret

0000000080002e2c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002e2c:	1101                	addi	sp,sp,-32
    80002e2e:	ec06                	sd	ra,24(sp)
    80002e30:	e822                	sd	s0,16(sp)
    80002e32:	e426                	sd	s1,8(sp)
    80002e34:	e04a                	sd	s2,0(sp)
    80002e36:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002e38:	00015917          	auipc	s2,0x15
    80002e3c:	b8890913          	addi	s2,s2,-1144 # 800179c0 <log>
    80002e40:	01892583          	lw	a1,24(s2)
    80002e44:	02892503          	lw	a0,40(s2)
    80002e48:	9deff0ef          	jal	ra,80002026 <bread>
    80002e4c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002e4e:	02c92683          	lw	a3,44(s2)
    80002e52:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002e54:	02d05863          	blez	a3,80002e84 <write_head+0x58>
    80002e58:	00015797          	auipc	a5,0x15
    80002e5c:	b9878793          	addi	a5,a5,-1128 # 800179f0 <log+0x30>
    80002e60:	05c50713          	addi	a4,a0,92
    80002e64:	36fd                	addiw	a3,a3,-1
    80002e66:	02069613          	slli	a2,a3,0x20
    80002e6a:	01e65693          	srli	a3,a2,0x1e
    80002e6e:	00015617          	auipc	a2,0x15
    80002e72:	b8660613          	addi	a2,a2,-1146 # 800179f4 <log+0x34>
    80002e76:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80002e78:	4390                	lw	a2,0(a5)
    80002e7a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002e7c:	0791                	addi	a5,a5,4
    80002e7e:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80002e80:	fed79ce3          	bne	a5,a3,80002e78 <write_head+0x4c>
  }
  bwrite(buf);
    80002e84:	8526                	mv	a0,s1
    80002e86:	a76ff0ef          	jal	ra,800020fc <bwrite>
  brelse(buf);
    80002e8a:	8526                	mv	a0,s1
    80002e8c:	aa2ff0ef          	jal	ra,8000212e <brelse>
}
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	64a2                	ld	s1,8(sp)
    80002e96:	6902                	ld	s2,0(sp)
    80002e98:	6105                	addi	sp,sp,32
    80002e9a:	8082                	ret

0000000080002e9c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002e9c:	00015797          	auipc	a5,0x15
    80002ea0:	b507a783          	lw	a5,-1200(a5) # 800179ec <log+0x2c>
    80002ea4:	08f05f63          	blez	a5,80002f42 <install_trans+0xa6>
{
    80002ea8:	7139                	addi	sp,sp,-64
    80002eaa:	fc06                	sd	ra,56(sp)
    80002eac:	f822                	sd	s0,48(sp)
    80002eae:	f426                	sd	s1,40(sp)
    80002eb0:	f04a                	sd	s2,32(sp)
    80002eb2:	ec4e                	sd	s3,24(sp)
    80002eb4:	e852                	sd	s4,16(sp)
    80002eb6:	e456                	sd	s5,8(sp)
    80002eb8:	e05a                	sd	s6,0(sp)
    80002eba:	0080                	addi	s0,sp,64
    80002ebc:	8b2a                	mv	s6,a0
    80002ebe:	00015a97          	auipc	s5,0x15
    80002ec2:	b32a8a93          	addi	s5,s5,-1230 # 800179f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002ec6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002ec8:	00015997          	auipc	s3,0x15
    80002ecc:	af898993          	addi	s3,s3,-1288 # 800179c0 <log>
    80002ed0:	a829                	j	80002eea <install_trans+0x4e>
    brelse(lbuf);
    80002ed2:	854a                	mv	a0,s2
    80002ed4:	a5aff0ef          	jal	ra,8000212e <brelse>
    brelse(dbuf);
    80002ed8:	8526                	mv	a0,s1
    80002eda:	a54ff0ef          	jal	ra,8000212e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002ede:	2a05                	addiw	s4,s4,1
    80002ee0:	0a91                	addi	s5,s5,4
    80002ee2:	02c9a783          	lw	a5,44(s3)
    80002ee6:	04fa5463          	bge	s4,a5,80002f2e <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002eea:	0189a583          	lw	a1,24(s3)
    80002eee:	014585bb          	addw	a1,a1,s4
    80002ef2:	2585                	addiw	a1,a1,1
    80002ef4:	0289a503          	lw	a0,40(s3)
    80002ef8:	92eff0ef          	jal	ra,80002026 <bread>
    80002efc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002efe:	000aa583          	lw	a1,0(s5)
    80002f02:	0289a503          	lw	a0,40(s3)
    80002f06:	920ff0ef          	jal	ra,80002026 <bread>
    80002f0a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002f0c:	40000613          	li	a2,1024
    80002f10:	05890593          	addi	a1,s2,88
    80002f14:	05850513          	addi	a0,a0,88
    80002f18:	a92fd0ef          	jal	ra,800001aa <memmove>
    bwrite(dbuf);  // write dst to disk
    80002f1c:	8526                	mv	a0,s1
    80002f1e:	9deff0ef          	jal	ra,800020fc <bwrite>
    if(recovering == 0)
    80002f22:	fa0b18e3          	bnez	s6,80002ed2 <install_trans+0x36>
      bunpin(dbuf);
    80002f26:	8526                	mv	a0,s1
    80002f28:	ac4ff0ef          	jal	ra,800021ec <bunpin>
    80002f2c:	b75d                	j	80002ed2 <install_trans+0x36>
}
    80002f2e:	70e2                	ld	ra,56(sp)
    80002f30:	7442                	ld	s0,48(sp)
    80002f32:	74a2                	ld	s1,40(sp)
    80002f34:	7902                	ld	s2,32(sp)
    80002f36:	69e2                	ld	s3,24(sp)
    80002f38:	6a42                	ld	s4,16(sp)
    80002f3a:	6aa2                	ld	s5,8(sp)
    80002f3c:	6b02                	ld	s6,0(sp)
    80002f3e:	6121                	addi	sp,sp,64
    80002f40:	8082                	ret
    80002f42:	8082                	ret

0000000080002f44 <initlog>:
{
    80002f44:	7179                	addi	sp,sp,-48
    80002f46:	f406                	sd	ra,40(sp)
    80002f48:	f022                	sd	s0,32(sp)
    80002f4a:	ec26                	sd	s1,24(sp)
    80002f4c:	e84a                	sd	s2,16(sp)
    80002f4e:	e44e                	sd	s3,8(sp)
    80002f50:	1800                	addi	s0,sp,48
    80002f52:	892a                	mv	s2,a0
    80002f54:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80002f56:	00015497          	auipc	s1,0x15
    80002f5a:	a6a48493          	addi	s1,s1,-1430 # 800179c0 <log>
    80002f5e:	00004597          	auipc	a1,0x4
    80002f62:	74258593          	addi	a1,a1,1858 # 800076a0 <syscalls+0x240>
    80002f66:	8526                	mv	a0,s1
    80002f68:	6ea020ef          	jal	ra,80005652 <initlock>
  log.start = sb->logstart;
    80002f6c:	0149a583          	lw	a1,20(s3)
    80002f70:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80002f72:	0109a783          	lw	a5,16(s3)
    80002f76:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80002f78:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80002f7c:	854a                	mv	a0,s2
    80002f7e:	8a8ff0ef          	jal	ra,80002026 <bread>
  log.lh.n = lh->n;
    80002f82:	4d34                	lw	a3,88(a0)
    80002f84:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80002f86:	02d05663          	blez	a3,80002fb2 <initlog+0x6e>
    80002f8a:	05c50793          	addi	a5,a0,92
    80002f8e:	00015717          	auipc	a4,0x15
    80002f92:	a6270713          	addi	a4,a4,-1438 # 800179f0 <log+0x30>
    80002f96:	36fd                	addiw	a3,a3,-1
    80002f98:	02069613          	slli	a2,a3,0x20
    80002f9c:	01e65693          	srli	a3,a2,0x1e
    80002fa0:	06050613          	addi	a2,a0,96
    80002fa4:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80002fa6:	4390                	lw	a2,0(a5)
    80002fa8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002faa:	0791                	addi	a5,a5,4
    80002fac:	0711                	addi	a4,a4,4
    80002fae:	fed79ce3          	bne	a5,a3,80002fa6 <initlog+0x62>
  brelse(buf);
    80002fb2:	97cff0ef          	jal	ra,8000212e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80002fb6:	4505                	li	a0,1
    80002fb8:	ee5ff0ef          	jal	ra,80002e9c <install_trans>
  log.lh.n = 0;
    80002fbc:	00015797          	auipc	a5,0x15
    80002fc0:	a207a823          	sw	zero,-1488(a5) # 800179ec <log+0x2c>
  write_head(); // clear the log
    80002fc4:	e69ff0ef          	jal	ra,80002e2c <write_head>
}
    80002fc8:	70a2                	ld	ra,40(sp)
    80002fca:	7402                	ld	s0,32(sp)
    80002fcc:	64e2                	ld	s1,24(sp)
    80002fce:	6942                	ld	s2,16(sp)
    80002fd0:	69a2                	ld	s3,8(sp)
    80002fd2:	6145                	addi	sp,sp,48
    80002fd4:	8082                	ret

0000000080002fd6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80002fd6:	1101                	addi	sp,sp,-32
    80002fd8:	ec06                	sd	ra,24(sp)
    80002fda:	e822                	sd	s0,16(sp)
    80002fdc:	e426                	sd	s1,8(sp)
    80002fde:	e04a                	sd	s2,0(sp)
    80002fe0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80002fe2:	00015517          	auipc	a0,0x15
    80002fe6:	9de50513          	addi	a0,a0,-1570 # 800179c0 <log>
    80002fea:	6e8020ef          	jal	ra,800056d2 <acquire>
  while(1){
    if(log.committing){
    80002fee:	00015497          	auipc	s1,0x15
    80002ff2:	9d248493          	addi	s1,s1,-1582 # 800179c0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002ff6:	4979                	li	s2,30
    80002ff8:	a029                	j	80003002 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80002ffa:	85a6                	mv	a1,s1
    80002ffc:	8526                	mv	a0,s1
    80002ffe:	c02fe0ef          	jal	ra,80001400 <sleep>
    if(log.committing){
    80003002:	50dc                	lw	a5,36(s1)
    80003004:	fbfd                	bnez	a5,80002ffa <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003006:	5098                	lw	a4,32(s1)
    80003008:	2705                	addiw	a4,a4,1
    8000300a:	0007069b          	sext.w	a3,a4
    8000300e:	0027179b          	slliw	a5,a4,0x2
    80003012:	9fb9                	addw	a5,a5,a4
    80003014:	0017979b          	slliw	a5,a5,0x1
    80003018:	54d8                	lw	a4,44(s1)
    8000301a:	9fb9                	addw	a5,a5,a4
    8000301c:	00f95763          	bge	s2,a5,8000302a <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003020:	85a6                	mv	a1,s1
    80003022:	8526                	mv	a0,s1
    80003024:	bdcfe0ef          	jal	ra,80001400 <sleep>
    80003028:	bfe9                	j	80003002 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000302a:	00015517          	auipc	a0,0x15
    8000302e:	99650513          	addi	a0,a0,-1642 # 800179c0 <log>
    80003032:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80003034:	736020ef          	jal	ra,8000576a <release>
      break;
    }
  }
}
    80003038:	60e2                	ld	ra,24(sp)
    8000303a:	6442                	ld	s0,16(sp)
    8000303c:	64a2                	ld	s1,8(sp)
    8000303e:	6902                	ld	s2,0(sp)
    80003040:	6105                	addi	sp,sp,32
    80003042:	8082                	ret

0000000080003044 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003044:	7139                	addi	sp,sp,-64
    80003046:	fc06                	sd	ra,56(sp)
    80003048:	f822                	sd	s0,48(sp)
    8000304a:	f426                	sd	s1,40(sp)
    8000304c:	f04a                	sd	s2,32(sp)
    8000304e:	ec4e                	sd	s3,24(sp)
    80003050:	e852                	sd	s4,16(sp)
    80003052:	e456                	sd	s5,8(sp)
    80003054:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003056:	00015497          	auipc	s1,0x15
    8000305a:	96a48493          	addi	s1,s1,-1686 # 800179c0 <log>
    8000305e:	8526                	mv	a0,s1
    80003060:	672020ef          	jal	ra,800056d2 <acquire>
  log.outstanding -= 1;
    80003064:	509c                	lw	a5,32(s1)
    80003066:	37fd                	addiw	a5,a5,-1
    80003068:	0007891b          	sext.w	s2,a5
    8000306c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000306e:	50dc                	lw	a5,36(s1)
    80003070:	ef9d                	bnez	a5,800030ae <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003072:	04091463          	bnez	s2,800030ba <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003076:	00015497          	auipc	s1,0x15
    8000307a:	94a48493          	addi	s1,s1,-1718 # 800179c0 <log>
    8000307e:	4785                	li	a5,1
    80003080:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003082:	8526                	mv	a0,s1
    80003084:	6e6020ef          	jal	ra,8000576a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003088:	54dc                	lw	a5,44(s1)
    8000308a:	04f04b63          	bgtz	a5,800030e0 <end_op+0x9c>
    acquire(&log.lock);
    8000308e:	00015497          	auipc	s1,0x15
    80003092:	93248493          	addi	s1,s1,-1742 # 800179c0 <log>
    80003096:	8526                	mv	a0,s1
    80003098:	63a020ef          	jal	ra,800056d2 <acquire>
    log.committing = 0;
    8000309c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800030a0:	8526                	mv	a0,s1
    800030a2:	baafe0ef          	jal	ra,8000144c <wakeup>
    release(&log.lock);
    800030a6:	8526                	mv	a0,s1
    800030a8:	6c2020ef          	jal	ra,8000576a <release>
}
    800030ac:	a00d                	j	800030ce <end_op+0x8a>
    panic("log.committing");
    800030ae:	00004517          	auipc	a0,0x4
    800030b2:	5fa50513          	addi	a0,a0,1530 # 800076a8 <syscalls+0x248>
    800030b6:	30c020ef          	jal	ra,800053c2 <panic>
    wakeup(&log);
    800030ba:	00015497          	auipc	s1,0x15
    800030be:	90648493          	addi	s1,s1,-1786 # 800179c0 <log>
    800030c2:	8526                	mv	a0,s1
    800030c4:	b88fe0ef          	jal	ra,8000144c <wakeup>
  release(&log.lock);
    800030c8:	8526                	mv	a0,s1
    800030ca:	6a0020ef          	jal	ra,8000576a <release>
}
    800030ce:	70e2                	ld	ra,56(sp)
    800030d0:	7442                	ld	s0,48(sp)
    800030d2:	74a2                	ld	s1,40(sp)
    800030d4:	7902                	ld	s2,32(sp)
    800030d6:	69e2                	ld	s3,24(sp)
    800030d8:	6a42                	ld	s4,16(sp)
    800030da:	6aa2                	ld	s5,8(sp)
    800030dc:	6121                	addi	sp,sp,64
    800030de:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800030e0:	00015a97          	auipc	s5,0x15
    800030e4:	910a8a93          	addi	s5,s5,-1776 # 800179f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800030e8:	00015a17          	auipc	s4,0x15
    800030ec:	8d8a0a13          	addi	s4,s4,-1832 # 800179c0 <log>
    800030f0:	018a2583          	lw	a1,24(s4)
    800030f4:	012585bb          	addw	a1,a1,s2
    800030f8:	2585                	addiw	a1,a1,1
    800030fa:	028a2503          	lw	a0,40(s4)
    800030fe:	f29fe0ef          	jal	ra,80002026 <bread>
    80003102:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003104:	000aa583          	lw	a1,0(s5)
    80003108:	028a2503          	lw	a0,40(s4)
    8000310c:	f1bfe0ef          	jal	ra,80002026 <bread>
    80003110:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003112:	40000613          	li	a2,1024
    80003116:	05850593          	addi	a1,a0,88
    8000311a:	05848513          	addi	a0,s1,88
    8000311e:	88cfd0ef          	jal	ra,800001aa <memmove>
    bwrite(to);  // write the log
    80003122:	8526                	mv	a0,s1
    80003124:	fd9fe0ef          	jal	ra,800020fc <bwrite>
    brelse(from);
    80003128:	854e                	mv	a0,s3
    8000312a:	804ff0ef          	jal	ra,8000212e <brelse>
    brelse(to);
    8000312e:	8526                	mv	a0,s1
    80003130:	ffffe0ef          	jal	ra,8000212e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003134:	2905                	addiw	s2,s2,1
    80003136:	0a91                	addi	s5,s5,4
    80003138:	02ca2783          	lw	a5,44(s4)
    8000313c:	faf94ae3          	blt	s2,a5,800030f0 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003140:	cedff0ef          	jal	ra,80002e2c <write_head>
    install_trans(0); // Now install writes to home locations
    80003144:	4501                	li	a0,0
    80003146:	d57ff0ef          	jal	ra,80002e9c <install_trans>
    log.lh.n = 0;
    8000314a:	00015797          	auipc	a5,0x15
    8000314e:	8a07a123          	sw	zero,-1886(a5) # 800179ec <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003152:	cdbff0ef          	jal	ra,80002e2c <write_head>
    80003156:	bf25                	j	8000308e <end_op+0x4a>

0000000080003158 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003158:	1101                	addi	sp,sp,-32
    8000315a:	ec06                	sd	ra,24(sp)
    8000315c:	e822                	sd	s0,16(sp)
    8000315e:	e426                	sd	s1,8(sp)
    80003160:	e04a                	sd	s2,0(sp)
    80003162:	1000                	addi	s0,sp,32
    80003164:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003166:	00015917          	auipc	s2,0x15
    8000316a:	85a90913          	addi	s2,s2,-1958 # 800179c0 <log>
    8000316e:	854a                	mv	a0,s2
    80003170:	562020ef          	jal	ra,800056d2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003174:	02c92603          	lw	a2,44(s2)
    80003178:	47f5                	li	a5,29
    8000317a:	06c7c363          	blt	a5,a2,800031e0 <log_write+0x88>
    8000317e:	00015797          	auipc	a5,0x15
    80003182:	85e7a783          	lw	a5,-1954(a5) # 800179dc <log+0x1c>
    80003186:	37fd                	addiw	a5,a5,-1
    80003188:	04f65c63          	bge	a2,a5,800031e0 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000318c:	00015797          	auipc	a5,0x15
    80003190:	8547a783          	lw	a5,-1964(a5) # 800179e0 <log+0x20>
    80003194:	04f05c63          	blez	a5,800031ec <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003198:	4781                	li	a5,0
    8000319a:	04c05f63          	blez	a2,800031f8 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000319e:	44cc                	lw	a1,12(s1)
    800031a0:	00015717          	auipc	a4,0x15
    800031a4:	85070713          	addi	a4,a4,-1968 # 800179f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800031a8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800031aa:	4314                	lw	a3,0(a4)
    800031ac:	04b68663          	beq	a3,a1,800031f8 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800031b0:	2785                	addiw	a5,a5,1
    800031b2:	0711                	addi	a4,a4,4
    800031b4:	fef61be3          	bne	a2,a5,800031aa <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    800031b8:	0621                	addi	a2,a2,8
    800031ba:	060a                	slli	a2,a2,0x2
    800031bc:	00015797          	auipc	a5,0x15
    800031c0:	80478793          	addi	a5,a5,-2044 # 800179c0 <log>
    800031c4:	97b2                	add	a5,a5,a2
    800031c6:	44d8                	lw	a4,12(s1)
    800031c8:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800031ca:	8526                	mv	a0,s1
    800031cc:	fedfe0ef          	jal	ra,800021b8 <bpin>
    log.lh.n++;
    800031d0:	00014717          	auipc	a4,0x14
    800031d4:	7f070713          	addi	a4,a4,2032 # 800179c0 <log>
    800031d8:	575c                	lw	a5,44(a4)
    800031da:	2785                	addiw	a5,a5,1
    800031dc:	d75c                	sw	a5,44(a4)
    800031de:	a80d                	j	80003210 <log_write+0xb8>
    panic("too big a transaction");
    800031e0:	00004517          	auipc	a0,0x4
    800031e4:	4d850513          	addi	a0,a0,1240 # 800076b8 <syscalls+0x258>
    800031e8:	1da020ef          	jal	ra,800053c2 <panic>
    panic("log_write outside of trans");
    800031ec:	00004517          	auipc	a0,0x4
    800031f0:	4e450513          	addi	a0,a0,1252 # 800076d0 <syscalls+0x270>
    800031f4:	1ce020ef          	jal	ra,800053c2 <panic>
  log.lh.block[i] = b->blockno;
    800031f8:	00878693          	addi	a3,a5,8
    800031fc:	068a                	slli	a3,a3,0x2
    800031fe:	00014717          	auipc	a4,0x14
    80003202:	7c270713          	addi	a4,a4,1986 # 800179c0 <log>
    80003206:	9736                	add	a4,a4,a3
    80003208:	44d4                	lw	a3,12(s1)
    8000320a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000320c:	faf60fe3          	beq	a2,a5,800031ca <log_write+0x72>
  }
  release(&log.lock);
    80003210:	00014517          	auipc	a0,0x14
    80003214:	7b050513          	addi	a0,a0,1968 # 800179c0 <log>
    80003218:	552020ef          	jal	ra,8000576a <release>
}
    8000321c:	60e2                	ld	ra,24(sp)
    8000321e:	6442                	ld	s0,16(sp)
    80003220:	64a2                	ld	s1,8(sp)
    80003222:	6902                	ld	s2,0(sp)
    80003224:	6105                	addi	sp,sp,32
    80003226:	8082                	ret

0000000080003228 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003228:	1101                	addi	sp,sp,-32
    8000322a:	ec06                	sd	ra,24(sp)
    8000322c:	e822                	sd	s0,16(sp)
    8000322e:	e426                	sd	s1,8(sp)
    80003230:	e04a                	sd	s2,0(sp)
    80003232:	1000                	addi	s0,sp,32
    80003234:	84aa                	mv	s1,a0
    80003236:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003238:	00004597          	auipc	a1,0x4
    8000323c:	4b858593          	addi	a1,a1,1208 # 800076f0 <syscalls+0x290>
    80003240:	0521                	addi	a0,a0,8
    80003242:	410020ef          	jal	ra,80005652 <initlock>
  lk->name = name;
    80003246:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000324a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000324e:	0204a423          	sw	zero,40(s1)
}
    80003252:	60e2                	ld	ra,24(sp)
    80003254:	6442                	ld	s0,16(sp)
    80003256:	64a2                	ld	s1,8(sp)
    80003258:	6902                	ld	s2,0(sp)
    8000325a:	6105                	addi	sp,sp,32
    8000325c:	8082                	ret

000000008000325e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000325e:	1101                	addi	sp,sp,-32
    80003260:	ec06                	sd	ra,24(sp)
    80003262:	e822                	sd	s0,16(sp)
    80003264:	e426                	sd	s1,8(sp)
    80003266:	e04a                	sd	s2,0(sp)
    80003268:	1000                	addi	s0,sp,32
    8000326a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000326c:	00850913          	addi	s2,a0,8
    80003270:	854a                	mv	a0,s2
    80003272:	460020ef          	jal	ra,800056d2 <acquire>
  while (lk->locked) {
    80003276:	409c                	lw	a5,0(s1)
    80003278:	c799                	beqz	a5,80003286 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000327a:	85ca                	mv	a1,s2
    8000327c:	8526                	mv	a0,s1
    8000327e:	982fe0ef          	jal	ra,80001400 <sleep>
  while (lk->locked) {
    80003282:	409c                	lw	a5,0(s1)
    80003284:	fbfd                	bnez	a5,8000327a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003286:	4785                	li	a5,1
    80003288:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000328a:	babfd0ef          	jal	ra,80000e34 <myproc>
    8000328e:	591c                	lw	a5,48(a0)
    80003290:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003292:	854a                	mv	a0,s2
    80003294:	4d6020ef          	jal	ra,8000576a <release>
}
    80003298:	60e2                	ld	ra,24(sp)
    8000329a:	6442                	ld	s0,16(sp)
    8000329c:	64a2                	ld	s1,8(sp)
    8000329e:	6902                	ld	s2,0(sp)
    800032a0:	6105                	addi	sp,sp,32
    800032a2:	8082                	ret

00000000800032a4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800032a4:	1101                	addi	sp,sp,-32
    800032a6:	ec06                	sd	ra,24(sp)
    800032a8:	e822                	sd	s0,16(sp)
    800032aa:	e426                	sd	s1,8(sp)
    800032ac:	e04a                	sd	s2,0(sp)
    800032ae:	1000                	addi	s0,sp,32
    800032b0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800032b2:	00850913          	addi	s2,a0,8
    800032b6:	854a                	mv	a0,s2
    800032b8:	41a020ef          	jal	ra,800056d2 <acquire>
  lk->locked = 0;
    800032bc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800032c0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800032c4:	8526                	mv	a0,s1
    800032c6:	986fe0ef          	jal	ra,8000144c <wakeup>
  release(&lk->lk);
    800032ca:	854a                	mv	a0,s2
    800032cc:	49e020ef          	jal	ra,8000576a <release>
}
    800032d0:	60e2                	ld	ra,24(sp)
    800032d2:	6442                	ld	s0,16(sp)
    800032d4:	64a2                	ld	s1,8(sp)
    800032d6:	6902                	ld	s2,0(sp)
    800032d8:	6105                	addi	sp,sp,32
    800032da:	8082                	ret

00000000800032dc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800032dc:	7179                	addi	sp,sp,-48
    800032de:	f406                	sd	ra,40(sp)
    800032e0:	f022                	sd	s0,32(sp)
    800032e2:	ec26                	sd	s1,24(sp)
    800032e4:	e84a                	sd	s2,16(sp)
    800032e6:	e44e                	sd	s3,8(sp)
    800032e8:	1800                	addi	s0,sp,48
    800032ea:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800032ec:	00850913          	addi	s2,a0,8
    800032f0:	854a                	mv	a0,s2
    800032f2:	3e0020ef          	jal	ra,800056d2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800032f6:	409c                	lw	a5,0(s1)
    800032f8:	ef89                	bnez	a5,80003312 <holdingsleep+0x36>
    800032fa:	4481                	li	s1,0
  release(&lk->lk);
    800032fc:	854a                	mv	a0,s2
    800032fe:	46c020ef          	jal	ra,8000576a <release>
  return r;
}
    80003302:	8526                	mv	a0,s1
    80003304:	70a2                	ld	ra,40(sp)
    80003306:	7402                	ld	s0,32(sp)
    80003308:	64e2                	ld	s1,24(sp)
    8000330a:	6942                	ld	s2,16(sp)
    8000330c:	69a2                	ld	s3,8(sp)
    8000330e:	6145                	addi	sp,sp,48
    80003310:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003312:	0284a983          	lw	s3,40(s1)
    80003316:	b1ffd0ef          	jal	ra,80000e34 <myproc>
    8000331a:	5904                	lw	s1,48(a0)
    8000331c:	413484b3          	sub	s1,s1,s3
    80003320:	0014b493          	seqz	s1,s1
    80003324:	bfe1                	j	800032fc <holdingsleep+0x20>

0000000080003326 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003326:	1141                	addi	sp,sp,-16
    80003328:	e406                	sd	ra,8(sp)
    8000332a:	e022                	sd	s0,0(sp)
    8000332c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000332e:	00004597          	auipc	a1,0x4
    80003332:	3d258593          	addi	a1,a1,978 # 80007700 <syscalls+0x2a0>
    80003336:	00014517          	auipc	a0,0x14
    8000333a:	7d250513          	addi	a0,a0,2002 # 80017b08 <ftable>
    8000333e:	314020ef          	jal	ra,80005652 <initlock>
}
    80003342:	60a2                	ld	ra,8(sp)
    80003344:	6402                	ld	s0,0(sp)
    80003346:	0141                	addi	sp,sp,16
    80003348:	8082                	ret

000000008000334a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000334a:	1101                	addi	sp,sp,-32
    8000334c:	ec06                	sd	ra,24(sp)
    8000334e:	e822                	sd	s0,16(sp)
    80003350:	e426                	sd	s1,8(sp)
    80003352:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003354:	00014517          	auipc	a0,0x14
    80003358:	7b450513          	addi	a0,a0,1972 # 80017b08 <ftable>
    8000335c:	376020ef          	jal	ra,800056d2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003360:	00014497          	auipc	s1,0x14
    80003364:	7c048493          	addi	s1,s1,1984 # 80017b20 <ftable+0x18>
    80003368:	00015717          	auipc	a4,0x15
    8000336c:	75870713          	addi	a4,a4,1880 # 80018ac0 <disk>
    if(f->ref == 0){
    80003370:	40dc                	lw	a5,4(s1)
    80003372:	cf89                	beqz	a5,8000338c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003374:	02848493          	addi	s1,s1,40
    80003378:	fee49ce3          	bne	s1,a4,80003370 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000337c:	00014517          	auipc	a0,0x14
    80003380:	78c50513          	addi	a0,a0,1932 # 80017b08 <ftable>
    80003384:	3e6020ef          	jal	ra,8000576a <release>
  return 0;
    80003388:	4481                	li	s1,0
    8000338a:	a809                	j	8000339c <filealloc+0x52>
      f->ref = 1;
    8000338c:	4785                	li	a5,1
    8000338e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003390:	00014517          	auipc	a0,0x14
    80003394:	77850513          	addi	a0,a0,1912 # 80017b08 <ftable>
    80003398:	3d2020ef          	jal	ra,8000576a <release>
}
    8000339c:	8526                	mv	a0,s1
    8000339e:	60e2                	ld	ra,24(sp)
    800033a0:	6442                	ld	s0,16(sp)
    800033a2:	64a2                	ld	s1,8(sp)
    800033a4:	6105                	addi	sp,sp,32
    800033a6:	8082                	ret

00000000800033a8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800033a8:	1101                	addi	sp,sp,-32
    800033aa:	ec06                	sd	ra,24(sp)
    800033ac:	e822                	sd	s0,16(sp)
    800033ae:	e426                	sd	s1,8(sp)
    800033b0:	1000                	addi	s0,sp,32
    800033b2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800033b4:	00014517          	auipc	a0,0x14
    800033b8:	75450513          	addi	a0,a0,1876 # 80017b08 <ftable>
    800033bc:	316020ef          	jal	ra,800056d2 <acquire>
  if(f->ref < 1)
    800033c0:	40dc                	lw	a5,4(s1)
    800033c2:	02f05063          	blez	a5,800033e2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800033c6:	2785                	addiw	a5,a5,1
    800033c8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800033ca:	00014517          	auipc	a0,0x14
    800033ce:	73e50513          	addi	a0,a0,1854 # 80017b08 <ftable>
    800033d2:	398020ef          	jal	ra,8000576a <release>
  return f;
}
    800033d6:	8526                	mv	a0,s1
    800033d8:	60e2                	ld	ra,24(sp)
    800033da:	6442                	ld	s0,16(sp)
    800033dc:	64a2                	ld	s1,8(sp)
    800033de:	6105                	addi	sp,sp,32
    800033e0:	8082                	ret
    panic("filedup");
    800033e2:	00004517          	auipc	a0,0x4
    800033e6:	32650513          	addi	a0,a0,806 # 80007708 <syscalls+0x2a8>
    800033ea:	7d9010ef          	jal	ra,800053c2 <panic>

00000000800033ee <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800033ee:	7139                	addi	sp,sp,-64
    800033f0:	fc06                	sd	ra,56(sp)
    800033f2:	f822                	sd	s0,48(sp)
    800033f4:	f426                	sd	s1,40(sp)
    800033f6:	f04a                	sd	s2,32(sp)
    800033f8:	ec4e                	sd	s3,24(sp)
    800033fa:	e852                	sd	s4,16(sp)
    800033fc:	e456                	sd	s5,8(sp)
    800033fe:	0080                	addi	s0,sp,64
    80003400:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003402:	00014517          	auipc	a0,0x14
    80003406:	70650513          	addi	a0,a0,1798 # 80017b08 <ftable>
    8000340a:	2c8020ef          	jal	ra,800056d2 <acquire>
  if(f->ref < 1)
    8000340e:	40dc                	lw	a5,4(s1)
    80003410:	04f05963          	blez	a5,80003462 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80003414:	37fd                	addiw	a5,a5,-1
    80003416:	0007871b          	sext.w	a4,a5
    8000341a:	c0dc                	sw	a5,4(s1)
    8000341c:	04e04963          	bgtz	a4,8000346e <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003420:	0004a903          	lw	s2,0(s1)
    80003424:	0094ca83          	lbu	s5,9(s1)
    80003428:	0104ba03          	ld	s4,16(s1)
    8000342c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003430:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003434:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003438:	00014517          	auipc	a0,0x14
    8000343c:	6d050513          	addi	a0,a0,1744 # 80017b08 <ftable>
    80003440:	32a020ef          	jal	ra,8000576a <release>

  if(ff.type == FD_PIPE){
    80003444:	4785                	li	a5,1
    80003446:	04f90363          	beq	s2,a5,8000348c <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000344a:	3979                	addiw	s2,s2,-2
    8000344c:	4785                	li	a5,1
    8000344e:	0327e663          	bltu	a5,s2,8000347a <fileclose+0x8c>
    begin_op();
    80003452:	b85ff0ef          	jal	ra,80002fd6 <begin_op>
    iput(ff.ip);
    80003456:	854e                	mv	a0,s3
    80003458:	c68ff0ef          	jal	ra,800028c0 <iput>
    end_op();
    8000345c:	be9ff0ef          	jal	ra,80003044 <end_op>
    80003460:	a829                	j	8000347a <fileclose+0x8c>
    panic("fileclose");
    80003462:	00004517          	auipc	a0,0x4
    80003466:	2ae50513          	addi	a0,a0,686 # 80007710 <syscalls+0x2b0>
    8000346a:	759010ef          	jal	ra,800053c2 <panic>
    release(&ftable.lock);
    8000346e:	00014517          	auipc	a0,0x14
    80003472:	69a50513          	addi	a0,a0,1690 # 80017b08 <ftable>
    80003476:	2f4020ef          	jal	ra,8000576a <release>
  }
}
    8000347a:	70e2                	ld	ra,56(sp)
    8000347c:	7442                	ld	s0,48(sp)
    8000347e:	74a2                	ld	s1,40(sp)
    80003480:	7902                	ld	s2,32(sp)
    80003482:	69e2                	ld	s3,24(sp)
    80003484:	6a42                	ld	s4,16(sp)
    80003486:	6aa2                	ld	s5,8(sp)
    80003488:	6121                	addi	sp,sp,64
    8000348a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000348c:	85d6                	mv	a1,s5
    8000348e:	8552                	mv	a0,s4
    80003490:	2ec000ef          	jal	ra,8000377c <pipeclose>
    80003494:	b7dd                	j	8000347a <fileclose+0x8c>

0000000080003496 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003496:	715d                	addi	sp,sp,-80
    80003498:	e486                	sd	ra,72(sp)
    8000349a:	e0a2                	sd	s0,64(sp)
    8000349c:	fc26                	sd	s1,56(sp)
    8000349e:	f84a                	sd	s2,48(sp)
    800034a0:	f44e                	sd	s3,40(sp)
    800034a2:	0880                	addi	s0,sp,80
    800034a4:	84aa                	mv	s1,a0
    800034a6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800034a8:	98dfd0ef          	jal	ra,80000e34 <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800034ac:	409c                	lw	a5,0(s1)
    800034ae:	37f9                	addiw	a5,a5,-2
    800034b0:	4705                	li	a4,1
    800034b2:	02f76f63          	bltu	a4,a5,800034f0 <filestat+0x5a>
    800034b6:	892a                	mv	s2,a0
    ilock(f->ip);
    800034b8:	6c88                	ld	a0,24(s1)
    800034ba:	a88ff0ef          	jal	ra,80002742 <ilock>
    stati(f->ip, &st);
    800034be:	fb840593          	addi	a1,s0,-72
    800034c2:	6c88                	ld	a0,24(s1)
    800034c4:	ca4ff0ef          	jal	ra,80002968 <stati>
    iunlock(f->ip);
    800034c8:	6c88                	ld	a0,24(s1)
    800034ca:	b22ff0ef          	jal	ra,800027ec <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800034ce:	46e1                	li	a3,24
    800034d0:	fb840613          	addi	a2,s0,-72
    800034d4:	85ce                	mv	a1,s3
    800034d6:	05093503          	ld	a0,80(s2)
    800034da:	d04fd0ef          	jal	ra,800009de <copyout>
    800034de:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800034e2:	60a6                	ld	ra,72(sp)
    800034e4:	6406                	ld	s0,64(sp)
    800034e6:	74e2                	ld	s1,56(sp)
    800034e8:	7942                	ld	s2,48(sp)
    800034ea:	79a2                	ld	s3,40(sp)
    800034ec:	6161                	addi	sp,sp,80
    800034ee:	8082                	ret
  return -1;
    800034f0:	557d                	li	a0,-1
    800034f2:	bfc5                	j	800034e2 <filestat+0x4c>

00000000800034f4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800034f4:	7179                	addi	sp,sp,-48
    800034f6:	f406                	sd	ra,40(sp)
    800034f8:	f022                	sd	s0,32(sp)
    800034fa:	ec26                	sd	s1,24(sp)
    800034fc:	e84a                	sd	s2,16(sp)
    800034fe:	e44e                	sd	s3,8(sp)
    80003500:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003502:	00854783          	lbu	a5,8(a0)
    80003506:	cbc1                	beqz	a5,80003596 <fileread+0xa2>
    80003508:	84aa                	mv	s1,a0
    8000350a:	89ae                	mv	s3,a1
    8000350c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000350e:	411c                	lw	a5,0(a0)
    80003510:	4705                	li	a4,1
    80003512:	04e78363          	beq	a5,a4,80003558 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003516:	470d                	li	a4,3
    80003518:	04e78563          	beq	a5,a4,80003562 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000351c:	4709                	li	a4,2
    8000351e:	06e79663          	bne	a5,a4,8000358a <fileread+0x96>
    ilock(f->ip);
    80003522:	6d08                	ld	a0,24(a0)
    80003524:	a1eff0ef          	jal	ra,80002742 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003528:	874a                	mv	a4,s2
    8000352a:	5094                	lw	a3,32(s1)
    8000352c:	864e                	mv	a2,s3
    8000352e:	4585                	li	a1,1
    80003530:	6c88                	ld	a0,24(s1)
    80003532:	c60ff0ef          	jal	ra,80002992 <readi>
    80003536:	892a                	mv	s2,a0
    80003538:	00a05563          	blez	a0,80003542 <fileread+0x4e>
      f->off += r;
    8000353c:	509c                	lw	a5,32(s1)
    8000353e:	9fa9                	addw	a5,a5,a0
    80003540:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003542:	6c88                	ld	a0,24(s1)
    80003544:	aa8ff0ef          	jal	ra,800027ec <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003548:	854a                	mv	a0,s2
    8000354a:	70a2                	ld	ra,40(sp)
    8000354c:	7402                	ld	s0,32(sp)
    8000354e:	64e2                	ld	s1,24(sp)
    80003550:	6942                	ld	s2,16(sp)
    80003552:	69a2                	ld	s3,8(sp)
    80003554:	6145                	addi	sp,sp,48
    80003556:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003558:	6908                	ld	a0,16(a0)
    8000355a:	34e000ef          	jal	ra,800038a8 <piperead>
    8000355e:	892a                	mv	s2,a0
    80003560:	b7e5                	j	80003548 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003562:	02451783          	lh	a5,36(a0)
    80003566:	03079693          	slli	a3,a5,0x30
    8000356a:	92c1                	srli	a3,a3,0x30
    8000356c:	4725                	li	a4,9
    8000356e:	02d76663          	bltu	a4,a3,8000359a <fileread+0xa6>
    80003572:	0792                	slli	a5,a5,0x4
    80003574:	00014717          	auipc	a4,0x14
    80003578:	4f470713          	addi	a4,a4,1268 # 80017a68 <devsw>
    8000357c:	97ba                	add	a5,a5,a4
    8000357e:	639c                	ld	a5,0(a5)
    80003580:	cf99                	beqz	a5,8000359e <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80003582:	4505                	li	a0,1
    80003584:	9782                	jalr	a5
    80003586:	892a                	mv	s2,a0
    80003588:	b7c1                	j	80003548 <fileread+0x54>
    panic("fileread");
    8000358a:	00004517          	auipc	a0,0x4
    8000358e:	19650513          	addi	a0,a0,406 # 80007720 <syscalls+0x2c0>
    80003592:	631010ef          	jal	ra,800053c2 <panic>
    return -1;
    80003596:	597d                	li	s2,-1
    80003598:	bf45                	j	80003548 <fileread+0x54>
      return -1;
    8000359a:	597d                	li	s2,-1
    8000359c:	b775                	j	80003548 <fileread+0x54>
    8000359e:	597d                	li	s2,-1
    800035a0:	b765                	j	80003548 <fileread+0x54>

00000000800035a2 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800035a2:	715d                	addi	sp,sp,-80
    800035a4:	e486                	sd	ra,72(sp)
    800035a6:	e0a2                	sd	s0,64(sp)
    800035a8:	fc26                	sd	s1,56(sp)
    800035aa:	f84a                	sd	s2,48(sp)
    800035ac:	f44e                	sd	s3,40(sp)
    800035ae:	f052                	sd	s4,32(sp)
    800035b0:	ec56                	sd	s5,24(sp)
    800035b2:	e85a                	sd	s6,16(sp)
    800035b4:	e45e                	sd	s7,8(sp)
    800035b6:	e062                	sd	s8,0(sp)
    800035b8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800035ba:	00954783          	lbu	a5,9(a0)
    800035be:	0e078863          	beqz	a5,800036ae <filewrite+0x10c>
    800035c2:	892a                	mv	s2,a0
    800035c4:	8b2e                	mv	s6,a1
    800035c6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800035c8:	411c                	lw	a5,0(a0)
    800035ca:	4705                	li	a4,1
    800035cc:	02e78263          	beq	a5,a4,800035f0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800035d0:	470d                	li	a4,3
    800035d2:	02e78463          	beq	a5,a4,800035fa <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800035d6:	4709                	li	a4,2
    800035d8:	0ce79563          	bne	a5,a4,800036a2 <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800035dc:	0ac05163          	blez	a2,8000367e <filewrite+0xdc>
    int i = 0;
    800035e0:	4981                	li	s3,0
    800035e2:	6b85                	lui	s7,0x1
    800035e4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800035e8:	6c05                	lui	s8,0x1
    800035ea:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800035ee:	a041                	j	8000366e <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800035f0:	6908                	ld	a0,16(a0)
    800035f2:	1e2000ef          	jal	ra,800037d4 <pipewrite>
    800035f6:	8a2a                	mv	s4,a0
    800035f8:	a071                	j	80003684 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800035fa:	02451783          	lh	a5,36(a0)
    800035fe:	03079693          	slli	a3,a5,0x30
    80003602:	92c1                	srli	a3,a3,0x30
    80003604:	4725                	li	a4,9
    80003606:	0ad76663          	bltu	a4,a3,800036b2 <filewrite+0x110>
    8000360a:	0792                	slli	a5,a5,0x4
    8000360c:	00014717          	auipc	a4,0x14
    80003610:	45c70713          	addi	a4,a4,1116 # 80017a68 <devsw>
    80003614:	97ba                	add	a5,a5,a4
    80003616:	679c                	ld	a5,8(a5)
    80003618:	cfd9                	beqz	a5,800036b6 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    8000361a:	4505                	li	a0,1
    8000361c:	9782                	jalr	a5
    8000361e:	8a2a                	mv	s4,a0
    80003620:	a095                	j	80003684 <filewrite+0xe2>
    80003622:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003626:	9b1ff0ef          	jal	ra,80002fd6 <begin_op>
      ilock(f->ip);
    8000362a:	01893503          	ld	a0,24(s2)
    8000362e:	914ff0ef          	jal	ra,80002742 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003632:	8756                	mv	a4,s5
    80003634:	02092683          	lw	a3,32(s2)
    80003638:	01698633          	add	a2,s3,s6
    8000363c:	4585                	li	a1,1
    8000363e:	01893503          	ld	a0,24(s2)
    80003642:	c34ff0ef          	jal	ra,80002a76 <writei>
    80003646:	84aa                	mv	s1,a0
    80003648:	00a05763          	blez	a0,80003656 <filewrite+0xb4>
        f->off += r;
    8000364c:	02092783          	lw	a5,32(s2)
    80003650:	9fa9                	addw	a5,a5,a0
    80003652:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003656:	01893503          	ld	a0,24(s2)
    8000365a:	992ff0ef          	jal	ra,800027ec <iunlock>
      end_op();
    8000365e:	9e7ff0ef          	jal	ra,80003044 <end_op>

      if(r != n1){
    80003662:	009a9f63          	bne	s5,s1,80003680 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80003666:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000366a:	0149db63          	bge	s3,s4,80003680 <filewrite+0xde>
      int n1 = n - i;
    8000366e:	413a04bb          	subw	s1,s4,s3
    80003672:	0004879b          	sext.w	a5,s1
    80003676:	fafbd6e3          	bge	s7,a5,80003622 <filewrite+0x80>
    8000367a:	84e2                	mv	s1,s8
    8000367c:	b75d                	j	80003622 <filewrite+0x80>
    int i = 0;
    8000367e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003680:	013a1f63          	bne	s4,s3,8000369e <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003684:	8552                	mv	a0,s4
    80003686:	60a6                	ld	ra,72(sp)
    80003688:	6406                	ld	s0,64(sp)
    8000368a:	74e2                	ld	s1,56(sp)
    8000368c:	7942                	ld	s2,48(sp)
    8000368e:	79a2                	ld	s3,40(sp)
    80003690:	7a02                	ld	s4,32(sp)
    80003692:	6ae2                	ld	s5,24(sp)
    80003694:	6b42                	ld	s6,16(sp)
    80003696:	6ba2                	ld	s7,8(sp)
    80003698:	6c02                	ld	s8,0(sp)
    8000369a:	6161                	addi	sp,sp,80
    8000369c:	8082                	ret
    ret = (i == n ? n : -1);
    8000369e:	5a7d                	li	s4,-1
    800036a0:	b7d5                	j	80003684 <filewrite+0xe2>
    panic("filewrite");
    800036a2:	00004517          	auipc	a0,0x4
    800036a6:	08e50513          	addi	a0,a0,142 # 80007730 <syscalls+0x2d0>
    800036aa:	519010ef          	jal	ra,800053c2 <panic>
    return -1;
    800036ae:	5a7d                	li	s4,-1
    800036b0:	bfd1                	j	80003684 <filewrite+0xe2>
      return -1;
    800036b2:	5a7d                	li	s4,-1
    800036b4:	bfc1                	j	80003684 <filewrite+0xe2>
    800036b6:	5a7d                	li	s4,-1
    800036b8:	b7f1                	j	80003684 <filewrite+0xe2>

00000000800036ba <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800036ba:	7179                	addi	sp,sp,-48
    800036bc:	f406                	sd	ra,40(sp)
    800036be:	f022                	sd	s0,32(sp)
    800036c0:	ec26                	sd	s1,24(sp)
    800036c2:	e84a                	sd	s2,16(sp)
    800036c4:	e44e                	sd	s3,8(sp)
    800036c6:	e052                	sd	s4,0(sp)
    800036c8:	1800                	addi	s0,sp,48
    800036ca:	84aa                	mv	s1,a0
    800036cc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800036ce:	0005b023          	sd	zero,0(a1)
    800036d2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800036d6:	c75ff0ef          	jal	ra,8000334a <filealloc>
    800036da:	e088                	sd	a0,0(s1)
    800036dc:	cd35                	beqz	a0,80003758 <pipealloc+0x9e>
    800036de:	c6dff0ef          	jal	ra,8000334a <filealloc>
    800036e2:	00aa3023          	sd	a0,0(s4)
    800036e6:	c52d                	beqz	a0,80003750 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800036e8:	a17fc0ef          	jal	ra,800000fe <kalloc>
    800036ec:	892a                	mv	s2,a0
    800036ee:	cd31                	beqz	a0,8000374a <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800036f0:	4985                	li	s3,1
    800036f2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800036f6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800036fa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800036fe:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003702:	00004597          	auipc	a1,0x4
    80003706:	03e58593          	addi	a1,a1,62 # 80007740 <syscalls+0x2e0>
    8000370a:	749010ef          	jal	ra,80005652 <initlock>
  (*f0)->type = FD_PIPE;
    8000370e:	609c                	ld	a5,0(s1)
    80003710:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003714:	609c                	ld	a5,0(s1)
    80003716:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000371a:	609c                	ld	a5,0(s1)
    8000371c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003720:	609c                	ld	a5,0(s1)
    80003722:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003726:	000a3783          	ld	a5,0(s4)
    8000372a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000372e:	000a3783          	ld	a5,0(s4)
    80003732:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003736:	000a3783          	ld	a5,0(s4)
    8000373a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000373e:	000a3783          	ld	a5,0(s4)
    80003742:	0127b823          	sd	s2,16(a5)
  return 0;
    80003746:	4501                	li	a0,0
    80003748:	a005                	j	80003768 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000374a:	6088                	ld	a0,0(s1)
    8000374c:	e501                	bnez	a0,80003754 <pipealloc+0x9a>
    8000374e:	a029                	j	80003758 <pipealloc+0x9e>
    80003750:	6088                	ld	a0,0(s1)
    80003752:	c11d                	beqz	a0,80003778 <pipealloc+0xbe>
    fileclose(*f0);
    80003754:	c9bff0ef          	jal	ra,800033ee <fileclose>
  if(*f1)
    80003758:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000375c:	557d                	li	a0,-1
  if(*f1)
    8000375e:	c789                	beqz	a5,80003768 <pipealloc+0xae>
    fileclose(*f1);
    80003760:	853e                	mv	a0,a5
    80003762:	c8dff0ef          	jal	ra,800033ee <fileclose>
  return -1;
    80003766:	557d                	li	a0,-1
}
    80003768:	70a2                	ld	ra,40(sp)
    8000376a:	7402                	ld	s0,32(sp)
    8000376c:	64e2                	ld	s1,24(sp)
    8000376e:	6942                	ld	s2,16(sp)
    80003770:	69a2                	ld	s3,8(sp)
    80003772:	6a02                	ld	s4,0(sp)
    80003774:	6145                	addi	sp,sp,48
    80003776:	8082                	ret
  return -1;
    80003778:	557d                	li	a0,-1
    8000377a:	b7fd                	j	80003768 <pipealloc+0xae>

000000008000377c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000377c:	1101                	addi	sp,sp,-32
    8000377e:	ec06                	sd	ra,24(sp)
    80003780:	e822                	sd	s0,16(sp)
    80003782:	e426                	sd	s1,8(sp)
    80003784:	e04a                	sd	s2,0(sp)
    80003786:	1000                	addi	s0,sp,32
    80003788:	84aa                	mv	s1,a0
    8000378a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000378c:	747010ef          	jal	ra,800056d2 <acquire>
  if(writable){
    80003790:	02090763          	beqz	s2,800037be <pipeclose+0x42>
    pi->writeopen = 0;
    80003794:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003798:	21848513          	addi	a0,s1,536
    8000379c:	cb1fd0ef          	jal	ra,8000144c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800037a0:	2204b783          	ld	a5,544(s1)
    800037a4:	e785                	bnez	a5,800037cc <pipeclose+0x50>
    release(&pi->lock);
    800037a6:	8526                	mv	a0,s1
    800037a8:	7c3010ef          	jal	ra,8000576a <release>
    kfree((char*)pi);
    800037ac:	8526                	mv	a0,s1
    800037ae:	86ffc0ef          	jal	ra,8000001c <kfree>
  } else
    release(&pi->lock);
}
    800037b2:	60e2                	ld	ra,24(sp)
    800037b4:	6442                	ld	s0,16(sp)
    800037b6:	64a2                	ld	s1,8(sp)
    800037b8:	6902                	ld	s2,0(sp)
    800037ba:	6105                	addi	sp,sp,32
    800037bc:	8082                	ret
    pi->readopen = 0;
    800037be:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800037c2:	21c48513          	addi	a0,s1,540
    800037c6:	c87fd0ef          	jal	ra,8000144c <wakeup>
    800037ca:	bfd9                	j	800037a0 <pipeclose+0x24>
    release(&pi->lock);
    800037cc:	8526                	mv	a0,s1
    800037ce:	79d010ef          	jal	ra,8000576a <release>
}
    800037d2:	b7c5                	j	800037b2 <pipeclose+0x36>

00000000800037d4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800037d4:	711d                	addi	sp,sp,-96
    800037d6:	ec86                	sd	ra,88(sp)
    800037d8:	e8a2                	sd	s0,80(sp)
    800037da:	e4a6                	sd	s1,72(sp)
    800037dc:	e0ca                	sd	s2,64(sp)
    800037de:	fc4e                	sd	s3,56(sp)
    800037e0:	f852                	sd	s4,48(sp)
    800037e2:	f456                	sd	s5,40(sp)
    800037e4:	f05a                	sd	s6,32(sp)
    800037e6:	ec5e                	sd	s7,24(sp)
    800037e8:	e862                	sd	s8,16(sp)
    800037ea:	1080                	addi	s0,sp,96
    800037ec:	84aa                	mv	s1,a0
    800037ee:	8aae                	mv	s5,a1
    800037f0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800037f2:	e42fd0ef          	jal	ra,80000e34 <myproc>
    800037f6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800037f8:	8526                	mv	a0,s1
    800037fa:	6d9010ef          	jal	ra,800056d2 <acquire>
  while(i < n){
    800037fe:	09405c63          	blez	s4,80003896 <pipewrite+0xc2>
  int i = 0;
    80003802:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003804:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003806:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000380a:	21c48b93          	addi	s7,s1,540
    8000380e:	a81d                	j	80003844 <pipewrite+0x70>
      release(&pi->lock);
    80003810:	8526                	mv	a0,s1
    80003812:	759010ef          	jal	ra,8000576a <release>
      return -1;
    80003816:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003818:	854a                	mv	a0,s2
    8000381a:	60e6                	ld	ra,88(sp)
    8000381c:	6446                	ld	s0,80(sp)
    8000381e:	64a6                	ld	s1,72(sp)
    80003820:	6906                	ld	s2,64(sp)
    80003822:	79e2                	ld	s3,56(sp)
    80003824:	7a42                	ld	s4,48(sp)
    80003826:	7aa2                	ld	s5,40(sp)
    80003828:	7b02                	ld	s6,32(sp)
    8000382a:	6be2                	ld	s7,24(sp)
    8000382c:	6c42                	ld	s8,16(sp)
    8000382e:	6125                	addi	sp,sp,96
    80003830:	8082                	ret
      wakeup(&pi->nread);
    80003832:	8562                	mv	a0,s8
    80003834:	c19fd0ef          	jal	ra,8000144c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003838:	85a6                	mv	a1,s1
    8000383a:	855e                	mv	a0,s7
    8000383c:	bc5fd0ef          	jal	ra,80001400 <sleep>
  while(i < n){
    80003840:	05495c63          	bge	s2,s4,80003898 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80003844:	2204a783          	lw	a5,544(s1)
    80003848:	d7e1                	beqz	a5,80003810 <pipewrite+0x3c>
    8000384a:	854e                	mv	a0,s3
    8000384c:	dedfd0ef          	jal	ra,80001638 <killed>
    80003850:	f161                	bnez	a0,80003810 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003852:	2184a783          	lw	a5,536(s1)
    80003856:	21c4a703          	lw	a4,540(s1)
    8000385a:	2007879b          	addiw	a5,a5,512
    8000385e:	fcf70ae3          	beq	a4,a5,80003832 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003862:	4685                	li	a3,1
    80003864:	01590633          	add	a2,s2,s5
    80003868:	faf40593          	addi	a1,s0,-81
    8000386c:	0509b503          	ld	a0,80(s3)
    80003870:	a26fd0ef          	jal	ra,80000a96 <copyin>
    80003874:	03650263          	beq	a0,s6,80003898 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003878:	21c4a783          	lw	a5,540(s1)
    8000387c:	0017871b          	addiw	a4,a5,1
    80003880:	20e4ae23          	sw	a4,540(s1)
    80003884:	1ff7f793          	andi	a5,a5,511
    80003888:	97a6                	add	a5,a5,s1
    8000388a:	faf44703          	lbu	a4,-81(s0)
    8000388e:	00e78c23          	sb	a4,24(a5)
      i++;
    80003892:	2905                	addiw	s2,s2,1
    80003894:	b775                	j	80003840 <pipewrite+0x6c>
  int i = 0;
    80003896:	4901                	li	s2,0
  wakeup(&pi->nread);
    80003898:	21848513          	addi	a0,s1,536
    8000389c:	bb1fd0ef          	jal	ra,8000144c <wakeup>
  release(&pi->lock);
    800038a0:	8526                	mv	a0,s1
    800038a2:	6c9010ef          	jal	ra,8000576a <release>
  return i;
    800038a6:	bf8d                	j	80003818 <pipewrite+0x44>

00000000800038a8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800038a8:	715d                	addi	sp,sp,-80
    800038aa:	e486                	sd	ra,72(sp)
    800038ac:	e0a2                	sd	s0,64(sp)
    800038ae:	fc26                	sd	s1,56(sp)
    800038b0:	f84a                	sd	s2,48(sp)
    800038b2:	f44e                	sd	s3,40(sp)
    800038b4:	f052                	sd	s4,32(sp)
    800038b6:	ec56                	sd	s5,24(sp)
    800038b8:	e85a                	sd	s6,16(sp)
    800038ba:	0880                	addi	s0,sp,80
    800038bc:	84aa                	mv	s1,a0
    800038be:	892e                	mv	s2,a1
    800038c0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800038c2:	d72fd0ef          	jal	ra,80000e34 <myproc>
    800038c6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800038c8:	8526                	mv	a0,s1
    800038ca:	609010ef          	jal	ra,800056d2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800038ce:	2184a703          	lw	a4,536(s1)
    800038d2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800038d6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800038da:	02f71363          	bne	a4,a5,80003900 <piperead+0x58>
    800038de:	2244a783          	lw	a5,548(s1)
    800038e2:	cf99                	beqz	a5,80003900 <piperead+0x58>
    if(killed(pr)){
    800038e4:	8552                	mv	a0,s4
    800038e6:	d53fd0ef          	jal	ra,80001638 <killed>
    800038ea:	e149                	bnez	a0,8000396c <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800038ec:	85a6                	mv	a1,s1
    800038ee:	854e                	mv	a0,s3
    800038f0:	b11fd0ef          	jal	ra,80001400 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800038f4:	2184a703          	lw	a4,536(s1)
    800038f8:	21c4a783          	lw	a5,540(s1)
    800038fc:	fef701e3          	beq	a4,a5,800038de <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003900:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003902:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003904:	05505263          	blez	s5,80003948 <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    80003908:	2184a783          	lw	a5,536(s1)
    8000390c:	21c4a703          	lw	a4,540(s1)
    80003910:	02f70c63          	beq	a4,a5,80003948 <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003914:	0017871b          	addiw	a4,a5,1
    80003918:	20e4ac23          	sw	a4,536(s1)
    8000391c:	1ff7f793          	andi	a5,a5,511
    80003920:	97a6                	add	a5,a5,s1
    80003922:	0187c783          	lbu	a5,24(a5)
    80003926:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000392a:	4685                	li	a3,1
    8000392c:	fbf40613          	addi	a2,s0,-65
    80003930:	85ca                	mv	a1,s2
    80003932:	050a3503          	ld	a0,80(s4)
    80003936:	8a8fd0ef          	jal	ra,800009de <copyout>
    8000393a:	01650763          	beq	a0,s6,80003948 <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000393e:	2985                	addiw	s3,s3,1
    80003940:	0905                	addi	s2,s2,1
    80003942:	fd3a93e3          	bne	s5,s3,80003908 <piperead+0x60>
    80003946:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003948:	21c48513          	addi	a0,s1,540
    8000394c:	b01fd0ef          	jal	ra,8000144c <wakeup>
  release(&pi->lock);
    80003950:	8526                	mv	a0,s1
    80003952:	619010ef          	jal	ra,8000576a <release>
  return i;
}
    80003956:	854e                	mv	a0,s3
    80003958:	60a6                	ld	ra,72(sp)
    8000395a:	6406                	ld	s0,64(sp)
    8000395c:	74e2                	ld	s1,56(sp)
    8000395e:	7942                	ld	s2,48(sp)
    80003960:	79a2                	ld	s3,40(sp)
    80003962:	7a02                	ld	s4,32(sp)
    80003964:	6ae2                	ld	s5,24(sp)
    80003966:	6b42                	ld	s6,16(sp)
    80003968:	6161                	addi	sp,sp,80
    8000396a:	8082                	ret
      release(&pi->lock);
    8000396c:	8526                	mv	a0,s1
    8000396e:	5fd010ef          	jal	ra,8000576a <release>
      return -1;
    80003972:	59fd                	li	s3,-1
    80003974:	b7cd                	j	80003956 <piperead+0xae>

0000000080003976 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003976:	1141                	addi	sp,sp,-16
    80003978:	e422                	sd	s0,8(sp)
    8000397a:	0800                	addi	s0,sp,16
    8000397c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000397e:	8905                	andi	a0,a0,1
    80003980:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003982:	8b89                	andi	a5,a5,2
    80003984:	c399                	beqz	a5,8000398a <flags2perm+0x14>
      perm |= PTE_W;
    80003986:	00456513          	ori	a0,a0,4
    return perm;
}
    8000398a:	6422                	ld	s0,8(sp)
    8000398c:	0141                	addi	sp,sp,16
    8000398e:	8082                	ret

0000000080003990 <exec>:

int
exec(char *path, char **argv)
{
    80003990:	de010113          	addi	sp,sp,-544
    80003994:	20113c23          	sd	ra,536(sp)
    80003998:	20813823          	sd	s0,528(sp)
    8000399c:	20913423          	sd	s1,520(sp)
    800039a0:	21213023          	sd	s2,512(sp)
    800039a4:	ffce                	sd	s3,504(sp)
    800039a6:	fbd2                	sd	s4,496(sp)
    800039a8:	f7d6                	sd	s5,488(sp)
    800039aa:	f3da                	sd	s6,480(sp)
    800039ac:	efde                	sd	s7,472(sp)
    800039ae:	ebe2                	sd	s8,464(sp)
    800039b0:	e7e6                	sd	s9,456(sp)
    800039b2:	e3ea                	sd	s10,448(sp)
    800039b4:	ff6e                	sd	s11,440(sp)
    800039b6:	1400                	addi	s0,sp,544
    800039b8:	892a                	mv	s2,a0
    800039ba:	dea43423          	sd	a0,-536(s0)
    800039be:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800039c2:	c72fd0ef          	jal	ra,80000e34 <myproc>
    800039c6:	84aa                	mv	s1,a0

  begin_op();
    800039c8:	e0eff0ef          	jal	ra,80002fd6 <begin_op>

  if((ip = namei(path)) == 0){
    800039cc:	854a                	mv	a0,s2
    800039ce:	c2cff0ef          	jal	ra,80002dfa <namei>
    800039d2:	c13d                	beqz	a0,80003a38 <exec+0xa8>
    800039d4:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800039d6:	d6dfe0ef          	jal	ra,80002742 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800039da:	04000713          	li	a4,64
    800039de:	4681                	li	a3,0
    800039e0:	e5040613          	addi	a2,s0,-432
    800039e4:	4581                	li	a1,0
    800039e6:	8556                	mv	a0,s5
    800039e8:	fabfe0ef          	jal	ra,80002992 <readi>
    800039ec:	04000793          	li	a5,64
    800039f0:	00f51a63          	bne	a0,a5,80003a04 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800039f4:	e5042703          	lw	a4,-432(s0)
    800039f8:	464c47b7          	lui	a5,0x464c4
    800039fc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003a00:	04f70063          	beq	a4,a5,80003a40 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003a04:	8556                	mv	a0,s5
    80003a06:	f43fe0ef          	jal	ra,80002948 <iunlockput>
    end_op();
    80003a0a:	e3aff0ef          	jal	ra,80003044 <end_op>
  }
  return -1;
    80003a0e:	557d                	li	a0,-1
}
    80003a10:	21813083          	ld	ra,536(sp)
    80003a14:	21013403          	ld	s0,528(sp)
    80003a18:	20813483          	ld	s1,520(sp)
    80003a1c:	20013903          	ld	s2,512(sp)
    80003a20:	79fe                	ld	s3,504(sp)
    80003a22:	7a5e                	ld	s4,496(sp)
    80003a24:	7abe                	ld	s5,488(sp)
    80003a26:	7b1e                	ld	s6,480(sp)
    80003a28:	6bfe                	ld	s7,472(sp)
    80003a2a:	6c5e                	ld	s8,464(sp)
    80003a2c:	6cbe                	ld	s9,456(sp)
    80003a2e:	6d1e                	ld	s10,448(sp)
    80003a30:	7dfa                	ld	s11,440(sp)
    80003a32:	22010113          	addi	sp,sp,544
    80003a36:	8082                	ret
    end_op();
    80003a38:	e0cff0ef          	jal	ra,80003044 <end_op>
    return -1;
    80003a3c:	557d                	li	a0,-1
    80003a3e:	bfc9                	j	80003a10 <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    80003a40:	8526                	mv	a0,s1
    80003a42:	c9afd0ef          	jal	ra,80000edc <proc_pagetable>
    80003a46:	8b2a                	mv	s6,a0
    80003a48:	dd55                	beqz	a0,80003a04 <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a4a:	e7042783          	lw	a5,-400(s0)
    80003a4e:	e8845703          	lhu	a4,-376(s0)
    80003a52:	c325                	beqz	a4,80003ab2 <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003a54:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a56:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80003a5a:	6a05                	lui	s4,0x1
    80003a5c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80003a60:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80003a64:	6d85                	lui	s11,0x1
    80003a66:	7d7d                	lui	s10,0xfffff
    80003a68:	a409                	j	80003c6a <exec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80003a6a:	00004517          	auipc	a0,0x4
    80003a6e:	cde50513          	addi	a0,a0,-802 # 80007748 <syscalls+0x2e8>
    80003a72:	151010ef          	jal	ra,800053c2 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003a76:	874a                	mv	a4,s2
    80003a78:	009c86bb          	addw	a3,s9,s1
    80003a7c:	4581                	li	a1,0
    80003a7e:	8556                	mv	a0,s5
    80003a80:	f13fe0ef          	jal	ra,80002992 <readi>
    80003a84:	2501                	sext.w	a0,a0
    80003a86:	18a91163          	bne	s2,a0,80003c08 <exec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80003a8a:	009d84bb          	addw	s1,s11,s1
    80003a8e:	013d09bb          	addw	s3,s10,s3
    80003a92:	1b74fc63          	bgeu	s1,s7,80003c4a <exec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80003a96:	02049593          	slli	a1,s1,0x20
    80003a9a:	9181                	srli	a1,a1,0x20
    80003a9c:	95e2                	add	a1,a1,s8
    80003a9e:	855a                	mv	a0,s6
    80003aa0:	9cffc0ef          	jal	ra,8000046e <walkaddr>
    80003aa4:	862a                	mv	a2,a0
    if(pa == 0)
    80003aa6:	d171                	beqz	a0,80003a6a <exec+0xda>
      n = PGSIZE;
    80003aa8:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80003aaa:	fd49f6e3          	bgeu	s3,s4,80003a76 <exec+0xe6>
      n = sz - i;
    80003aae:	894e                	mv	s2,s3
    80003ab0:	b7d9                	j	80003a76 <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003ab2:	4901                	li	s2,0
  iunlockput(ip);
    80003ab4:	8556                	mv	a0,s5
    80003ab6:	e93fe0ef          	jal	ra,80002948 <iunlockput>
  end_op();
    80003aba:	d8aff0ef          	jal	ra,80003044 <end_op>
  p = myproc();
    80003abe:	b76fd0ef          	jal	ra,80000e34 <myproc>
    80003ac2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80003ac4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003ac8:	6785                	lui	a5,0x1
    80003aca:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80003acc:	97ca                	add	a5,a5,s2
    80003ace:	777d                	lui	a4,0xfffff
    80003ad0:	8ff9                	and	a5,a5,a4
    80003ad2:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003ad6:	4691                	li	a3,4
    80003ad8:	6609                	lui	a2,0x2
    80003ada:	963e                	add	a2,a2,a5
    80003adc:	85be                	mv	a1,a5
    80003ade:	855a                	mv	a0,s6
    80003ae0:	cf7fc0ef          	jal	ra,800007d6 <uvmalloc>
    80003ae4:	8c2a                	mv	s8,a0
  ip = 0;
    80003ae6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003ae8:	12050063          	beqz	a0,80003c08 <exec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003aec:	75f9                	lui	a1,0xffffe
    80003aee:	95aa                	add	a1,a1,a0
    80003af0:	855a                	mv	a0,s6
    80003af2:	ec3fc0ef          	jal	ra,800009b4 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003af6:	7afd                	lui	s5,0xfffff
    80003af8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80003afa:	df043783          	ld	a5,-528(s0)
    80003afe:	6388                	ld	a0,0(a5)
    80003b00:	c135                	beqz	a0,80003b64 <exec+0x1d4>
    80003b02:	e9040993          	addi	s3,s0,-368
    80003b06:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80003b0a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003b0c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003b0e:	fb8fc0ef          	jal	ra,800002c6 <strlen>
    80003b12:	0015079b          	addiw	a5,a0,1
    80003b16:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003b1a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003b1e:	11596a63          	bltu	s2,s5,80003c32 <exec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003b22:	df043d83          	ld	s11,-528(s0)
    80003b26:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80003b2a:	8552                	mv	a0,s4
    80003b2c:	f9afc0ef          	jal	ra,800002c6 <strlen>
    80003b30:	0015069b          	addiw	a3,a0,1
    80003b34:	8652                	mv	a2,s4
    80003b36:	85ca                	mv	a1,s2
    80003b38:	855a                	mv	a0,s6
    80003b3a:	ea5fc0ef          	jal	ra,800009de <copyout>
    80003b3e:	0e054e63          	bltz	a0,80003c3a <exec+0x2aa>
    ustack[argc] = sp;
    80003b42:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003b46:	0485                	addi	s1,s1,1
    80003b48:	008d8793          	addi	a5,s11,8
    80003b4c:	def43823          	sd	a5,-528(s0)
    80003b50:	008db503          	ld	a0,8(s11)
    80003b54:	c911                	beqz	a0,80003b68 <exec+0x1d8>
    if(argc >= MAXARG)
    80003b56:	09a1                	addi	s3,s3,8
    80003b58:	fb3c9be3          	bne	s9,s3,80003b0e <exec+0x17e>
  sz = sz1;
    80003b5c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003b60:	4a81                	li	s5,0
    80003b62:	a05d                	j	80003c08 <exec+0x278>
  sp = sz;
    80003b64:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003b66:	4481                	li	s1,0
  ustack[argc] = 0;
    80003b68:	00349793          	slli	a5,s1,0x3
    80003b6c:	f9078793          	addi	a5,a5,-112
    80003b70:	97a2                	add	a5,a5,s0
    80003b72:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003b76:	00148693          	addi	a3,s1,1
    80003b7a:	068e                	slli	a3,a3,0x3
    80003b7c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003b80:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80003b84:	01597663          	bgeu	s2,s5,80003b90 <exec+0x200>
  sz = sz1;
    80003b88:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003b8c:	4a81                	li	s5,0
    80003b8e:	a8ad                	j	80003c08 <exec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003b90:	e9040613          	addi	a2,s0,-368
    80003b94:	85ca                	mv	a1,s2
    80003b96:	855a                	mv	a0,s6
    80003b98:	e47fc0ef          	jal	ra,800009de <copyout>
    80003b9c:	0a054363          	bltz	a0,80003c42 <exec+0x2b2>
  p->trapframe->a1 = sp;
    80003ba0:	058bb783          	ld	a5,88(s7)
    80003ba4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003ba8:	de843783          	ld	a5,-536(s0)
    80003bac:	0007c703          	lbu	a4,0(a5)
    80003bb0:	cf11                	beqz	a4,80003bcc <exec+0x23c>
    80003bb2:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003bb4:	02f00693          	li	a3,47
    80003bb8:	a039                	j	80003bc6 <exec+0x236>
      last = s+1;
    80003bba:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80003bbe:	0785                	addi	a5,a5,1
    80003bc0:	fff7c703          	lbu	a4,-1(a5)
    80003bc4:	c701                	beqz	a4,80003bcc <exec+0x23c>
    if(*s == '/')
    80003bc6:	fed71ce3          	bne	a4,a3,80003bbe <exec+0x22e>
    80003bca:	bfc5                	j	80003bba <exec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80003bcc:	4641                	li	a2,16
    80003bce:	de843583          	ld	a1,-536(s0)
    80003bd2:	158b8513          	addi	a0,s7,344
    80003bd6:	ebefc0ef          	jal	ra,80000294 <safestrcpy>
  oldpagetable = p->pagetable;
    80003bda:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80003bde:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80003be2:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003be6:	058bb783          	ld	a5,88(s7)
    80003bea:	e6843703          	ld	a4,-408(s0)
    80003bee:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003bf0:	058bb783          	ld	a5,88(s7)
    80003bf4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003bf8:	85ea                	mv	a1,s10
    80003bfa:	b66fd0ef          	jal	ra,80000f60 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003bfe:	0004851b          	sext.w	a0,s1
    80003c02:	b539                	j	80003a10 <exec+0x80>
    80003c04:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80003c08:	df843583          	ld	a1,-520(s0)
    80003c0c:	855a                	mv	a0,s6
    80003c0e:	b52fd0ef          	jal	ra,80000f60 <proc_freepagetable>
  if(ip){
    80003c12:	de0a99e3          	bnez	s5,80003a04 <exec+0x74>
  return -1;
    80003c16:	557d                	li	a0,-1
    80003c18:	bbe5                	j	80003a10 <exec+0x80>
    80003c1a:	df243c23          	sd	s2,-520(s0)
    80003c1e:	b7ed                	j	80003c08 <exec+0x278>
    80003c20:	df243c23          	sd	s2,-520(s0)
    80003c24:	b7d5                	j	80003c08 <exec+0x278>
    80003c26:	df243c23          	sd	s2,-520(s0)
    80003c2a:	bff9                	j	80003c08 <exec+0x278>
    80003c2c:	df243c23          	sd	s2,-520(s0)
    80003c30:	bfe1                	j	80003c08 <exec+0x278>
  sz = sz1;
    80003c32:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003c36:	4a81                	li	s5,0
    80003c38:	bfc1                	j	80003c08 <exec+0x278>
  sz = sz1;
    80003c3a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003c3e:	4a81                	li	s5,0
    80003c40:	b7e1                	j	80003c08 <exec+0x278>
  sz = sz1;
    80003c42:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003c46:	4a81                	li	s5,0
    80003c48:	b7c1                	j	80003c08 <exec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003c4a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c4e:	e0843783          	ld	a5,-504(s0)
    80003c52:	0017869b          	addiw	a3,a5,1
    80003c56:	e0d43423          	sd	a3,-504(s0)
    80003c5a:	e0043783          	ld	a5,-512(s0)
    80003c5e:	0387879b          	addiw	a5,a5,56
    80003c62:	e8845703          	lhu	a4,-376(s0)
    80003c66:	e4e6d7e3          	bge	a3,a4,80003ab4 <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003c6a:	2781                	sext.w	a5,a5
    80003c6c:	e0f43023          	sd	a5,-512(s0)
    80003c70:	03800713          	li	a4,56
    80003c74:	86be                	mv	a3,a5
    80003c76:	e1840613          	addi	a2,s0,-488
    80003c7a:	4581                	li	a1,0
    80003c7c:	8556                	mv	a0,s5
    80003c7e:	d15fe0ef          	jal	ra,80002992 <readi>
    80003c82:	03800793          	li	a5,56
    80003c86:	f6f51fe3          	bne	a0,a5,80003c04 <exec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80003c8a:	e1842783          	lw	a5,-488(s0)
    80003c8e:	4705                	li	a4,1
    80003c90:	fae79fe3          	bne	a5,a4,80003c4e <exec+0x2be>
    if(ph.memsz < ph.filesz)
    80003c94:	e4043483          	ld	s1,-448(s0)
    80003c98:	e3843783          	ld	a5,-456(s0)
    80003c9c:	f6f4efe3          	bltu	s1,a5,80003c1a <exec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003ca0:	e2843783          	ld	a5,-472(s0)
    80003ca4:	94be                	add	s1,s1,a5
    80003ca6:	f6f4ede3          	bltu	s1,a5,80003c20 <exec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80003caa:	de043703          	ld	a4,-544(s0)
    80003cae:	8ff9                	and	a5,a5,a4
    80003cb0:	fbbd                	bnez	a5,80003c26 <exec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003cb2:	e1c42503          	lw	a0,-484(s0)
    80003cb6:	cc1ff0ef          	jal	ra,80003976 <flags2perm>
    80003cba:	86aa                	mv	a3,a0
    80003cbc:	8626                	mv	a2,s1
    80003cbe:	85ca                	mv	a1,s2
    80003cc0:	855a                	mv	a0,s6
    80003cc2:	b15fc0ef          	jal	ra,800007d6 <uvmalloc>
    80003cc6:	dea43c23          	sd	a0,-520(s0)
    80003cca:	d12d                	beqz	a0,80003c2c <exec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003ccc:	e2843c03          	ld	s8,-472(s0)
    80003cd0:	e2042c83          	lw	s9,-480(s0)
    80003cd4:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003cd8:	f60b89e3          	beqz	s7,80003c4a <exec+0x2ba>
    80003cdc:	89de                	mv	s3,s7
    80003cde:	4481                	li	s1,0
    80003ce0:	bb5d                	j	80003a96 <exec+0x106>

0000000080003ce2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003ce2:	7179                	addi	sp,sp,-48
    80003ce4:	f406                	sd	ra,40(sp)
    80003ce6:	f022                	sd	s0,32(sp)
    80003ce8:	ec26                	sd	s1,24(sp)
    80003cea:	e84a                	sd	s2,16(sp)
    80003cec:	1800                	addi	s0,sp,48
    80003cee:	892e                	mv	s2,a1
    80003cf0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003cf2:	fdc40593          	addi	a1,s0,-36
    80003cf6:	fedfd0ef          	jal	ra,80001ce2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003cfa:	fdc42703          	lw	a4,-36(s0)
    80003cfe:	47bd                	li	a5,15
    80003d00:	02e7e963          	bltu	a5,a4,80003d32 <argfd+0x50>
    80003d04:	930fd0ef          	jal	ra,80000e34 <myproc>
    80003d08:	fdc42703          	lw	a4,-36(s0)
    80003d0c:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffde31a>
    80003d10:	078e                	slli	a5,a5,0x3
    80003d12:	953e                	add	a0,a0,a5
    80003d14:	611c                	ld	a5,0(a0)
    80003d16:	c385                	beqz	a5,80003d36 <argfd+0x54>
    return -1;
  if(pfd)
    80003d18:	00090463          	beqz	s2,80003d20 <argfd+0x3e>
    *pfd = fd;
    80003d1c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003d20:	4501                	li	a0,0
  if(pf)
    80003d22:	c091                	beqz	s1,80003d26 <argfd+0x44>
    *pf = f;
    80003d24:	e09c                	sd	a5,0(s1)
}
    80003d26:	70a2                	ld	ra,40(sp)
    80003d28:	7402                	ld	s0,32(sp)
    80003d2a:	64e2                	ld	s1,24(sp)
    80003d2c:	6942                	ld	s2,16(sp)
    80003d2e:	6145                	addi	sp,sp,48
    80003d30:	8082                	ret
    return -1;
    80003d32:	557d                	li	a0,-1
    80003d34:	bfcd                	j	80003d26 <argfd+0x44>
    80003d36:	557d                	li	a0,-1
    80003d38:	b7fd                	j	80003d26 <argfd+0x44>

0000000080003d3a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003d3a:	1101                	addi	sp,sp,-32
    80003d3c:	ec06                	sd	ra,24(sp)
    80003d3e:	e822                	sd	s0,16(sp)
    80003d40:	e426                	sd	s1,8(sp)
    80003d42:	1000                	addi	s0,sp,32
    80003d44:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003d46:	8eefd0ef          	jal	ra,80000e34 <myproc>
    80003d4a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003d4c:	0d050793          	addi	a5,a0,208
    80003d50:	4501                	li	a0,0
    80003d52:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003d54:	6398                	ld	a4,0(a5)
    80003d56:	cb19                	beqz	a4,80003d6c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003d58:	2505                	addiw	a0,a0,1
    80003d5a:	07a1                	addi	a5,a5,8
    80003d5c:	fed51ce3          	bne	a0,a3,80003d54 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003d60:	557d                	li	a0,-1
}
    80003d62:	60e2                	ld	ra,24(sp)
    80003d64:	6442                	ld	s0,16(sp)
    80003d66:	64a2                	ld	s1,8(sp)
    80003d68:	6105                	addi	sp,sp,32
    80003d6a:	8082                	ret
      p->ofile[fd] = f;
    80003d6c:	01a50793          	addi	a5,a0,26
    80003d70:	078e                	slli	a5,a5,0x3
    80003d72:	963e                	add	a2,a2,a5
    80003d74:	e204                	sd	s1,0(a2)
      return fd;
    80003d76:	b7f5                	j	80003d62 <fdalloc+0x28>

0000000080003d78 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003d78:	715d                	addi	sp,sp,-80
    80003d7a:	e486                	sd	ra,72(sp)
    80003d7c:	e0a2                	sd	s0,64(sp)
    80003d7e:	fc26                	sd	s1,56(sp)
    80003d80:	f84a                	sd	s2,48(sp)
    80003d82:	f44e                	sd	s3,40(sp)
    80003d84:	f052                	sd	s4,32(sp)
    80003d86:	ec56                	sd	s5,24(sp)
    80003d88:	e85a                	sd	s6,16(sp)
    80003d8a:	0880                	addi	s0,sp,80
    80003d8c:	8b2e                	mv	s6,a1
    80003d8e:	89b2                	mv	s3,a2
    80003d90:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003d92:	fb040593          	addi	a1,s0,-80
    80003d96:	87eff0ef          	jal	ra,80002e14 <nameiparent>
    80003d9a:	84aa                	mv	s1,a0
    80003d9c:	10050b63          	beqz	a0,80003eb2 <create+0x13a>
    return 0;

  ilock(dp);
    80003da0:	9a3fe0ef          	jal	ra,80002742 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003da4:	4601                	li	a2,0
    80003da6:	fb040593          	addi	a1,s0,-80
    80003daa:	8526                	mv	a0,s1
    80003dac:	de3fe0ef          	jal	ra,80002b8e <dirlookup>
    80003db0:	8aaa                	mv	s5,a0
    80003db2:	c521                	beqz	a0,80003dfa <create+0x82>
    iunlockput(dp);
    80003db4:	8526                	mv	a0,s1
    80003db6:	b93fe0ef          	jal	ra,80002948 <iunlockput>
    ilock(ip);
    80003dba:	8556                	mv	a0,s5
    80003dbc:	987fe0ef          	jal	ra,80002742 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003dc0:	000b059b          	sext.w	a1,s6
    80003dc4:	4789                	li	a5,2
    80003dc6:	02f59563          	bne	a1,a5,80003df0 <create+0x78>
    80003dca:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde344>
    80003dce:	37f9                	addiw	a5,a5,-2
    80003dd0:	17c2                	slli	a5,a5,0x30
    80003dd2:	93c1                	srli	a5,a5,0x30
    80003dd4:	4705                	li	a4,1
    80003dd6:	00f76d63          	bltu	a4,a5,80003df0 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003dda:	8556                	mv	a0,s5
    80003ddc:	60a6                	ld	ra,72(sp)
    80003dde:	6406                	ld	s0,64(sp)
    80003de0:	74e2                	ld	s1,56(sp)
    80003de2:	7942                	ld	s2,48(sp)
    80003de4:	79a2                	ld	s3,40(sp)
    80003de6:	7a02                	ld	s4,32(sp)
    80003de8:	6ae2                	ld	s5,24(sp)
    80003dea:	6b42                	ld	s6,16(sp)
    80003dec:	6161                	addi	sp,sp,80
    80003dee:	8082                	ret
    iunlockput(ip);
    80003df0:	8556                	mv	a0,s5
    80003df2:	b57fe0ef          	jal	ra,80002948 <iunlockput>
    return 0;
    80003df6:	4a81                	li	s5,0
    80003df8:	b7cd                	j	80003dda <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80003dfa:	85da                	mv	a1,s6
    80003dfc:	4088                	lw	a0,0(s1)
    80003dfe:	fdafe0ef          	jal	ra,800025d8 <ialloc>
    80003e02:	8a2a                	mv	s4,a0
    80003e04:	cd1d                	beqz	a0,80003e42 <create+0xca>
  ilock(ip);
    80003e06:	93dfe0ef          	jal	ra,80002742 <ilock>
  ip->major = major;
    80003e0a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003e0e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003e12:	4905                	li	s2,1
    80003e14:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003e18:	8552                	mv	a0,s4
    80003e1a:	875fe0ef          	jal	ra,8000268e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003e1e:	000b059b          	sext.w	a1,s6
    80003e22:	03258563          	beq	a1,s2,80003e4c <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80003e26:	004a2603          	lw	a2,4(s4)
    80003e2a:	fb040593          	addi	a1,s0,-80
    80003e2e:	8526                	mv	a0,s1
    80003e30:	f31fe0ef          	jal	ra,80002d60 <dirlink>
    80003e34:	06054363          	bltz	a0,80003e9a <create+0x122>
  iunlockput(dp);
    80003e38:	8526                	mv	a0,s1
    80003e3a:	b0ffe0ef          	jal	ra,80002948 <iunlockput>
  return ip;
    80003e3e:	8ad2                	mv	s5,s4
    80003e40:	bf69                	j	80003dda <create+0x62>
    iunlockput(dp);
    80003e42:	8526                	mv	a0,s1
    80003e44:	b05fe0ef          	jal	ra,80002948 <iunlockput>
    return 0;
    80003e48:	8ad2                	mv	s5,s4
    80003e4a:	bf41                	j	80003dda <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003e4c:	004a2603          	lw	a2,4(s4)
    80003e50:	00004597          	auipc	a1,0x4
    80003e54:	91858593          	addi	a1,a1,-1768 # 80007768 <syscalls+0x308>
    80003e58:	8552                	mv	a0,s4
    80003e5a:	f07fe0ef          	jal	ra,80002d60 <dirlink>
    80003e5e:	02054e63          	bltz	a0,80003e9a <create+0x122>
    80003e62:	40d0                	lw	a2,4(s1)
    80003e64:	00004597          	auipc	a1,0x4
    80003e68:	90c58593          	addi	a1,a1,-1780 # 80007770 <syscalls+0x310>
    80003e6c:	8552                	mv	a0,s4
    80003e6e:	ef3fe0ef          	jal	ra,80002d60 <dirlink>
    80003e72:	02054463          	bltz	a0,80003e9a <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80003e76:	004a2603          	lw	a2,4(s4)
    80003e7a:	fb040593          	addi	a1,s0,-80
    80003e7e:	8526                	mv	a0,s1
    80003e80:	ee1fe0ef          	jal	ra,80002d60 <dirlink>
    80003e84:	00054b63          	bltz	a0,80003e9a <create+0x122>
    dp->nlink++;  // for ".."
    80003e88:	04a4d783          	lhu	a5,74(s1)
    80003e8c:	2785                	addiw	a5,a5,1
    80003e8e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003e92:	8526                	mv	a0,s1
    80003e94:	ffafe0ef          	jal	ra,8000268e <iupdate>
    80003e98:	b745                	j	80003e38 <create+0xc0>
  ip->nlink = 0;
    80003e9a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003e9e:	8552                	mv	a0,s4
    80003ea0:	feefe0ef          	jal	ra,8000268e <iupdate>
  iunlockput(ip);
    80003ea4:	8552                	mv	a0,s4
    80003ea6:	aa3fe0ef          	jal	ra,80002948 <iunlockput>
  iunlockput(dp);
    80003eaa:	8526                	mv	a0,s1
    80003eac:	a9dfe0ef          	jal	ra,80002948 <iunlockput>
  return 0;
    80003eb0:	b72d                	j	80003dda <create+0x62>
    return 0;
    80003eb2:	8aaa                	mv	s5,a0
    80003eb4:	b71d                	j	80003dda <create+0x62>

0000000080003eb6 <sys_dup>:
{
    80003eb6:	7179                	addi	sp,sp,-48
    80003eb8:	f406                	sd	ra,40(sp)
    80003eba:	f022                	sd	s0,32(sp)
    80003ebc:	ec26                	sd	s1,24(sp)
    80003ebe:	e84a                	sd	s2,16(sp)
    80003ec0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80003ec2:	fd840613          	addi	a2,s0,-40
    80003ec6:	4581                	li	a1,0
    80003ec8:	4501                	li	a0,0
    80003eca:	e19ff0ef          	jal	ra,80003ce2 <argfd>
    return -1;
    80003ece:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80003ed0:	00054f63          	bltz	a0,80003eee <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80003ed4:	fd843903          	ld	s2,-40(s0)
    80003ed8:	854a                	mv	a0,s2
    80003eda:	e61ff0ef          	jal	ra,80003d3a <fdalloc>
    80003ede:	84aa                	mv	s1,a0
    return -1;
    80003ee0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80003ee2:	00054663          	bltz	a0,80003eee <sys_dup+0x38>
  filedup(f);
    80003ee6:	854a                	mv	a0,s2
    80003ee8:	cc0ff0ef          	jal	ra,800033a8 <filedup>
  return fd;
    80003eec:	87a6                	mv	a5,s1
}
    80003eee:	853e                	mv	a0,a5
    80003ef0:	70a2                	ld	ra,40(sp)
    80003ef2:	7402                	ld	s0,32(sp)
    80003ef4:	64e2                	ld	s1,24(sp)
    80003ef6:	6942                	ld	s2,16(sp)
    80003ef8:	6145                	addi	sp,sp,48
    80003efa:	8082                	ret

0000000080003efc <sys_read>:
{
    80003efc:	7179                	addi	sp,sp,-48
    80003efe:	f406                	sd	ra,40(sp)
    80003f00:	f022                	sd	s0,32(sp)
    80003f02:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f04:	fd840593          	addi	a1,s0,-40
    80003f08:	4505                	li	a0,1
    80003f0a:	df5fd0ef          	jal	ra,80001cfe <argaddr>
  argint(2, &n);
    80003f0e:	fe440593          	addi	a1,s0,-28
    80003f12:	4509                	li	a0,2
    80003f14:	dcffd0ef          	jal	ra,80001ce2 <argint>
  if(argfd(0, 0, &f) < 0)
    80003f18:	fe840613          	addi	a2,s0,-24
    80003f1c:	4581                	li	a1,0
    80003f1e:	4501                	li	a0,0
    80003f20:	dc3ff0ef          	jal	ra,80003ce2 <argfd>
    80003f24:	87aa                	mv	a5,a0
    return -1;
    80003f26:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f28:	0007ca63          	bltz	a5,80003f3c <sys_read+0x40>
  return fileread(f, p, n);
    80003f2c:	fe442603          	lw	a2,-28(s0)
    80003f30:	fd843583          	ld	a1,-40(s0)
    80003f34:	fe843503          	ld	a0,-24(s0)
    80003f38:	dbcff0ef          	jal	ra,800034f4 <fileread>
}
    80003f3c:	70a2                	ld	ra,40(sp)
    80003f3e:	7402                	ld	s0,32(sp)
    80003f40:	6145                	addi	sp,sp,48
    80003f42:	8082                	ret

0000000080003f44 <sys_write>:
{
    80003f44:	7179                	addi	sp,sp,-48
    80003f46:	f406                	sd	ra,40(sp)
    80003f48:	f022                	sd	s0,32(sp)
    80003f4a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f4c:	fd840593          	addi	a1,s0,-40
    80003f50:	4505                	li	a0,1
    80003f52:	dadfd0ef          	jal	ra,80001cfe <argaddr>
  argint(2, &n);
    80003f56:	fe440593          	addi	a1,s0,-28
    80003f5a:	4509                	li	a0,2
    80003f5c:	d87fd0ef          	jal	ra,80001ce2 <argint>
  if(argfd(0, 0, &f) < 0)
    80003f60:	fe840613          	addi	a2,s0,-24
    80003f64:	4581                	li	a1,0
    80003f66:	4501                	li	a0,0
    80003f68:	d7bff0ef          	jal	ra,80003ce2 <argfd>
    80003f6c:	87aa                	mv	a5,a0
    return -1;
    80003f6e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f70:	0007ca63          	bltz	a5,80003f84 <sys_write+0x40>
  return filewrite(f, p, n);
    80003f74:	fe442603          	lw	a2,-28(s0)
    80003f78:	fd843583          	ld	a1,-40(s0)
    80003f7c:	fe843503          	ld	a0,-24(s0)
    80003f80:	e22ff0ef          	jal	ra,800035a2 <filewrite>
}
    80003f84:	70a2                	ld	ra,40(sp)
    80003f86:	7402                	ld	s0,32(sp)
    80003f88:	6145                	addi	sp,sp,48
    80003f8a:	8082                	ret

0000000080003f8c <sys_close>:
{
    80003f8c:	1101                	addi	sp,sp,-32
    80003f8e:	ec06                	sd	ra,24(sp)
    80003f90:	e822                	sd	s0,16(sp)
    80003f92:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80003f94:	fe040613          	addi	a2,s0,-32
    80003f98:	fec40593          	addi	a1,s0,-20
    80003f9c:	4501                	li	a0,0
    80003f9e:	d45ff0ef          	jal	ra,80003ce2 <argfd>
    return -1;
    80003fa2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80003fa4:	02054063          	bltz	a0,80003fc4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80003fa8:	e8dfc0ef          	jal	ra,80000e34 <myproc>
    80003fac:	fec42783          	lw	a5,-20(s0)
    80003fb0:	07e9                	addi	a5,a5,26
    80003fb2:	078e                	slli	a5,a5,0x3
    80003fb4:	953e                	add	a0,a0,a5
    80003fb6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80003fba:	fe043503          	ld	a0,-32(s0)
    80003fbe:	c30ff0ef          	jal	ra,800033ee <fileclose>
  return 0;
    80003fc2:	4781                	li	a5,0
}
    80003fc4:	853e                	mv	a0,a5
    80003fc6:	60e2                	ld	ra,24(sp)
    80003fc8:	6442                	ld	s0,16(sp)
    80003fca:	6105                	addi	sp,sp,32
    80003fcc:	8082                	ret

0000000080003fce <sys_fstat>:
{
    80003fce:	1101                	addi	sp,sp,-32
    80003fd0:	ec06                	sd	ra,24(sp)
    80003fd2:	e822                	sd	s0,16(sp)
    80003fd4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80003fd6:	fe040593          	addi	a1,s0,-32
    80003fda:	4505                	li	a0,1
    80003fdc:	d23fd0ef          	jal	ra,80001cfe <argaddr>
  if(argfd(0, 0, &f) < 0)
    80003fe0:	fe840613          	addi	a2,s0,-24
    80003fe4:	4581                	li	a1,0
    80003fe6:	4501                	li	a0,0
    80003fe8:	cfbff0ef          	jal	ra,80003ce2 <argfd>
    80003fec:	87aa                	mv	a5,a0
    return -1;
    80003fee:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003ff0:	0007c863          	bltz	a5,80004000 <sys_fstat+0x32>
  return filestat(f, st);
    80003ff4:	fe043583          	ld	a1,-32(s0)
    80003ff8:	fe843503          	ld	a0,-24(s0)
    80003ffc:	c9aff0ef          	jal	ra,80003496 <filestat>
}
    80004000:	60e2                	ld	ra,24(sp)
    80004002:	6442                	ld	s0,16(sp)
    80004004:	6105                	addi	sp,sp,32
    80004006:	8082                	ret

0000000080004008 <sys_link>:
{
    80004008:	7169                	addi	sp,sp,-304
    8000400a:	f606                	sd	ra,296(sp)
    8000400c:	f222                	sd	s0,288(sp)
    8000400e:	ee26                	sd	s1,280(sp)
    80004010:	ea4a                	sd	s2,272(sp)
    80004012:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004014:	08000613          	li	a2,128
    80004018:	ed040593          	addi	a1,s0,-304
    8000401c:	4501                	li	a0,0
    8000401e:	cfdfd0ef          	jal	ra,80001d1a <argstr>
    return -1;
    80004022:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004024:	0c054663          	bltz	a0,800040f0 <sys_link+0xe8>
    80004028:	08000613          	li	a2,128
    8000402c:	f5040593          	addi	a1,s0,-176
    80004030:	4505                	li	a0,1
    80004032:	ce9fd0ef          	jal	ra,80001d1a <argstr>
    return -1;
    80004036:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004038:	0a054c63          	bltz	a0,800040f0 <sys_link+0xe8>
  begin_op();
    8000403c:	f9bfe0ef          	jal	ra,80002fd6 <begin_op>
  if((ip = namei(old)) == 0){
    80004040:	ed040513          	addi	a0,s0,-304
    80004044:	db7fe0ef          	jal	ra,80002dfa <namei>
    80004048:	84aa                	mv	s1,a0
    8000404a:	c525                	beqz	a0,800040b2 <sys_link+0xaa>
  ilock(ip);
    8000404c:	ef6fe0ef          	jal	ra,80002742 <ilock>
  if(ip->type == T_DIR){
    80004050:	04449703          	lh	a4,68(s1)
    80004054:	4785                	li	a5,1
    80004056:	06f70263          	beq	a4,a5,800040ba <sys_link+0xb2>
  ip->nlink++;
    8000405a:	04a4d783          	lhu	a5,74(s1)
    8000405e:	2785                	addiw	a5,a5,1
    80004060:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004064:	8526                	mv	a0,s1
    80004066:	e28fe0ef          	jal	ra,8000268e <iupdate>
  iunlock(ip);
    8000406a:	8526                	mv	a0,s1
    8000406c:	f80fe0ef          	jal	ra,800027ec <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004070:	fd040593          	addi	a1,s0,-48
    80004074:	f5040513          	addi	a0,s0,-176
    80004078:	d9dfe0ef          	jal	ra,80002e14 <nameiparent>
    8000407c:	892a                	mv	s2,a0
    8000407e:	c921                	beqz	a0,800040ce <sys_link+0xc6>
  ilock(dp);
    80004080:	ec2fe0ef          	jal	ra,80002742 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004084:	00092703          	lw	a4,0(s2)
    80004088:	409c                	lw	a5,0(s1)
    8000408a:	02f71f63          	bne	a4,a5,800040c8 <sys_link+0xc0>
    8000408e:	40d0                	lw	a2,4(s1)
    80004090:	fd040593          	addi	a1,s0,-48
    80004094:	854a                	mv	a0,s2
    80004096:	ccbfe0ef          	jal	ra,80002d60 <dirlink>
    8000409a:	02054763          	bltz	a0,800040c8 <sys_link+0xc0>
  iunlockput(dp);
    8000409e:	854a                	mv	a0,s2
    800040a0:	8a9fe0ef          	jal	ra,80002948 <iunlockput>
  iput(ip);
    800040a4:	8526                	mv	a0,s1
    800040a6:	81bfe0ef          	jal	ra,800028c0 <iput>
  end_op();
    800040aa:	f9bfe0ef          	jal	ra,80003044 <end_op>
  return 0;
    800040ae:	4781                	li	a5,0
    800040b0:	a081                	j	800040f0 <sys_link+0xe8>
    end_op();
    800040b2:	f93fe0ef          	jal	ra,80003044 <end_op>
    return -1;
    800040b6:	57fd                	li	a5,-1
    800040b8:	a825                	j	800040f0 <sys_link+0xe8>
    iunlockput(ip);
    800040ba:	8526                	mv	a0,s1
    800040bc:	88dfe0ef          	jal	ra,80002948 <iunlockput>
    end_op();
    800040c0:	f85fe0ef          	jal	ra,80003044 <end_op>
    return -1;
    800040c4:	57fd                	li	a5,-1
    800040c6:	a02d                	j	800040f0 <sys_link+0xe8>
    iunlockput(dp);
    800040c8:	854a                	mv	a0,s2
    800040ca:	87ffe0ef          	jal	ra,80002948 <iunlockput>
  ilock(ip);
    800040ce:	8526                	mv	a0,s1
    800040d0:	e72fe0ef          	jal	ra,80002742 <ilock>
  ip->nlink--;
    800040d4:	04a4d783          	lhu	a5,74(s1)
    800040d8:	37fd                	addiw	a5,a5,-1
    800040da:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800040de:	8526                	mv	a0,s1
    800040e0:	daefe0ef          	jal	ra,8000268e <iupdate>
  iunlockput(ip);
    800040e4:	8526                	mv	a0,s1
    800040e6:	863fe0ef          	jal	ra,80002948 <iunlockput>
  end_op();
    800040ea:	f5bfe0ef          	jal	ra,80003044 <end_op>
  return -1;
    800040ee:	57fd                	li	a5,-1
}
    800040f0:	853e                	mv	a0,a5
    800040f2:	70b2                	ld	ra,296(sp)
    800040f4:	7412                	ld	s0,288(sp)
    800040f6:	64f2                	ld	s1,280(sp)
    800040f8:	6952                	ld	s2,272(sp)
    800040fa:	6155                	addi	sp,sp,304
    800040fc:	8082                	ret

00000000800040fe <sys_unlink>:
{
    800040fe:	7151                	addi	sp,sp,-240
    80004100:	f586                	sd	ra,232(sp)
    80004102:	f1a2                	sd	s0,224(sp)
    80004104:	eda6                	sd	s1,216(sp)
    80004106:	e9ca                	sd	s2,208(sp)
    80004108:	e5ce                	sd	s3,200(sp)
    8000410a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000410c:	08000613          	li	a2,128
    80004110:	f3040593          	addi	a1,s0,-208
    80004114:	4501                	li	a0,0
    80004116:	c05fd0ef          	jal	ra,80001d1a <argstr>
    8000411a:	12054b63          	bltz	a0,80004250 <sys_unlink+0x152>
  begin_op();
    8000411e:	eb9fe0ef          	jal	ra,80002fd6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004122:	fb040593          	addi	a1,s0,-80
    80004126:	f3040513          	addi	a0,s0,-208
    8000412a:	cebfe0ef          	jal	ra,80002e14 <nameiparent>
    8000412e:	84aa                	mv	s1,a0
    80004130:	c54d                	beqz	a0,800041da <sys_unlink+0xdc>
  ilock(dp);
    80004132:	e10fe0ef          	jal	ra,80002742 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004136:	00003597          	auipc	a1,0x3
    8000413a:	63258593          	addi	a1,a1,1586 # 80007768 <syscalls+0x308>
    8000413e:	fb040513          	addi	a0,s0,-80
    80004142:	a37fe0ef          	jal	ra,80002b78 <namecmp>
    80004146:	10050a63          	beqz	a0,8000425a <sys_unlink+0x15c>
    8000414a:	00003597          	auipc	a1,0x3
    8000414e:	62658593          	addi	a1,a1,1574 # 80007770 <syscalls+0x310>
    80004152:	fb040513          	addi	a0,s0,-80
    80004156:	a23fe0ef          	jal	ra,80002b78 <namecmp>
    8000415a:	10050063          	beqz	a0,8000425a <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000415e:	f2c40613          	addi	a2,s0,-212
    80004162:	fb040593          	addi	a1,s0,-80
    80004166:	8526                	mv	a0,s1
    80004168:	a27fe0ef          	jal	ra,80002b8e <dirlookup>
    8000416c:	892a                	mv	s2,a0
    8000416e:	0e050663          	beqz	a0,8000425a <sys_unlink+0x15c>
  ilock(ip);
    80004172:	dd0fe0ef          	jal	ra,80002742 <ilock>
  if(ip->nlink < 1)
    80004176:	04a91783          	lh	a5,74(s2)
    8000417a:	06f05463          	blez	a5,800041e2 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000417e:	04491703          	lh	a4,68(s2)
    80004182:	4785                	li	a5,1
    80004184:	06f70563          	beq	a4,a5,800041ee <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004188:	4641                	li	a2,16
    8000418a:	4581                	li	a1,0
    8000418c:	fc040513          	addi	a0,s0,-64
    80004190:	fbffb0ef          	jal	ra,8000014e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004194:	4741                	li	a4,16
    80004196:	f2c42683          	lw	a3,-212(s0)
    8000419a:	fc040613          	addi	a2,s0,-64
    8000419e:	4581                	li	a1,0
    800041a0:	8526                	mv	a0,s1
    800041a2:	8d5fe0ef          	jal	ra,80002a76 <writei>
    800041a6:	47c1                	li	a5,16
    800041a8:	08f51563          	bne	a0,a5,80004232 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800041ac:	04491703          	lh	a4,68(s2)
    800041b0:	4785                	li	a5,1
    800041b2:	08f70663          	beq	a4,a5,8000423e <sys_unlink+0x140>
  iunlockput(dp);
    800041b6:	8526                	mv	a0,s1
    800041b8:	f90fe0ef          	jal	ra,80002948 <iunlockput>
  ip->nlink--;
    800041bc:	04a95783          	lhu	a5,74(s2)
    800041c0:	37fd                	addiw	a5,a5,-1
    800041c2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800041c6:	854a                	mv	a0,s2
    800041c8:	cc6fe0ef          	jal	ra,8000268e <iupdate>
  iunlockput(ip);
    800041cc:	854a                	mv	a0,s2
    800041ce:	f7afe0ef          	jal	ra,80002948 <iunlockput>
  end_op();
    800041d2:	e73fe0ef          	jal	ra,80003044 <end_op>
  return 0;
    800041d6:	4501                	li	a0,0
    800041d8:	a079                	j	80004266 <sys_unlink+0x168>
    end_op();
    800041da:	e6bfe0ef          	jal	ra,80003044 <end_op>
    return -1;
    800041de:	557d                	li	a0,-1
    800041e0:	a059                	j	80004266 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800041e2:	00003517          	auipc	a0,0x3
    800041e6:	59650513          	addi	a0,a0,1430 # 80007778 <syscalls+0x318>
    800041ea:	1d8010ef          	jal	ra,800053c2 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800041ee:	04c92703          	lw	a4,76(s2)
    800041f2:	02000793          	li	a5,32
    800041f6:	f8e7f9e3          	bgeu	a5,a4,80004188 <sys_unlink+0x8a>
    800041fa:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041fe:	4741                	li	a4,16
    80004200:	86ce                	mv	a3,s3
    80004202:	f1840613          	addi	a2,s0,-232
    80004206:	4581                	li	a1,0
    80004208:	854a                	mv	a0,s2
    8000420a:	f88fe0ef          	jal	ra,80002992 <readi>
    8000420e:	47c1                	li	a5,16
    80004210:	00f51b63          	bne	a0,a5,80004226 <sys_unlink+0x128>
    if(de.inum != 0)
    80004214:	f1845783          	lhu	a5,-232(s0)
    80004218:	ef95                	bnez	a5,80004254 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000421a:	29c1                	addiw	s3,s3,16
    8000421c:	04c92783          	lw	a5,76(s2)
    80004220:	fcf9efe3          	bltu	s3,a5,800041fe <sys_unlink+0x100>
    80004224:	b795                	j	80004188 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004226:	00003517          	auipc	a0,0x3
    8000422a:	56a50513          	addi	a0,a0,1386 # 80007790 <syscalls+0x330>
    8000422e:	194010ef          	jal	ra,800053c2 <panic>
    panic("unlink: writei");
    80004232:	00003517          	auipc	a0,0x3
    80004236:	57650513          	addi	a0,a0,1398 # 800077a8 <syscalls+0x348>
    8000423a:	188010ef          	jal	ra,800053c2 <panic>
    dp->nlink--;
    8000423e:	04a4d783          	lhu	a5,74(s1)
    80004242:	37fd                	addiw	a5,a5,-1
    80004244:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004248:	8526                	mv	a0,s1
    8000424a:	c44fe0ef          	jal	ra,8000268e <iupdate>
    8000424e:	b7a5                	j	800041b6 <sys_unlink+0xb8>
    return -1;
    80004250:	557d                	li	a0,-1
    80004252:	a811                	j	80004266 <sys_unlink+0x168>
    iunlockput(ip);
    80004254:	854a                	mv	a0,s2
    80004256:	ef2fe0ef          	jal	ra,80002948 <iunlockput>
  iunlockput(dp);
    8000425a:	8526                	mv	a0,s1
    8000425c:	eecfe0ef          	jal	ra,80002948 <iunlockput>
  end_op();
    80004260:	de5fe0ef          	jal	ra,80003044 <end_op>
  return -1;
    80004264:	557d                	li	a0,-1
}
    80004266:	70ae                	ld	ra,232(sp)
    80004268:	740e                	ld	s0,224(sp)
    8000426a:	64ee                	ld	s1,216(sp)
    8000426c:	694e                	ld	s2,208(sp)
    8000426e:	69ae                	ld	s3,200(sp)
    80004270:	616d                	addi	sp,sp,240
    80004272:	8082                	ret

0000000080004274 <sys_open>:

uint64
sys_open(void)
{
    80004274:	7131                	addi	sp,sp,-192
    80004276:	fd06                	sd	ra,184(sp)
    80004278:	f922                	sd	s0,176(sp)
    8000427a:	f526                	sd	s1,168(sp)
    8000427c:	f14a                	sd	s2,160(sp)
    8000427e:	ed4e                	sd	s3,152(sp)
    80004280:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004282:	f4c40593          	addi	a1,s0,-180
    80004286:	4505                	li	a0,1
    80004288:	a5bfd0ef          	jal	ra,80001ce2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000428c:	08000613          	li	a2,128
    80004290:	f5040593          	addi	a1,s0,-176
    80004294:	4501                	li	a0,0
    80004296:	a85fd0ef          	jal	ra,80001d1a <argstr>
    8000429a:	87aa                	mv	a5,a0
    return -1;
    8000429c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000429e:	0807cd63          	bltz	a5,80004338 <sys_open+0xc4>

  begin_op();
    800042a2:	d35fe0ef          	jal	ra,80002fd6 <begin_op>

  if(omode & O_CREATE){
    800042a6:	f4c42783          	lw	a5,-180(s0)
    800042aa:	2007f793          	andi	a5,a5,512
    800042ae:	c3c5                	beqz	a5,8000434e <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800042b0:	4681                	li	a3,0
    800042b2:	4601                	li	a2,0
    800042b4:	4589                	li	a1,2
    800042b6:	f5040513          	addi	a0,s0,-176
    800042ba:	abfff0ef          	jal	ra,80003d78 <create>
    800042be:	84aa                	mv	s1,a0
    if(ip == 0){
    800042c0:	c159                	beqz	a0,80004346 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800042c2:	04449703          	lh	a4,68(s1)
    800042c6:	478d                	li	a5,3
    800042c8:	00f71763          	bne	a4,a5,800042d6 <sys_open+0x62>
    800042cc:	0464d703          	lhu	a4,70(s1)
    800042d0:	47a5                	li	a5,9
    800042d2:	0ae7e963          	bltu	a5,a4,80004384 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800042d6:	874ff0ef          	jal	ra,8000334a <filealloc>
    800042da:	89aa                	mv	s3,a0
    800042dc:	0c050963          	beqz	a0,800043ae <sys_open+0x13a>
    800042e0:	a5bff0ef          	jal	ra,80003d3a <fdalloc>
    800042e4:	892a                	mv	s2,a0
    800042e6:	0c054163          	bltz	a0,800043a8 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800042ea:	04449703          	lh	a4,68(s1)
    800042ee:	478d                	li	a5,3
    800042f0:	0af70163          	beq	a4,a5,80004392 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800042f4:	4789                	li	a5,2
    800042f6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800042fa:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800042fe:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004302:	f4c42783          	lw	a5,-180(s0)
    80004306:	0017c713          	xori	a4,a5,1
    8000430a:	8b05                	andi	a4,a4,1
    8000430c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004310:	0037f713          	andi	a4,a5,3
    80004314:	00e03733          	snez	a4,a4
    80004318:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000431c:	4007f793          	andi	a5,a5,1024
    80004320:	c791                	beqz	a5,8000432c <sys_open+0xb8>
    80004322:	04449703          	lh	a4,68(s1)
    80004326:	4789                	li	a5,2
    80004328:	06f70c63          	beq	a4,a5,800043a0 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    8000432c:	8526                	mv	a0,s1
    8000432e:	cbefe0ef          	jal	ra,800027ec <iunlock>
  end_op();
    80004332:	d13fe0ef          	jal	ra,80003044 <end_op>

  return fd;
    80004336:	854a                	mv	a0,s2
}
    80004338:	70ea                	ld	ra,184(sp)
    8000433a:	744a                	ld	s0,176(sp)
    8000433c:	74aa                	ld	s1,168(sp)
    8000433e:	790a                	ld	s2,160(sp)
    80004340:	69ea                	ld	s3,152(sp)
    80004342:	6129                	addi	sp,sp,192
    80004344:	8082                	ret
      end_op();
    80004346:	cfffe0ef          	jal	ra,80003044 <end_op>
      return -1;
    8000434a:	557d                	li	a0,-1
    8000434c:	b7f5                	j	80004338 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    8000434e:	f5040513          	addi	a0,s0,-176
    80004352:	aa9fe0ef          	jal	ra,80002dfa <namei>
    80004356:	84aa                	mv	s1,a0
    80004358:	c115                	beqz	a0,8000437c <sys_open+0x108>
    ilock(ip);
    8000435a:	be8fe0ef          	jal	ra,80002742 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000435e:	04449703          	lh	a4,68(s1)
    80004362:	4785                	li	a5,1
    80004364:	f4f71fe3          	bne	a4,a5,800042c2 <sys_open+0x4e>
    80004368:	f4c42783          	lw	a5,-180(s0)
    8000436c:	d7ad                	beqz	a5,800042d6 <sys_open+0x62>
      iunlockput(ip);
    8000436e:	8526                	mv	a0,s1
    80004370:	dd8fe0ef          	jal	ra,80002948 <iunlockput>
      end_op();
    80004374:	cd1fe0ef          	jal	ra,80003044 <end_op>
      return -1;
    80004378:	557d                	li	a0,-1
    8000437a:	bf7d                	j	80004338 <sys_open+0xc4>
      end_op();
    8000437c:	cc9fe0ef          	jal	ra,80003044 <end_op>
      return -1;
    80004380:	557d                	li	a0,-1
    80004382:	bf5d                	j	80004338 <sys_open+0xc4>
    iunlockput(ip);
    80004384:	8526                	mv	a0,s1
    80004386:	dc2fe0ef          	jal	ra,80002948 <iunlockput>
    end_op();
    8000438a:	cbbfe0ef          	jal	ra,80003044 <end_op>
    return -1;
    8000438e:	557d                	li	a0,-1
    80004390:	b765                	j	80004338 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80004392:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004396:	04649783          	lh	a5,70(s1)
    8000439a:	02f99223          	sh	a5,36(s3)
    8000439e:	b785                	j	800042fe <sys_open+0x8a>
    itrunc(ip);
    800043a0:	8526                	mv	a0,s1
    800043a2:	c8afe0ef          	jal	ra,8000282c <itrunc>
    800043a6:	b759                	j	8000432c <sys_open+0xb8>
      fileclose(f);
    800043a8:	854e                	mv	a0,s3
    800043aa:	844ff0ef          	jal	ra,800033ee <fileclose>
    iunlockput(ip);
    800043ae:	8526                	mv	a0,s1
    800043b0:	d98fe0ef          	jal	ra,80002948 <iunlockput>
    end_op();
    800043b4:	c91fe0ef          	jal	ra,80003044 <end_op>
    return -1;
    800043b8:	557d                	li	a0,-1
    800043ba:	bfbd                	j	80004338 <sys_open+0xc4>

00000000800043bc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800043bc:	7175                	addi	sp,sp,-144
    800043be:	e506                	sd	ra,136(sp)
    800043c0:	e122                	sd	s0,128(sp)
    800043c2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800043c4:	c13fe0ef          	jal	ra,80002fd6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800043c8:	08000613          	li	a2,128
    800043cc:	f7040593          	addi	a1,s0,-144
    800043d0:	4501                	li	a0,0
    800043d2:	949fd0ef          	jal	ra,80001d1a <argstr>
    800043d6:	02054363          	bltz	a0,800043fc <sys_mkdir+0x40>
    800043da:	4681                	li	a3,0
    800043dc:	4601                	li	a2,0
    800043de:	4585                	li	a1,1
    800043e0:	f7040513          	addi	a0,s0,-144
    800043e4:	995ff0ef          	jal	ra,80003d78 <create>
    800043e8:	c911                	beqz	a0,800043fc <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800043ea:	d5efe0ef          	jal	ra,80002948 <iunlockput>
  end_op();
    800043ee:	c57fe0ef          	jal	ra,80003044 <end_op>
  return 0;
    800043f2:	4501                	li	a0,0
}
    800043f4:	60aa                	ld	ra,136(sp)
    800043f6:	640a                	ld	s0,128(sp)
    800043f8:	6149                	addi	sp,sp,144
    800043fa:	8082                	ret
    end_op();
    800043fc:	c49fe0ef          	jal	ra,80003044 <end_op>
    return -1;
    80004400:	557d                	li	a0,-1
    80004402:	bfcd                	j	800043f4 <sys_mkdir+0x38>

0000000080004404 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004404:	7135                	addi	sp,sp,-160
    80004406:	ed06                	sd	ra,152(sp)
    80004408:	e922                	sd	s0,144(sp)
    8000440a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000440c:	bcbfe0ef          	jal	ra,80002fd6 <begin_op>
  argint(1, &major);
    80004410:	f6c40593          	addi	a1,s0,-148
    80004414:	4505                	li	a0,1
    80004416:	8cdfd0ef          	jal	ra,80001ce2 <argint>
  argint(2, &minor);
    8000441a:	f6840593          	addi	a1,s0,-152
    8000441e:	4509                	li	a0,2
    80004420:	8c3fd0ef          	jal	ra,80001ce2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004424:	08000613          	li	a2,128
    80004428:	f7040593          	addi	a1,s0,-144
    8000442c:	4501                	li	a0,0
    8000442e:	8edfd0ef          	jal	ra,80001d1a <argstr>
    80004432:	02054563          	bltz	a0,8000445c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004436:	f6841683          	lh	a3,-152(s0)
    8000443a:	f6c41603          	lh	a2,-148(s0)
    8000443e:	458d                	li	a1,3
    80004440:	f7040513          	addi	a0,s0,-144
    80004444:	935ff0ef          	jal	ra,80003d78 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004448:	c911                	beqz	a0,8000445c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000444a:	cfefe0ef          	jal	ra,80002948 <iunlockput>
  end_op();
    8000444e:	bf7fe0ef          	jal	ra,80003044 <end_op>
  return 0;
    80004452:	4501                	li	a0,0
}
    80004454:	60ea                	ld	ra,152(sp)
    80004456:	644a                	ld	s0,144(sp)
    80004458:	610d                	addi	sp,sp,160
    8000445a:	8082                	ret
    end_op();
    8000445c:	be9fe0ef          	jal	ra,80003044 <end_op>
    return -1;
    80004460:	557d                	li	a0,-1
    80004462:	bfcd                	j	80004454 <sys_mknod+0x50>

0000000080004464 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004464:	7135                	addi	sp,sp,-160
    80004466:	ed06                	sd	ra,152(sp)
    80004468:	e922                	sd	s0,144(sp)
    8000446a:	e526                	sd	s1,136(sp)
    8000446c:	e14a                	sd	s2,128(sp)
    8000446e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004470:	9c5fc0ef          	jal	ra,80000e34 <myproc>
    80004474:	892a                	mv	s2,a0

  begin_op();
    80004476:	b61fe0ef          	jal	ra,80002fd6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000447a:	08000613          	li	a2,128
    8000447e:	f6040593          	addi	a1,s0,-160
    80004482:	4501                	li	a0,0
    80004484:	897fd0ef          	jal	ra,80001d1a <argstr>
    80004488:	04054163          	bltz	a0,800044ca <sys_chdir+0x66>
    8000448c:	f6040513          	addi	a0,s0,-160
    80004490:	96bfe0ef          	jal	ra,80002dfa <namei>
    80004494:	84aa                	mv	s1,a0
    80004496:	c915                	beqz	a0,800044ca <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004498:	aaafe0ef          	jal	ra,80002742 <ilock>
  if(ip->type != T_DIR){
    8000449c:	04449703          	lh	a4,68(s1)
    800044a0:	4785                	li	a5,1
    800044a2:	02f71863          	bne	a4,a5,800044d2 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800044a6:	8526                	mv	a0,s1
    800044a8:	b44fe0ef          	jal	ra,800027ec <iunlock>
  iput(p->cwd);
    800044ac:	15093503          	ld	a0,336(s2)
    800044b0:	c10fe0ef          	jal	ra,800028c0 <iput>
  end_op();
    800044b4:	b91fe0ef          	jal	ra,80003044 <end_op>
  p->cwd = ip;
    800044b8:	14993823          	sd	s1,336(s2)
  return 0;
    800044bc:	4501                	li	a0,0
}
    800044be:	60ea                	ld	ra,152(sp)
    800044c0:	644a                	ld	s0,144(sp)
    800044c2:	64aa                	ld	s1,136(sp)
    800044c4:	690a                	ld	s2,128(sp)
    800044c6:	610d                	addi	sp,sp,160
    800044c8:	8082                	ret
    end_op();
    800044ca:	b7bfe0ef          	jal	ra,80003044 <end_op>
    return -1;
    800044ce:	557d                	li	a0,-1
    800044d0:	b7fd                	j	800044be <sys_chdir+0x5a>
    iunlockput(ip);
    800044d2:	8526                	mv	a0,s1
    800044d4:	c74fe0ef          	jal	ra,80002948 <iunlockput>
    end_op();
    800044d8:	b6dfe0ef          	jal	ra,80003044 <end_op>
    return -1;
    800044dc:	557d                	li	a0,-1
    800044de:	b7c5                	j	800044be <sys_chdir+0x5a>

00000000800044e0 <sys_exec>:

uint64
sys_exec(void)
{
    800044e0:	7145                	addi	sp,sp,-464
    800044e2:	e786                	sd	ra,456(sp)
    800044e4:	e3a2                	sd	s0,448(sp)
    800044e6:	ff26                	sd	s1,440(sp)
    800044e8:	fb4a                	sd	s2,432(sp)
    800044ea:	f74e                	sd	s3,424(sp)
    800044ec:	f352                	sd	s4,416(sp)
    800044ee:	ef56                	sd	s5,408(sp)
    800044f0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800044f2:	e3840593          	addi	a1,s0,-456
    800044f6:	4505                	li	a0,1
    800044f8:	807fd0ef          	jal	ra,80001cfe <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800044fc:	08000613          	li	a2,128
    80004500:	f4040593          	addi	a1,s0,-192
    80004504:	4501                	li	a0,0
    80004506:	815fd0ef          	jal	ra,80001d1a <argstr>
    8000450a:	87aa                	mv	a5,a0
    return -1;
    8000450c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000450e:	0a07c563          	bltz	a5,800045b8 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80004512:	10000613          	li	a2,256
    80004516:	4581                	li	a1,0
    80004518:	e4040513          	addi	a0,s0,-448
    8000451c:	c33fb0ef          	jal	ra,8000014e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004520:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004524:	89a6                	mv	s3,s1
    80004526:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004528:	02000a13          	li	s4,32
    8000452c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004530:	00391513          	slli	a0,s2,0x3
    80004534:	e3040593          	addi	a1,s0,-464
    80004538:	e3843783          	ld	a5,-456(s0)
    8000453c:	953e                	add	a0,a0,a5
    8000453e:	f1afd0ef          	jal	ra,80001c58 <fetchaddr>
    80004542:	02054663          	bltz	a0,8000456e <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80004546:	e3043783          	ld	a5,-464(s0)
    8000454a:	cf8d                	beqz	a5,80004584 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000454c:	bb3fb0ef          	jal	ra,800000fe <kalloc>
    80004550:	85aa                	mv	a1,a0
    80004552:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004556:	cd01                	beqz	a0,8000456e <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004558:	6605                	lui	a2,0x1
    8000455a:	e3043503          	ld	a0,-464(s0)
    8000455e:	f44fd0ef          	jal	ra,80001ca2 <fetchstr>
    80004562:	00054663          	bltz	a0,8000456e <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80004566:	0905                	addi	s2,s2,1
    80004568:	09a1                	addi	s3,s3,8
    8000456a:	fd4911e3          	bne	s2,s4,8000452c <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000456e:	f4040913          	addi	s2,s0,-192
    80004572:	6088                	ld	a0,0(s1)
    80004574:	c129                	beqz	a0,800045b6 <sys_exec+0xd6>
    kfree(argv[i]);
    80004576:	aa7fb0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000457a:	04a1                	addi	s1,s1,8
    8000457c:	ff249be3          	bne	s1,s2,80004572 <sys_exec+0x92>
  return -1;
    80004580:	557d                	li	a0,-1
    80004582:	a81d                	j	800045b8 <sys_exec+0xd8>
      argv[i] = 0;
    80004584:	0a8e                	slli	s5,s5,0x3
    80004586:	fc0a8793          	addi	a5,s5,-64
    8000458a:	00878ab3          	add	s5,a5,s0
    8000458e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004592:	e4040593          	addi	a1,s0,-448
    80004596:	f4040513          	addi	a0,s0,-192
    8000459a:	bf6ff0ef          	jal	ra,80003990 <exec>
    8000459e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045a0:	f4040993          	addi	s3,s0,-192
    800045a4:	6088                	ld	a0,0(s1)
    800045a6:	c511                	beqz	a0,800045b2 <sys_exec+0xd2>
    kfree(argv[i]);
    800045a8:	a75fb0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045ac:	04a1                	addi	s1,s1,8
    800045ae:	ff349be3          	bne	s1,s3,800045a4 <sys_exec+0xc4>
  return ret;
    800045b2:	854a                	mv	a0,s2
    800045b4:	a011                	j	800045b8 <sys_exec+0xd8>
  return -1;
    800045b6:	557d                	li	a0,-1
}
    800045b8:	60be                	ld	ra,456(sp)
    800045ba:	641e                	ld	s0,448(sp)
    800045bc:	74fa                	ld	s1,440(sp)
    800045be:	795a                	ld	s2,432(sp)
    800045c0:	79ba                	ld	s3,424(sp)
    800045c2:	7a1a                	ld	s4,416(sp)
    800045c4:	6afa                	ld	s5,408(sp)
    800045c6:	6179                	addi	sp,sp,464
    800045c8:	8082                	ret

00000000800045ca <sys_pipe>:

uint64
sys_pipe(void)
{
    800045ca:	7139                	addi	sp,sp,-64
    800045cc:	fc06                	sd	ra,56(sp)
    800045ce:	f822                	sd	s0,48(sp)
    800045d0:	f426                	sd	s1,40(sp)
    800045d2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800045d4:	861fc0ef          	jal	ra,80000e34 <myproc>
    800045d8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800045da:	fd840593          	addi	a1,s0,-40
    800045de:	4501                	li	a0,0
    800045e0:	f1efd0ef          	jal	ra,80001cfe <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800045e4:	fc840593          	addi	a1,s0,-56
    800045e8:	fd040513          	addi	a0,s0,-48
    800045ec:	8ceff0ef          	jal	ra,800036ba <pipealloc>
    return -1;
    800045f0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800045f2:	0a054463          	bltz	a0,8000469a <sys_pipe+0xd0>
  fd0 = -1;
    800045f6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800045fa:	fd043503          	ld	a0,-48(s0)
    800045fe:	f3cff0ef          	jal	ra,80003d3a <fdalloc>
    80004602:	fca42223          	sw	a0,-60(s0)
    80004606:	08054163          	bltz	a0,80004688 <sys_pipe+0xbe>
    8000460a:	fc843503          	ld	a0,-56(s0)
    8000460e:	f2cff0ef          	jal	ra,80003d3a <fdalloc>
    80004612:	fca42023          	sw	a0,-64(s0)
    80004616:	06054063          	bltz	a0,80004676 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000461a:	4691                	li	a3,4
    8000461c:	fc440613          	addi	a2,s0,-60
    80004620:	fd843583          	ld	a1,-40(s0)
    80004624:	68a8                	ld	a0,80(s1)
    80004626:	bb8fc0ef          	jal	ra,800009de <copyout>
    8000462a:	00054e63          	bltz	a0,80004646 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000462e:	4691                	li	a3,4
    80004630:	fc040613          	addi	a2,s0,-64
    80004634:	fd843583          	ld	a1,-40(s0)
    80004638:	0591                	addi	a1,a1,4
    8000463a:	68a8                	ld	a0,80(s1)
    8000463c:	ba2fc0ef          	jal	ra,800009de <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004640:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004642:	04055c63          	bgez	a0,8000469a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004646:	fc442783          	lw	a5,-60(s0)
    8000464a:	07e9                	addi	a5,a5,26
    8000464c:	078e                	slli	a5,a5,0x3
    8000464e:	97a6                	add	a5,a5,s1
    80004650:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004654:	fc042783          	lw	a5,-64(s0)
    80004658:	07e9                	addi	a5,a5,26
    8000465a:	078e                	slli	a5,a5,0x3
    8000465c:	94be                	add	s1,s1,a5
    8000465e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004662:	fd043503          	ld	a0,-48(s0)
    80004666:	d89fe0ef          	jal	ra,800033ee <fileclose>
    fileclose(wf);
    8000466a:	fc843503          	ld	a0,-56(s0)
    8000466e:	d81fe0ef          	jal	ra,800033ee <fileclose>
    return -1;
    80004672:	57fd                	li	a5,-1
    80004674:	a01d                	j	8000469a <sys_pipe+0xd0>
    if(fd0 >= 0)
    80004676:	fc442783          	lw	a5,-60(s0)
    8000467a:	0007c763          	bltz	a5,80004688 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000467e:	07e9                	addi	a5,a5,26
    80004680:	078e                	slli	a5,a5,0x3
    80004682:	97a6                	add	a5,a5,s1
    80004684:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80004688:	fd043503          	ld	a0,-48(s0)
    8000468c:	d63fe0ef          	jal	ra,800033ee <fileclose>
    fileclose(wf);
    80004690:	fc843503          	ld	a0,-56(s0)
    80004694:	d5bfe0ef          	jal	ra,800033ee <fileclose>
    return -1;
    80004698:	57fd                	li	a5,-1
}
    8000469a:	853e                	mv	a0,a5
    8000469c:	70e2                	ld	ra,56(sp)
    8000469e:	7442                	ld	s0,48(sp)
    800046a0:	74a2                	ld	s1,40(sp)
    800046a2:	6121                	addi	sp,sp,64
    800046a4:	8082                	ret
	...

00000000800046b0 <kernelvec>:
    800046b0:	7111                	addi	sp,sp,-256
    800046b2:	e006                	sd	ra,0(sp)
    800046b4:	e40a                	sd	sp,8(sp)
    800046b6:	e80e                	sd	gp,16(sp)
    800046b8:	ec12                	sd	tp,24(sp)
    800046ba:	f016                	sd	t0,32(sp)
    800046bc:	f41a                	sd	t1,40(sp)
    800046be:	f81e                	sd	t2,48(sp)
    800046c0:	e4aa                	sd	a0,72(sp)
    800046c2:	e8ae                	sd	a1,80(sp)
    800046c4:	ecb2                	sd	a2,88(sp)
    800046c6:	f0b6                	sd	a3,96(sp)
    800046c8:	f4ba                	sd	a4,104(sp)
    800046ca:	f8be                	sd	a5,112(sp)
    800046cc:	fcc2                	sd	a6,120(sp)
    800046ce:	e146                	sd	a7,128(sp)
    800046d0:	edf2                	sd	t3,216(sp)
    800046d2:	f1f6                	sd	t4,224(sp)
    800046d4:	f5fa                	sd	t5,232(sp)
    800046d6:	f9fe                	sd	t6,240(sp)
    800046d8:	c90fd0ef          	jal	ra,80001b68 <kerneltrap>
    800046dc:	6082                	ld	ra,0(sp)
    800046de:	6122                	ld	sp,8(sp)
    800046e0:	61c2                	ld	gp,16(sp)
    800046e2:	7282                	ld	t0,32(sp)
    800046e4:	7322                	ld	t1,40(sp)
    800046e6:	73c2                	ld	t2,48(sp)
    800046e8:	6526                	ld	a0,72(sp)
    800046ea:	65c6                	ld	a1,80(sp)
    800046ec:	6666                	ld	a2,88(sp)
    800046ee:	7686                	ld	a3,96(sp)
    800046f0:	7726                	ld	a4,104(sp)
    800046f2:	77c6                	ld	a5,112(sp)
    800046f4:	7866                	ld	a6,120(sp)
    800046f6:	688a                	ld	a7,128(sp)
    800046f8:	6e6e                	ld	t3,216(sp)
    800046fa:	7e8e                	ld	t4,224(sp)
    800046fc:	7f2e                	ld	t5,232(sp)
    800046fe:	7fce                	ld	t6,240(sp)
    80004700:	6111                	addi	sp,sp,256
    80004702:	10200073          	sret
	...

000000008000470e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000470e:	1141                	addi	sp,sp,-16
    80004710:	e422                	sd	s0,8(sp)
    80004712:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004714:	0c0007b7          	lui	a5,0xc000
    80004718:	4705                	li	a4,1
    8000471a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000471c:	c3d8                	sw	a4,4(a5)
}
    8000471e:	6422                	ld	s0,8(sp)
    80004720:	0141                	addi	sp,sp,16
    80004722:	8082                	ret

0000000080004724 <plicinithart>:

void
plicinithart(void)
{
    80004724:	1141                	addi	sp,sp,-16
    80004726:	e406                	sd	ra,8(sp)
    80004728:	e022                	sd	s0,0(sp)
    8000472a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000472c:	edcfc0ef          	jal	ra,80000e08 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004730:	0085171b          	slliw	a4,a0,0x8
    80004734:	0c0027b7          	lui	a5,0xc002
    80004738:	97ba                	add	a5,a5,a4
    8000473a:	40200713          	li	a4,1026
    8000473e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004742:	00d5151b          	slliw	a0,a0,0xd
    80004746:	0c2017b7          	lui	a5,0xc201
    8000474a:	97aa                	add	a5,a5,a0
    8000474c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004750:	60a2                	ld	ra,8(sp)
    80004752:	6402                	ld	s0,0(sp)
    80004754:	0141                	addi	sp,sp,16
    80004756:	8082                	ret

0000000080004758 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004758:	1141                	addi	sp,sp,-16
    8000475a:	e406                	sd	ra,8(sp)
    8000475c:	e022                	sd	s0,0(sp)
    8000475e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004760:	ea8fc0ef          	jal	ra,80000e08 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004764:	00d5151b          	slliw	a0,a0,0xd
    80004768:	0c2017b7          	lui	a5,0xc201
    8000476c:	97aa                	add	a5,a5,a0
  return irq;
}
    8000476e:	43c8                	lw	a0,4(a5)
    80004770:	60a2                	ld	ra,8(sp)
    80004772:	6402                	ld	s0,0(sp)
    80004774:	0141                	addi	sp,sp,16
    80004776:	8082                	ret

0000000080004778 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004778:	1101                	addi	sp,sp,-32
    8000477a:	ec06                	sd	ra,24(sp)
    8000477c:	e822                	sd	s0,16(sp)
    8000477e:	e426                	sd	s1,8(sp)
    80004780:	1000                	addi	s0,sp,32
    80004782:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004784:	e84fc0ef          	jal	ra,80000e08 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80004788:	00d5151b          	slliw	a0,a0,0xd
    8000478c:	0c2017b7          	lui	a5,0xc201
    80004790:	97aa                	add	a5,a5,a0
    80004792:	c3c4                	sw	s1,4(a5)
}
    80004794:	60e2                	ld	ra,24(sp)
    80004796:	6442                	ld	s0,16(sp)
    80004798:	64a2                	ld	s1,8(sp)
    8000479a:	6105                	addi	sp,sp,32
    8000479c:	8082                	ret

000000008000479e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000479e:	1141                	addi	sp,sp,-16
    800047a0:	e406                	sd	ra,8(sp)
    800047a2:	e022                	sd	s0,0(sp)
    800047a4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800047a6:	479d                	li	a5,7
    800047a8:	04a7ca63          	blt	a5,a0,800047fc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800047ac:	00014797          	auipc	a5,0x14
    800047b0:	31478793          	addi	a5,a5,788 # 80018ac0 <disk>
    800047b4:	97aa                	add	a5,a5,a0
    800047b6:	0187c783          	lbu	a5,24(a5)
    800047ba:	e7b9                	bnez	a5,80004808 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800047bc:	00451693          	slli	a3,a0,0x4
    800047c0:	00014797          	auipc	a5,0x14
    800047c4:	30078793          	addi	a5,a5,768 # 80018ac0 <disk>
    800047c8:	6398                	ld	a4,0(a5)
    800047ca:	9736                	add	a4,a4,a3
    800047cc:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800047d0:	6398                	ld	a4,0(a5)
    800047d2:	9736                	add	a4,a4,a3
    800047d4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800047d8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800047dc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800047e0:	97aa                	add	a5,a5,a0
    800047e2:	4705                	li	a4,1
    800047e4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800047e8:	00014517          	auipc	a0,0x14
    800047ec:	2f050513          	addi	a0,a0,752 # 80018ad8 <disk+0x18>
    800047f0:	c5dfc0ef          	jal	ra,8000144c <wakeup>
}
    800047f4:	60a2                	ld	ra,8(sp)
    800047f6:	6402                	ld	s0,0(sp)
    800047f8:	0141                	addi	sp,sp,16
    800047fa:	8082                	ret
    panic("free_desc 1");
    800047fc:	00003517          	auipc	a0,0x3
    80004800:	fbc50513          	addi	a0,a0,-68 # 800077b8 <syscalls+0x358>
    80004804:	3bf000ef          	jal	ra,800053c2 <panic>
    panic("free_desc 2");
    80004808:	00003517          	auipc	a0,0x3
    8000480c:	fc050513          	addi	a0,a0,-64 # 800077c8 <syscalls+0x368>
    80004810:	3b3000ef          	jal	ra,800053c2 <panic>

0000000080004814 <virtio_disk_init>:
{
    80004814:	1101                	addi	sp,sp,-32
    80004816:	ec06                	sd	ra,24(sp)
    80004818:	e822                	sd	s0,16(sp)
    8000481a:	e426                	sd	s1,8(sp)
    8000481c:	e04a                	sd	s2,0(sp)
    8000481e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004820:	00003597          	auipc	a1,0x3
    80004824:	fb858593          	addi	a1,a1,-72 # 800077d8 <syscalls+0x378>
    80004828:	00014517          	auipc	a0,0x14
    8000482c:	3c050513          	addi	a0,a0,960 # 80018be8 <disk+0x128>
    80004830:	623000ef          	jal	ra,80005652 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004834:	100017b7          	lui	a5,0x10001
    80004838:	4398                	lw	a4,0(a5)
    8000483a:	2701                	sext.w	a4,a4
    8000483c:	747277b7          	lui	a5,0x74727
    80004840:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004844:	12f71f63          	bne	a4,a5,80004982 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004848:	100017b7          	lui	a5,0x10001
    8000484c:	43dc                	lw	a5,4(a5)
    8000484e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004850:	4709                	li	a4,2
    80004852:	12e79863          	bne	a5,a4,80004982 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004856:	100017b7          	lui	a5,0x10001
    8000485a:	479c                	lw	a5,8(a5)
    8000485c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000485e:	12e79263          	bne	a5,a4,80004982 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004862:	100017b7          	lui	a5,0x10001
    80004866:	47d8                	lw	a4,12(a5)
    80004868:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000486a:	554d47b7          	lui	a5,0x554d4
    8000486e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004872:	10f71863          	bne	a4,a5,80004982 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004876:	100017b7          	lui	a5,0x10001
    8000487a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000487e:	4705                	li	a4,1
    80004880:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004882:	470d                	li	a4,3
    80004884:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004886:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004888:	c7ffe6b7          	lui	a3,0xc7ffe
    8000488c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdda5f>
    80004890:	8f75                	and	a4,a4,a3
    80004892:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004894:	472d                	li	a4,11
    80004896:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80004898:	5bbc                	lw	a5,112(a5)
    8000489a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000489e:	8ba1                	andi	a5,a5,8
    800048a0:	0e078763          	beqz	a5,8000498e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800048a4:	100017b7          	lui	a5,0x10001
    800048a8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800048ac:	43fc                	lw	a5,68(a5)
    800048ae:	2781                	sext.w	a5,a5
    800048b0:	0e079563          	bnez	a5,8000499a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800048b4:	100017b7          	lui	a5,0x10001
    800048b8:	5bdc                	lw	a5,52(a5)
    800048ba:	2781                	sext.w	a5,a5
  if(max == 0)
    800048bc:	0e078563          	beqz	a5,800049a6 <virtio_disk_init+0x192>
  if(max < NUM)
    800048c0:	471d                	li	a4,7
    800048c2:	0ef77863          	bgeu	a4,a5,800049b2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    800048c6:	839fb0ef          	jal	ra,800000fe <kalloc>
    800048ca:	00014497          	auipc	s1,0x14
    800048ce:	1f648493          	addi	s1,s1,502 # 80018ac0 <disk>
    800048d2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800048d4:	82bfb0ef          	jal	ra,800000fe <kalloc>
    800048d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800048da:	825fb0ef          	jal	ra,800000fe <kalloc>
    800048de:	87aa                	mv	a5,a0
    800048e0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800048e2:	6088                	ld	a0,0(s1)
    800048e4:	cd69                	beqz	a0,800049be <virtio_disk_init+0x1aa>
    800048e6:	00014717          	auipc	a4,0x14
    800048ea:	1e273703          	ld	a4,482(a4) # 80018ac8 <disk+0x8>
    800048ee:	cb61                	beqz	a4,800049be <virtio_disk_init+0x1aa>
    800048f0:	c7f9                	beqz	a5,800049be <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    800048f2:	6605                	lui	a2,0x1
    800048f4:	4581                	li	a1,0
    800048f6:	859fb0ef          	jal	ra,8000014e <memset>
  memset(disk.avail, 0, PGSIZE);
    800048fa:	00014497          	auipc	s1,0x14
    800048fe:	1c648493          	addi	s1,s1,454 # 80018ac0 <disk>
    80004902:	6605                	lui	a2,0x1
    80004904:	4581                	li	a1,0
    80004906:	6488                	ld	a0,8(s1)
    80004908:	847fb0ef          	jal	ra,8000014e <memset>
  memset(disk.used, 0, PGSIZE);
    8000490c:	6605                	lui	a2,0x1
    8000490e:	4581                	li	a1,0
    80004910:	6888                	ld	a0,16(s1)
    80004912:	83dfb0ef          	jal	ra,8000014e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004916:	100017b7          	lui	a5,0x10001
    8000491a:	4721                	li	a4,8
    8000491c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000491e:	4098                	lw	a4,0(s1)
    80004920:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004924:	40d8                	lw	a4,4(s1)
    80004926:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000492a:	6498                	ld	a4,8(s1)
    8000492c:	0007069b          	sext.w	a3,a4
    80004930:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004934:	9701                	srai	a4,a4,0x20
    80004936:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000493a:	6898                	ld	a4,16(s1)
    8000493c:	0007069b          	sext.w	a3,a4
    80004940:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004944:	9701                	srai	a4,a4,0x20
    80004946:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000494a:	4705                	li	a4,1
    8000494c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000494e:	00e48c23          	sb	a4,24(s1)
    80004952:	00e48ca3          	sb	a4,25(s1)
    80004956:	00e48d23          	sb	a4,26(s1)
    8000495a:	00e48da3          	sb	a4,27(s1)
    8000495e:	00e48e23          	sb	a4,28(s1)
    80004962:	00e48ea3          	sb	a4,29(s1)
    80004966:	00e48f23          	sb	a4,30(s1)
    8000496a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000496e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004972:	0727a823          	sw	s2,112(a5)
}
    80004976:	60e2                	ld	ra,24(sp)
    80004978:	6442                	ld	s0,16(sp)
    8000497a:	64a2                	ld	s1,8(sp)
    8000497c:	6902                	ld	s2,0(sp)
    8000497e:	6105                	addi	sp,sp,32
    80004980:	8082                	ret
    panic("could not find virtio disk");
    80004982:	00003517          	auipc	a0,0x3
    80004986:	e6650513          	addi	a0,a0,-410 # 800077e8 <syscalls+0x388>
    8000498a:	239000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000498e:	00003517          	auipc	a0,0x3
    80004992:	e7a50513          	addi	a0,a0,-390 # 80007808 <syscalls+0x3a8>
    80004996:	22d000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk should not be ready");
    8000499a:	00003517          	auipc	a0,0x3
    8000499e:	e8e50513          	addi	a0,a0,-370 # 80007828 <syscalls+0x3c8>
    800049a2:	221000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk has no queue 0");
    800049a6:	00003517          	auipc	a0,0x3
    800049aa:	ea250513          	addi	a0,a0,-350 # 80007848 <syscalls+0x3e8>
    800049ae:	215000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk max queue too short");
    800049b2:	00003517          	auipc	a0,0x3
    800049b6:	eb650513          	addi	a0,a0,-330 # 80007868 <syscalls+0x408>
    800049ba:	209000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk kalloc");
    800049be:	00003517          	auipc	a0,0x3
    800049c2:	eca50513          	addi	a0,a0,-310 # 80007888 <syscalls+0x428>
    800049c6:	1fd000ef          	jal	ra,800053c2 <panic>

00000000800049ca <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800049ca:	7119                	addi	sp,sp,-128
    800049cc:	fc86                	sd	ra,120(sp)
    800049ce:	f8a2                	sd	s0,112(sp)
    800049d0:	f4a6                	sd	s1,104(sp)
    800049d2:	f0ca                	sd	s2,96(sp)
    800049d4:	ecce                	sd	s3,88(sp)
    800049d6:	e8d2                	sd	s4,80(sp)
    800049d8:	e4d6                	sd	s5,72(sp)
    800049da:	e0da                	sd	s6,64(sp)
    800049dc:	fc5e                	sd	s7,56(sp)
    800049de:	f862                	sd	s8,48(sp)
    800049e0:	f466                	sd	s9,40(sp)
    800049e2:	f06a                	sd	s10,32(sp)
    800049e4:	ec6e                	sd	s11,24(sp)
    800049e6:	0100                	addi	s0,sp,128
    800049e8:	8aaa                	mv	s5,a0
    800049ea:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800049ec:	00c52d03          	lw	s10,12(a0)
    800049f0:	001d1d1b          	slliw	s10,s10,0x1
    800049f4:	1d02                	slli	s10,s10,0x20
    800049f6:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800049fa:	00014517          	auipc	a0,0x14
    800049fe:	1ee50513          	addi	a0,a0,494 # 80018be8 <disk+0x128>
    80004a02:	4d1000ef          	jal	ra,800056d2 <acquire>
  for(int i = 0; i < 3; i++){
    80004a06:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004a08:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004a0a:	00014b97          	auipc	s7,0x14
    80004a0e:	0b6b8b93          	addi	s7,s7,182 # 80018ac0 <disk>
  for(int i = 0; i < 3; i++){
    80004a12:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004a14:	00014c97          	auipc	s9,0x14
    80004a18:	1d4c8c93          	addi	s9,s9,468 # 80018be8 <disk+0x128>
    80004a1c:	a8a9                	j	80004a76 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004a1e:	00fb8733          	add	a4,s7,a5
    80004a22:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80004a26:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004a28:	0207c563          	bltz	a5,80004a52 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80004a2c:	2905                	addiw	s2,s2,1
    80004a2e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004a30:	05690863          	beq	s2,s6,80004a80 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80004a34:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004a36:	00014717          	auipc	a4,0x14
    80004a3a:	08a70713          	addi	a4,a4,138 # 80018ac0 <disk>
    80004a3e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004a40:	01874683          	lbu	a3,24(a4)
    80004a44:	fee9                	bnez	a3,80004a1e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80004a46:	2785                	addiw	a5,a5,1
    80004a48:	0705                	addi	a4,a4,1
    80004a4a:	fe979be3          	bne	a5,s1,80004a40 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80004a4e:	57fd                	li	a5,-1
    80004a50:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004a52:	01205b63          	blez	s2,80004a68 <virtio_disk_rw+0x9e>
    80004a56:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80004a58:	000a2503          	lw	a0,0(s4)
    80004a5c:	d43ff0ef          	jal	ra,8000479e <free_desc>
      for(int j = 0; j < i; j++)
    80004a60:	2d85                	addiw	s11,s11,1
    80004a62:	0a11                	addi	s4,s4,4
    80004a64:	ff2d9ae3          	bne	s11,s2,80004a58 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004a68:	85e6                	mv	a1,s9
    80004a6a:	00014517          	auipc	a0,0x14
    80004a6e:	06e50513          	addi	a0,a0,110 # 80018ad8 <disk+0x18>
    80004a72:	98ffc0ef          	jal	ra,80001400 <sleep>
  for(int i = 0; i < 3; i++){
    80004a76:	f8040a13          	addi	s4,s0,-128
{
    80004a7a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80004a7c:	894e                	mv	s2,s3
    80004a7e:	bf5d                	j	80004a34 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004a80:	f8042503          	lw	a0,-128(s0)
    80004a84:	00a50713          	addi	a4,a0,10
    80004a88:	0712                	slli	a4,a4,0x4

  if(write)
    80004a8a:	00014797          	auipc	a5,0x14
    80004a8e:	03678793          	addi	a5,a5,54 # 80018ac0 <disk>
    80004a92:	00e786b3          	add	a3,a5,a4
    80004a96:	01803633          	snez	a2,s8
    80004a9a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004a9c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80004aa0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004aa4:	f6070613          	addi	a2,a4,-160
    80004aa8:	6394                	ld	a3,0(a5)
    80004aaa:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004aac:	00870593          	addi	a1,a4,8
    80004ab0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004ab2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004ab4:	0007b803          	ld	a6,0(a5)
    80004ab8:	9642                	add	a2,a2,a6
    80004aba:	46c1                	li	a3,16
    80004abc:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004abe:	4585                	li	a1,1
    80004ac0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80004ac4:	f8442683          	lw	a3,-124(s0)
    80004ac8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004acc:	0692                	slli	a3,a3,0x4
    80004ace:	9836                	add	a6,a6,a3
    80004ad0:	058a8613          	addi	a2,s5,88
    80004ad4:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80004ad8:	0007b803          	ld	a6,0(a5)
    80004adc:	96c2                	add	a3,a3,a6
    80004ade:	40000613          	li	a2,1024
    80004ae2:	c690                	sw	a2,8(a3)
  if(write)
    80004ae4:	001c3613          	seqz	a2,s8
    80004ae8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004aec:	00166613          	ori	a2,a2,1
    80004af0:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80004af4:	f8842603          	lw	a2,-120(s0)
    80004af8:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004afc:	00250693          	addi	a3,a0,2
    80004b00:	0692                	slli	a3,a3,0x4
    80004b02:	96be                	add	a3,a3,a5
    80004b04:	58fd                	li	a7,-1
    80004b06:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004b0a:	0612                	slli	a2,a2,0x4
    80004b0c:	9832                	add	a6,a6,a2
    80004b0e:	f9070713          	addi	a4,a4,-112
    80004b12:	973e                	add	a4,a4,a5
    80004b14:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80004b18:	6398                	ld	a4,0(a5)
    80004b1a:	9732                	add	a4,a4,a2
    80004b1c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004b1e:	4609                	li	a2,2
    80004b20:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80004b24:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004b28:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80004b2c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004b30:	6794                	ld	a3,8(a5)
    80004b32:	0026d703          	lhu	a4,2(a3)
    80004b36:	8b1d                	andi	a4,a4,7
    80004b38:	0706                	slli	a4,a4,0x1
    80004b3a:	96ba                	add	a3,a3,a4
    80004b3c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004b40:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004b44:	6798                	ld	a4,8(a5)
    80004b46:	00275783          	lhu	a5,2(a4)
    80004b4a:	2785                	addiw	a5,a5,1
    80004b4c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004b50:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004b54:	100017b7          	lui	a5,0x10001
    80004b58:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004b5c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80004b60:	00014917          	auipc	s2,0x14
    80004b64:	08890913          	addi	s2,s2,136 # 80018be8 <disk+0x128>
  while(b->disk == 1) {
    80004b68:	4485                	li	s1,1
    80004b6a:	00b79a63          	bne	a5,a1,80004b7e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80004b6e:	85ca                	mv	a1,s2
    80004b70:	8556                	mv	a0,s5
    80004b72:	88ffc0ef          	jal	ra,80001400 <sleep>
  while(b->disk == 1) {
    80004b76:	004aa783          	lw	a5,4(s5)
    80004b7a:	fe978ae3          	beq	a5,s1,80004b6e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80004b7e:	f8042903          	lw	s2,-128(s0)
    80004b82:	00290713          	addi	a4,s2,2
    80004b86:	0712                	slli	a4,a4,0x4
    80004b88:	00014797          	auipc	a5,0x14
    80004b8c:	f3878793          	addi	a5,a5,-200 # 80018ac0 <disk>
    80004b90:	97ba                	add	a5,a5,a4
    80004b92:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004b96:	00014997          	auipc	s3,0x14
    80004b9a:	f2a98993          	addi	s3,s3,-214 # 80018ac0 <disk>
    80004b9e:	00491713          	slli	a4,s2,0x4
    80004ba2:	0009b783          	ld	a5,0(s3)
    80004ba6:	97ba                	add	a5,a5,a4
    80004ba8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004bac:	854a                	mv	a0,s2
    80004bae:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004bb2:	bedff0ef          	jal	ra,8000479e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004bb6:	8885                	andi	s1,s1,1
    80004bb8:	f0fd                	bnez	s1,80004b9e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004bba:	00014517          	auipc	a0,0x14
    80004bbe:	02e50513          	addi	a0,a0,46 # 80018be8 <disk+0x128>
    80004bc2:	3a9000ef          	jal	ra,8000576a <release>
}
    80004bc6:	70e6                	ld	ra,120(sp)
    80004bc8:	7446                	ld	s0,112(sp)
    80004bca:	74a6                	ld	s1,104(sp)
    80004bcc:	7906                	ld	s2,96(sp)
    80004bce:	69e6                	ld	s3,88(sp)
    80004bd0:	6a46                	ld	s4,80(sp)
    80004bd2:	6aa6                	ld	s5,72(sp)
    80004bd4:	6b06                	ld	s6,64(sp)
    80004bd6:	7be2                	ld	s7,56(sp)
    80004bd8:	7c42                	ld	s8,48(sp)
    80004bda:	7ca2                	ld	s9,40(sp)
    80004bdc:	7d02                	ld	s10,32(sp)
    80004bde:	6de2                	ld	s11,24(sp)
    80004be0:	6109                	addi	sp,sp,128
    80004be2:	8082                	ret

0000000080004be4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004be4:	1101                	addi	sp,sp,-32
    80004be6:	ec06                	sd	ra,24(sp)
    80004be8:	e822                	sd	s0,16(sp)
    80004bea:	e426                	sd	s1,8(sp)
    80004bec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004bee:	00014497          	auipc	s1,0x14
    80004bf2:	ed248493          	addi	s1,s1,-302 # 80018ac0 <disk>
    80004bf6:	00014517          	auipc	a0,0x14
    80004bfa:	ff250513          	addi	a0,a0,-14 # 80018be8 <disk+0x128>
    80004bfe:	2d5000ef          	jal	ra,800056d2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004c02:	10001737          	lui	a4,0x10001
    80004c06:	533c                	lw	a5,96(a4)
    80004c08:	8b8d                	andi	a5,a5,3
    80004c0a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80004c0c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004c10:	689c                	ld	a5,16(s1)
    80004c12:	0204d703          	lhu	a4,32(s1)
    80004c16:	0027d783          	lhu	a5,2(a5)
    80004c1a:	04f70663          	beq	a4,a5,80004c66 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80004c1e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004c22:	6898                	ld	a4,16(s1)
    80004c24:	0204d783          	lhu	a5,32(s1)
    80004c28:	8b9d                	andi	a5,a5,7
    80004c2a:	078e                	slli	a5,a5,0x3
    80004c2c:	97ba                	add	a5,a5,a4
    80004c2e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004c30:	00278713          	addi	a4,a5,2
    80004c34:	0712                	slli	a4,a4,0x4
    80004c36:	9726                	add	a4,a4,s1
    80004c38:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80004c3c:	e321                	bnez	a4,80004c7c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004c3e:	0789                	addi	a5,a5,2
    80004c40:	0792                	slli	a5,a5,0x4
    80004c42:	97a6                	add	a5,a5,s1
    80004c44:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004c46:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004c4a:	803fc0ef          	jal	ra,8000144c <wakeup>

    disk.used_idx += 1;
    80004c4e:	0204d783          	lhu	a5,32(s1)
    80004c52:	2785                	addiw	a5,a5,1
    80004c54:	17c2                	slli	a5,a5,0x30
    80004c56:	93c1                	srli	a5,a5,0x30
    80004c58:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004c5c:	6898                	ld	a4,16(s1)
    80004c5e:	00275703          	lhu	a4,2(a4)
    80004c62:	faf71ee3          	bne	a4,a5,80004c1e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80004c66:	00014517          	auipc	a0,0x14
    80004c6a:	f8250513          	addi	a0,a0,-126 # 80018be8 <disk+0x128>
    80004c6e:	2fd000ef          	jal	ra,8000576a <release>
}
    80004c72:	60e2                	ld	ra,24(sp)
    80004c74:	6442                	ld	s0,16(sp)
    80004c76:	64a2                	ld	s1,8(sp)
    80004c78:	6105                	addi	sp,sp,32
    80004c7a:	8082                	ret
      panic("virtio_disk_intr status");
    80004c7c:	00003517          	auipc	a0,0x3
    80004c80:	c2450513          	addi	a0,a0,-988 # 800078a0 <syscalls+0x440>
    80004c84:	73e000ef          	jal	ra,800053c2 <panic>

0000000080004c88 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004c88:	1141                	addi	sp,sp,-16
    80004c8a:	e422                	sd	s0,8(sp)
    80004c8c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004c8e:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004c92:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004c96:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004c9a:	30a027f3          	csrr	a5,0x30a

  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63));
    80004c9e:	577d                	li	a4,-1
    80004ca0:	177e                	slli	a4,a4,0x3f
    80004ca2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004ca4:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004ca8:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004cac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004cb0:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004cb4:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004cb8:	000f4737          	lui	a4,0xf4
    80004cbc:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004cc0:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004cc2:	14d79073          	csrw	0x14d,a5
}
    80004cc6:	6422                	ld	s0,8(sp)
    80004cc8:	0141                	addi	sp,sp,16
    80004cca:	8082                	ret

0000000080004ccc <start>:
{
    80004ccc:	1141                	addi	sp,sp,-16
    80004cce:	e406                	sd	ra,8(sp)
    80004cd0:	e022                	sd	s0,0(sp)
    80004cd2:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004cd4:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004cd8:	7779                	lui	a4,0xffffe
    80004cda:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddaff>
    80004cde:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004ce0:	6705                	lui	a4,0x1
    80004ce2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004ce6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004ce8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004cec:	ffffb797          	auipc	a5,0xffffb
    80004cf0:	60478793          	addi	a5,a5,1540 # 800002f0 <main>
    80004cf4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004cf8:	4781                	li	a5,0
    80004cfa:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004cfe:	67c1                	lui	a5,0x10
    80004d00:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004d02:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004d06:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004d0a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004d0e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004d12:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004d16:	57fd                	li	a5,-1
    80004d18:	83a9                	srli	a5,a5,0xa
    80004d1a:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004d1e:	47bd                	li	a5,15
    80004d20:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004d24:	f65ff0ef          	jal	ra,80004c88 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004d28:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004d2c:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004d2e:	823e                	mv	tp,a5
  asm volatile("mret");
    80004d30:	30200073          	mret
}
    80004d34:	60a2                	ld	ra,8(sp)
    80004d36:	6402                	ld	s0,0(sp)
    80004d38:	0141                	addi	sp,sp,16
    80004d3a:	8082                	ret

0000000080004d3c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004d3c:	715d                	addi	sp,sp,-80
    80004d3e:	e486                	sd	ra,72(sp)
    80004d40:	e0a2                	sd	s0,64(sp)
    80004d42:	fc26                	sd	s1,56(sp)
    80004d44:	f84a                	sd	s2,48(sp)
    80004d46:	f44e                	sd	s3,40(sp)
    80004d48:	f052                	sd	s4,32(sp)
    80004d4a:	ec56                	sd	s5,24(sp)
    80004d4c:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004d4e:	04c05363          	blez	a2,80004d94 <consolewrite+0x58>
    80004d52:	8a2a                	mv	s4,a0
    80004d54:	84ae                	mv	s1,a1
    80004d56:	89b2                	mv	s3,a2
    80004d58:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004d5a:	5afd                	li	s5,-1
    80004d5c:	4685                	li	a3,1
    80004d5e:	8626                	mv	a2,s1
    80004d60:	85d2                	mv	a1,s4
    80004d62:	fbf40513          	addi	a0,s0,-65
    80004d66:	a41fc0ef          	jal	ra,800017a6 <either_copyin>
    80004d6a:	01550b63          	beq	a0,s5,80004d80 <consolewrite+0x44>
      break;
    uartputc(c);
    80004d6e:	fbf44503          	lbu	a0,-65(s0)
    80004d72:	7da000ef          	jal	ra,8000554c <uartputc>
  for(i = 0; i < n; i++){
    80004d76:	2905                	addiw	s2,s2,1
    80004d78:	0485                	addi	s1,s1,1
    80004d7a:	ff2991e3          	bne	s3,s2,80004d5c <consolewrite+0x20>
    80004d7e:	894e                	mv	s2,s3
  }

  return i;
}
    80004d80:	854a                	mv	a0,s2
    80004d82:	60a6                	ld	ra,72(sp)
    80004d84:	6406                	ld	s0,64(sp)
    80004d86:	74e2                	ld	s1,56(sp)
    80004d88:	7942                	ld	s2,48(sp)
    80004d8a:	79a2                	ld	s3,40(sp)
    80004d8c:	7a02                	ld	s4,32(sp)
    80004d8e:	6ae2                	ld	s5,24(sp)
    80004d90:	6161                	addi	sp,sp,80
    80004d92:	8082                	ret
  for(i = 0; i < n; i++){
    80004d94:	4901                	li	s2,0
    80004d96:	b7ed                	j	80004d80 <consolewrite+0x44>

0000000080004d98 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004d98:	7159                	addi	sp,sp,-112
    80004d9a:	f486                	sd	ra,104(sp)
    80004d9c:	f0a2                	sd	s0,96(sp)
    80004d9e:	eca6                	sd	s1,88(sp)
    80004da0:	e8ca                	sd	s2,80(sp)
    80004da2:	e4ce                	sd	s3,72(sp)
    80004da4:	e0d2                	sd	s4,64(sp)
    80004da6:	fc56                	sd	s5,56(sp)
    80004da8:	f85a                	sd	s6,48(sp)
    80004daa:	f45e                	sd	s7,40(sp)
    80004dac:	f062                	sd	s8,32(sp)
    80004dae:	ec66                	sd	s9,24(sp)
    80004db0:	e86a                	sd	s10,16(sp)
    80004db2:	1880                	addi	s0,sp,112
    80004db4:	8aaa                	mv	s5,a0
    80004db6:	8a2e                	mv	s4,a1
    80004db8:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004dba:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004dbe:	0001c517          	auipc	a0,0x1c
    80004dc2:	e4250513          	addi	a0,a0,-446 # 80020c00 <cons>
    80004dc6:	10d000ef          	jal	ra,800056d2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004dca:	0001c497          	auipc	s1,0x1c
    80004dce:	e3648493          	addi	s1,s1,-458 # 80020c00 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004dd2:	0001c917          	auipc	s2,0x1c
    80004dd6:	ec690913          	addi	s2,s2,-314 # 80020c98 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80004dda:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004ddc:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80004dde:	4ca9                	li	s9,10
  while(n > 0){
    80004de0:	07305363          	blez	s3,80004e46 <consoleread+0xae>
    while(cons.r == cons.w){
    80004de4:	0984a783          	lw	a5,152(s1)
    80004de8:	09c4a703          	lw	a4,156(s1)
    80004dec:	02f71163          	bne	a4,a5,80004e0e <consoleread+0x76>
      if(killed(myproc())){
    80004df0:	844fc0ef          	jal	ra,80000e34 <myproc>
    80004df4:	845fc0ef          	jal	ra,80001638 <killed>
    80004df8:	e125                	bnez	a0,80004e58 <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    80004dfa:	85a6                	mv	a1,s1
    80004dfc:	854a                	mv	a0,s2
    80004dfe:	e02fc0ef          	jal	ra,80001400 <sleep>
    while(cons.r == cons.w){
    80004e02:	0984a783          	lw	a5,152(s1)
    80004e06:	09c4a703          	lw	a4,156(s1)
    80004e0a:	fef703e3          	beq	a4,a5,80004df0 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004e0e:	0017871b          	addiw	a4,a5,1
    80004e12:	08e4ac23          	sw	a4,152(s1)
    80004e16:	07f7f713          	andi	a4,a5,127
    80004e1a:	9726                	add	a4,a4,s1
    80004e1c:	01874703          	lbu	a4,24(a4)
    80004e20:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80004e24:	057d0f63          	beq	s10,s7,80004e82 <consoleread+0xea>
    cbuf = c;
    80004e28:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004e2c:	4685                	li	a3,1
    80004e2e:	f9f40613          	addi	a2,s0,-97
    80004e32:	85d2                	mv	a1,s4
    80004e34:	8556                	mv	a0,s5
    80004e36:	927fc0ef          	jal	ra,8000175c <either_copyout>
    80004e3a:	01850663          	beq	a0,s8,80004e46 <consoleread+0xae>
    dst++;
    80004e3e:	0a05                	addi	s4,s4,1
    --n;
    80004e40:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80004e42:	f99d1fe3          	bne	s10,s9,80004de0 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80004e46:	0001c517          	auipc	a0,0x1c
    80004e4a:	dba50513          	addi	a0,a0,-582 # 80020c00 <cons>
    80004e4e:	11d000ef          	jal	ra,8000576a <release>

  return target - n;
    80004e52:	413b053b          	subw	a0,s6,s3
    80004e56:	a801                	j	80004e66 <consoleread+0xce>
        release(&cons.lock);
    80004e58:	0001c517          	auipc	a0,0x1c
    80004e5c:	da850513          	addi	a0,a0,-600 # 80020c00 <cons>
    80004e60:	10b000ef          	jal	ra,8000576a <release>
        return -1;
    80004e64:	557d                	li	a0,-1
}
    80004e66:	70a6                	ld	ra,104(sp)
    80004e68:	7406                	ld	s0,96(sp)
    80004e6a:	64e6                	ld	s1,88(sp)
    80004e6c:	6946                	ld	s2,80(sp)
    80004e6e:	69a6                	ld	s3,72(sp)
    80004e70:	6a06                	ld	s4,64(sp)
    80004e72:	7ae2                	ld	s5,56(sp)
    80004e74:	7b42                	ld	s6,48(sp)
    80004e76:	7ba2                	ld	s7,40(sp)
    80004e78:	7c02                	ld	s8,32(sp)
    80004e7a:	6ce2                	ld	s9,24(sp)
    80004e7c:	6d42                	ld	s10,16(sp)
    80004e7e:	6165                	addi	sp,sp,112
    80004e80:	8082                	ret
      if(n < target){
    80004e82:	0009871b          	sext.w	a4,s3
    80004e86:	fd6770e3          	bgeu	a4,s6,80004e46 <consoleread+0xae>
        cons.r--;
    80004e8a:	0001c717          	auipc	a4,0x1c
    80004e8e:	e0f72723          	sw	a5,-498(a4) # 80020c98 <cons+0x98>
    80004e92:	bf55                	j	80004e46 <consoleread+0xae>

0000000080004e94 <consputc>:
{
    80004e94:	1141                	addi	sp,sp,-16
    80004e96:	e406                	sd	ra,8(sp)
    80004e98:	e022                	sd	s0,0(sp)
    80004e9a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80004e9c:	10000793          	li	a5,256
    80004ea0:	00f50863          	beq	a0,a5,80004eb0 <consputc+0x1c>
    uartputc_sync(c);
    80004ea4:	5d2000ef          	jal	ra,80005476 <uartputc_sync>
}
    80004ea8:	60a2                	ld	ra,8(sp)
    80004eaa:	6402                	ld	s0,0(sp)
    80004eac:	0141                	addi	sp,sp,16
    80004eae:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80004eb0:	4521                	li	a0,8
    80004eb2:	5c4000ef          	jal	ra,80005476 <uartputc_sync>
    80004eb6:	02000513          	li	a0,32
    80004eba:	5bc000ef          	jal	ra,80005476 <uartputc_sync>
    80004ebe:	4521                	li	a0,8
    80004ec0:	5b6000ef          	jal	ra,80005476 <uartputc_sync>
    80004ec4:	b7d5                	j	80004ea8 <consputc+0x14>

0000000080004ec6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80004ec6:	1101                	addi	sp,sp,-32
    80004ec8:	ec06                	sd	ra,24(sp)
    80004eca:	e822                	sd	s0,16(sp)
    80004ecc:	e426                	sd	s1,8(sp)
    80004ece:	e04a                	sd	s2,0(sp)
    80004ed0:	1000                	addi	s0,sp,32
    80004ed2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80004ed4:	0001c517          	auipc	a0,0x1c
    80004ed8:	d2c50513          	addi	a0,a0,-724 # 80020c00 <cons>
    80004edc:	7f6000ef          	jal	ra,800056d2 <acquire>

  switch(c){
    80004ee0:	47d5                	li	a5,21
    80004ee2:	0af48063          	beq	s1,a5,80004f82 <consoleintr+0xbc>
    80004ee6:	0297c663          	blt	a5,s1,80004f12 <consoleintr+0x4c>
    80004eea:	47a1                	li	a5,8
    80004eec:	0cf48f63          	beq	s1,a5,80004fca <consoleintr+0x104>
    80004ef0:	47c1                	li	a5,16
    80004ef2:	10f49063          	bne	s1,a5,80004ff2 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    80004ef6:	8fbfc0ef          	jal	ra,800017f0 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    80004efa:	0001c517          	auipc	a0,0x1c
    80004efe:	d0650513          	addi	a0,a0,-762 # 80020c00 <cons>
    80004f02:	069000ef          	jal	ra,8000576a <release>
}
    80004f06:	60e2                	ld	ra,24(sp)
    80004f08:	6442                	ld	s0,16(sp)
    80004f0a:	64a2                	ld	s1,8(sp)
    80004f0c:	6902                	ld	s2,0(sp)
    80004f0e:	6105                	addi	sp,sp,32
    80004f10:	8082                	ret
  switch(c){
    80004f12:	07f00793          	li	a5,127
    80004f16:	0af48a63          	beq	s1,a5,80004fca <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004f1a:	0001c717          	auipc	a4,0x1c
    80004f1e:	ce670713          	addi	a4,a4,-794 # 80020c00 <cons>
    80004f22:	0a072783          	lw	a5,160(a4)
    80004f26:	09872703          	lw	a4,152(a4)
    80004f2a:	9f99                	subw	a5,a5,a4
    80004f2c:	07f00713          	li	a4,127
    80004f30:	fcf765e3          	bltu	a4,a5,80004efa <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    80004f34:	47b5                	li	a5,13
    80004f36:	0cf48163          	beq	s1,a5,80004ff8 <consoleintr+0x132>
      consputc(c);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	f59ff0ef          	jal	ra,80004e94 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80004f40:	0001c797          	auipc	a5,0x1c
    80004f44:	cc078793          	addi	a5,a5,-832 # 80020c00 <cons>
    80004f48:	0a07a683          	lw	a3,160(a5)
    80004f4c:	0016871b          	addiw	a4,a3,1
    80004f50:	0007061b          	sext.w	a2,a4
    80004f54:	0ae7a023          	sw	a4,160(a5)
    80004f58:	07f6f693          	andi	a3,a3,127
    80004f5c:	97b6                	add	a5,a5,a3
    80004f5e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80004f62:	47a9                	li	a5,10
    80004f64:	0af48f63          	beq	s1,a5,80005022 <consoleintr+0x15c>
    80004f68:	4791                	li	a5,4
    80004f6a:	0af48c63          	beq	s1,a5,80005022 <consoleintr+0x15c>
    80004f6e:	0001c797          	auipc	a5,0x1c
    80004f72:	d2a7a783          	lw	a5,-726(a5) # 80020c98 <cons+0x98>
    80004f76:	9f1d                	subw	a4,a4,a5
    80004f78:	08000793          	li	a5,128
    80004f7c:	f6f71fe3          	bne	a4,a5,80004efa <consoleintr+0x34>
    80004f80:	a04d                	j	80005022 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80004f82:	0001c717          	auipc	a4,0x1c
    80004f86:	c7e70713          	addi	a4,a4,-898 # 80020c00 <cons>
    80004f8a:	0a072783          	lw	a5,160(a4)
    80004f8e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80004f92:	0001c497          	auipc	s1,0x1c
    80004f96:	c6e48493          	addi	s1,s1,-914 # 80020c00 <cons>
    while(cons.e != cons.w &&
    80004f9a:	4929                	li	s2,10
    80004f9c:	f4f70fe3          	beq	a4,a5,80004efa <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80004fa0:	37fd                	addiw	a5,a5,-1
    80004fa2:	07f7f713          	andi	a4,a5,127
    80004fa6:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80004fa8:	01874703          	lbu	a4,24(a4)
    80004fac:	f52707e3          	beq	a4,s2,80004efa <consoleintr+0x34>
      cons.e--;
    80004fb0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80004fb4:	10000513          	li	a0,256
    80004fb8:	eddff0ef          	jal	ra,80004e94 <consputc>
    while(cons.e != cons.w &&
    80004fbc:	0a04a783          	lw	a5,160(s1)
    80004fc0:	09c4a703          	lw	a4,156(s1)
    80004fc4:	fcf71ee3          	bne	a4,a5,80004fa0 <consoleintr+0xda>
    80004fc8:	bf0d                	j	80004efa <consoleintr+0x34>
    if(cons.e != cons.w){
    80004fca:	0001c717          	auipc	a4,0x1c
    80004fce:	c3670713          	addi	a4,a4,-970 # 80020c00 <cons>
    80004fd2:	0a072783          	lw	a5,160(a4)
    80004fd6:	09c72703          	lw	a4,156(a4)
    80004fda:	f2f700e3          	beq	a4,a5,80004efa <consoleintr+0x34>
      cons.e--;
    80004fde:	37fd                	addiw	a5,a5,-1
    80004fe0:	0001c717          	auipc	a4,0x1c
    80004fe4:	ccf72023          	sw	a5,-832(a4) # 80020ca0 <cons+0xa0>
      consputc(BACKSPACE);
    80004fe8:	10000513          	li	a0,256
    80004fec:	ea9ff0ef          	jal	ra,80004e94 <consputc>
    80004ff0:	b729                	j	80004efa <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004ff2:	f00484e3          	beqz	s1,80004efa <consoleintr+0x34>
    80004ff6:	b715                	j	80004f1a <consoleintr+0x54>
      consputc(c);
    80004ff8:	4529                	li	a0,10
    80004ffa:	e9bff0ef          	jal	ra,80004e94 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80004ffe:	0001c797          	auipc	a5,0x1c
    80005002:	c0278793          	addi	a5,a5,-1022 # 80020c00 <cons>
    80005006:	0a07a703          	lw	a4,160(a5)
    8000500a:	0017069b          	addiw	a3,a4,1
    8000500e:	0006861b          	sext.w	a2,a3
    80005012:	0ad7a023          	sw	a3,160(a5)
    80005016:	07f77713          	andi	a4,a4,127
    8000501a:	97ba                	add	a5,a5,a4
    8000501c:	4729                	li	a4,10
    8000501e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005022:	0001c797          	auipc	a5,0x1c
    80005026:	c6c7ad23          	sw	a2,-902(a5) # 80020c9c <cons+0x9c>
        wakeup(&cons.r);
    8000502a:	0001c517          	auipc	a0,0x1c
    8000502e:	c6e50513          	addi	a0,a0,-914 # 80020c98 <cons+0x98>
    80005032:	c1afc0ef          	jal	ra,8000144c <wakeup>
    80005036:	b5d1                	j	80004efa <consoleintr+0x34>

0000000080005038 <consoleinit>:

void
consoleinit(void)
{
    80005038:	1141                	addi	sp,sp,-16
    8000503a:	e406                	sd	ra,8(sp)
    8000503c:	e022                	sd	s0,0(sp)
    8000503e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005040:	00003597          	auipc	a1,0x3
    80005044:	87858593          	addi	a1,a1,-1928 # 800078b8 <syscalls+0x458>
    80005048:	0001c517          	auipc	a0,0x1c
    8000504c:	bb850513          	addi	a0,a0,-1096 # 80020c00 <cons>
    80005050:	602000ef          	jal	ra,80005652 <initlock>

  uartinit();
    80005054:	3d6000ef          	jal	ra,8000542a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005058:	00013797          	auipc	a5,0x13
    8000505c:	a1078793          	addi	a5,a5,-1520 # 80017a68 <devsw>
    80005060:	00000717          	auipc	a4,0x0
    80005064:	d3870713          	addi	a4,a4,-712 # 80004d98 <consoleread>
    80005068:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000506a:	00000717          	auipc	a4,0x0
    8000506e:	cd270713          	addi	a4,a4,-814 # 80004d3c <consolewrite>
    80005072:	ef98                	sd	a4,24(a5)
}
    80005074:	60a2                	ld	ra,8(sp)
    80005076:	6402                	ld	s0,0(sp)
    80005078:	0141                	addi	sp,sp,16
    8000507a:	8082                	ret

000000008000507c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000507c:	7179                	addi	sp,sp,-48
    8000507e:	f406                	sd	ra,40(sp)
    80005080:	f022                	sd	s0,32(sp)
    80005082:	ec26                	sd	s1,24(sp)
    80005084:	e84a                	sd	s2,16(sp)
    80005086:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005088:	c219                	beqz	a2,8000508e <printint+0x12>
    8000508a:	06054e63          	bltz	a0,80005106 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000508e:	4881                	li	a7,0
    80005090:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005094:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005096:	00003617          	auipc	a2,0x3
    8000509a:	84a60613          	addi	a2,a2,-1974 # 800078e0 <digits>
    8000509e:	883e                	mv	a6,a5
    800050a0:	2785                	addiw	a5,a5,1
    800050a2:	02b57733          	remu	a4,a0,a1
    800050a6:	9732                	add	a4,a4,a2
    800050a8:	00074703          	lbu	a4,0(a4)
    800050ac:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800050b0:	872a                	mv	a4,a0
    800050b2:	02b55533          	divu	a0,a0,a1
    800050b6:	0685                	addi	a3,a3,1
    800050b8:	feb773e3          	bgeu	a4,a1,8000509e <printint+0x22>

  if(sign)
    800050bc:	00088a63          	beqz	a7,800050d0 <printint+0x54>
    buf[i++] = '-';
    800050c0:	1781                	addi	a5,a5,-32
    800050c2:	97a2                	add	a5,a5,s0
    800050c4:	02d00713          	li	a4,45
    800050c8:	fee78823          	sb	a4,-16(a5)
    800050cc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800050d0:	02f05563          	blez	a5,800050fa <printint+0x7e>
    800050d4:	fd040713          	addi	a4,s0,-48
    800050d8:	00f704b3          	add	s1,a4,a5
    800050dc:	fff70913          	addi	s2,a4,-1
    800050e0:	993e                	add	s2,s2,a5
    800050e2:	37fd                	addiw	a5,a5,-1
    800050e4:	1782                	slli	a5,a5,0x20
    800050e6:	9381                	srli	a5,a5,0x20
    800050e8:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800050ec:	fff4c503          	lbu	a0,-1(s1)
    800050f0:	da5ff0ef          	jal	ra,80004e94 <consputc>
  while(--i >= 0)
    800050f4:	14fd                	addi	s1,s1,-1
    800050f6:	ff249be3          	bne	s1,s2,800050ec <printint+0x70>
}
    800050fa:	70a2                	ld	ra,40(sp)
    800050fc:	7402                	ld	s0,32(sp)
    800050fe:	64e2                	ld	s1,24(sp)
    80005100:	6942                	ld	s2,16(sp)
    80005102:	6145                	addi	sp,sp,48
    80005104:	8082                	ret
    x = -xx;
    80005106:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000510a:	4885                	li	a7,1
    x = -xx;
    8000510c:	b751                	j	80005090 <printint+0x14>

000000008000510e <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000510e:	7155                	addi	sp,sp,-208
    80005110:	e506                	sd	ra,136(sp)
    80005112:	e122                	sd	s0,128(sp)
    80005114:	fca6                	sd	s1,120(sp)
    80005116:	f8ca                	sd	s2,112(sp)
    80005118:	f4ce                	sd	s3,104(sp)
    8000511a:	f0d2                	sd	s4,96(sp)
    8000511c:	ecd6                	sd	s5,88(sp)
    8000511e:	e8da                	sd	s6,80(sp)
    80005120:	e4de                	sd	s7,72(sp)
    80005122:	e0e2                	sd	s8,64(sp)
    80005124:	fc66                	sd	s9,56(sp)
    80005126:	f86a                	sd	s10,48(sp)
    80005128:	f46e                	sd	s11,40(sp)
    8000512a:	0900                	addi	s0,sp,144
    8000512c:	8a2a                	mv	s4,a0
    8000512e:	e40c                	sd	a1,8(s0)
    80005130:	e810                	sd	a2,16(s0)
    80005132:	ec14                	sd	a3,24(s0)
    80005134:	f018                	sd	a4,32(s0)
    80005136:	f41c                	sd	a5,40(s0)
    80005138:	03043823          	sd	a6,48(s0)
    8000513c:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    80005140:	0001c797          	auipc	a5,0x1c
    80005144:	b807a783          	lw	a5,-1152(a5) # 80020cc0 <pr+0x18>
    80005148:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    8000514c:	eb9d                	bnez	a5,80005182 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    8000514e:	00840793          	addi	a5,s0,8
    80005152:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005156:	00054503          	lbu	a0,0(a0)
    8000515a:	24050463          	beqz	a0,800053a2 <printf+0x294>
    8000515e:	4981                	li	s3,0
    if(cx != '%'){
    80005160:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005164:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005168:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000516c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005170:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005174:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005178:	00002b97          	auipc	s7,0x2
    8000517c:	768b8b93          	addi	s7,s7,1896 # 800078e0 <digits>
    80005180:	a081                	j	800051c0 <printf+0xb2>
    acquire(&pr.lock);
    80005182:	0001c517          	auipc	a0,0x1c
    80005186:	b2650513          	addi	a0,a0,-1242 # 80020ca8 <pr>
    8000518a:	548000ef          	jal	ra,800056d2 <acquire>
  va_start(ap, fmt);
    8000518e:	00840793          	addi	a5,s0,8
    80005192:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005196:	000a4503          	lbu	a0,0(s4)
    8000519a:	f171                	bnez	a0,8000515e <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    8000519c:	0001c517          	auipc	a0,0x1c
    800051a0:	b0c50513          	addi	a0,a0,-1268 # 80020ca8 <pr>
    800051a4:	5c6000ef          	jal	ra,8000576a <release>
    800051a8:	aaed                	j	800053a2 <printf+0x294>
      consputc(cx);
    800051aa:	cebff0ef          	jal	ra,80004e94 <consputc>
      continue;
    800051ae:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800051b0:	0014899b          	addiw	s3,s1,1
    800051b4:	013a07b3          	add	a5,s4,s3
    800051b8:	0007c503          	lbu	a0,0(a5)
    800051bc:	1c050f63          	beqz	a0,8000539a <printf+0x28c>
    if(cx != '%'){
    800051c0:	ff5515e3          	bne	a0,s5,800051aa <printf+0x9c>
    i++;
    800051c4:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    800051c8:	009a07b3          	add	a5,s4,s1
    800051cc:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    800051d0:	1c090563          	beqz	s2,8000539a <printf+0x28c>
    800051d4:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800051d8:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800051da:	c789                	beqz	a5,800051e4 <printf+0xd6>
    800051dc:	009a0733          	add	a4,s4,s1
    800051e0:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800051e4:	03690463          	beq	s2,s6,8000520c <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    800051e8:	03890e63          	beq	s2,s8,80005224 <printf+0x116>
    } else if(c0 == 'u'){
    800051ec:	0b990d63          	beq	s2,s9,800052a6 <printf+0x198>
    } else if(c0 == 'x'){
    800051f0:	11a90363          	beq	s2,s10,800052f6 <printf+0x1e8>
    } else if(c0 == 'p'){
    800051f4:	13b90b63          	beq	s2,s11,8000532a <printf+0x21c>
    } else if(c0 == 's'){
    800051f8:	07300793          	li	a5,115
    800051fc:	16f90363          	beq	s2,a5,80005362 <printf+0x254>
    } else if(c0 == '%'){
    80005200:	03591c63          	bne	s2,s5,80005238 <printf+0x12a>
      consputc('%');
    80005204:	8556                	mv	a0,s5
    80005206:	c8fff0ef          	jal	ra,80004e94 <consputc>
    8000520a:	b75d                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    8000520c:	f8843783          	ld	a5,-120(s0)
    80005210:	00878713          	addi	a4,a5,8
    80005214:	f8e43423          	sd	a4,-120(s0)
    80005218:	4605                	li	a2,1
    8000521a:	45a9                	li	a1,10
    8000521c:	4388                	lw	a0,0(a5)
    8000521e:	e5fff0ef          	jal	ra,8000507c <printint>
    80005222:	b779                	j	800051b0 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    80005224:	03678163          	beq	a5,s6,80005246 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005228:	03878d63          	beq	a5,s8,80005262 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    8000522c:	09978963          	beq	a5,s9,800052be <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005230:	03878b63          	beq	a5,s8,80005266 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    80005234:	0da78d63          	beq	a5,s10,8000530e <printf+0x200>
      consputc('%');
    80005238:	8556                	mv	a0,s5
    8000523a:	c5bff0ef          	jal	ra,80004e94 <consputc>
      consputc(c0);
    8000523e:	854a                	mv	a0,s2
    80005240:	c55ff0ef          	jal	ra,80004e94 <consputc>
    80005244:	b7b5                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    80005246:	f8843783          	ld	a5,-120(s0)
    8000524a:	00878713          	addi	a4,a5,8
    8000524e:	f8e43423          	sd	a4,-120(s0)
    80005252:	4605                	li	a2,1
    80005254:	45a9                	li	a1,10
    80005256:	6388                	ld	a0,0(a5)
    80005258:	e25ff0ef          	jal	ra,8000507c <printint>
      i += 1;
    8000525c:	0029849b          	addiw	s1,s3,2
    80005260:	bf81                	j	800051b0 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005262:	03668463          	beq	a3,s6,8000528a <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005266:	07968a63          	beq	a3,s9,800052da <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000526a:	fda697e3          	bne	a3,s10,80005238 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    8000526e:	f8843783          	ld	a5,-120(s0)
    80005272:	00878713          	addi	a4,a5,8
    80005276:	f8e43423          	sd	a4,-120(s0)
    8000527a:	4601                	li	a2,0
    8000527c:	45c1                	li	a1,16
    8000527e:	6388                	ld	a0,0(a5)
    80005280:	dfdff0ef          	jal	ra,8000507c <printint>
      i += 2;
    80005284:	0039849b          	addiw	s1,s3,3
    80005288:	b725                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    8000528a:	f8843783          	ld	a5,-120(s0)
    8000528e:	00878713          	addi	a4,a5,8
    80005292:	f8e43423          	sd	a4,-120(s0)
    80005296:	4605                	li	a2,1
    80005298:	45a9                	li	a1,10
    8000529a:	6388                	ld	a0,0(a5)
    8000529c:	de1ff0ef          	jal	ra,8000507c <printint>
      i += 2;
    800052a0:	0039849b          	addiw	s1,s3,3
    800052a4:	b731                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    800052a6:	f8843783          	ld	a5,-120(s0)
    800052aa:	00878713          	addi	a4,a5,8
    800052ae:	f8e43423          	sd	a4,-120(s0)
    800052b2:	4601                	li	a2,0
    800052b4:	45a9                	li	a1,10
    800052b6:	4388                	lw	a0,0(a5)
    800052b8:	dc5ff0ef          	jal	ra,8000507c <printint>
    800052bc:	bdd5                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    800052be:	f8843783          	ld	a5,-120(s0)
    800052c2:	00878713          	addi	a4,a5,8
    800052c6:	f8e43423          	sd	a4,-120(s0)
    800052ca:	4601                	li	a2,0
    800052cc:	45a9                	li	a1,10
    800052ce:	6388                	ld	a0,0(a5)
    800052d0:	dadff0ef          	jal	ra,8000507c <printint>
      i += 1;
    800052d4:	0029849b          	addiw	s1,s3,2
    800052d8:	bde1                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    800052da:	f8843783          	ld	a5,-120(s0)
    800052de:	00878713          	addi	a4,a5,8
    800052e2:	f8e43423          	sd	a4,-120(s0)
    800052e6:	4601                	li	a2,0
    800052e8:	45a9                	li	a1,10
    800052ea:	6388                	ld	a0,0(a5)
    800052ec:	d91ff0ef          	jal	ra,8000507c <printint>
      i += 2;
    800052f0:	0039849b          	addiw	s1,s3,3
    800052f4:	bd75                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    800052f6:	f8843783          	ld	a5,-120(s0)
    800052fa:	00878713          	addi	a4,a5,8
    800052fe:	f8e43423          	sd	a4,-120(s0)
    80005302:	4601                	li	a2,0
    80005304:	45c1                	li	a1,16
    80005306:	4388                	lw	a0,0(a5)
    80005308:	d75ff0ef          	jal	ra,8000507c <printint>
    8000530c:	b555                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    8000530e:	f8843783          	ld	a5,-120(s0)
    80005312:	00878713          	addi	a4,a5,8
    80005316:	f8e43423          	sd	a4,-120(s0)
    8000531a:	4601                	li	a2,0
    8000531c:	45c1                	li	a1,16
    8000531e:	6388                	ld	a0,0(a5)
    80005320:	d5dff0ef          	jal	ra,8000507c <printint>
      i += 1;
    80005324:	0029849b          	addiw	s1,s3,2
    80005328:	b561                	j	800051b0 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    8000532a:	f8843783          	ld	a5,-120(s0)
    8000532e:	00878713          	addi	a4,a5,8
    80005332:	f8e43423          	sd	a4,-120(s0)
    80005336:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000533a:	03000513          	li	a0,48
    8000533e:	b57ff0ef          	jal	ra,80004e94 <consputc>
  consputc('x');
    80005342:	856a                	mv	a0,s10
    80005344:	b51ff0ef          	jal	ra,80004e94 <consputc>
    80005348:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000534a:	03c9d793          	srli	a5,s3,0x3c
    8000534e:	97de                	add	a5,a5,s7
    80005350:	0007c503          	lbu	a0,0(a5)
    80005354:	b41ff0ef          	jal	ra,80004e94 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005358:	0992                	slli	s3,s3,0x4
    8000535a:	397d                	addiw	s2,s2,-1
    8000535c:	fe0917e3          	bnez	s2,8000534a <printf+0x23c>
    80005360:	bd81                	j	800051b0 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    80005362:	f8843783          	ld	a5,-120(s0)
    80005366:	00878713          	addi	a4,a5,8
    8000536a:	f8e43423          	sd	a4,-120(s0)
    8000536e:	0007b903          	ld	s2,0(a5)
    80005372:	00090d63          	beqz	s2,8000538c <printf+0x27e>
      for(; *s; s++)
    80005376:	00094503          	lbu	a0,0(s2)
    8000537a:	e2050be3          	beqz	a0,800051b0 <printf+0xa2>
        consputc(*s);
    8000537e:	b17ff0ef          	jal	ra,80004e94 <consputc>
      for(; *s; s++)
    80005382:	0905                	addi	s2,s2,1
    80005384:	00094503          	lbu	a0,0(s2)
    80005388:	f97d                	bnez	a0,8000537e <printf+0x270>
    8000538a:	b51d                	j	800051b0 <printf+0xa2>
        s = "(null)";
    8000538c:	00002917          	auipc	s2,0x2
    80005390:	53490913          	addi	s2,s2,1332 # 800078c0 <syscalls+0x460>
      for(; *s; s++)
    80005394:	02800513          	li	a0,40
    80005398:	b7dd                	j	8000537e <printf+0x270>
  if(locking)
    8000539a:	f7843783          	ld	a5,-136(s0)
    8000539e:	de079fe3          	bnez	a5,8000519c <printf+0x8e>

  return 0;
}
    800053a2:	4501                	li	a0,0
    800053a4:	60aa                	ld	ra,136(sp)
    800053a6:	640a                	ld	s0,128(sp)
    800053a8:	74e6                	ld	s1,120(sp)
    800053aa:	7946                	ld	s2,112(sp)
    800053ac:	79a6                	ld	s3,104(sp)
    800053ae:	7a06                	ld	s4,96(sp)
    800053b0:	6ae6                	ld	s5,88(sp)
    800053b2:	6b46                	ld	s6,80(sp)
    800053b4:	6ba6                	ld	s7,72(sp)
    800053b6:	6c06                	ld	s8,64(sp)
    800053b8:	7ce2                	ld	s9,56(sp)
    800053ba:	7d42                	ld	s10,48(sp)
    800053bc:	7da2                	ld	s11,40(sp)
    800053be:	6169                	addi	sp,sp,208
    800053c0:	8082                	ret

00000000800053c2 <panic>:

void
panic(char *s)
{
    800053c2:	1101                	addi	sp,sp,-32
    800053c4:	ec06                	sd	ra,24(sp)
    800053c6:	e822                	sd	s0,16(sp)
    800053c8:	e426                	sd	s1,8(sp)
    800053ca:	1000                	addi	s0,sp,32
    800053cc:	84aa                	mv	s1,a0
  pr.locking = 0;
    800053ce:	0001c797          	auipc	a5,0x1c
    800053d2:	8e07a923          	sw	zero,-1806(a5) # 80020cc0 <pr+0x18>
  printf("panic: ");
    800053d6:	00002517          	auipc	a0,0x2
    800053da:	4f250513          	addi	a0,a0,1266 # 800078c8 <syscalls+0x468>
    800053de:	d31ff0ef          	jal	ra,8000510e <printf>
  printf("%s\n", s);
    800053e2:	85a6                	mv	a1,s1
    800053e4:	00002517          	auipc	a0,0x2
    800053e8:	4ec50513          	addi	a0,a0,1260 # 800078d0 <syscalls+0x470>
    800053ec:	d23ff0ef          	jal	ra,8000510e <printf>
  panicked = 1; // freeze uart output from other CPUs
    800053f0:	4785                	li	a5,1
    800053f2:	00002717          	auipc	a4,0x2
    800053f6:	5cf72523          	sw	a5,1482(a4) # 800079bc <panicked>
  for(;;)
    800053fa:	a001                	j	800053fa <panic+0x38>

00000000800053fc <printfinit>:
    ;
}

void
printfinit(void)
{
    800053fc:	1101                	addi	sp,sp,-32
    800053fe:	ec06                	sd	ra,24(sp)
    80005400:	e822                	sd	s0,16(sp)
    80005402:	e426                	sd	s1,8(sp)
    80005404:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005406:	0001c497          	auipc	s1,0x1c
    8000540a:	8a248493          	addi	s1,s1,-1886 # 80020ca8 <pr>
    8000540e:	00002597          	auipc	a1,0x2
    80005412:	4ca58593          	addi	a1,a1,1226 # 800078d8 <syscalls+0x478>
    80005416:	8526                	mv	a0,s1
    80005418:	23a000ef          	jal	ra,80005652 <initlock>
  pr.locking = 1;
    8000541c:	4785                	li	a5,1
    8000541e:	cc9c                	sw	a5,24(s1)
}
    80005420:	60e2                	ld	ra,24(sp)
    80005422:	6442                	ld	s0,16(sp)
    80005424:	64a2                	ld	s1,8(sp)
    80005426:	6105                	addi	sp,sp,32
    80005428:	8082                	ret

000000008000542a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000542a:	1141                	addi	sp,sp,-16
    8000542c:	e406                	sd	ra,8(sp)
    8000542e:	e022                	sd	s0,0(sp)
    80005430:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005432:	100007b7          	lui	a5,0x10000
    80005436:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000543a:	f8000713          	li	a4,-128
    8000543e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005442:	470d                	li	a4,3
    80005444:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005448:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000544c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005450:	469d                	li	a3,7
    80005452:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005456:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000545a:	00002597          	auipc	a1,0x2
    8000545e:	49e58593          	addi	a1,a1,1182 # 800078f8 <digits+0x18>
    80005462:	0001c517          	auipc	a0,0x1c
    80005466:	86650513          	addi	a0,a0,-1946 # 80020cc8 <uart_tx_lock>
    8000546a:	1e8000ef          	jal	ra,80005652 <initlock>
}
    8000546e:	60a2                	ld	ra,8(sp)
    80005470:	6402                	ld	s0,0(sp)
    80005472:	0141                	addi	sp,sp,16
    80005474:	8082                	ret

0000000080005476 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005476:	1101                	addi	sp,sp,-32
    80005478:	ec06                	sd	ra,24(sp)
    8000547a:	e822                	sd	s0,16(sp)
    8000547c:	e426                	sd	s1,8(sp)
    8000547e:	1000                	addi	s0,sp,32
    80005480:	84aa                	mv	s1,a0
  push_off();
    80005482:	210000ef          	jal	ra,80005692 <push_off>

  if(panicked){
    80005486:	00002797          	auipc	a5,0x2
    8000548a:	5367a783          	lw	a5,1334(a5) # 800079bc <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000548e:	10000737          	lui	a4,0x10000
  if(panicked){
    80005492:	c391                	beqz	a5,80005496 <uartputc_sync+0x20>
    for(;;)
    80005494:	a001                	j	80005494 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005496:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000549a:	0207f793          	andi	a5,a5,32
    8000549e:	dfe5                	beqz	a5,80005496 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800054a0:	0ff4f513          	zext.b	a0,s1
    800054a4:	100007b7          	lui	a5,0x10000
    800054a8:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800054ac:	26a000ef          	jal	ra,80005716 <pop_off>
}
    800054b0:	60e2                	ld	ra,24(sp)
    800054b2:	6442                	ld	s0,16(sp)
    800054b4:	64a2                	ld	s1,8(sp)
    800054b6:	6105                	addi	sp,sp,32
    800054b8:	8082                	ret

00000000800054ba <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800054ba:	00002797          	auipc	a5,0x2
    800054be:	5067b783          	ld	a5,1286(a5) # 800079c0 <uart_tx_r>
    800054c2:	00002717          	auipc	a4,0x2
    800054c6:	50673703          	ld	a4,1286(a4) # 800079c8 <uart_tx_w>
    800054ca:	06f70c63          	beq	a4,a5,80005542 <uartstart+0x88>
{
    800054ce:	7139                	addi	sp,sp,-64
    800054d0:	fc06                	sd	ra,56(sp)
    800054d2:	f822                	sd	s0,48(sp)
    800054d4:	f426                	sd	s1,40(sp)
    800054d6:	f04a                	sd	s2,32(sp)
    800054d8:	ec4e                	sd	s3,24(sp)
    800054da:	e852                	sd	s4,16(sp)
    800054dc:	e456                	sd	s5,8(sp)
    800054de:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }

    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800054e0:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }

    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800054e4:	0001ba17          	auipc	s4,0x1b
    800054e8:	7e4a0a13          	addi	s4,s4,2020 # 80020cc8 <uart_tx_lock>
    uart_tx_r += 1;
    800054ec:	00002497          	auipc	s1,0x2
    800054f0:	4d448493          	addi	s1,s1,1236 # 800079c0 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800054f4:	00002997          	auipc	s3,0x2
    800054f8:	4d498993          	addi	s3,s3,1236 # 800079c8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800054fc:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80005500:	02077713          	andi	a4,a4,32
    80005504:	c715                	beqz	a4,80005530 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005506:	01f7f713          	andi	a4,a5,31
    8000550a:	9752                	add	a4,a4,s4
    8000550c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80005510:	0785                	addi	a5,a5,1
    80005512:	e09c                	sd	a5,0(s1)

    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80005514:	8526                	mv	a0,s1
    80005516:	f37fb0ef          	jal	ra,8000144c <wakeup>

    WriteReg(THR, c);
    8000551a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000551e:	609c                	ld	a5,0(s1)
    80005520:	0009b703          	ld	a4,0(s3)
    80005524:	fcf71ce3          	bne	a4,a5,800054fc <uartstart+0x42>
      ReadReg(ISR);
    80005528:	100007b7          	lui	a5,0x10000
    8000552c:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80005530:	70e2                	ld	ra,56(sp)
    80005532:	7442                	ld	s0,48(sp)
    80005534:	74a2                	ld	s1,40(sp)
    80005536:	7902                	ld	s2,32(sp)
    80005538:	69e2                	ld	s3,24(sp)
    8000553a:	6a42                	ld	s4,16(sp)
    8000553c:	6aa2                	ld	s5,8(sp)
    8000553e:	6121                	addi	sp,sp,64
    80005540:	8082                	ret
      ReadReg(ISR);
    80005542:	100007b7          	lui	a5,0x10000
    80005546:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    8000554a:	8082                	ret

000000008000554c <uartputc>:
{
    8000554c:	7179                	addi	sp,sp,-48
    8000554e:	f406                	sd	ra,40(sp)
    80005550:	f022                	sd	s0,32(sp)
    80005552:	ec26                	sd	s1,24(sp)
    80005554:	e84a                	sd	s2,16(sp)
    80005556:	e44e                	sd	s3,8(sp)
    80005558:	e052                	sd	s4,0(sp)
    8000555a:	1800                	addi	s0,sp,48
    8000555c:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000555e:	0001b517          	auipc	a0,0x1b
    80005562:	76a50513          	addi	a0,a0,1898 # 80020cc8 <uart_tx_lock>
    80005566:	16c000ef          	jal	ra,800056d2 <acquire>
  if(panicked){
    8000556a:	00002797          	auipc	a5,0x2
    8000556e:	4527a783          	lw	a5,1106(a5) # 800079bc <panicked>
    80005572:	efbd                	bnez	a5,800055f0 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005574:	00002717          	auipc	a4,0x2
    80005578:	45473703          	ld	a4,1108(a4) # 800079c8 <uart_tx_w>
    8000557c:	00002797          	auipc	a5,0x2
    80005580:	4447b783          	ld	a5,1092(a5) # 800079c0 <uart_tx_r>
    80005584:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005588:	0001b997          	auipc	s3,0x1b
    8000558c:	74098993          	addi	s3,s3,1856 # 80020cc8 <uart_tx_lock>
    80005590:	00002497          	auipc	s1,0x2
    80005594:	43048493          	addi	s1,s1,1072 # 800079c0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005598:	00002917          	auipc	s2,0x2
    8000559c:	43090913          	addi	s2,s2,1072 # 800079c8 <uart_tx_w>
    800055a0:	00e79d63          	bne	a5,a4,800055ba <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800055a4:	85ce                	mv	a1,s3
    800055a6:	8526                	mv	a0,s1
    800055a8:	e59fb0ef          	jal	ra,80001400 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800055ac:	00093703          	ld	a4,0(s2)
    800055b0:	609c                	ld	a5,0(s1)
    800055b2:	02078793          	addi	a5,a5,32
    800055b6:	fee787e3          	beq	a5,a4,800055a4 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800055ba:	0001b497          	auipc	s1,0x1b
    800055be:	70e48493          	addi	s1,s1,1806 # 80020cc8 <uart_tx_lock>
    800055c2:	01f77793          	andi	a5,a4,31
    800055c6:	97a6                	add	a5,a5,s1
    800055c8:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800055cc:	0705                	addi	a4,a4,1
    800055ce:	00002797          	auipc	a5,0x2
    800055d2:	3ee7bd23          	sd	a4,1018(a5) # 800079c8 <uart_tx_w>
  uartstart();
    800055d6:	ee5ff0ef          	jal	ra,800054ba <uartstart>
  release(&uart_tx_lock);
    800055da:	8526                	mv	a0,s1
    800055dc:	18e000ef          	jal	ra,8000576a <release>
}
    800055e0:	70a2                	ld	ra,40(sp)
    800055e2:	7402                	ld	s0,32(sp)
    800055e4:	64e2                	ld	s1,24(sp)
    800055e6:	6942                	ld	s2,16(sp)
    800055e8:	69a2                	ld	s3,8(sp)
    800055ea:	6a02                	ld	s4,0(sp)
    800055ec:	6145                	addi	sp,sp,48
    800055ee:	8082                	ret
    for(;;)
    800055f0:	a001                	j	800055f0 <uartputc+0xa4>

00000000800055f2 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800055f2:	1141                	addi	sp,sp,-16
    800055f4:	e422                	sd	s0,8(sp)
    800055f6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800055f8:	100007b7          	lui	a5,0x10000
    800055fc:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80005600:	8b85                	andi	a5,a5,1
    80005602:	cb81                	beqz	a5,80005612 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80005604:	100007b7          	lui	a5,0x10000
    80005608:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000560c:	6422                	ld	s0,8(sp)
    8000560e:	0141                	addi	sp,sp,16
    80005610:	8082                	ret
    return -1;
    80005612:	557d                	li	a0,-1
    80005614:	bfe5                	j	8000560c <uartgetc+0x1a>

0000000080005616 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005616:	1101                	addi	sp,sp,-32
    80005618:	ec06                	sd	ra,24(sp)
    8000561a:	e822                	sd	s0,16(sp)
    8000561c:	e426                	sd	s1,8(sp)
    8000561e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80005620:	54fd                	li	s1,-1
    80005622:	a019                	j	80005628 <uartintr+0x12>
      break;
    consoleintr(c);
    80005624:	8a3ff0ef          	jal	ra,80004ec6 <consoleintr>
    int c = uartgetc();
    80005628:	fcbff0ef          	jal	ra,800055f2 <uartgetc>
    if(c == -1)
    8000562c:	fe951ce3          	bne	a0,s1,80005624 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80005630:	0001b497          	auipc	s1,0x1b
    80005634:	69848493          	addi	s1,s1,1688 # 80020cc8 <uart_tx_lock>
    80005638:	8526                	mv	a0,s1
    8000563a:	098000ef          	jal	ra,800056d2 <acquire>
  uartstart();
    8000563e:	e7dff0ef          	jal	ra,800054ba <uartstart>
  release(&uart_tx_lock);
    80005642:	8526                	mv	a0,s1
    80005644:	126000ef          	jal	ra,8000576a <release>
}
    80005648:	60e2                	ld	ra,24(sp)
    8000564a:	6442                	ld	s0,16(sp)
    8000564c:	64a2                	ld	s1,8(sp)
    8000564e:	6105                	addi	sp,sp,32
    80005650:	8082                	ret

0000000080005652 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005652:	1141                	addi	sp,sp,-16
    80005654:	e422                	sd	s0,8(sp)
    80005656:	0800                	addi	s0,sp,16
  lk->name = name;
    80005658:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    8000565a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000565e:	00053823          	sd	zero,16(a0)
}
    80005662:	6422                	ld	s0,8(sp)
    80005664:	0141                	addi	sp,sp,16
    80005666:	8082                	ret

0000000080005668 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005668:	411c                	lw	a5,0(a0)
    8000566a:	e399                	bnez	a5,80005670 <holding+0x8>
    8000566c:	4501                	li	a0,0
  return r;
}
    8000566e:	8082                	ret
{
    80005670:	1101                	addi	sp,sp,-32
    80005672:	ec06                	sd	ra,24(sp)
    80005674:	e822                	sd	s0,16(sp)
    80005676:	e426                	sd	s1,8(sp)
    80005678:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    8000567a:	6904                	ld	s1,16(a0)
    8000567c:	f9cfb0ef          	jal	ra,80000e18 <mycpu>
    80005680:	40a48533          	sub	a0,s1,a0
    80005684:	00153513          	seqz	a0,a0
}
    80005688:	60e2                	ld	ra,24(sp)
    8000568a:	6442                	ld	s0,16(sp)
    8000568c:	64a2                	ld	s1,8(sp)
    8000568e:	6105                	addi	sp,sp,32
    80005690:	8082                	ret

0000000080005692 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005692:	1101                	addi	sp,sp,-32
    80005694:	ec06                	sd	ra,24(sp)
    80005696:	e822                	sd	s0,16(sp)
    80005698:	e426                	sd	s1,8(sp)
    8000569a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000569c:	100024f3          	csrr	s1,sstatus
    800056a0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800056a4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800056a6:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800056aa:	f6efb0ef          	jal	ra,80000e18 <mycpu>
    800056ae:	5d3c                	lw	a5,120(a0)
    800056b0:	cb99                	beqz	a5,800056c6 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800056b2:	f66fb0ef          	jal	ra,80000e18 <mycpu>
    800056b6:	5d3c                	lw	a5,120(a0)
    800056b8:	2785                	addiw	a5,a5,1
    800056ba:	dd3c                	sw	a5,120(a0)
}
    800056bc:	60e2                	ld	ra,24(sp)
    800056be:	6442                	ld	s0,16(sp)
    800056c0:	64a2                	ld	s1,8(sp)
    800056c2:	6105                	addi	sp,sp,32
    800056c4:	8082                	ret
    mycpu()->intena = old;
    800056c6:	f52fb0ef          	jal	ra,80000e18 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800056ca:	8085                	srli	s1,s1,0x1
    800056cc:	8885                	andi	s1,s1,1
    800056ce:	dd64                	sw	s1,124(a0)
    800056d0:	b7cd                	j	800056b2 <push_off+0x20>

00000000800056d2 <acquire>:
{
    800056d2:	1101                	addi	sp,sp,-32
    800056d4:	ec06                	sd	ra,24(sp)
    800056d6:	e822                	sd	s0,16(sp)
    800056d8:	e426                	sd	s1,8(sp)
    800056da:	1000                	addi	s0,sp,32
    800056dc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800056de:	fb5ff0ef          	jal	ra,80005692 <push_off>
  if(holding(lk))
    800056e2:	8526                	mv	a0,s1
    800056e4:	f85ff0ef          	jal	ra,80005668 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800056e8:	4705                	li	a4,1
  if(holding(lk))
    800056ea:	e105                	bnez	a0,8000570a <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800056ec:	87ba                	mv	a5,a4
    800056ee:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800056f2:	2781                	sext.w	a5,a5
    800056f4:	ffe5                	bnez	a5,800056ec <acquire+0x1a>
  __sync_synchronize();
    800056f6:	0ff0000f          	fence
  lk->cpu = mycpu();
    800056fa:	f1efb0ef          	jal	ra,80000e18 <mycpu>
    800056fe:	e888                	sd	a0,16(s1)
}
    80005700:	60e2                	ld	ra,24(sp)
    80005702:	6442                	ld	s0,16(sp)
    80005704:	64a2                	ld	s1,8(sp)
    80005706:	6105                	addi	sp,sp,32
    80005708:	8082                	ret
    panic("acquire");
    8000570a:	00002517          	auipc	a0,0x2
    8000570e:	1f650513          	addi	a0,a0,502 # 80007900 <digits+0x20>
    80005712:	cb1ff0ef          	jal	ra,800053c2 <panic>

0000000080005716 <pop_off>:

void
pop_off(void)
{
    80005716:	1141                	addi	sp,sp,-16
    80005718:	e406                	sd	ra,8(sp)
    8000571a:	e022                	sd	s0,0(sp)
    8000571c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000571e:	efafb0ef          	jal	ra,80000e18 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005722:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005726:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005728:	e78d                	bnez	a5,80005752 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    8000572a:	5d3c                	lw	a5,120(a0)
    8000572c:	02f05963          	blez	a5,8000575e <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005730:	37fd                	addiw	a5,a5,-1
    80005732:	0007871b          	sext.w	a4,a5
    80005736:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005738:	eb09                	bnez	a4,8000574a <pop_off+0x34>
    8000573a:	5d7c                	lw	a5,124(a0)
    8000573c:	c799                	beqz	a5,8000574a <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000573e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005742:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005746:	10079073          	csrw	sstatus,a5
    intr_on();
}
    8000574a:	60a2                	ld	ra,8(sp)
    8000574c:	6402                	ld	s0,0(sp)
    8000574e:	0141                	addi	sp,sp,16
    80005750:	8082                	ret
    panic("pop_off - interruptible");
    80005752:	00002517          	auipc	a0,0x2
    80005756:	1b650513          	addi	a0,a0,438 # 80007908 <digits+0x28>
    8000575a:	c69ff0ef          	jal	ra,800053c2 <panic>
    panic("pop_off");
    8000575e:	00002517          	auipc	a0,0x2
    80005762:	1c250513          	addi	a0,a0,450 # 80007920 <digits+0x40>
    80005766:	c5dff0ef          	jal	ra,800053c2 <panic>

000000008000576a <release>:
{
    8000576a:	1101                	addi	sp,sp,-32
    8000576c:	ec06                	sd	ra,24(sp)
    8000576e:	e822                	sd	s0,16(sp)
    80005770:	e426                	sd	s1,8(sp)
    80005772:	1000                	addi	s0,sp,32
    80005774:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005776:	ef3ff0ef          	jal	ra,80005668 <holding>
    8000577a:	c105                	beqz	a0,8000579a <release+0x30>
  lk->cpu = 0;
    8000577c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005780:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80005784:	0f50000f          	fence	iorw,ow
    80005788:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8000578c:	f8bff0ef          	jal	ra,80005716 <pop_off>
}
    80005790:	60e2                	ld	ra,24(sp)
    80005792:	6442                	ld	s0,16(sp)
    80005794:	64a2                	ld	s1,8(sp)
    80005796:	6105                	addi	sp,sp,32
    80005798:	8082                	ret
    panic("release");
    8000579a:	00002517          	auipc	a0,0x2
    8000579e:	18e50513          	addi	a0,a0,398 # 80007928 <digits+0x48>
    800057a2:	c21ff0ef          	jal	ra,800053c2 <panic>
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
