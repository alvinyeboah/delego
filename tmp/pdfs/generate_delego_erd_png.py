from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


ROOT = Path("/Users/alvinyeboah/Documents/projects/code/delego")
OUT = ROOT / "tmp" / "pdfs" / "assets" / "delego_erd.png"


def get_font(size: int):
    try:
        return ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", size)
    except Exception:
        return ImageFont.load_default()


def box(draw, xy, title, fields, fill="#F7F9FC", outline="#21334D"):
    x, y, w, h = xy
    draw.rounded_rectangle((x, y, x + w, y + h), radius=14, fill=fill, outline=outline, width=2)
    draw.rounded_rectangle((x, y, x + w, y + 36), radius=14, fill="#132033", outline="#132033")
    draw.text((x + 12, y + 9), title, fill="white", font=get_font(18))
    ty = y + 48
    for f in fields:
        draw.text((x + 12, ty), f, fill="#12253B", font=get_font(14))
        ty += 22


def link(draw, a, b, label):
    ax, ay = a
    bx, by = b
    draw.line((ax, ay, bx, by), fill="#4A5F7D", width=3)
    mx = (ax + bx) // 2
    my = (ay + by) // 2
    draw.rounded_rectangle((mx - 54, my - 12, mx + 54, my + 12), radius=8, fill="#E9EEF6", outline="#94A5BE")
    draw.text((mx - 46, my - 8), label, fill="#243A5A", font=get_font(12))


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    img = Image.new("RGB", (2200, 1400), "#FFFFFF")
    draw = ImageDraw.Draw(img)

    draw.text((60, 30), "Delego Entity Relationship Diagram (Conceptual)", fill="#101E31", font=get_font(30))

    box(draw, (80, 120, 360, 230), "Tenant", ["id (PK)", "name", "createdAt"])
    box(draw, (520, 120, 420, 280), "Organization", ["id (PK)", "tenantId (FK)", "name", "createdAt", "updatedAt"])
    box(draw, (1030, 120, 420, 280), "Workspace", ["id (PK)", "organizationId (FK)", "name", "createdAt", "updatedAt"])
    box(draw, (1530, 120, 560, 330), "User", ["id (PK)", "tenantId (FK)", "email", "passwordHash", "firstName", "lastName"])

    box(draw, (1030, 520, 460, 320), "Task", ["id (PK)", "workspaceId (FK)", "createdById (FK)", "assigneeUserId (FK)", "status", "priority", "version"])
    box(draw, (520, 520, 420, 240), "CaptureSession", ["id (PK)", "workspaceId (FK)", "createdById (FK)", "createdAt"])
    box(draw, (80, 520, 360, 210), "CaptureImage", ["id (PK)", "captureSessionId (FK)", "storageKey", "ocrText"])
    box(draw, (80, 780, 360, 210), "CaptureMetadata", ["id (PK)", "captureSessionId (FK)", "latitude/longitude", "capturedAt"])

    box(draw, (1530, 520, 560, 260), "Notification", ["id (PK)", "userId (FK)", "title", "body", "createdAt"])
    box(draw, (1530, 840, 560, 230), "AuditLog", ["id (PK)", "tenantId (FK)", "actorUserId (FK?)", "action", "resource", "createdAt"])

    link(draw, (440, 210), (520, 210), "1..n")
    link(draw, (940, 210), (1030, 210), "1..n")
    link(draw, (1450, 210), (1530, 240), "1..n")
    link(draw, (1230, 400), (1230, 520), "1..n")
    link(draw, (800, 400), (730, 520), "1..n")
    link(draw, (440, 620), (520, 620), "1..n")
    link(draw, (260, 730), (260, 780), "1..1")
    link(draw, (1530, 620), (1490, 620), "1..n")
    link(draw, (1530, 930), (1450, 930), "1..n")

    draw.text(
        (60, 1310),
        "Legend: PK = Primary Key, FK = Foreign Key. Diagram is conceptual and aligned to Delego domain modules.",
        fill="#4A5A6F",
        font=get_font(14),
    )

    img.save(OUT)
    print(str(OUT))


if __name__ == "__main__":
    main()
